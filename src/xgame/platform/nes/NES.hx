package xgame.platform.nes;

import haxe.ds.Vector;
import xgame.platform.nes.Processor6502;
import xgame.platform.nes.OpCode;
import xgame.platform.nes.PPU;


typedef Memory = Vector<Int>;

class NES
{
    var pc:Int = 0x8000;        // program counter
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
    
    var cpuMemory:Memory;
    var ppuMemory:Memory;
    var objMemory:Memory;
    
    var cpu:Processor6502;
    var ppu:PPU;
    
    var ntsc:Bool=true;
    
    var ppuSteps:Float=0;
    var ppuStepSize:Float=3;
    
    function new(cpu:Processor6502)
    {
        this.cpu = cpu;
        
        cpuMemory = new Memory(0x10000);
        ppuMemory = new Memory(0x01000);
        objMemory = new Memory(0x00100);
        
        for (i in 0 ... 0xFFFF)
            cpuMemory[i] = 0;
        
        for (i in 0 ... 0x07FF)
            cpuMemory[i] = 0xFF;
        
        // load first program bank
        for (i in 0x8000...0xBFFF)
        {
            cpuMemory[i] = cpu.getByte(i - 0x8000);
        }
        // load second program bank
        for (i in 0xC000...0xFFFF)
        {
            cpuMemory[i] = cpu.getByte(i - 0xC000);
        }
        
        cpuMemory[0x2002] = 0x80;
        
        if (!ntsc) ppuStepSize = 3.2;
        
        var start = Sys.time();
        runCPU();
        trace(Sys.time() - start);
    }
    
    inline function runCPU()
    {
        var op:Command;
        var ad:Int, v:Int;
        var code:OpCode;
        var mode:AddressingMode;
        
        do
        {
            var byte = cpuMemory[pc];
            op = Processor6502.decodeByte(byte);
            code = Commands.getCode(op);
            
            var value:Null<Int> = null;
            
            trace(pc+" "+Std.string(code)+" "+byte);
            pc++;
            
            switch (code)
            {
                case OpCodes.STA:                   // store accumulator
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    cpuMemory[ad] = accumulator;
                case OpCodes.STX:                   // store x
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    cpuMemory[ad] = x;
                case OpCodes.STY:                   // store y
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    cpuMemory[ad] = y;
                case OpCodes.SAX:                   // store acc & x
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    cpuMemory[ad] = x & accumulator;
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
                case OpCodes.ADC:                   // add with carry
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    value = adc(v);
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
                    setFlags(popStack());
                    pc = popStack() + (popStack() << 8) + 1;
                case OpCodes.AND:                   // logical and
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    v = getValue(mode, ad);
                    accumulator &= v;
                    value = accumulator;
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
                    var to_check = switch(code)
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
                    
                    var check_against = switch(code)
                    {
                        case OpCodes.BCS, OpCodes.BEQ, OpCodes.BMI, OpCodes.BVS:
                            true;
                        default:
                            false;
                    }
                    
                    if (to_check == check_against)
                    {
                        mode = Commands.getMode(op);
                        pc = getAddress(mode);
                    }
                case OpCodes.JMP:                   // jump
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    pc = ad;
                case OpCodes.JMA:                   // jump absolute
                    ad = getAddress(AddressingModes.Indirect);
                    pc = ad;
                case OpCodes.LDA:                   // load accumulator
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    accumulator = getValue(mode, ad);
                    zf = accumulator == 0;
                    nf = accumulator & 0x80 == 0x80;
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
                    value = 0;
                    if (cf) value |= 1;
                    if (zf) value |= 1<<1;
                    if (id) value |= 1<<2;
                    if (dm) value |= 1<<3;
                    value |= 1<<4;
                    value |= 1<<5;
                    if (of) value |= 1<<6;
                    if (nf) value |= 1<<7;
                    pushStack(value);
                case OpCodes.PLP:                   // pull cpu status
                    value = popStack();
                    setFlags(value);
                case OpCodes.PLA:                   // pull accumulator
                    accumulator = value = popStack();
                case OpCodes.INC:                   // increment cpuMemory
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    cpuMemory[ad] = (cpuMemory[ad] + 1) & 0xFF;
                case OpCodes.INX:                   // increment x
                    x += 1;
                    x &= 0xFF;
                    value = x;
                case OpCodes.INY:                   // increment x
                    y += 1;
                    y &= 0xFF;
                    value = y;
                case OpCodes.DEC:                   // decrement cpuMemory
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    cpuMemory[ad] = (cpuMemory[ad] - 1) & 0xFF;
                case OpCodes.EOR:                   // exclusive or
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    value = getValue(mode, ad);
                    accumulator = value ^ accumulator;
                    value = accumulator;
                case OpCodes.ORA:                   // logical or
                    mode = Commands.getMode(op);
                    ad = getAddress(mode);
                    value = getValue(mode, ad);
                    accumulator = accumulator | value;
                    value = accumulator;
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
                    sp = value = x;
                case OpCodes.TXA:                   // transfer x to accumulator
                    accumulator = value = x;
                case OpCodes.NOP: {}                // no operation
                case OpCodes.NOP1:                  // no operation +1
                    pc += 1;
                case OpCodes.NOP2:                  // no operation +2
                    pc += 2;
                case OpCodes.BRK:
                    trace("Break");
                    break;
                default:
                    trace("Instruction " + code + " not yet implemented");
                    break;
            }
            
            if (value != null)
            {
                zf = value == 0;
                nf = value & 0x80 == 0x80;
            }
        }
        while (op != null);
    }
    
