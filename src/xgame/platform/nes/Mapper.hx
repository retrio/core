package xgame.platform.nes;
import xgame.platform.nes.mappers.*;

import haxe.ds.Vector;


class Mapper
{
	public var rom:ROM;
	public var ram:RAM;
	public var ppu:PPU;

	// nametable pointers
	public var nt0:Vector<Int>;
	public var nt1:Vector<Int>;
	public var nt2:Vector<Int>;
	public var nt3:Vector<Int>;

	public var mirror(default, set):MirrorMode;
	function set_mirror(m:MirrorMode)
	{
		switch(m)
		{
			case H_MIRROR:
				nt0 = ppu.t0;
				nt1 = ppu.t0;
				nt2 = ppu.t1;
				nt3 = ppu.t1;
				//trace("h");

			case V_MIRROR:
				nt0 = ppu.t0;
				nt1 = ppu.t1;
				nt2 = ppu.t0;
				nt3 = ppu.t1;
				//trace("v");

			case SS_MIRROR0:
				nt0 = ppu.t0;
				nt1 = ppu.t0;
				nt2 = ppu.t0;
				nt3 = ppu.t0;
				//trace("ss0");

			case SS_MIRROR1:
				nt0 = ppu.t1;
				nt1 = ppu.t1;
				nt2 = ppu.t1;
				nt3 = ppu.t1;
				//trace("ss1");

			case FOUR_SCREEN_MIRROR:
				nt0 = ppu.t0;
				nt1 = ppu.t1;
				nt2 = ppu.t2;
				nt3 = ppu.t3;
				//trace("4s");
		}
		return mirror = m;
	}

	// this is an abstract class
	function new()
	{

	}

	public static function getMapper(mapperNumber:Int):Mapper
	{
		return switch (mapperNumber)
		{
			case 0: new NromMapper();
			default: throw ("Mapper " + mapperNumber + " is not implemented yet.");
		}
	}

	public function init(ppu:PPU, rom:ROM, ram:RAM)
	{
		this.ppu = ppu;
		this.rom = rom;
		this.ram = ram;

		mirror = rom.mirror;
	}

	public function read(addr:Int)
	{
		if (addr >= 0x8000)
		{
			return rom.prgRom[rom.prgMap[((addr & 0x7fff)) >> 10] + (addr & 0x3ff)];
		}
		else if (addr >= 0x6000 && rom.hasPrgRam)
		{
			return rom.prgRam[addr & 0x1fff];
		}
		else return addr >> 8;
	}

	public function write(addr:Int, data:Int)
	{
		if (addr >= 0x6000 && addr < 0x8000)
		{
			rom.prgRam[addr & 0x1fff] = data;
		}
	}

	var _readResult:Int;
	public inline function ppuRead(addr:Int)
	{
		if (addr < 0x2000)
		{
			_readResult = rom.chr[rom.chrMap[addr >> 10] + (addr & 1023)];
		}
		else
		{
			switch (addr & 0xc00)
			{
				case 0:
					_readResult = nt0[addr & 0x3ff];

				case 0x400:
					_readResult = nt1[addr & 0x3ff];

				case 0x800:
					_readResult = nt2[addr & 0x3ff];

				default:
					if (addr >= 0x3f00)
					{
						addr &= 0x1f;
						if (addr >= 0x10 && ((addr & 3) == 0))
						{
							addr -= 0x10;
						}
						_readResult = ppu.pal[addr];
					}
					else
					{
						_readResult = nt3[addr & 0x3ff];
					}
			}
		}
		return _readResult;
	}

	public inline function ppuWrite(addr:Int, data:Int)
	{
		if (addr < 0x2000)
		{
			rom.chr[rom.chrMap[addr >> 10] + (addr & 1023)] = data;
		}
		else
		{
			switch (addr & 0xc00)
			{
				case 0x0:
					nt0[addr & 0x3ff] = data;

				case 0x400:
					nt1[addr & 0x3ff] = data;

				case 0x800:
					nt2[addr & 0x3ff] = data;

				default:
					if (addr >= 0x3f00 && addr < 0x4000)
					{
						addr &= 0x1f;
						if (addr >= 0x10 && ((addr & 3) == 0))
						{
							// mirrors
							addr -= 0x10;
						}
						ppu.pal[addr] = (data & 0x3f);
					}
					else
					{
						nt3[addr & 0x3ff] = data;
					}
			}
		}
	}

	public function onLoad() {}
	public function onReset() {}
	public function onCpuCycle(cycles:Int) {}
	public function onScanline(scanline:Int) {}
}
