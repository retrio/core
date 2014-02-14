package xgame.processor;

import haxe.io.Bytes;
import haxe.io.Input;


// http://www.obelisk.demon.co.uk/6502/reference.html
enum OpCode
{
    ORA;    // logical OR
    AND;    // logical AND
    EOR;    // exclusive or
    ADC;    // add with carry
    STA;    // store accumulator
    LDA;    // load accumulator
    CMP;    // compare
    SBC;    // subtract with carry
    ASL;    // arithmetic shift left
    ROL;    // rotate left
    LSR;    // logical shift right
    ROR;    // rotate right
    STX;    // store X
    LDX;    // load X
    DEC;    // decrement memory
    INC;    // increment memory
    BIT;    // bit test
    JMP;    // jump
    JMA;    // jump absolute
    STY;    // store Y
    LDY;    // load Y
    CPY;    // compare Y
    CPX;    // compare X
    BCC;    // branch if carry clear
    BCS;    // branch if carry set
    BEQ;    // branch if equal
    BMI;    // branch if minus
    BNE;    // branch if not equal
    BPL;    // branch if positive
    BVC;    // branch if overflow clear
    BVS;    // branch if overflow set
    BRK;    // force interrupt
    CLC;    // clear carry flag
    CLD;    // clear decimal mode
    CLI;    // clear interrupt disable
    CLV;    // clear overflow flag
    DEX;    // decrement X register
    DEY;    // decrement Y register
    INX;    // increment X register
    INY;    // increment Y register
    JSR;    // jump to subroutine
    NOP(ignore:Int); // no operation
    PHA;    // push accumulator
    PHP;    // push processor status
    PLA;    // pull accumulator
    PLP;    // pull processor status
    RTI;    // return from interrupt
    RTS;    // return from subroutine
    SEC;    // set carry flag
    SED;    // set decimal flag
    SEI;    // set interrupt disabled
    TAX;    // transfer accumulator to X
    TAY;    // transfer accumulator to Y
    TSX;    // transfer stack pointer to X
    TSY;    // transfer stack pointer to Y
    TYA;    // transfer Y to accumulator
    TXS;    // transfer X to stack pointer
    TXA;    // transfer X to stack pointer

// unofficial

    LAX;    // load both accumulator and X
    SAX;    // AND, CMP and store
    RLA;
    SLO;
    SRE;
    RRA;
    DCP;
    ISB;
}


// http://www.obelisk.demon.co.uk/6502/addressing.html
enum AddressingMode
{
    Accumulator;
    Immediate;
    ZeroPage;
    ZeroPageX;
    ZeroPageY;
    Relative;
    Absolute;
    AbsoluteX;
    AbsoluteY;
    Indirect;
    IndirectX;
    IndirectY;
}


typedef Command =
{
    var code:OpCode;
    var mode:AddressingMode;
}


class CommandPool
{
    static var pool:Array<Command>;
    
    public static inline function get():Command
    {
        if (pool == null)
        {
            pool = new Array();
        }
        
        if (pool.length > 0)
        {
            return pool.pop();
        }
        else
        {
            return {code:BRK, mode:Absolute};
        }
    }
    
    public static inline function recycle(cmd:Command)
    {
        pool.push(cmd);
    }
}


class Processor6502
{
    var data:Bytes;
    var offset:Int;
    
    public function new(file:Bytes, offset:Int)
    {
        this.data = file;
        this.offset = offset;
        
        parseHeader();
    }
    
    function parseHeader()
    {
        var f6 = data.get(6);
        var f7 = data.get(7);
        
        var mapper = (f6 & 0xF0 >> 4) + f7 & 0xF0;
    }
    
    public inline function getByte(address:Int):Int
    {
        return data.get(address + offset);
    }
    
    public inline function getOP(address:Int):Command
    {
        return decodeByte(getByte(address));
    }
    
