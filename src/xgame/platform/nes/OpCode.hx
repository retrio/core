package xgame.platform.nes;


typedef OpCode = Int;

// http://www.obelisk.demon.co.uk/6502/reference.html
class OpCodes
{
    static inline var pos:Int=8;
    public static inline var ORA:OpCode=01<<pos;    // logical OR
    public static inline var AND:OpCode=02<<pos;    // logical AND
    public static inline var EOR:OpCode=03<<pos;    // exclusive or
    public static inline var ADC:OpCode=04<<pos;    // add with carry
    public static inline var STA:OpCode=05<<pos;    // store accumulator
    public static inline var LDA:OpCode=06<<pos;    // load accumulator
    public static inline var CMP:OpCode=07<<pos;    // compare
    public static inline var SBC:OpCode=08<<pos;    // subtract with carry
    public static inline var ASL:OpCode=09<<pos;    // arithmetic shift left
    public static inline var ROL:OpCode=10<<pos;    // rotate left
    public static inline var LSR:OpCode=11<<pos;    // logical shift right
    public static inline var ROR:OpCode=12<<pos;    // rotate right
    public static inline var STX:OpCode=13<<pos;    // store X
    public static inline var LDX:OpCode=14<<pos;    // load X
    public static inline var DEC:OpCode=15<<pos;    // decrement memory
    public static inline var INC:OpCode=16<<pos;    // increment memory
    public static inline var BIT:OpCode=17<<pos;    // bit test
    public static inline var JMP:OpCode=18<<pos;    // jump
    public static inline var STY:OpCode=19<<pos;    // store Y
    public static inline var LDY:OpCode=20<<pos;    // load Y
    public static inline var CPY:OpCode=21<<pos;    // compare Y
    public static inline var CPX:OpCode=22<<pos;    // compare X
    public static inline var BCC:OpCode=23<<pos;    // branch if carry clear
    public static inline var BCS:OpCode=24<<pos;    // branch if carry set
    public static inline var BEQ:OpCode=25<<pos;    // branch if equal
    public static inline var BMI:OpCode=26<<pos;    // branch if minus
    public static inline var BNE:OpCode=27<<pos;    // branch if not equal
    public static inline var BPL:OpCode=28<<pos;    // branch if positive
    public static inline var BVC:OpCode=29<<pos;    // branch if overflow clear
    public static inline var BVS:OpCode=30<<pos;    // branch if overflow set
    public static inline var BRK:OpCode=31<<pos;    // force interrupt
    public static inline var CLC:OpCode=32<<pos;    // clear carry flag
    public static inline var CLD:OpCode=33<<pos;    // clear decimal mode
    public static inline var CLI:OpCode=34<<pos;    // clear interrupt disable
    public static inline var CLV:OpCode=35<<pos;    // clear overflow flag
    public static inline var DEX:OpCode=36<<pos;    // decrement X register
    public static inline var DEY:OpCode=37<<pos;    // decrement Y register
    public static inline var INX:OpCode=38<<pos;    // increment X register
    public static inline var INY:OpCode=39<<pos;    // increment Y register
    public static inline var JSR:OpCode=40<<pos;    // jump to subroutine
    public static inline var NOP:OpCode=41<<pos;    // no operation
    public static inline var IGN1:OpCode=42<<pos;   // nop +1
    public static inline var IGN2:OpCode=43<<pos;   // nop +2
    public static inline var PHA:OpCode=44<<pos;    // push accumulator
    public static inline var PHP:OpCode=45<<pos;    // push processor status
    public static inline var PLA:OpCode=46<<pos;    // pull accumulator
    public static inline var PLP:OpCode=47<<pos;    // pull processor status
    public static inline var RTI:OpCode=48<<pos;    // return from interrupt
    public static inline var RTS:OpCode=49<<pos;    // return from subroutine
    public static inline var SEC:OpCode=50<<pos;    // set carry flag
    public static inline var SED:OpCode=51<<pos;    // set decimal flag
    public static inline var SEI:OpCode=52<<pos;    // set interrupt disabled
    public static inline var TAX:OpCode=53<<pos;    // transfer accumulator to X
    public static inline var TAY:OpCode=54<<pos;    // transfer accumulator to Y
    public static inline var TSX:OpCode=55<<pos;    // transfer stack pointer to X
    public static inline var TSY:OpCode=56<<pos;    // transfer stack pointer to Y
    public static inline var TYA:OpCode=57<<pos;    // transfer Y to accumulator
    public static inline var TXS:OpCode=58<<pos;    // transfer X to stack pointer
    public static inline var TXA:OpCode=59<<pos;    // transfer X to stack pointer

// unofficial

