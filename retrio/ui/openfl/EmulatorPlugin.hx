package retrio.ui.openfl;

import haxe.Serializer;
import flash.display.BitmapData;
import flash.display.Sprite;


class EmulatorPlugin extends Sprite
{
	public var running:Bool = false;
	public var initialized:Bool = false;
	public var active:Bool = false;
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
		activate();
	}
	public function pause()
	{
		running = false;
		deactivate();
	}
	public function reset()
	{
		emu.reset();
	}

	public function close()
	{
		deactivate();
		running = initialized = false;
	}

	public function activate()
	{
		active = true;
	}

	public function deactivate()
	{
		active = false;
	}

	public function saveState():String
	{
		return Serializer.run(emu);
	}

	public function loadState(state:IEmulator)
	{
		emu = state;
	}

	public function capture():Null<BitmapData> return null;

	public function getSamples(e:Dynamic)
	{
		// fill with empty data
		var data = e.data;
		for (i in 0 ... 2048)
		{
			data.writeFloat(0);
			data.writeFloat(0);
		}
	}
}
