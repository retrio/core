package retrio.ui.openfl;

import flash.display.Sprite;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;


class Toolbar extends Sprite
{
	public function new()
	{
		super();

		mouseEnabled = mouseChildren = true;
		useHandCursor = true;

#if flash
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.CLICK, onClick);
#end
	}

	public function addButton(btn:InteractiveObject)
	{
		btn.x = (numChildren/2) * btn.width;

		//width = (numChildren/2) * btn.width;
		//height = btn.height;

		addChildAt(btn, 0);

		var hint = cast(btn, IButton).hint;
		hint.x = Std.int(Math.max(x + btn.x + btn.width/2 - hint.width/2, 0));
		hint.y = Std.int(-hint.height/2);
		addChild(hint);
	}

	public function onClick(e:Dynamic)
	{
		//trace("click", e.target, e.currentTarget);
		if (Std.is(e.target, IButton))
		{
			cast(e.target, IButton).onClick(e);
		}
		e.stopPropagation();
	}

	public function onMouseOver(e:Dynamic)
	{
		//trace("over", e.target, e.currentTarget);
		if (Std.is(e.target, IButton))
		{
			cast(e.target, IButton).onMouseOver(e);
		}
		e.stopPropagation();
	}

	public function onMouseOut(e:Dynamic)
	{
		//trace("out", e.target, e.currentTarget);
		if (Std.is(e.target, IButton))
		{
			cast(e.target, IButton).onMouseOut(e);
		}
		e.stopPropagation();
	}

	public function onMouseDown(e:Dynamic)
	{
		//trace("down", e.target, e.currentTarget);
		if (Std.is(e.target, IButton))
		{
			cast(e.target, IButton).onMouseDown(e);
		}
		e.stopPropagation();
	}
}
