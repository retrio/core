package strafe.ui.openfl;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import openfl.Assets;


class ToggleButton extends Sprite
{
	var btns:Array<Button>;

	var bmp:Bitmap;
	var mode(default, set):Int = 0;
	function set_mode(m:Int)
	{
		bmp.bitmapData = btns[m].getImage(hover, click);
		return mode = m;
	}
	var modeFunction:Void->Int;

	var hover:Bool = false;
	var click:Bool = false;

	function new(defs:Array<ButtonDef>, modeFunction:Void->Int)
	{
		super();

		btns = new Array();
		for (def in defs)
		{
			btns.push(new Button(def));
		}

		var img = btns[0].getImage();
		addChild(bmp = new Bitmap(img));

		width = img.width;
		height = img.height;

		this.modeFunction = modeFunction;

		this.addEventListener(Event.ENTER_FRAME, update);
		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseOver);
		this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		this.addEventListener(MouseEvent.CLICK, onClick);
	}

	function update(e:Dynamic)
	{
		mode = modeFunction();
	}

	function onClick(e:Dynamic)
	{
		btns[mode].onClick();
	}

	function onMouseOver(e:Dynamic)
	{
		// TODO: show tooltip
		hover = true;
		click = false;
		mode = mode;
	}

	function onMouseOut(e:Dynamic)
	{
		// TODO: hide tooltip
		hover = false;
		click = false;
		mode = mode;
	}

	function onMouseDown(e:Dynamic)
	{
		hover = true;
		click = true;
		mode = mode;
	}
}
