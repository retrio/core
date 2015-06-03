package strafe.platform.nes;


// http://www.obelisk.demon.co.uk/6502/reference.html
@:enum
abstract OpCode(Int) from Int to Int
{
	static inline var pos:Int=0x10;

	var ORA = 0x01<<pos;	// logical OR
	var AND = 0x02<<pos;	// logical AND
	var EOR = 0x03<<pos;	// exclusive or
	var ADC = 0x04<<pos;	// add with carry
	var STA = 0x05<<pos;	// store accumulator
	var LDA = 0x06<<pos;	// load accumulator
	var CMP = 0x07<<pos;	// compare
	var SBC = 0x08<<pos;	// subtract with carry
	var ASL = 0x09<<pos;	// arithmetic shift left
	var ROL = 0x10<<pos;	// rotate left
	var LSR = 0x11<<pos;	// logical shift right
	var ROR = 0x12<<pos;	// rotate right
	var STX = 0x13<<pos;	// store X
	var LDX = 0x14<<pos;	// load X
	var DEC = 0x15<<pos;	// decrement memory
	var INC = 0x16<<pos;	// increment memory
	var BIT = 0x17<<pos;	// bit test
	var JMP = 0x18<<pos;	// jump
	var STY = 0x19<<pos;	// store Y
	var LDY = 0x20<<pos;	// load Y
	var CPY = 0x21<<pos;	// compare Y
	var CPX = 0x22<<pos;	// compare X
	var BCC = 0x23<<pos;	// branch if carry clear
	var BCS = 0x24<<pos;	// branch if carry set
	var BEQ = 0x25<<pos;	// branch if equal
	var BMI = 0x26<<pos;	// branch if minus
	var BNE = 0x27<<pos;	// branch if not equal
	var BPL = 0x28<<pos;	// branch if positive
	var BVC = 0x29<<pos;	// branch if overflow clear
	var BVS = 0x30<<pos;	// branch if overflow set
	var BRK = 0x31<<pos;	// force interrupt
	var CLC = 0x32<<pos;	// clear carry flag
	var CLD = 0x33<<pos;	// clear decimal mode
	var CLI = 0x34<<pos;	// clear interrupt disable
	var CLV = 0x35<<pos;	// clear overflow flag
	var DEX = 0x36<<pos;	// decrement X register
	var DEY = 0x37<<pos;	// decrement Y register
	var INX = 0x38<<pos;	// increment X register
	var INY = 0x39<<pos;	// increment Y register
	var JSR = 0x40<<pos;	// jump to subroutine
	var NOP = 0x41<<pos;	// no operation
	var IGN1 = 0x42<<pos;	// nop +1
	var IGN2 = 0x43<<pos;	// nop +2
	var PHA = 0x44<<pos;	// push accumulator
	var PHP = 0x45<<pos;	// push processor status
	var PLA = 0x46<<pos;	// pull accumulator
	var PLP = 0x47<<pos;	// pull processor status
	var RTI = 0x48<<pos;	// return from interrupt
	var RTS = 0x49<<pos;	// return from subroutine
	var SEC = 0x50<<pos;	// set carry flag
	var SED = 0x51<<pos;	// set decimal flag
	var SEI = 0x52<<pos;	// set interrupt disabled
	var TAX = 0x53<<pos;	// transfer accumulator to X
	var TAY = 0x54<<pos;	// transfer accumulator to Y
	var TSX = 0x55<<pos;	// transfer stack pointer to X
	var TSY = 0x56<<pos;	// transfer stack pointer to Y
	var TYA = 0x57<<pos;	// transfer Y to accumulator
	var TXS = 0x58<<pos;	// transfer X to stack pointer
	var TXA = 0x59<<pos;	// transfer X to stack pointer

	// unofficial

	var LAX = 0x60<<pos;	// load both accumulator and X
	var SAX = 0x61<<pos;	// AND, CMP and store
	var RLA = 0x62<<pos;	// ROL then AND
	var RRA = 0x63<<pos;	// ROR then ADC
	var SLO = 0x64<<pos;	// ASL then ORA
	var SRE = 0x65<<pos;	// LSR then EOR
	var DCP = 0x66<<pos;	// DEC then COMP
	var ISC = 0x67<<pos;	// INC then SBC

	var UNKNOWN = 0x0;

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
