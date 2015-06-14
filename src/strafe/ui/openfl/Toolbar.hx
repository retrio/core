package strafe.ui.openfl;

import flash.display.Sprite;
import flash.display.InteractiveObject;


class Toolbar extends Sprite
{
	public function new()
	{
		super();
	}

	public function addButton(btn:InteractiveObject)
	{
		btn.x = numChildren * btn.width;

		addChild(btn);

		width = numChildren * btn.width;
		height = btn.height;
	}
}
