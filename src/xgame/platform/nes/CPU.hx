package xgame.platform.nes;


class CPU
{
	public var ram:RAM;
	public var cycles:Int = 0;
	public var nmi:Bool = false;
	public var pc:Int = 0x8000;	// program counter
	public var dma:Int = 0;

	var nmiQueued:Bool = false;
	var prevNmi:Bool = false;
	var sp:Int = 0xFD;			// stack pointer
	var accumulator:Int = 0;	// accumulator
	var x:Int = 0;				// x register
	var y:Int = 0;				// y register

	var cf:Bool = false;		// carry
	var zf:Bool = false;		// zero
	var id:Bool = true;			// interrupt disable
	var dm:Bool = false;		// decimal mode
	var bc:Bool = false;		// break command
	var of:Bool = false;		// overflow
	var nf:Bool = false;		// negative

	var ticks:Int = 0;

	public function new(ram:RAM)
	{
		this.ram = ram;
	}

	public function init(mapper:Mapper)
	{
		for (i in 0 ... 0x07FF)
		{
			write(i, 0xFF);
		}

		write(0x0008, 0xF7);
		write(0x0009, 0xEF);
		write(0x000A, 0xDF);
		write(0x000F, 0xBF);

		for (i in 0x4000 ...  0x400F)
		{
			ram.write(i, 0);
		}

		write(0x4015, 0);
		write(0x4017, 0);

		pc = (read(0xFFFC) | (read(0xFFFD) << 8));
	}

	public function reset()
	{
		pc = (read(0xFFFC) | (read(0xFFFD) << 8));
		write(0x4015, 0);
		write(0x4017, read(0x4017));
		id = true;
	}

