package xgame.platform.nes;

import haxe.io.Bytes;
import haxe.io.Input;
import haxe.ds.Vector;
import flash.utils.ByteArray;
import xgame.platform.nes.OpCode;


class CPU
{
    static inline var ppuStepSize:Float=3;
    
    public var memory:Vector<Int>;
    public var ticks:Float=0;
    
    var nes:NES;
    var mapper:Mapper;
    var rom:ROM;
    var ppu:PPU;
    
    public var pc:Int = 0x8000; // program counter
    var sp:Int = 0xFD;          // stack pointer
    var accumulator:Int = 0;    // accumulator
    var x:Int = 0;              // x register
    var y:Int = 0;              // y register
    
    var cf:Bool = false;        // carry
    var zf:Bool = false;        // zero
    var id:Bool = false;        // interrupt disable
    var dm:Bool = false;        // decimal mode
    var bc:Bool = false;        // break command
    var of:Bool = false;        // overflow
    var nf:Bool = false;        // negative
    
    var irqRequested:Bool = false;
    
    public function new(nes:NES)
    {
        this.nes = nes;
        
        memory = new Vector(0x10000);
        
        for (i in 0 ... 0xFFFF)
        {
            memory[i] = 0;
        }
    }
    
    public function init()
    {
        rom = nes.rom;
        ppu = nes.ppu;
        mapper = rom.mapper;
        
        for (i in 0 ... 0x07FF)
        {
            memory[i] = 0xFF;
        }
        
        memory[0x0008] = 0xF7;
        memory[0x0009] = 0xEF;
        memory[0x000A] = 0xDF;
        memory[0x000F] = 0xBF;
        
        for (i in 0x4000 ...  0x400F)
        {
            memory[i] = 0;
        }
        
        memory[0x4015] = 0;
        memory[0x4017] = 0;
        
        pc = (read(0xFFFD) << 8) + read(0xFFFC);
    }
    
    public function reset()
    {
        pc = (read(0xFFFD) << 8) + read(0xFFFC);
        write(0x4015, 0);
        write(0x4017, read(0x4017));
        id = true;
    }
    
