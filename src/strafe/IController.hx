package strafe;


interface IController
{
	public function init(e:Dynamic):Void;
	public function remove(e:Dynamic):Void;
	public function pressed(e:Dynamic):Bool;
}
