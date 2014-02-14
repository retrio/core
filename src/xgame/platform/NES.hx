package xgame.platform;

import xgame.processor.Processor6502;


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
    
    var memory:Array<Int>;      // addressed memory
    
    var processor:Processor6502;
    
    function new(processor:Processor6502)
    {
        this.processor = processor;
        memory = new Array();
        for (i in 0 ... 0xFFFF)
            memory[i] = 0;
        
        for (i in 0 ... 0x07FF)
            memory[i] = 0xFF;
        
        // load rom into memory
        for (i in 0x8000...0xBFFF)
        {
            memory[i] = processor.getByte(i - 0x8000);
        }
        for (i in 0xC000...0xFFFF)
        {
            memory[i] = processor.getByte(i - 0xC000);
        }
        
        memory[0x2002] = 0x80;
        
        run();
    }
    
    function run()
    {
        var op:Command;
        var ad:Int, v:Int;
        
        do
        {
            var byte = memory[pc];
            op = processor.decodeByte(byte);
            
            var value:Null<Int> = null;
            
            trace(pc+" "+Std.string(op.code)+" "+byte);
            pc++;
            
            switch (op.code)
            {
                case STA:                   // store accumulator
                    ad = getAddress(op.mode);
                    memory[ad] = accumulator;
                case STX:                   // store x
                    ad = getAddress(op.mode);
                    memory[ad] = x;
                case STY:                   // store y
                    ad = getAddress(op.mode);
                    memory[ad] = y;
                case SAX:                   // store acc & x
                    ad = getAddress(op.mode);
                    memory[ad] = x & accumulator;
                case SEI, CLI:              // set/clear interrupt disable
                    id = op.code == SEI;
                case SED, CLD:              // set/clear decimal mode
                    dm = op.code == SED;
                case SEC, CLC:              // set/clear carry
                    cf = op.code == SEC;
                case CLV:                   // clear overflow
                    of = false;
                case BIT:                   // bit test
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    zf = accumulator & v == 0;
                    of = v & 0x40 != 0;
                    nf = v & 0x80 != 0;
                case CMP, CPX, CPY:         // compare [x/y]
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    
                    var compare_to = switch (op.code)
                    {
                        case CMP: accumulator;
                        case CPX: x;
                        default: y;
                    }
                    
                    var tmp = compare_to - v;
                    if (tmp < 0)
                        tmp += 0xFF + 1;
                    
                    cf = compare_to >= v;
                    zf = compare_to == v;
                    nf = tmp & 0x80 == 0x80;
                case ADC:                   // add with carry
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    value = adc(v);
                case SBC:                   // subtract with carry
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    value = sbc(v);
                case JSR:                   // jump to subroutine
                    ad = getAddress(op.mode);
                    pushStack(pc - 1 >> 8);
                    pushStack(pc - 1 & 0xFF);
                    pc = ad;
                case RTS:                   // return from subroutine
                    pc = popStack() + (popStack() << 8) + 1;
                case RTI:                   // return from interrupt
                    setFlags(popStack());
                    pc = popStack() + (popStack() << 8) + 1;
                case AND:                   // logical and
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    accumulator &= v;
                    value = accumulator;
                case ASL:                   // arithmetic shift left
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    cf = v & 0x80 != 0;
                    value = (v << 1) & 0xFF;
                    storeValue(op.mode, ad, value);
                case LSR:                   // logical shift right
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    cf = v & 1 != 0;
                    value = v >> 1;
                    storeValue(op.mode, ad, value);
                case ROL:                   // rotate left
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    var new_cf = v & 0x80 != 0;
                    value = (v << 1) & 0xFF;
                    value += cf ? 1 : 0;
                    cf = new_cf;
                    storeValue(op.mode, ad, value);
                case ROR:                   // rotate right
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    var new_cf = v & 1 != 0;
                    value = (v >> 1) & 0xFF;
                    value += cf ? 0x80 : 0;
                    cf = new_cf;
                    storeValue(op.mode, ad, value);
                case BCC,BCS,BEQ,BMI,BNE,BPL,BVC,BVS:    // branch
                    var to_check = switch(op.code)
                    {
                        case BCC, BCS:
                            cf;
                        case BEQ, BNE:
                            zf;
                        case BMI, BPL:
                            nf;
                        case BVC, BVS:
                            of;
                        default: false;
                    }
                    
                    var check_against = switch(op.code)
                    {
                        case BCS, BEQ, BMI, BVS:
                            true;
                        default:
                            false;
                    }
                    
                    if (to_check == check_against)
                    {
                        pc = getAddress(op.mode);
                    }
                case JMP:                   // jump
                    ad = getAddress(op.mode);
                    pc = ad;
                case JMA:                   // jump absolute
                    ad = getAddress(Indirect);
                    pc = ad;
                case LDA:                   // load accumulator
                    ad = getAddress(op.mode);
                    accumulator = getValue(op.mode, ad);
                    zf = accumulator == 0;
                    nf = accumulator & 0x80 == 0x80;
                case LDX:                   // load x
                    ad = getAddress(op.mode);
                    x = getValue(op.mode, ad);
                    zf = x == 0;
                    nf = x & 0x80 == 0x80;
                case LDY:                   // load y
                    ad = getAddress(op.mode);
                    y = getValue(op.mode, ad);
                    zf = y == 0;
                    nf = y & 0x80 == 0x80;
                case PHA:                   // push accumulator
                    pushStack(accumulator);
                case PHP:                   // push processor status
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
                case PLP:                   // pull processor status
                    value = popStack();
                    setFlags(value);
                case PLA:                   // pull accumulator
                    accumulator = value = popStack();
                case INC:                   // increment memory
                    ad = getAddress(op.mode);
                    memory[ad] = (memory[ad] + 1) & 0xFF;
                case INX:                   // increment x
                    x += 1;
                    x &= 0xFF;
                    value = x;
                case INY:                   // increment x
                    y += 1;
                    y &= 0xFF;
                    value = y;
                case DEC:                   // decrement memory
                    ad = getAddress(op.mode);
                    memory[ad] = (memory[ad] - 1) & 0xFF;
                case EOR:                   // exclusive or
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    accumulator = value ^ accumulator;
                    value = accumulator;
                case ORA:                   // logical or
                    ad = getAddress(op.mode);
                    v = getValue(op.mode, ad);
                    accumulator |= value;
                    value = accumulator;
                case DEX:                   // decrement x
                    x = (x-1) & 0xFF;
                    value = x;
                case DEY:                   // decrement y
                    y = (y-1) & 0xFF;
                    value = y;
                case TAX:                   // transfer accumulator to x
                    x = value = accumulator;
                case TAY:                   // transfer accumulator to y
                    y = value = accumulator;
                case TSX:                   // transfer stack pointer to x
                    x = value = sp;
                case TSY:                   // transfer stack pointer to y
                    y = value = sp;
                case TYA:                   // transfer y to accumulator
                    accumulator = value = y;
                case TXS:                   // transfer x to stack pointer
                    sp = value = x;
                case TXA:                   // transfer x to accumulator
                    accumulator = value = x;
                case NOP(i):                // no operation
                    pc += i;
                case BRK:
                    trace("Break");
                    break;
                default:
                    trace("Instruction " + op.code + " not yet implemented");
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
            case Accumulator: {}
            case ZeroPage, Immediate:
                address = memory[pc++];
            case ZeroPageX, ZeroPageY:
                address = memory[pc++];
                address += (mode==ZeroPageX) ? x : y;
                address &= 0xFF;
            case Relative:
                address = getSigned(memory[pc]);
                address += ++pc;
            case Indirect:
                address = memory[pc] + (memory[pc+1] << 8);
                pc += 2;
                
                var next_addr = address + 1;
                if (next_addr & 0xFF == 0)
                {
                    next_addr -= 0x0100;
                }
                
                address = memory[address] + (memory[next_addr] << 8);
            case IndirectX:
                address = memory[pc++];
                address += x;
                address &= 0xFF;
                address = memory[address] + (memory[(address+1) & 0xFF] << 8);
            case IndirectY:
                address = memory[pc++];
                address = memory[address] + (memory[(address+1) & 0xFF] << 8);
                address += y;
                address &= 0xFFFF;
            case Absolute, AbsoluteX, AbsoluteY:
                address = memory[pc] + (memory[pc+1] << 8);
                pc += 2;
                
                if (mode==AbsoluteX)
                    address += x;
                else if (mode==AbsoluteY)
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
            case Immediate: return address & 0xFF;
            case Accumulator: return accumulator;
            default: return memory[address];
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
        memory[0x100 + sp] = value;
        sp--;
    }
    
    inline function popStack():Int
    {
        return memory[0x100 + sp++];
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
        if (mode == Accumulator)
        {
            accumulator = value;
        }
        else
        {
            memory[ad] = value;
        }
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