    public inline function run(maxCycles:Null<Float>=null, quitOnBreak=false)
    {
        var op:Command;
        var ad:Int, v:Int;
        var code:OpCode;
        var mode:AddressingMode;
        var value:Null<Int>;
        var byte:Int;
        
        do
        {
            byte = read(pc);
            op = Commands.decodeByte(byte);
            code = Commands.getCode(op);
            
            value = null;
            
#if (debug && !flash)
            Sys.print(StringTools.hex(pc,4)+" "+
                      StringTools.rpad(OpCodes.opCodeNames[code], " ", 6)+" "+
                      StringTools.hex(byte,2));
#end
            pc++;
            
            // get base number of CPU cycles for this operation
            // (in some cirtumstances, this may increase during execution)
            var ticks = Commands.getTicks(op);
            
            // execute instruction
            switch (code)
            {
                case OpCodes.ORA:                   // logical or
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    value = getValue(mode, ad);
                    accumulator |= value;
                    value = accumulator;
                case OpCodes.AND:                   // logical and
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    accumulator &= v;
                    value = accumulator;
                case OpCodes.EOR:                   // exclusive or
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    value = getValue(mode, ad);
                    accumulator = value ^ accumulator;
                    value = accumulator;
                case OpCodes.ADC:                   // add with carry
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    value = adc(v);
                case OpCodes.STA:                   // store accumulator
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    write(ad, accumulator);
                case OpCodes.LDA:                   // load accumulator
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    accumulator = getValue(mode, ad);
                    zf = accumulator == 0;
                    nf = accumulator & 0x80 == 0x80;
                case OpCodes.STX:                   // store x
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    write(ad, x);
                case OpCodes.STY:                   // store y
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    write(ad, y);
                case OpCodes.SEI, OpCodes.CLI:      // set/clear interrupt disable
                    id = code == OpCodes.SEI;
                case OpCodes.SED, OpCodes.CLD:      // set/clear decimal mode
                    dm = code == OpCodes.SED;
                case OpCodes.SEC, OpCodes.CLC:      // set/clear carry
                    cf = code == OpCodes.SEC;
                case OpCodes.CLV:                   // clear overflow
                    of = false;
                case OpCodes.BIT:                   // bit test
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    zf = accumulator & v == 0;
                    of = v & 0x40 != 0;
                    nf = v & 0x80 != 0;
                case OpCodes.CMP, 
                     OpCodes.CPX, 
                     OpCodes.CPY:                   // compare [x/y]
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    
                    var compare_to = switch (code)
                    {
                        case OpCodes.CMP: accumulator;
                        case OpCodes.CPX: x;
                        default: y;
                    }
                    
                    var tmp = compare_to - v;
                    if (tmp < 0)
                        tmp += 0xFF + 1;
                    
                    cf = compare_to >= v;
                    zf = compare_to == v;
                    nf = tmp & 0x80 == 0x80;
                case OpCodes.SBC:                   // subtract with carry
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    value = sbc(v);
                case OpCodes.JSR:                   // jump to subroutine
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    pushStack(pc - 1 >> 8);
                    pushStack(pc - 1 & 0xFF);
                    pc = ad;
                case OpCodes.RTS:                   // return from subroutine
                    pc = popStack() + (popStack() << 8) + 1;
                case OpCodes.RTI:                   // return from interrupt
                    popStatus();
                    pc = popStack() + (popStack() << 8);
                case OpCodes.ASL:                   // arithmetic shift left
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    cf = v & 0x80 != 0;
                    value = (v << 1) & 0xFF;
                    storeValue(mode, ad, value);
                case OpCodes.LSR:                   // logical shift right
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    cf = v & 1 != 0;
                    value = v >> 1;
                    storeValue(mode, ad, value);
                case OpCodes.ROL:                   // rotate left
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    var new_cf = v & 0x80 != 0;
                    value = (v << 1) & 0xFF;
                    value += cf ? 1 : 0;
                    cf = new_cf;
                    storeValue(mode, ad, value);
                case OpCodes.ROR:                   // rotate right
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    var new_cf = v & 1 != 0;
                    value = (v >> 1) & 0xFF;
                    value += cf ? 0x80 : 0;
                    cf = new_cf;
                    storeValue(mode, ad, value);
                case OpCodes.BCC,
                     OpCodes.BCS,
                     OpCodes.BEQ,
                     OpCodes.BMI,
                     OpCodes.BNE,
                     OpCodes.BPL,
                     OpCodes.BVC,
                     OpCodes.BVS:                   // branch
                    var toCheck = switch(code)
                    {
                        case OpCodes.BCC, OpCodes.BCS:
                            cf;
                        case OpCodes.BEQ, OpCodes.BNE:
                            zf;
                        case OpCodes.BMI, OpCodes.BPL:
                            nf;
                        case OpCodes.BVC, OpCodes.BVS:
                            of;
                        default: false;
                    }
                    
                    var checkAgainst = switch(code)
                    {
                        case OpCodes.BCS, OpCodes.BEQ, OpCodes.BMI, OpCodes.BVS:
                            true;
                        default:
                            false;
                    }
                    
                    mode = Commands.getMode(op);
                    var jumpTo = getAddress(mode);
                    if (toCheck == checkAgainst)
                    {
                        ticks += 1;
                        pc = jumpTo;
                    }
                case OpCodes.JMP:                   // jump
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    pc = ad;
                case OpCodes.LDX:                   // load x
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    x = getValue(mode, ad);
                    zf = x == 0;
                    nf = x & 0x80 == 0x80;
                case OpCodes.LDY:                   // load y
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    y = getValue(mode, ad);
                    zf = y == 0;
                    nf = y & 0x80 == 0x80;
                case OpCodes.PHA:                   // push accumulator
                    pushStack(accumulator);
                case OpCodes.PHP:                   // push cpu status
                    pushStatus();
                case OpCodes.PLP:                   // pull cpu status
                    popStatus();
                case OpCodes.PLA:                   // pull accumulator
                    accumulator = value = popStack();
                case OpCodes.INC:                   // increment memory
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    value = (read(ad) + 1) & 0xFF;
                    write(ad, value);
                case OpCodes.INX:                   // increment x
                    x += 1;
                    x &= 0xFF;
                    value = x;
                case OpCodes.INY:                   // increment x
                    y += 1;
                    y &= 0xFF;
                    value = y;
                case OpCodes.DEC:                   // decrement memory
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    value = (read(ad) - 1) & 0xFF;
                    write(ad, value);
                case OpCodes.DEX:                   // decrement x
                    x = (x-1) & 0xFF;
                    value = x;
                case OpCodes.DEY:                   // decrement y
                    y = (y-1) & 0xFF;
                    value = y;
                case OpCodes.TAX:                   // transfer accumulator to x
                    x = value = accumulator;
                case OpCodes.TAY:                   // transfer accumulator to y
                    y = value = accumulator;
                case OpCodes.TSX:                   // transfer stack pointer to x
                    x = value = sp;
                case OpCodes.TSY:                   // transfer stack pointer to y
                    y = value = sp;
                case OpCodes.TYA:                   // transfer y to accumulator
                    accumulator = value = y;
                case OpCodes.TXS:                   // transfer x to stack pointer
                    sp = x;
                case OpCodes.TXA:                   // transfer x to accumulator
                    accumulator = value = x;
                case OpCodes.NOP: {}                // no operation
                case OpCodes.IGN1:
                    pc += 1;
                case OpCodes.IGN2:
                    pc += 2;
                case OpCodes.LAX:                   // LDX + TXA
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    x = getValue(mode, ad);
                    accumulator = value = x;
                case OpCodes.SAX:                   // store (x & accumulator)
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    write(ad, x & accumulator);
                case OpCodes.RLA:
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    value = (v << 1) & 0xFF;
                    value += cf ? 1 : 0;
                    
                    write(ad, value);
                    cf = v & 0x80 != 0;
                    
                    accumulator &= value;
                    value = accumulator;
                case OpCodes.RRA:
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    value = (v >> 1) & 0xFF;
                    value += cf ? 0x80 : 0;
                    
                    write(ad, value);
                    cf = v & 1 != 0;
                    
                    value = accumulator = adc(value);
                case OpCodes.SLO:
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    cf = v & 0x80 != 0;
                    v = (v << 1) & 0xFF;
                    write(ad, v);
                    accumulator |= v;
                    value = accumulator;
                case OpCodes.SRE:
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    cf = v & 1 != 0;
                    value = v >> 1;
                    write(ad, value);
                    accumulator = value ^ accumulator;
                    value = accumulator;
                case OpCodes.DCP:
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad) - 1;
                    v &= 0xFF;
                    write(ad, v);
                    
                    var tmp = accumulator - v;
                    if (tmp < 0) tmp += 0xFF + 1;
                    
                    cf = accumulator >= v;
                    zf = accumulator == v;
                    nf = tmp & 0x80 == 0x80;
                case OpCodes.ISC:
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    v = (v+1) & 0xFF;
                    write(ad, v);
                    value = sbc(v);
                case OpCodes.BRK:
                    if (quitOnBreak) {
                        break;
                    }
                    pushStack(pc);
                    bc = true;
                    pc = read(0xFFFE) + (read(0xFFFF) << 8);
                default:
                    trace("Instruction $" + StringTools.hex(byte,2) + " not yet implemented");
                    break;
            }
            
            if (value != null)
            {
                zf = value == 0;
                nf = value & 0x80 == 0x80;
            }
            
            this.ticks += ticks;
            nes.ppu.run(ticks);
            
#if (debug && !flash)
            Sys.print(dump_machine_state() + "\n");
#end
        }
        while (maxCycles == null || ticks < maxCycles);
        
