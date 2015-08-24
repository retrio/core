package retrio;

import haxe.io.Input;
import haxe.ds.Vector;
import retrio.io.FileWrapper;
import retrio.io.IEnvironment;
import retrio.io.IScreenBuffer;


interface IEmulator
{
	// interface to provide file loading/saving capabilities
	public var io:IEnvironment;
	public var screenBuffer(default, set):IScreenBuffer;

	public var extensions:Array<String>;
	public var width:Int;
	public var height:Int;
	public var maxControllers:Int;

	// load a game and start emulation
	public function loadGame(gameData:FileWrapper, ?loadSram:Bool=true):Void;

	// persistent save states
	public function savePersistentState(slot:SaveSlot):Void;
	public function loadPersistentState(slot:SaveSlot):Void;

	// reset the currently running game
	public function reset():Void;

	// add/remove input devices
	public function addController(c:IController, port:Int):Void;
	public function removeController(port:Int):Void;

	// called once per frame
	public function frame(rate:Float):Void;
}
