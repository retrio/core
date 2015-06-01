package xgame;

import haxe.io.Input;


interface IEmulator<G, C:IController>
{
	public function loadGame(gameData:FileWrapper):Void;
	public function startGame(game:G):Void;

	public function saveState(slot:SaveSlot):Void;
	public function loadState(slot:SaveSlot):Void;

	public function reset():Void;

	public function addController(c:C, ?port:Int=null):Null<Int>;
}
