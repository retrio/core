package strafe;

import haxe.io.Input;


interface IEmulator
{
	public var buffer:ByteString;
	public var extensions:Array<String>;
	public var width:Int;
	public var height:Int;

	// load a game and start emulation
	public function loadGame(gameData:FileWrapper):Void;

	// reset the currently running game
	public function reset():Void;

	// add a new controller to a specific port or the first empty port
	public function addController(c:IController, ?port:Int=null):Null<Int>;

	// called once per frame
	public function frame():Void;

	public function getColor(c:Int):Int;
}