    public static inline var LAX:OpCode=60<<pos;    // load both accumulator and X
    public static inline var SAX:OpCode=61<<pos;    // AND, CMP and store
    public static inline var RLA:OpCode=62<<pos;    // ROL then AND
    public static inline var RRA:OpCode=63<<pos;    // ROR then ADC
    public static inline var SLO:OpCode=64<<pos;    // ASL then ORA
    public static inline var SRE:OpCode=65<<pos;    // LSR then EOR
    public static inline var DCP:OpCode=66<<pos;    // DEC then COMP
    public static inline var ISC:OpCode=67<<pos;    // INC then SBC
    
    public static inline var UNKNOWN:OpCode=0;
    
    public static var opCodeNames=[
        ORA => "ORA",
        AND => "AND",
        EOR => "EOR",
        ADC => "ADC",
        STA => "STA",
        LDA => "LDA",
        CMP => "CMP",
        SBC => "SBC",
        ASL => "ASL",
        ROL => "ROL",
        LSR => "LSR",
        ROR => "ROR",
        STX => "STX",
        LDX => "LDX",
        DEC => "DEC",
        INC => "INC",
        BIT => "BIT",
        JMP => "JMP",
        STY => "STY",
        LDY => "LDY",
        CPY => "CPY",
        CPX => "CPX",
        BCC => "BCC",
        BCS => "BCS",
        BEQ => "BEQ",
        BMI => "BMI",
        BNE => "BNE",
        BPL => "BPL",
        BVC => "BVC",
        BVS => "BVS",
        BRK => "BRK",
        CLC => "CLC",
        CLD => "CLD",
        CLI => "CLI",
        CLV => "CLV",
        DEX => "DEX",
        DEY => "DEY",
        INX => "INX",
        INY => "INY",
        JSR => "JSR",
        NOP => "NOP",
        IGN1 => "NOP(1)",
        IGN2 => "NOP(2)",
        PHA => "PHA",
        PHP => "PHP",
        PLA => "PLA",
        PLP => "PLP",
        RTI => "RTI",
        RTS => "RTS",
        SEC => "SEC",
        SED => "SED",
        SEI => "SEI",
        TAX => "TAX",
        TAY => "TAY",
        TSX => "TSX",
        TSY => "TSY",
        TYA => "TYA",
        TXS => "TXS",
        TXA => "TXA",
        LAX => "LAX",
        SAX => "SAX",
        RLA => "RLA",
        RRA => "RRA",
        SLO => "SLO",
        SRE => "SRE",
        DCP => "DCP",
        ISC => "ISC",
        
        UNKNOWN => "???",
    ];
}


typedef AddressingMode = Int;

// http://www.obelisk.demon.co.uk/6502/addressing.html
class AddressingModes
{
    static inline var pos:Int=4;
    public static inline var Accumulator:AddressingMode=01<<pos;
    public static inline var Immediate:AddressingMode=02<<pos;
    public static inline var ZeroPage:AddressingMode=03<<pos;
    public static inline var ZeroPageX:AddressingMode=04<<pos;
    public static inline var ZeroPageY:AddressingMode=05<<pos;
    public static inline var Relative:AddressingMode=06<<pos;
    public static inline var Absolute:AddressingMode=07<<pos;
    public static inline var AbsoluteX:AddressingMode=08<<pos;
    public static inline var AbsoluteY:AddressingMode=09<<pos;
    public static inline var Indirect:AddressingMode=10<<pos;
    public static inline var IndirectX:AddressingMode=11<<pos;
    public static inline var IndirectY:AddressingMode=12<<pos;
    
    public static var addressingModeNames = [
        Accumulator => "Accumulator",
        Immediate => "Immediate",
        ZeroPage => "ZeroPage",
        ZeroPageX => "ZeroPageX",
        ZeroPageY => "ZeroPageY",
        Relative => "Relative",
        Absolute => "Absolute",
        AbsoluteX => "AbsoluteX",
        AbsoluteY => "AbsoluteY",
        Indirect => "Indirect",
        IndirectX => "IndirectX",
        IndirectY => "IndirectY",
    ];
}