        if (maxCycles != null) ticks -= maxCycles;
    }
    
    inline function getAddress(mode:AddressingMode):Int
    {
        var address:Int;
        switch(mode)
        {
            case AddressingModes.ZeroPage, AddressingModes.Immediate:
            {
                address = read(pc++);
            }
            case AddressingModes.ZeroPageX, AddressingModes.ZeroPageY:
            {
                address = read(pc++);
                address += (mode==AddressingModes.ZeroPageX) ? x : y;
                address &= 0xFF;
            }
            case AddressingModes.Relative:
            {
                address = getSigned(read(pc++));
                address += pc;
                // new page
                if (address>>8 != pc>>8) ticks += 1;
            }
            case AddressingModes.Indirect:
            {
                address = read(pc++) + (read(pc++) << 8);
                
                var next_addr = address + 1;
                if (next_addr & 0xFF == 0)
                {
                    next_addr -= 0x0100;
                }
                
                address = read(address) + (read(next_addr) << 8);
            }
            case AddressingModes.IndirectX:
            {
                address = read(pc++);
                address += x;
                address &= 0xFF;
                address = read(address) + (read((address+1) & 0xFF) << 8);
            }
            case AddressingModes.IndirectY:
            {
                address = read(pc++);
                address = read(address) + (read((address+1) & 0xFF) << 8);
                
                // new page
                if (ticks == 5 && address>>8 != (address+y)>>8) ticks += 1;
                
                address += y;
                address &= 0xFFFF;
            }
            case AddressingModes.Absolute, 
                 AddressingModes.AbsoluteX, 
                 AddressingModes.AbsoluteY:
            {
                address = read(pc++) + (read(pc++) << 8);
                
                if (mode==AddressingModes.AbsoluteX)
                {
                    // new page
                    if (ticks==4 && (address>>8 != (address+x)>>8)) ticks += 1;
                    
                    address += x;
                }
                else if (mode==AddressingModes.AbsoluteY)
                {
                    // new page
                    if (ticks==4 && (address>>8 != (address+y)>>8)) ticks += 1;
                    
                    address += y;
                }
                
                address &= 0xFFFF;
            }
            default: {
                address = 0;
            }
        }
        
        return address;
    }
    
    inline function getSigned(byte:Int)
    {
        byte &= 0xFF;
        
        return (byte & 0x80 != 0) ? -((~(byte - 1)) & 0xFF) : byte;
    }
    
    inline function getValue(mode:AddressingMode, address:Int)
    {
        switch(mode)
        {
            case AddressingModes.Immediate: return address & 0xFF;
            case AddressingModes.Accumulator: return accumulator;
            default: return read(address);
        }
    }
    
    inline function adc(value:Int)
    {
        var acc = accumulator;
        
        accumulator += value + (cf ? 1 : 0);
        if (accumulator > 0xFF)
        {
            cf = true;
            accumulator &= 0xFF;
        }
        else
        {
            cf = false;
        }
        
        of = (acc < 0x80 && accumulator >= 0x80 && (value & 0x80 != 0x80));
        
        return accumulator;
    }
    
    inline function sbc(value:Int)
    {
        var acc = accumulator;
        
        accumulator -= value + (cf ? 0 : 1);
        cf = !(accumulator > 0xFF || accumulator < 0);
        
        if (accumulator < 0) accumulator += 0xFF + 1;
        
        of = (acc > 0x7F && accumulator < 0x7F);
        
        return accumulator;
    }
    
    inline function pushStack(value:Int)
    {
        write(0x100+sp--, value);
    }
    
    inline function popStack():Int
    {
        return read(0x100 + ++sp);
    }
    
    inline function pushStatus()
    {
        var stackValue = 0;
        if (cf) stackValue |= 1;
        if (zf) stackValue |= 1<<1;
        if (id) stackValue |= 1<<2;
        if (dm) stackValue |= 1<<3;
        stackValue |= 1<<4;
        stackValue |= 1<<5;
        if (of) stackValue |= 1<<6;
        if (nf) stackValue |= 1<<7;
        pushStack(stackValue);
    }
    
    inline function popStatus()
    {
        var value = popStack();
        cf = value & 0x1 != 0;
        zf = value & 0x2 != 0;
        id = value & 0x4 != 0;
        dm = value & 0x8 != 0;
        bc = value & 0x10 != 0;
        of = value & 0x40 != 0;
        nf = value & 0x80 != 0;
    }
    
    inline function storeValue(mode:AddressingMode, ad:Int, value:Int)
    {
        if (mode == AddressingModes.Accumulator)
        {
            accumulator = value;
        }
        else
        {
            write(ad, value);
        }
    }
    
    public inline function read(addr:Int):Int
    {
        return mapper.read(addr);
    }
    
    public inline function write(addr:Int, data:Int)
    {
        mapper.write(addr, data);
    }
    
    inline function dump_machine_state()
    {
        var out = " -- ";
        out += "AC:"+StringTools.hex(accumulator, 2)+" ";
        out += "RX:"+StringTools.hex(x, 2)+" ";
        out += "RY:"+StringTools.hex(y, 2)+" ";
        out += "SP:"+StringTools.hex(sp, 2)+" ";
        out += (if (cf) "CF" else "xx")+" ";
        out += (if (zf) "ZF" else "xx")+" ";
        out += (if (id) "ID" else "xx")+" ";
        out += (if (dm) "DM" else "xx")+" ";
        out += (if (bc) "BC" else "xx")+" ";
        out += (if (of) "OF" else "xx")+" ";
        out += (if (nf) "NF" else "xx");
        
        return out;
    }
}
