package retrio.ui.openfl;

import haxe.Serializer;
import flash.display.BitmapData;
import flash.display.Sprite;


class EmulatorPlugin extends Sprite
{
	public var running:Bool = false;
	public var initialized:Bool = false;
	public var emu:IEmulator;
	public var frameSkip:Int = 0;
	public var extensions:Array<String>;

	// this is an abstract class
	function new()
	{
		super();

		mouseEnabled = mouseChildren = false;
	}

	public function frame() {}
	public function resize(width:Int, height:Int) {}

	public function loadGame(gameData:FileWrapper) emu.loadGame(gameData);
	public function start()
	{
		running = true;
	}
	public function pause() running = false;
	public function reset() emu.reset();

	public function close()
	{
		deactivate();
		running = initialized = false;
	}

	public function activate() {}
	public function deactivate() {}

	public function saveState():String
	{
		return Serializer.run(emu);
	}
	public function loadState(state:IEmulator)
	{
		emu = state;
	}

	public function capture():Null<BitmapData> return null;
}