// each interpreted command is a 16-bit int consisting of 3 parts:
// opcode (8 bits), addressing mode (4 bits), cpu ticks (4 bits)
typedef Command = Int;
class Commands
{
    public inline static function newCmd(code:OpCode, mode:AddressingMode, ticks:Int):Command
    {
        return code + mode + ticks;
    }
    
    public inline static function getCode(cmd:Command):OpCode
    {
        return (cmd & 0xFF00);
    }
    
    public inline static function getMode(cmd:Command):AddressingMode
    {
        return (cmd & 0xF0);
    }
    
    public inline static function getTicks(cmd:Command):Int
    {
        return (cmd & 0xF);
    }
    
    public static inline function decodeByte(byte:Int):Command
    {
        var code:OpCode;
        var mode:AddressingMode = AddressingModes.Absolute;
        var ticks:Int = 2;
        
        switch(byte) {
            // this section auto-generated by parse6502.py
            case 0x00: { code=OpCodes.BRK; ticks=7; }
            case 0x01: { code=OpCodes.ORA; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x05: { code=OpCodes.ORA; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x06: { code=OpCodes.ASL; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x08: { code=OpCodes.PHP; ticks=3; }
            case 0x09: { code=OpCodes.ORA; mode=AddressingModes.Immediate; }
            case 0x0A: { code=OpCodes.ASL; mode=AddressingModes.Accumulator; }
            case 0x0D: { code=OpCodes.ORA; ticks=4; }
            case 0x0E: { code=OpCodes.ASL; ticks=6; }
            case 0x10: { code=OpCodes.BPL; mode=AddressingModes.Relative; }
            case 0x11: { code=OpCodes.ORA; mode=AddressingModes.IndirectY; ticks=5; }
            case 0x15: { code=OpCodes.ORA; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x16: { code=OpCodes.ASL; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x18: { code=OpCodes.CLC; }
            case 0x19: { code=OpCodes.ORA; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0x1D: { code=OpCodes.ORA; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0x1E: { code=OpCodes.ASL; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0x20: { code=OpCodes.JSR; ticks=6; }
            case 0x21: { code=OpCodes.AND; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x24: { code=OpCodes.BIT; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x25: { code=OpCodes.AND; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x26: { code=OpCodes.ROL; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x28: { code=OpCodes.PLP; ticks=4; }
            case 0x29: { code=OpCodes.AND; mode=AddressingModes.Immediate; }
            case 0x2A: { code=OpCodes.ROL; mode=AddressingModes.Accumulator; }
            case 0x2C: { code=OpCodes.BIT; ticks=4; }
            case 0x2D: { code=OpCodes.AND; ticks=4; }
            case 0x2E: { code=OpCodes.ROL; ticks=6; }
            case 0x30: { code=OpCodes.BMI; mode=AddressingModes.Relative; }
            case 0x31: { code=OpCodes.AND; mode=AddressingModes.IndirectY; ticks=5; }
            case 0x35: { code=OpCodes.AND; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x36: { code=OpCodes.ROL; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x38: { code=OpCodes.SEC; }
            case 0x39: { code=OpCodes.AND; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0x3D: { code=OpCodes.AND; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0x3E: { code=OpCodes.ROL; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0x40: { code=OpCodes.RTI; ticks=6; }
            case 0x41: { code=OpCodes.EOR; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x45: { code=OpCodes.EOR; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x46: { code=OpCodes.LSR; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x48: { code=OpCodes.PHA; ticks=3; }
            case 0x49: { code=OpCodes.EOR; mode=AddressingModes.Immediate; }
            case 0x4A: { code=OpCodes.LSR; mode=AddressingModes.Accumulator; }
            case 0x4C: { code=OpCodes.JMP; ticks=3; }
            case 0x4D: { code=OpCodes.EOR; ticks=4; }
            case 0x4E: { code=OpCodes.LSR; ticks=6; }
            case 0x50: { code=OpCodes.BVC; mode=AddressingModes.Relative; }
            case 0x51: { code=OpCodes.EOR; mode=AddressingModes.IndirectY; ticks=5; }
            case 0x55: { code=OpCodes.EOR; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x56: { code=OpCodes.LSR; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x58: { code=OpCodes.CLI; }
            case 0x59: { code=OpCodes.EOR; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0x5D: { code=OpCodes.EOR; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0x5E: { code=OpCodes.LSR; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0x60: { code=OpCodes.RTS; ticks=6; }
            case 0x61: { code=OpCodes.ADC; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x65: { code=OpCodes.ADC; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x66: { code=OpCodes.ROR; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x68: { code=OpCodes.PLA; ticks=4; }
            case 0x69: { code=OpCodes.ADC; mode=AddressingModes.Immediate; }
            case 0x6A: { code=OpCodes.ROR; mode=AddressingModes.Accumulator; }
            case 0x6C: { code=OpCodes.JMP; mode=AddressingModes.Indirect; ticks=5; }
            case 0x6D: { code=OpCodes.ADC; ticks=4; }
            case 0x6E: { code=OpCodes.ROR; ticks=6; }
            case 0x70: { code=OpCodes.BVS; mode=AddressingModes.Relative; }
            case 0x71: { code=OpCodes.ADC; mode=AddressingModes.IndirectY; ticks=5; }
            case 0x75: { code=OpCodes.ADC; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x76: { code=OpCodes.ROR; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x78: { code=OpCodes.SEI; }
            case 0x79: { code=OpCodes.ADC; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0x7D: { code=OpCodes.ADC; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0x7E: { code=OpCodes.ROR; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0x81: { code=OpCodes.STA; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x84: { code=OpCodes.STY; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x85: { code=OpCodes.STA; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x86: { code=OpCodes.STX; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x88: { code=OpCodes.DEY; }
            case 0x8A: { code=OpCodes.TXA; }
            case 0x8C: { code=OpCodes.STY; ticks=4; }
            case 0x8D: { code=OpCodes.STA; ticks=4; }
            case 0x8E: { code=OpCodes.STX; ticks=4; }
            case 0x90: { code=OpCodes.BCC; mode=AddressingModes.Relative; }
            case 0x91: { code=OpCodes.STA; mode=AddressingModes.IndirectY; ticks=6; }
            case 0x94: { code=OpCodes.STY; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x95: { code=OpCodes.STA; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x96: { code=OpCodes.STX; mode=AddressingModes.ZeroPageY; ticks=4; }
            case 0x98: { code=OpCodes.TYA; }
            case 0x99: { code=OpCodes.STA; mode=AddressingModes.AbsoluteY; ticks=5; }
            case 0x9A: { code=OpCodes.TXS; }
            case 0x9D: { code=OpCodes.STA; mode=AddressingModes.AbsoluteX; ticks=5; }
            case 0xA0: { code=OpCodes.LDY; mode=AddressingModes.Immediate; }
            case 0xA1: { code=OpCodes.LDA; mode=AddressingModes.IndirectX; ticks=6; }
            case 0xA2: { code=OpCodes.LDX; mode=AddressingModes.Immediate; }
            case 0xA4: { code=OpCodes.LDY; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xA5: { code=OpCodes.LDA; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xA6: { code=OpCodes.LDX; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xA8: { code=OpCodes.TAY; }
            case 0xA9: { code=OpCodes.LDA; mode=AddressingModes.Immediate; }
            case 0xAA: { code=OpCodes.TAX; }
            case 0xAC: { code=OpCodes.LDY; ticks=4; }
            case 0xAD: { code=OpCodes.LDA; ticks=4; }
            case 0xAE: { code=OpCodes.LDX; ticks=4; }
            case 0xB0: { code=OpCodes.BCS; mode=AddressingModes.Relative; }
            case 0xB1: { code=OpCodes.LDA; mode=AddressingModes.IndirectY; ticks=5; }
            case 0xB4: { code=OpCodes.LDY; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0xB5: { code=OpCodes.LDA; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0xB6: { code=OpCodes.LDX; mode=AddressingModes.ZeroPageY; ticks=4; }
            case 0xB8: { code=OpCodes.CLV; }
            case 0xB9: { code=OpCodes.LDA; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0xBA: { code=OpCodes.TSX; }
            case 0xBC: { code=OpCodes.LDY; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0xBD: { code=OpCodes.LDA; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0xBE: { code=OpCodes.LDX; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0xC0: { code=OpCodes.CPY; mode=AddressingModes.Immediate; }
            case 0xC1: { code=OpCodes.CMP; mode=AddressingModes.IndirectX; ticks=6; }
            case 0xC4: { code=OpCodes.CPY; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xC5: { code=OpCodes.CMP; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xC6: { code=OpCodes.DEC; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0xC8: { code=OpCodes.INY; }
            case 0xC9: { code=OpCodes.CMP; mode=AddressingModes.Immediate; }
            case 0xCA: { code=OpCodes.DEX; }
            case 0xCC: { code=OpCodes.CPY; ticks=4; }
            case 0xCD: { code=OpCodes.CMP; ticks=4; }
            case 0xCE: { code=OpCodes.DEC; ticks=6; }
            case 0xD0: { code=OpCodes.BNE; mode=AddressingModes.Relative; }
            case 0xD1: { code=OpCodes.CMP; mode=AddressingModes.IndirectY; ticks=5; }
            case 0xD5: { code=OpCodes.CMP; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0xD6: { code=OpCodes.DEC; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0xD8: { code=OpCodes.CLD; }
            case 0xD9: { code=OpCodes.CMP; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0xDD: { code=OpCodes.CMP; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0xDE: { code=OpCodes.DEC; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0xE0: { code=OpCodes.CPX; mode=AddressingModes.Immediate; }
            case 0xE1: { code=OpCodes.SBC; mode=AddressingModes.IndirectX; ticks=6; }
            case 0xE4: { code=OpCodes.CPX; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xE5: { code=OpCodes.SBC; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xE6: { code=OpCodes.INC; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0xE8: { code=OpCodes.INX; }
            case 0xE9: { code=OpCodes.SBC; mode=AddressingModes.Immediate; }
            case 0xEA: { code=OpCodes.NOP; }
            case 0xEC: { code=OpCodes.CPX; ticks=4; }
            case 0xED: { code=OpCodes.SBC; ticks=4; }
            case 0xEE: { code=OpCodes.INC; ticks=6; }
            case 0xF0: { code=OpCodes.BEQ; mode=AddressingModes.Relative; }
            case 0xF1: { code=OpCodes.SBC; mode=AddressingModes.IndirectY; ticks=5; }
            case 0xF5: { code=OpCodes.SBC; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0xF6: { code=OpCodes.INC; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0xF8: { code=OpCodes.SED; }
            case 0xF9: { code=OpCodes.SBC; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0xFD: { code=OpCodes.SBC; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0xFE: { code=OpCodes.INC; mode=AddressingModes.AbsoluteX; ticks=7; }
            
            // the following are unofficial opcodes
            // http://wiki.nesdev.com/w/index.php/Programming_with_unofficial_opcodes
            
            // NOOP +
            case 0x1A,0x3A,0x5A,0x7A,0xDA,0xFA: {
                code=OpCodes.NOP;
            }
            case 0x80,0x82,0x89,0xC2,0xE2: {
                code=OpCodes.IGN1;
            }
            case 0x04,0x44,0x64: {
                code=OpCodes.IGN1;
                ticks=3;
            }
            case 0x14,0x34,0x54,0x74,0xD4,0xF4: { 
                code=OpCodes.IGN1;
                ticks=4;
            }
            case 0x0C: {
                code=OpCodes.IGN2;
                ticks = 4;
            }
            case 0x1C,0x3C,0x5C,0x7C,0xDC,0xFC: { 
                code=OpCodes.IGN2;
                // warning: can be 5 ticks if crossing page boundary    
                ticks=4;
            }
            // LAX
            case 0xA3: {
                code=OpCodes.LAX;
                mode=AddressingModes.IndirectX;
                ticks=6;
            }
            case 0xA7: {
                code=OpCodes.LAX;
                mode=AddressingModes.ZeroPage;
                ticks=3;
            }
            case 0xAF: {
                code=OpCodes.LAX;
                mode=AddressingModes.Absolute;
                ticks=4;
            }
            case 0xB3: {
                code=OpCodes.LAX;
                mode=AddressingModes.IndirectY;
                ticks=5;
            }
            case 0xB7: {
                code=OpCodes.LAX;
                mode=AddressingModes.ZeroPageY;
                ticks=4;
            }
            case 0xBF: {
                code=OpCodes.LAX;
                mode=AddressingModes.AbsoluteY;
                ticks=4;
            }
            // SAX
            case 0x83: {
                code=OpCodes.SAX;
                mode=AddressingModes.IndirectX;
                ticks=6;
            }
            case 0x87: {
                code=OpCodes.SAX;
                mode=AddressingModes.ZeroPage;
                ticks=3;
            }
            case 0x8F: {
                code=OpCodes.SAX;
                mode=AddressingModes.Absolute;
                ticks=4;
            }
            case 0x97: {
                code=OpCodes.SAX;
                mode=AddressingModes.ZeroPageY;
                ticks=4;
            }
            // SBC
            case 0xEB: { code=OpCodes.SBC; mode=AddressingModes.Immediate; }
            // RLA
            case 0x23: { code=OpCodes.RLA; mode=AddressingModes.IndirectX; ticks=8; }
            case 0x27: { code=OpCodes.RLA; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x2F: { code=OpCodes.RLA; mode=AddressingModes.Absolute; ticks=6; }
            case 0x33: { code=OpCodes.RLA; mode=AddressingModes.IndirectY; ticks=8; }
            case 0x37: { code=OpCodes.RLA; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x3B: { code=OpCodes.RLA; mode=AddressingModes.AbsoluteY; ticks=7; }
            case 0x3F: { code=OpCodes.RLA; mode=AddressingModes.AbsoluteX; ticks=7; }
            // RRA
            case 0x63: { code=OpCodes.RRA; mode=AddressingModes.IndirectX; ticks=8; }
            case 0x67: { code=OpCodes.RRA; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x6F: { code=OpCodes.RRA; mode=AddressingModes.Absolute; ticks=6; }
            case 0x73: { code=OpCodes.RRA; mode=AddressingModes.IndirectY; ticks=8; }
            case 0x77: { code=OpCodes.RRA; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x7B: { code=OpCodes.RRA; mode=AddressingModes.AbsoluteY; ticks=7; }
            case 0x7F: { code=OpCodes.RRA; mode=AddressingModes.AbsoluteX; ticks=7; }
            // SLO
            case 0x03: { code=OpCodes.SLO; mode=AddressingModes.IndirectX; ticks=8; }
            case 0x07: { code=OpCodes.SLO; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x0F: { code=OpCodes.SLO; mode=AddressingModes.Absolute; ticks=6; }
            case 0x13: { code=OpCodes.SLO; mode=AddressingModes.IndirectY; ticks=8; }
            case 0x17: { code=OpCodes.SLO; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x1B: { code=OpCodes.SLO; mode=AddressingModes.AbsoluteY; ticks=7; }
            case 0x1F: { code=OpCodes.SLO; mode=AddressingModes.AbsoluteX; ticks=7; }
            // SRE
            case 0x43: { code=OpCodes.SRE; mode=AddressingModes.IndirectX; ticks=8; }
            case 0x47: { code=OpCodes.SRE; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x4F: { code=OpCodes.SRE; mode=AddressingModes.Absolute; ticks=6; }
            case 0x53: { code=OpCodes.SRE; mode=AddressingModes.IndirectY; ticks=8; }
            case 0x57: { code=OpCodes.SRE; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x5B: { code=OpCodes.SRE; mode=AddressingModes.AbsoluteY; ticks=7; }
            case 0x5F: { code=OpCodes.SRE; mode=AddressingModes.AbsoluteX; ticks=7; }
            // DCP
            case 0xC3: { code=OpCodes.DCP; mode=AddressingModes.IndirectX; ticks=8; }
            case 0xC7: { code=OpCodes.DCP; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0xCF: { code=OpCodes.DCP; mode=AddressingModes.Absolute; ticks=6; }
            case 0xD3: { code=OpCodes.DCP; mode=AddressingModes.IndirectY; ticks=8; }
            case 0xD7: { code=OpCodes.DCP; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0xDB: { code=OpCodes.DCP; mode=AddressingModes.AbsoluteY; ticks=7; }
            case 0xDF: { code=OpCodes.DCP; mode=AddressingModes.AbsoluteX; ticks=7; }
            // ISC
            case 0xE3: { code=OpCodes.ISC; mode=AddressingModes.IndirectX; ticks=8; }
            case 0xE7: { code=OpCodes.ISC; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0xEF: { code=OpCodes.ISC; mode=AddressingModes.Absolute; ticks=6; }
            case 0xF3: { code=OpCodes.ISC; mode=AddressingModes.IndirectY; ticks=8; }
            case 0xF7: { code=OpCodes.ISC; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0xFB: { code=OpCodes.ISC; mode=AddressingModes.AbsoluteY; ticks=7; }
            case 0xFF: { code=OpCodes.ISC; mode=AddressingModes.AbsoluteX; ticks=7; }
            
            default: code=OpCodes.UNKNOWN;
        }
        
        return newCmd(code, mode, ticks);
    }
}
