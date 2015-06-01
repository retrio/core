package xgame.platform.nes;

import haxe.ds.Vector;
import haxe.io.Input;
import xgame.FileWrapper;


class ROM
{
	public var mapper:Mapper;
	public var mirror:MirrorMode;

	public var prgRom:Vector<Int>;
	public var prgRam:Vector<Int>;
	public var chr:Vector<Int>;				// ROM or RAM

	public var prgSize:Int=0;				// size of PRG ROM (# of 0x4000 blocks)
	public var chrSize:Int=0;				// size of CHR ROM (# of 0x2000 blocks)
	public var hasPrgRam:Bool=true;

	public var prgMap:Vector<Int>;
	public var chrMap:Vector<Int>;

	public var chrRam:Bool = false;

	var mapperNumber:Int=0;

	public function new(file:FileWrapper, ram:RAM)
	{
		var pos = 0;

		// check for "NES" at beginning of header
		var firstWord = file.readString(3);
		if (firstWord != "NES" || file.readByte() != 0x1A)
		{
			throw "Not in iNES format";
		}
		prgSize = file.readByte() * 0x4000;
		if (prgSize == 0)
			throw "No PRG ROM size in header";
		chrSize = file.readByte() * 0x2000;
		var f6 = file.readByte();
		var f7 = file.readByte();

		var fourScreenMirror = Util.getbit(f6, 3);
		var verticalMirror = Util.getbit(f6, 0);
		mirror = fourScreenMirror ? FOUR_SCREEN_MIRROR
			: verticalMirror ? V_MIRROR : H_MIRROR;

		//prgRamSize = file.readByte() * 0x2000;

		prgRom = new Vector(prgSize);
		prgRam = new Vector(0x2000);
		for (i in 0 ... prgRam.length) prgRam[i] = 0;

		mapperNumber = (f6 & 0xF0 >> 4) + f7 & 0xF0;
		mapper = Mapper.getMapper(mapperNumber);

		for (i in 0...8) file.readByte();

		for (i in 0 ... prgSize)
		{
			prgRom[i] = file.readByte();
		}
		if (chrSize > 0)
		{
			chr = new Vector(chrSize);
			for (i in 0 ... chrSize)
			{
				chr[i] = file.readByte();
			}
		}
		else
		{
			chrRam = true;
			chrSize = 0x2000;
			chr = new Vector(chrSize);
			for (i in 0 ... chrSize) chr[i] = 0;
		}

		prgMap = new Vector(32);
		for (i in 0 ... 32)
		{
			prgMap[i] = (0x400 * i) & (prgSize - 1);
		}
		chrMap = new Vector(8);
		for (i in 0 ... 8)
		{
			chrMap[i] = (0x400 * i) & (chrSize - 1);
		}
	}

	public inline function getPrgByte(bank:Int, address:Int):Int
	{
		return prgRom[bank*0x4000 + address];
	}

	public inline function getChrByte(bank:Int, address:Int):Int
	{
		return chr[bank*0x2000 + address];
	}
}
