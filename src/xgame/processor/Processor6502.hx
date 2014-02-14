package xgame.processor;

import haxe.io.Bytes;
import haxe.io.Input;


// http://www.obelisk.demon.co.uk/6502/reference.html
enum OPCode
{
    ORA;    // logical OR
    AND;    // logical AND
    EOR;    // exclusive or
    ADC;    // add with carry (?)
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
    PHP;    // push Processor Status
    PLA;    // pull accumulator
    PLP;    // pull Processor Status
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
    var opCode:OPCode;
    var addressingMode:AddressingMode;
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
            return {opCode:BRK, addressingMode:Absolute};
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
    
    static function main() {}
    
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
        var opCode:OPCode = null;
        var addressingMode:AddressingMode = Absolute;
        
        switch(byte) {
            case 0x00: opCode=BRK;
            case 0x01: opCode=ORA; addressingMode=IndirectX;
            case 0x05: opCode=ORA; addressingMode=ZeroPage;
            case 0x06: opCode=ASL; addressingMode=ZeroPage;
            case 0x08: opCode=PHP;
            case 0x09: opCode=ORA; addressingMode=Immediate;
            case 0x0A: opCode=ASL; addressingMode=Accumulator;
            case 0x0D: opCode=ORA;
            case 0x0E: opCode=ASL;
            case 0x10: opCode=BPL;
            case 0x11: opCode=ORA; addressingMode=IndirectY;
            case 0x15: opCode=ORA; addressingMode=ZeroPageX;
            case 0x16: opCode=ASL; addressingMode=ZeroPageX;
            case 0x18: opCode=CLC;
            case 0x19: opCode=ORA; addressingMode=AbsoluteY;
            case 0x1D: opCode=ORA; addressingMode=AbsoluteX;
            case 0x1E: opCode=ASL; addressingMode=AbsoluteX;
            case 0x20: opCode=JSR;
            case 0x21: opCode=AND; addressingMode=IndirectX;
            case 0x24: opCode=BIT; addressingMode=ZeroPage;
            case 0x25: opCode=AND; addressingMode=ZeroPage;
            case 0x26: opCode=ROL; addressingMode=ZeroPage;
            case 0x28: opCode=PLP;
            case 0x29: opCode=AND; addressingMode=Immediate;
            case 0x2A: opCode=ROL; addressingMode=Accumulator;
            case 0x2C: opCode=BIT;
            case 0x2D: opCode=AND;
            case 0x2E: opCode=ROL;
            case 0x30: opCode=BMI;
            case 0x31: opCode=AND; addressingMode=IndirectY;
            case 0x35: opCode=AND; addressingMode=ZeroPageX;
            case 0x36: opCode=ROL; addressingMode=ZeroPageX;
            case 0x38: opCode=SEC;
            case 0x39: opCode=AND; addressingMode=AbsoluteY;
            case 0x3D: opCode=AND; addressingMode=AbsoluteX;
            case 0x3E: opCode=ROL; addressingMode=AbsoluteX;
            case 0x40: opCode=RTI;
            case 0x41: opCode=EOR; addressingMode=IndirectX;
            case 0x45: opCode=EOR; addressingMode=ZeroPage;
            case 0x46: opCode=LSR; addressingMode=ZeroPage;
            case 0x48: opCode=PHA;
            case 0x49: opCode=EOR; addressingMode=Immediate;
            case 0x4A: opCode=LSR; addressingMode=Accumulator;
            case 0x4C: opCode=JMP;
            case 0x4D: opCode=EOR;
            case 0x4E: opCode=LSR;
            case 0x50: opCode=BVC;
            case 0x51: opCode=EOR; addressingMode=IndirectY;
            case 0x55: opCode=EOR; addressingMode=ZeroPageX;
            case 0x56: opCode=LSR; addressingMode=ZeroPageX;
            case 0x58: opCode=CLI;
            case 0x59: opCode=EOR; addressingMode=AbsoluteY;
            case 0x5D: opCode=EOR; addressingMode=AbsoluteX;
            case 0x5E: opCode=LSR; addressingMode=AbsoluteX;
            case 0x60: opCode=RTS;
            case 0x61: opCode=ADC; addressingMode=IndirectX;
            case 0x65: opCode=ADC; addressingMode=ZeroPage;
            case 0x66: opCode=ROR; addressingMode=ZeroPage;
            case 0x68: opCode=PLA;
            case 0x69: opCode=ADC; addressingMode=Immediate;
            case 0x6A: opCode=ROR; addressingMode=Accumulator;
            case 0x6C: opCode=JMP; addressingMode=Indirect;
            case 0x6D: opCode=ADC;
            case 0x6E: opCode=ROR;
            case 0x70: opCode=BVS;
            case 0x71: opCode=ADC; addressingMode=IndirectY;
            case 0x75: opCode=ADC; addressingMode=ZeroPageX;
            case 0x76: opCode=ROR; addressingMode=ZeroPageX;
            case 0x78: opCode=SEI;
            case 0x79: opCode=ADC; addressingMode=AbsoluteY;
            case 0x7D: opCode=ADC; addressingMode=AbsoluteX;
            case 0x7E: opCode=ROR; addressingMode=AbsoluteX;
            case 0x81: opCode=STA; addressingMode=IndirectX;
            case 0x84: opCode=STY; addressingMode=ZeroPage;
            case 0x85: opCode=STA; addressingMode=ZeroPage;
            case 0x86: opCode=STX; addressingMode=ZeroPage;
            case 0x88: opCode=DEY;
            case 0x8A: opCode=TXA;
            case 0x8C: opCode=STY;
            case 0x8D: opCode=STA;
            case 0x8E: opCode=STX;
            case 0x90: opCode=BCC;
            case 0x91: opCode=STA; addressingMode=IndirectY;
            case 0x94: opCode=STY; addressingMode=ZeroPageX;
            case 0x95: opCode=STA; addressingMode=ZeroPageX;
            case 0x96: opCode=STX; addressingMode=ZeroPageY;
            case 0x98: opCode=TYA;
            case 0x99: opCode=STA; addressingMode=AbsoluteY;
            case 0x9A: opCode=TXS;
            case 0x9D: opCode=STA; addressingMode=AbsoluteX;
            case 0xA0: opCode=LDY; addressingMode=Immediate;
            case 0xA1: opCode=LDA; addressingMode=IndirectX;
            case 0xA2: opCode=LDX; addressingMode=Immediate;
            case 0xA4: opCode=LDY; addressingMode=ZeroPage;
            case 0xA5: opCode=LDA; addressingMode=ZeroPage;
            case 0xA6: opCode=LDX; addressingMode=ZeroPage;
            case 0xA8: opCode=TAY;
            case 0xA9: opCode=LDA; addressingMode=Immediate;
            case 0xAA: opCode=TAX;
            case 0xAC: opCode=LDY;
            case 0xAD: opCode=LDA;
            case 0xAE: opCode=LDX;
            case 0xB0: opCode=BCS;
            case 0xB1: opCode=LDA; addressingMode=IndirectY;
            case 0xB4: opCode=LDY; addressingMode=ZeroPageX;
            case 0xB5: opCode=LDA; addressingMode=ZeroPageX;
            case 0xB6: opCode=LDX; addressingMode=ZeroPageY;
            case 0xB8: opCode=CLV;
            case 0xB9: opCode=LDA; addressingMode=AbsoluteY;
            case 0xBA: opCode=TSX;
            case 0xBC: opCode=LDY; addressingMode=AbsoluteX;
            case 0xBD: opCode=LDA; addressingMode=AbsoluteX;
            case 0xBE: opCode=LDX; addressingMode=AbsoluteY;
            case 0xC0: opCode=CPY; addressingMode=Immediate;
            case 0xC1: opCode=CMP; addressingMode=IndirectX;
            case 0xC4: opCode=CPY; addressingMode=ZeroPage;
            case 0xC5: opCode=CMP; addressingMode=ZeroPage;
            case 0xC6: opCode=DEC; addressingMode=ZeroPage;
            case 0xC8: opCode=INY;
            case 0xC9: opCode=CMP; addressingMode=Immediate;
            case 0xCA: opCode=DEX;
            case 0xCC: opCode=CPY;
            case 0xCD: opCode=CMP;
            case 0xCE: opCode=DEC;
            case 0xD0: opCode=BNE;
            case 0xD1: opCode=CMP; addressingMode=IndirectY;
            case 0xD5: opCode=CMP; addressingMode=ZeroPageX;
            case 0xD6: opCode=DEC; addressingMode=ZeroPageX;
            case 0xD8: opCode=CLD;
            case 0xD9: opCode=CMP; addressingMode=AbsoluteY;
            case 0xDD: opCode=CMP; addressingMode=AbsoluteX;
            case 0xDE: opCode=DEC; addressingMode=AbsoluteX;
            case 0xE0: opCode=CPX; addressingMode=Immediate;
            case 0xE1: opCode=SBC; addressingMode=IndirectX;
            case 0xE4: opCode=CPX; addressingMode=ZeroPage;
            case 0xE5: opCode=SBC; addressingMode=ZeroPage;
            case 0xE6: opCode=INC; addressingMode=ZeroPage;
            case 0xE8: opCode=INX;
            case 0xE9: opCode=SBC; addressingMode=Immediate;
            case 0xEC: opCode=CPX;
            case 0xED: opCode=SBC;
            case 0xEE: opCode=INC;
            case 0xF0: opCode=BEQ;
            case 0xF1: opCode=SBC; addressingMode=IndirectY;
            case 0xF5: opCode=SBC; addressingMode=ZeroPageX;
            case 0xF6: opCode=INC; addressingMode=ZeroPageX;
            case 0xF8: opCode=SED;
            case 0xF9: opCode=SBC; addressingMode=AbsoluteY;
            case 0xFD: opCode=SBC; addressingMode=AbsoluteX;
            case 0xFE: opCode=INC; addressingMode=AbsoluteX;
            
            case 0xEA,0x1A,0x3A,0x5A,0x7A,0xDA,0xFA: opCode=NOP(0);
            case 0x04,0x14,0x24,0x34,0x44,0x54,0x64,0x74,0xD4,0xF4,0x80: opCode=NOP(1);
            case 0x0C,0x1C,0x3C,0x5C,0x7C,0xDC,0xFC: opCode=NOP(2);
        }
        
        var cmd:Command = CommandPool.get();
        cmd.opCode = opCode;
        cmd.addressingMode = addressingMode;
        
        return cmd;
    }
}
