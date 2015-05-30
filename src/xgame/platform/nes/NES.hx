package xgame.platform.nes;

import haxe.io.Input;
import xgame.FileWrapper;
import xgame.platform.nes.CPU;
import xgame.platform.nes.PPU;
import xgame.platform.nes.ROM;


class NES implements IEmulator<ROM>
{
	// hardware components
	public var rom:ROM;
	public var ram:RAM;
	public var cpu:CPU;
	public var ppu:PPU;
	public var apu:APU;
	public var mapper:Mapper;

	var ntsc:Bool=true;

	public function new() {}

	public function loadGame(gameData:FileWrapper)
	{
		ram = new RAM();

		rom = new ROM(gameData, ram);
		mapper = rom.mapper;

		cpu = new CPU(ram);
		ppu = new PPU(mapper, cpu);
		apu = new APU();

		ram.init(mapper, ppu, apu);
		mapper.init(ppu, rom, ram);
		cpu.init(mapper, ppu, apu);
	}

	public function frame()
	{
		for (i in 0 ... 262)
		{
			runLine(i);
		}
	}

	public function runLine(line:Int)
	{
		ppu.clockLine(line);
	}

	static inline var cyclesPerSecond:Int=1790000;

	public function startGame(game:ROM):Void {}

	public function saveState(slot:SaveSlot):Void {}
	public function loadState(slot:SaveSlot):Void {}

	public function reset():Void {}
}
