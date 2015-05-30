package xgame.platform.nes;

import haxe.ds.Vector;


class RAM
{
	public var wram:Vector<Int>;
	public var mapper:Mapper;
	public var ppu:PPU;
	public var apu:APU;

	public function new() {}

	public function init(mapper:Mapper, ppu:PPU, apu:APU)
	{
		wram = new Vector(0x800);
		for (i in 0 ... wram.length) wram.set(i, 0xFF);
		this.mapper = mapper;
		this.ppu = ppu;
		this.apu = apu;
	}

	public inline function read(addr:Int):Int
	{
		if (addr > 0x4018)
		{
			// cartridge space
			return mapper.read(addr);
		}
		else if (addr < 0x2000)
		{
			// RAM
			return wram[addr & 0x7FF];
		}
		else if (addr < 0x4000)
		{
			// ppu, mirrored 7 bytes of io registers
			return ppu.read(addr & 7);
		}
		else if (addr == 0x4016 || addr == 0x4017)
		{
			// controller read
			//var controller = addr == 0x4016 ? null : null;
			//controller.strobe();
			return 0 | 0x40;
		}
		else if (addr >= 0x4000 && addr <= 4018)
		{
			// APU/IO registers
			return apu.read(addr - 0x4000);
		}
		else
		{
			return addr >> 8;
		}
	}

	public inline function write(addr:Int, data:Int)
	{
		if (addr > 0x4018)
		{
			/*if (data < 127 && data >= 32)
			{
				trace(StringTools.hex(addr, 4) + ": " + String.fromCharCode(data));
			}*/
			// cartridge space
			mapper.write(addr, data);
		}
		else if (addr < 0x2000)
		{
			// write to RAM (mirrored)
			wram[addr & 0x7FF] = data;
			//if (addr & 0x07FF < 0x0300 && addr & 0x07FF > 0x0200)
			//	trace("WRITE", StringTools.hex(addr, 4), data);
		}
		else if (addr == 0x4014)
		{
			// sprite DMA
			dma(data);
		}
		else if (addr < 0x4000)
		{
			// ppu, mirrored 7 bytes of io registers
			ppu.write(addr & 7, data);
		}
		else if (addr == 0x4016)
		{
			// controller latch
		}
		else if (addr >= 0x4000 && addr <= 4018)
		{
			apu.write(addr - 0x4000, data);
		}
	}

	inline function dma(data)
	{
		var start = (data << 8);
		//trace("DMA:", StringTools.hex(start, 4));
		var i = start;
		while (i < start + 256)
		{
			// shortcut, written to 0x2004
			//trace(StringTools.hex(i, 4), read(i));
			ppu.write(4, read(i));
			++i;
		}
	}
}