    inline function getAddress(mode:AddressingMode)
    {
        var address:Int=0;
        switch(mode)
        {
            case AddressingModes.Accumulator: {}
            case AddressingModes.ZeroPage, AddressingModes.Immediate:
                address = cpuMemory[pc++];
            case AddressingModes.ZeroPageX, AddressingModes.ZeroPageY:
                address = cpuMemory[pc++];
                address += (mode==AddressingModes.ZeroPageX) ? x : y;
                address &= 0xFF;
            case AddressingModes.Relative:
                address = getSigned(cpuMemory[pc]);
                address += ++pc;
            case AddressingModes.Indirect:
                address = cpuMemory[pc] + (cpuMemory[pc+1] << 8);
                pc += 2;
                
                var next_addr = address + 1;
                if (next_addr & 0xFF == 0)
                {
                    next_addr -= 0x0100;
                }
                
                address = cpuMemory[address] + (cpuMemory[next_addr] << 8);
            case AddressingModes.IndirectX:
                address = cpuMemory[pc++];
                address += x;
                address &= 0xFF;
                address = cpuMemory[address] + (cpuMemory[(address+1) & 0xFF] << 8);
            case AddressingModes.IndirectY:
                address = cpuMemory[pc++];
                address = cpuMemory[address] + (cpuMemory[(address+1) & 0xFF] << 8);
                address += y;
                address &= 0xFFFF;
            case AddressingModes.Absolute, 
                 AddressingModes.AbsoluteX, 
                 AddressingModes.AbsoluteY:
                address = cpuMemory[pc] + (cpuMemory[pc+1] << 8);
                pc += 2;
                
                if (mode==AddressingModes.AbsoluteX)
                    address += x;
                else if (mode==AddressingModes.AbsoluteY)
                    address += y;
                
                address &= 0xFFFF;
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
            default: return cpuMemory[address];
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
        
        of = (acc >= 0x80 && accumulator < 0x80);
        
        return accumulator;
    }
    
    inline function pushStack(value:Int)
    {
        storeMem(0x100+sp, value);
        sp--;
    }
    
    inline function popStack():Int
    {
        return cpuMemory[0x100 + sp++];
    }
    
    inline function setFlags(value:Int)
    {
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
            storeMem(ad, value);
        }
    }
    
    inline function storeMem(ad:Int, value:Int)
    {
        cpuMemory[ad] = value;
        runPPU();
    }
    
    inline function runPPU()
    {
        // figure out how many times to run
        ppuSteps += ppuStepSize;
        var steps = Std.int(ppuSteps);
        ppuSteps -= steps;
        
        
    }
    
    static function main()
    {
        var args = Sys.args();
        var fileName = args[0];
        
        var p = new Processor6502(sys.io.File.getBytes(fileName), 0x10);
        var vm = new NES(p);
        
        trace('done');
    }
}