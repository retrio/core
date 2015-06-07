package strafe.emu.nes;

import haxe.ds.Vector;


class RAM
{
	public var wram:Vector<Int>;
	public var mapper:Mapper;
	public var ppu:PPU;
	public var apu:APU;
	public var controllers:Vector<NESController>;

	public var dmaCounter:Int = 0;

	public function new() {}

	public function init(mapper:Mapper, ppu:PPU, apu:APU, controllers:Vector<NESController>)
	{
		wram = new Vector(0x800);
		for (i in 0 ... wram.length) wram.set(i, 0xff);
		this.mapper = mapper;
		this.ppu = ppu;
		this.apu = apu;
		this.controllers = controllers;
	}

	public inline function read(addr:Int):Int
	{
		if (addr < 0x2000)
		{
			// RAM
			return wram[addr & 0x7ff];
		}
		else if (addr > 0x4018)
		{
			// cartridge space
			return mapper.read(addr);
		}
		else if (addr < 0x4000)
		{
			// ppu, mirrored 7 bytes of io registers
			return ppu.read(addr & 7);
		}
		else if (addr == 0x4016 || addr == 0x4017)
		{
			// controller read
			var port = addr - 0x4016;
			return controllers[port] == null ? 0 : controllers[port].pop();
		}
		else if (addr >= 0x4000 && addr <= 4018)
		{
			// APU registers
			return apu.read(addr - 0x4000);
		}
		else
		{
			return addr >> 8;
		}
	}

	public inline function write(addr:Int, data:Int)
	{
		if (addr < 0x2000)
		{
			// write to RAM (mirrored)
			wram[addr & 0x7ff] = data;
		}
		else if (addr > 0x4018)
		{
			// cartridge space
			mapper.write(addr, data);
		}
		else if (addr < 0x4000)
		{
			// ppu, mirrored 7 bytes of io registers
			ppu.write(addr & 7, data);
		}
		else if (addr == 0x4014)
		{
			// sprite DMA
			dma(data);
		}
		else if (addr == 0x4016)
		{
			// controller latch
			for (controller in controllers)
				if (controller != null) controller.latch();
		}
		else if (addr >= 0x4000 && addr <= 4018)
		{
			apu.write(addr - 0x4000, data);
		}
	}

	inline function dma(data)
	{
		var start = (data << 8);
		var i = start;
		while (i < start + 256)
		{
			// shortcut, written to 0x2004
			ppu.write(4, read(i++));
		}
		dmaCounter = 2;
	}

	public function writeState(out:haxe.io.Output)
	{
		// TODO
	}
}
