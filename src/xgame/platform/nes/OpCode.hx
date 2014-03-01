package xgame.platform.nes;


typedef OpCode = Int;

// http://www.obelisk.demon.co.uk/6502/reference.html
class OpCodes
{
    public static inline var ORA:OpCode=01<<4;     // logical OR
    public static inline var AND:OpCode=02<<4;     // logical AND
    public static inline var EOR:OpCode=03<<4;     // exclusive or
    public static inline var ADC:OpCode=04<<4;     // add with carry
    public static inline var STA:OpCode=05<<4;     // store accumulator
    public static inline var LDA:OpCode=06<<4;     // load accumulator
    public static inline var CMP:OpCode=07<<4;     // compare
    public static inline var SBC:OpCode=08<<4;     // subtract with carry
    public static inline var ASL:OpCode=09<<4;     // arithmetic shift left
    public static inline var ROL:OpCode=10<<4;     // rotate left
    public static inline var LSR:OpCode=11<<4;     // logical shift right
    public static inline var ROR:OpCode=12<<4;     // rotate right
    public static inline var STX:OpCode=13<<4;     // store X
    public static inline var LDX:OpCode=14<<4;     // load X
    public static inline var DEC:OpCode=15<<4;     // decrement memory
    public static inline var INC:OpCode=16<<4;     // increment memory
    public static inline var BIT:OpCode=17<<4;     // bit test
    public static inline var JMP:OpCode=18<<4;     // jump
    public static inline var JMA:OpCode=19<<4;     // jump absolute
    public static inline var STY:OpCode=20<<4;     // store Y
    public static inline var LDY:OpCode=21<<4;     // load Y
    public static inline var CPY:OpCode=22<<4;     // compare Y
    public static inline var CPX:OpCode=23<<4;     // compare X
    public static inline var BCC:OpCode=24<<4;     // branch if carry clear
    public static inline var BCS:OpCode=25<<4;     // branch if carry set
    public static inline var BEQ:OpCode=26<<4;     // branch if equal
    public static inline var BMI:OpCode=27<<4;     // branch if minus
    public static inline var BNE:OpCode=28<<4;     // branch if not equal
    public static inline var BPL:OpCode=29<<4;     // branch if positive
    public static inline var BVC:OpCode=30<<4;     // branch if overflow clear
    public static inline var BVS:OpCode=31<<4;     // branch if overflow set
    public static inline var BRK:OpCode=32<<4;     // force interrupt
    public static inline var CLC:OpCode=33<<4;     // clear carry flag
    public static inline var CLD:OpCode=34<<4;     // clear decimal mode
    public static inline var CLI:OpCode=35<<4;     // clear interrupt disable
    public static inline var CLV:OpCode=36<<4;     // clear overflow flag
    public static inline var DEX:OpCode=37<<4;     // decrement X register
    public static inline var DEY:OpCode=38<<4;     // decrement Y register
    public static inline var INX:OpCode=39<<4;     // increment X register
    public static inline var INY:OpCode=40<<4;     // increment Y register
    public static inline var JSR:OpCode=41<<4;     // jump to subroutine
    public static inline var NOP:OpCode=42<<4;     // no operation
    public static inline var NOP1:OpCode=43<<4;    // no operation +1
    public static inline var NOP2:OpCode=44<<4;    // no operation +2
    public static inline var PHA:OpCode=45<<4;     // push accumulator
    public static inline var PHP:OpCode=46<<4;     // push processor status
    public static inline var PLA:OpCode=47<<4;     // pull accumulator
    public static inline var PLP:OpCode=48<<4;     // pull processor status
    public static inline var RTI:OpCode=49<<4;     // return from interrupt
    public static inline var RTS:OpCode=50<<4;     // return from subroutine
    public static inline var SEC:OpCode=51<<4;     // set carry flag
    public static inline var SED:OpCode=52<<4;     // set decimal flag
    public static inline var SEI:OpCode=53<<4;     // set interrupt disabled
    public static inline var TAX:OpCode=54<<4;     // transfer accumulator to X
    public static inline var TAY:OpCode=55<<4;     // transfer accumulator to Y
    public static inline var TSX:OpCode=56<<4;     // transfer stack pointer to X
    public static inline var TSY:OpCode=57<<4;     // transfer stack pointer to Y
    public static inline var TYA:OpCode=58<<4;     // transfer Y to accumulator
    public static inline var TXS:OpCode=59<<4;     // transfer X to stack pointer
    public static inline var TXA:OpCode=60<<4;     // transfer X to stack pointer

// unofficial

    public static inline var LAX:OpCode=61<<4;     // load both accumulator and X
    public static inline var SAX:OpCode=62<<4;     // AND, CMP and store
    public static inline var RLA:OpCode=63<<4;
    public static inline var SLO:OpCode=64<<4;
    public static inline var SRE:OpCode=65<<4;
    public static inline var RRA:OpCode=66<<4;
    public static inline var DCP:OpCode=67<<4;
    public static inline var ISB:OpCode=68<<4;
}


typedef AddressingMode = Int;

// http://www.obelisk.demon.co.uk/6502/addressing.html
class AddressingModes
{
    public static inline var Accumulator:AddressingMode=01;
    public static inline var Immediate:AddressingMode=02;
    public static inline var ZeroPage:AddressingMode=03;
    public static inline var ZeroPageX:AddressingMode=04;
    public static inline var ZeroPageY:AddressingMode=05;
    public static inline var Relative:AddressingMode=06;
    public static inline var Absolute:AddressingMode=07;
    public static inline var AbsoluteX:AddressingMode=08;
    public static inline var AbsoluteY:AddressingMode=09;
    public static inline var Indirect:AddressingMode=10;
    public static inline var IndirectX:AddressingMode=11;
    public static inline var IndirectY:AddressingMode=12;
}


typedef Command = Int;
class Commands
{
    public inline static function newCmd(code:OpCode, mode:AddressingMode):Command
    {
        return code + mode;
    }
    
    public inline static function getCode(cmd:Command):OpCode
    {
        return (cmd & 0xFF0);
    }
    
    public inline static function getMode(cmd:Command):AddressingMode
    {
        return (cmd & 0xF);
    }
}
