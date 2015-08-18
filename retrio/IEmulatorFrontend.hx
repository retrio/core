package retrio;

import haxe.ds.Vector;
import retrio.config.ISettingsHandler;
import retrio.io.FileWrapper;


interface IEmulatorFrontend extends ISettingsHandler
{
	public var emu:IEmulator;
	public var controllers:Vector<IController>;

	public function frame():Void;
	public function resize(width:Int, height:Int):Void;
	public function loadGame(gameData:FileWrapper):Void;

	public function addController(c:IController, port:Int):Void;
	public function removeController(port:Int):Void;
}