	/**
	 * Run a single instruction.
	 */
	public function runCycle()
	{
		//read(0x4000);
		if (dma > 0 && --dma == 0)
		{
			// account for CPU cycles from DMA
			cycles += 513;
		}

		if (cycles-- > 0) return;

		var ad:Int, v:Int;
		var mode:AddressingMode;

		if (nmiQueued) {
			doNmi();
			nmiQueued = false;
		}
		if (nmi && !prevNmi)
		{
			nmiQueued = true;
		}
		prevNmi = nmi;

		var byte:Int = read(pc);
		var op:Command = Command.decodeByte(byte);
		var code:OpCode = Command.getCode(op);

		var value:Null<Int> = null;

#if debug
		Sys.print(StringTools.hex(pc,4)+" "+
			StringTools.rpad(OpCode.opCodeNames[code], " ", 6)+" "+
			StringTools.hex(byte,2));
#end
		++pc;
		pc &= 0xFFFF;

		// get base number of CPU cycles for this operation
		// (in some circumstances, this may increase during execution)
		ticks = Command.getTicks(op);

		// execute instruction
		switch (code)
		{
			case ORA:					// logical or
				mode = Command.getMode(op);
				ad = getAddress(mode);
				value = getValue(mode, ad);
				accumulator |= value;
				value = accumulator;

			case AND:					// logical and
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				accumulator &= v;
				value = accumulator;

			case EOR:					// exclusive or
				mode = Command.getMode(op);
				ad = getAddress(mode);
				value = getValue(mode, ad);
				accumulator = value ^ accumulator;
				value = accumulator;

			case ADC:					// add with carry
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				value = adc(v);

			case STA:					// store accumulator
				mode = Command.getMode(op);
				ad = getAddress(mode);
				write(ad, accumulator);

			case LDA:					// load accumulator
				mode = Command.getMode(op);
				ad = getAddress(mode);
				accumulator = getValue(mode, ad);
				zf = accumulator == 0;
				nf = accumulator & 0x80 == 0x80;

			case STX:					// store x
				mode = Command.getMode(op);
				ad = getAddress(mode);
				write(ad, x);

			case STY:					// store y
				mode = Command.getMode(op);
				ad = getAddress(mode);
				write(ad, y);

			case SEI, CLI:	  // set/clear interrupt disable
				id = code == OpCode.SEI;

			case SED, CLD:	  // set/clear decimal mode
				dm = code == OpCode.SED;

			case SEC, CLC:	  // set/clear carry
				cf = code == OpCode.SEC;

			case CLV:					// clear overflow
				of = false;

			case BIT:					// bit test
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				zf = accumulator & v == 0;
				of = v & 0x40 != 0;
				nf = v & 0x80 != 0;

			case CMP,
				CPX,
				CPY:					// compare [x/y]
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);

				var compare_to = switch (code)
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

			case SBC:					// subtract with carry
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				value = sbc(v);

			case JSR:					// jump to subroutine
				mode = Command.getMode(op);
				ad = getAddress(mode);
				pushStack(pc - 1 >> 8);
				pushStack((pc - 1) & 0xFF);
				pc = ad;

			case RTS:					// return from subroutine
				read(pc++);
				pc = (popStack() | (popStack() << 8)) + 1;

			case RTI:					// return from interrupt
				popStatus();
				pc = popStack() | (popStack() << 8);

			case ASL:					// arithmetic shift left
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				cf = v & 0x80 != 0;
				value = (v << 1) & 0xFF;
				storeValue(mode, ad, value);

			case LSR:					// logical shift right
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				cf = v & 1 != 0;
				value = v >> 1;
				storeValue(mode, ad, value);

			case ROL:					// rotate left
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				var new_cf = v & 0x80 != 0;
				value = (v << 1) & 0xFF;
				value += cf ? 1 : 0;
				cf = new_cf;
				storeValue(mode, ad, value);

			case ROR:					// rotate right
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				var new_cf = v & 1 != 0;
				value = (v >> 1) & 0xFF;
				value += cf ? 0x80 : 0;
				cf = new_cf;
				storeValue(mode, ad, value);

			case BCC,
					BCS,
					BEQ,
					BMI,
					BNE,
					BPL,
					BVC,
					BVS:					// branch
				var toCheck = switch(code)
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

				var checkAgainst = switch(code)
				{
					case BCS, BEQ, BMI, BVS:
						true;
					default:
						false;
				}

				mode = Command.getMode(op);
				var jumpTo = getAddress(mode);
				if (toCheck == checkAgainst)
				{
					ticks += 1;
					pc = jumpTo;
				}

			case JMP:					// jump
				mode = Command.getMode(op);
				ad = getAddress(mode);
				pc = ad;

			case LDX:					// load x
				mode = Command.getMode(op);
				ad = getAddress(mode);
				x = getValue(mode, ad);
				zf = x == 0;
				nf = x & 0x80 == 0x80;

			case LDY:					// load y
				mode = Command.getMode(op);
				ad = getAddress(mode);
				y = getValue(mode, ad);
				zf = y == 0;
				nf = y & 0x80 == 0x80;

			case PHA:					// push accumulator
				pushStack(accumulator);

			case PHP:					// push cpu status
				pushStatus();

			case PLP:					// pull cpu status
				popStatus();

			case PLA:					// pull accumulator
				accumulator = value = popStack();

			case INC:					// increment memory
				mode = Command.getMode(op);
				ad = getAddress(mode);
				value = (read(ad) + 1) & 0xFF;
				write(ad, value);

			case INX:					// increment x
				x += 1;
				x &= 0xFF;
				value = x;

			case INY:					// increment x
				y += 1;
				y &= 0xFF;
				value = y;

			case DEC:					// decrement memory
				mode = Command.getMode(op);
				ad = getAddress(mode);
				value = (read(ad) - 1) & 0xFF;
				write(ad, value);

			case DEX:					// decrement x
				x = (x-1) & 0xFF;
				value = x;

			case DEY:					// decrement y
				y = (y-1) & 0xFF;
				value = y;

			case TAX:					// transfer accumulator to x
				x = value = accumulator;

			case TAY:					// transfer accumulator to y
				y = value = accumulator;

			case TSX:					// transfer stack pointer to x
				x = value = sp;

			case TSY:					// transfer stack pointer to y
				y = value = sp;

			case TYA:					// transfer y to accumulator
				accumulator = value = y;

			case TXS:					// transfer x to stack pointer
				sp = x;

			case TXA:					// transfer x to accumulator
				accumulator = value = x;

			case NOP: {}					// no operation

			case IGN1:
				pc += 1;

			case IGN2:
				pc += 2;

			case LAX:					// LDX + TXA
				mode = Command.getMode(op);
				ad = getAddress(mode);
				x = getValue(mode, ad);
				accumulator = value = x;

			case SAX:					// store (x & accumulator)
				mode = Command.getMode(op);
				ad = getAddress(mode);
				write(ad, x & accumulator);

			case RLA:					// ROL then AND
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				value = (v << 1) & 0xFF;
				value += cf ? 1 : 0;

				write(ad, value);
				cf = v & 0x80 != 0;

				accumulator &= value;
				value = accumulator;

			case RRA:					// ROR then ADC
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				value = (v >> 1) & 0xFF;
				value += cf ? 0x80 : 0;

				write(ad, value);
				cf = v & 1 != 0;

				value = accumulator = adc(value);

			case SLO:					// ASL then ORA
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				cf = v & 0x80 != 0;
				v = (v << 1) & 0xFF;
				write(ad, v);
				accumulator |= v;
				value = accumulator;

			case SRE:					// LSR then EOR
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				cf = v & 1 != 0;
				value = v >> 1;
				write(ad, value);
				accumulator = value ^ accumulator;
				value = accumulator;

			case DCP:					// DEC then CMP
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad) - 1;
				v &= 0xFF;
				write(ad, v);

