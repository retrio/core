package strafe.ui.openfl;

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

	public inline function loadGame(gameData:FileWrapper) emu.loadGame(gameData);
	public inline function start()
	{
		running = true;
	}
	public inline function pause() running = false;
	public inline function reset() emu.reset();
	public inline function addController(c:IController, ?port:Int=null) return emu.addController(c, port);

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
