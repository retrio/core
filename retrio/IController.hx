package retrio;


interface IController
{
	public function add():Void;
	public function remove():Void;
	public function pressed(button:Int):Bool;

	public function define(code:Int, button:Int):Void;
	public function clearDefinition(button:Int):Void;
	public function getDefinitions():Map<Int, Int>;

	public function ask(callback:Null<Int->Void>):Void;
	public function codeName(code:Int):String;
	public function codeForButton(button:Int):Null<Int>;

	public dynamic function inputHandler(e:Dynamic):Void;
}
