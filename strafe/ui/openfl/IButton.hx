package strafe.ui.openfl;

import flash.text.TextField;


interface IButton
{
	public var hint:TextField;

	public function onClick(e:Dynamic):Void;
	public function onMouseOver(e:Dynamic):Void;
	public function onMouseOut(e:Dynamic):Void;
	public function onMouseDown(e:Dynamic):Void;
}