    public inline function decodeByte(byte:Int):Command
    {
        var code:OpCode = null;
        var mode:AddressingMode = Absolute;
        
        switch(byte) {
            case 0x00: code=BRK;
            case 0x01: code=ORA; mode=IndirectX;
            case 0x05: code=ORA; mode=ZeroPage;
            case 0x06: code=ASL; mode=ZeroPage;
            case 0x08: code=PHP;
            case 0x09: code=ORA; mode=Immediate;
            case 0x0A: code=ASL; mode=Accumulator;
            case 0x0D: code=ORA;
            case 0x0E: code=ASL;
            case 0x10: code=BPL;
            case 0x11: code=ORA; mode=IndirectY;
            case 0x15: code=ORA; mode=ZeroPageX;
            case 0x16: code=ASL; mode=ZeroPageX;
            case 0x18: code=CLC;
            case 0x19: code=ORA; mode=AbsoluteY;
            case 0x1D: code=ORA; mode=AbsoluteX;
            case 0x1E: code=ASL; mode=AbsoluteX;
            case 0x20: code=JSR;
            case 0x21: code=AND; mode=IndirectX;
            case 0x24: code=BIT; mode=ZeroPage;
            case 0x25: code=AND; mode=ZeroPage;
            case 0x26: code=ROL; mode=ZeroPage;
            case 0x28: code=PLP;
            case 0x29: code=AND; mode=Immediate;
            case 0x2A: code=ROL; mode=Accumulator;
            case 0x2C: code=BIT;
            case 0x2D: code=AND;
            case 0x2E: code=ROL;
            case 0x30: code=BMI;
            case 0x31: code=AND; mode=IndirectY;
            case 0x35: code=AND; mode=ZeroPageX;
            case 0x36: code=ROL; mode=ZeroPageX;
            case 0x38: code=SEC;
            case 0x39: code=AND; mode=AbsoluteY;
            case 0x3D: code=AND; mode=AbsoluteX;
            case 0x3E: code=ROL; mode=AbsoluteX;
            case 0x40: code=RTI;
            case 0x41: code=EOR; mode=IndirectX;
            case 0x45: code=EOR; mode=ZeroPage;
            case 0x46: code=LSR; mode=ZeroPage;
            case 0x48: code=PHA;
            case 0x49: code=EOR; mode=Immediate;
            case 0x4A: code=LSR; mode=Accumulator;
            case 0x4C: code=JMP;
            case 0x4D: code=EOR;
            case 0x4E: code=LSR;
            case 0x50: code=BVC;
            case 0x51: code=EOR; mode=IndirectY;
            case 0x55: code=EOR; mode=ZeroPageX;
            case 0x56: code=LSR; mode=ZeroPageX;
            case 0x58: code=CLI;
            case 0x59: code=EOR; mode=AbsoluteY;
            case 0x5D: code=EOR; mode=AbsoluteX;
            case 0x5E: code=LSR; mode=AbsoluteX;
            case 0x60: code=RTS;
            case 0x61: code=ADC; mode=IndirectX;
            case 0x65: code=ADC; mode=ZeroPage;
            case 0x66: code=ROR; mode=ZeroPage;
            case 0x68: code=PLA;
            case 0x69: code=ADC; mode=Immediate;
            case 0x6A: code=ROR; mode=Accumulator;
            case 0x6C: code=JMP; mode=Indirect;
            case 0x6D: code=ADC;
            case 0x6E: code=ROR;
            case 0x70: code=BVS;
            case 0x71: code=ADC; mode=IndirectY;
            case 0x75: code=ADC; mode=ZeroPageX;
            case 0x76: code=ROR; mode=ZeroPageX;
            case 0x78: code=SEI;
            case 0x79: code=ADC; mode=AbsoluteY;
            case 0x7D: code=ADC; mode=AbsoluteX;
            case 0x7E: code=ROR; mode=AbsoluteX;
            case 0x81: code=STA; mode=IndirectX;
            case 0x84: code=STY; mode=ZeroPage;
            case 0x85: code=STA; mode=ZeroPage;
            case 0x86: code=STX; mode=ZeroPage;
            case 0x88: code=DEY;
            case 0x8A: code=TXA;
            case 0x8C: code=STY;
            case 0x8D: code=STA;
            case 0x8E: code=STX;
            case 0x90: code=BCC;
            case 0x91: code=STA; mode=IndirectY;
            case 0x94: code=STY; mode=ZeroPageX;
            case 0x95: code=STA; mode=ZeroPageX;
            case 0x96: code=STX; mode=ZeroPageY;
            case 0x98: code=TYA;
            case 0x99: code=STA; mode=AbsoluteY;
            case 0x9A: code=TXS;
            case 0x9D: code=STA; mode=AbsoluteX;
            case 0xA0: code=LDY; mode=Immediate;
            case 0xA1: code=LDA; mode=IndirectX;
            case 0xA2: code=LDX; mode=Immediate;
            case 0xA4: code=LDY; mode=ZeroPage;
            case 0xA5: code=LDA; mode=ZeroPage;
            case 0xA6: code=LDX; mode=ZeroPage;
            case 0xA8: code=TAY;
            case 0xA9: code=LDA; mode=Immediate;
            case 0xAA: code=TAX;
            case 0xAC: code=LDY;
            case 0xAD: code=LDA;
            case 0xAE: code=LDX;
            case 0xB0: code=BCS;
            case 0xB1: code=LDA; mode=IndirectY;
            case 0xB4: code=LDY; mode=ZeroPageX;
            case 0xB5: code=LDA; mode=ZeroPageX;
            case 0xB6: code=LDX; mode=ZeroPageY;
            case 0xB8: code=CLV;
            case 0xB9: code=LDA; mode=AbsoluteY;
            case 0xBA: code=TSX;
            case 0xBC: code=LDY; mode=AbsoluteX;
            case 0xBD: code=LDA; mode=AbsoluteX;
            case 0xBE: code=LDX; mode=AbsoluteY;
            case 0xC0: code=CPY; mode=Immediate;
            case 0xC1: code=CMP; mode=IndirectX;
            case 0xC4: code=CPY; mode=ZeroPage;
            case 0xC5: code=CMP; mode=ZeroPage;
            case 0xC6: code=DEC; mode=ZeroPage;
            case 0xC8: code=INY;
            case 0xC9: code=CMP; mode=Immediate;
            case 0xCA: code=DEX;
            case 0xCC: code=CPY;
            case 0xCD: code=CMP;
            case 0xCE: code=DEC;
            case 0xD0: code=BNE;
            case 0xD1: code=CMP; mode=IndirectY;
            case 0xD5: code=CMP; mode=ZeroPageX;
            case 0xD6: code=DEC; mode=ZeroPageX;
            case 0xD8: code=CLD;
            case 0xD9: code=CMP; mode=AbsoluteY;
            case 0xDD: code=CMP; mode=AbsoluteX;
            case 0xDE: code=DEC; mode=AbsoluteX;
            case 0xE0: code=CPX; mode=Immediate;
            case 0xE1: code=SBC; mode=IndirectX;
            case 0xE4: code=CPX; mode=ZeroPage;
            case 0xE5: code=SBC; mode=ZeroPage;
            case 0xE6: code=INC; mode=ZeroPage;
            case 0xE8: code=INX;
            case 0xE9: code=SBC; mode=Immediate;
            case 0xEC: code=CPX;
            case 0xED: code=SBC;
            case 0xEE: code=INC;
            case 0xF0: code=BEQ;
            case 0xF1: code=SBC; mode=IndirectY;
            case 0xF5: code=SBC; mode=ZeroPageX;
            case 0xF6: code=INC; mode=ZeroPageX;
            case 0xF8: code=SED;
            case 0xF9: code=SBC; mode=AbsoluteY;
            case 0xFD: code=SBC; mode=AbsoluteX;
            case 0xFE: code=INC; mode=AbsoluteX;
            
            case 0xEA,0x1A,0x3A,0x5A,0x7A,0xDA,0xFA: code=NOP(0);
            case 0x04,0x14,0x24,0x34,0x44,0x54,0x64,0x74,0xD4,0xF4,0x80: code=NOP(1);
            case 0x0C,0x1C,0x3C,0x5C,0x7C,0xDC,0xFC: code=NOP(2);
            
            default: code=NOP(0);
        }
        
        var cmd:Command = CommandPool.get();
        cmd.code = code;
        cmd.mode = mode;
        
        return cmd;
    }
}
