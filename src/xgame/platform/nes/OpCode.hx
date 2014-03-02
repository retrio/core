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
    public static inline var RLA:OpCode=62<<pos;
    public static inline var RRA:OpCode=63<<pos;
    public static inline var SLO:OpCode=64<<pos;
    public static inline var SRE:OpCode=65<<pos;
    public static inline var DCP:OpCode=66<<pos;
    public static inline var ISC:OpCode=67<<pos;
    
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
}