				var tmp = accumulator - v;
				if (tmp < 0) tmp += 0xFF + 1;

				cf = accumulator >= v;
				zf = accumulator == v;
				nf = tmp & 0x80 == 0x80;

			case ISC:					// INC then SBC
				mode = Command.getMode(op);
				ad = getAddress(mode);
				v = getValue(mode, ad);
				v = (v+1) & 0xFF;
				write(ad, v);
				value = sbc(v);

			case BRK:					// break
				breakInterrupt();

			default:
				throw "Instruction $" + StringTools.hex(byte,2) + " not implemented";
		}

		if (value != null)
		{
			zf = value == 0;
			nf = value & 0x80 == 0x80;
		}

#if (debug && !flash)
		Sys.print(dump_machine_state() + "\n");
#end

		cycles += ticks;
		pc &= 0xffff;
	}

	inline function getAddress(mode:AddressingMode):Int
	{
		var address:Int;
		switch(mode)
		{
			case ZeroPage, Immediate:
				address = read(pc++);

			case ZeroPageX, ZeroPageY:
				address = read(pc++);
				address += (mode==ZeroPageX) ? x : y;
				address &= 0xFF;

			case Relative:
				address = getSigned(read(pc++));
				address += pc;
				//address = (read(pc++) & 0xFF) + pc;
				// new page
				if ((address & 0xFF00) != (pc & 0xFF00)) ticks += 2;

			case Indirect:
				address = read(pc++) | (read(pc++) << 8);

				var next_addr = address + 1;
				if (next_addr & 0xFF == 0)
				{
					next_addr -= 0x0100;
				}

				address = (read(address) & 0xFF) | (read(next_addr) << 8);

			case IndirectX:
				address = read(pc++);
				address += x;
				address &= 0xFF;
				address = (read(address) & 0xFF) | (read((address+1) & 0xFF) << 8);

			case IndirectY:
				address = read(pc++);
				address = (read(address) & 0xFF) | (read((address+1) & 0xFF) << 8);

				// new page
				if (ticks == 5 && address>>8 != (address+y)>>8) ticks += 1;

				address += y;
				address &= 0xFFFF;

			case Absolute,
				 AbsoluteX,
				 AbsoluteY:

				address = read(pc++) | (read(pc++) << 8);

				if (mode==AddressingMode.AbsoluteX)
				{
					// new page
					if (ticks==4 && (address>>8 != (address+x)>>8)) ticks += 1;

					address += x;
				}
				else if (mode==AddressingMode.AbsoluteY)
				{
					// new page
					if (ticks==4 && (address>>8 != (address+y)>>8)) ticks += 1;

					address += y;
				}

				address &= 0xFFFF;

			case Accumulator:
				// not important; will use the value of the accumulator
				address = 0;

			default:
				throw "Unknown addressing mode: " + mode;
		}

		return address;
	}

	inline function getSigned(byte:Int)
	{
		byte &= 0xFF;

		return (byte & 0x80 != 0) ? -((~(byte - 1)) & 0xFF) : byte;
	}

	inline function getValue(mode:AddressingMode, addr:Int)
	{
		switch(mode)
		{
			case AddressingMode.Immediate: return addr & 0xFF;
			case AddressingMode.Accumulator: return accumulator;
			default:
				var r = read(addr);
				//trace(StringTools.hex(addr), StringTools.hex(r));
				return r;
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
		write(0x100 + (sp & 0xFF), value);
		sp--;
		sp &= 0xFF;
	}

	inline function popStack():Int
	{
		++sp;
		sp &= 0xFF;
		return read(0x100 + sp);
	}

	inline function pushStatus()
	{
		pushStack(statusFlag);
	}

	inline function popStatus()
	{
		statusFlag = popStack();
	}

	inline function storeValue(mode:AddressingMode, ad:Int, value:Int)
	{
		if (mode == AddressingMode.Accumulator)
		{
			accumulator = value;
		}
		else
		{
			write(ad, value);
		}
	}

	var statusFlag(get, set):Int;
	inline function get_statusFlag()
	{
		return (cf ? 0x1 : 0) |
			(zf ? 0x2 : 0) |
			(id ? 0x4 : 0) |
			(dm ? 0x8 : 0) |
			(0x10) | (0x20) |
			(of ? 0x40 : 0) |
			(nf ? 0x80 : 0);
	}
	inline function set_statusFlag(val:Int)
	{
		cf = val & 0x1 != 0;
		zf = val & 0x2 != 0;
		id = val & 0x4 != 0;
		dm = val & 0x8 != 0;
		bc = val & 0x10 != 0;
		of = val & 0x40 != 0;
		nf = val & 0x80 != 0;
		return val;
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

	public inline function read(addr:Int):Int
	{
		return ram.read(addr) & 0xFF;
	}

	public inline function write(addr:Int, data:Int):Void
	{
		ram.write(addr, data & 0xFF);
	}

	function doNmi()
	{
		pushStack(pc >> 8); // high bit 1st
		pushStack((pc) & 0xFF);// check that this pushes right address
		pushStack(statusFlag);
		pc = read(0xFFFA) | (read(0xFFFB) << 8);
		cycles += 7;
		id = true;
	}

	function doInterrupt()
	{
		pushStack(pc >> 8); // high bit 1st
		pushStack((pc) & 0xFF);// check that this pushes right address
		pushStack(statusFlag);
		pc = read(0xFFFE) | (read(0xFFFF) << 8);
		id = true;
	}

	function breakInterrupt()
	{
		//same as interrupt but BRK flag is turned on
		read(pc++); //dummy fetch
		pushStack(pc >> 8); // high bit 1st
		pushStack(pc & 0xFF);// check that this pushes right address
		pushStack(statusFlag | 0x20);
		pc = ram.read(0xFFFE) | (read(0xFFFF)  << 8);
		id = true;
	}
}
