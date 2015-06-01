package xgame.platform.nes;

import haxe.ds.Vector;
import haxe.io.Input;
import xgame.FileWrapper;
import xgame.IController;
import xgame.platform.nes.CPU;
import xgame.platform.nes.PPU;
import xgame.platform.nes.ROM;


class NES implements IEmulator<ROM, NESController>
{
	// hardware components
	public var rom:ROM;
	public var ram:RAM;
	public var cpu:CPU;
	public var ppu:PPU;
	public var apu:APU;
	public var mapper:Mapper;
	public var controllers:Vector<NESController> = new Vector(2);

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

		ram.init(mapper, ppu, apu, controllers);
		mapper.init(ppu, rom, ram);
		cpu.init(mapper);
	}

	public function frame()
	{
		ppu.runFrame();
	}

	static inline var cyclesPerSecond:Int=1790000;

	public function startGame(game:ROM):Void {}

	public function saveState(slot:SaveSlot):Void {}
	public function loadState(slot:SaveSlot):Void {}

	public function reset():Void
	{
		cpu.reset();
	}

	public function addController(controller:NESController, ?port:Int=null):Null<Int>
	{
		if (port == null)
		{
			for (i in 0 ... controllers.length)
			{
				if (controllers[i] == null)
				{
					port = i;
					break;
				}
			}
			if (port == null) return null;
		}
		else
		{
			if (controllers[port] != null) return null;
		}

		controllers[port] = controller;
		controller.init(this);
		return port;
	}
}
