package retrio.ui.openfl;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import openfl.Assets;


class ToggleButton extends Sprite implements IButton
{
	public var hint:TextField;

	var btns:Array<Button>;

	var bmp:Bitmap;
	var mode(default, set):Int = 0;
	function set_mode(m:Int)
	{
		bmp.bitmapData = btns[m].getImage(hover, click);
		hint.text = btns[m].tooltip;
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

		hint = new ButtonHint(btns[0].tooltip);

		this.modeFunction = modeFunction;

		this.addEventListener(Event.ENTER_FRAME, update);
#if !flash
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.CLICK, onClick);
#end
	}

	function update(e:Dynamic)
	{
		mode = modeFunction();
	}

	public function onClick(e:Dynamic)
	{
		btns[mode].onClick();
	}

	public function onMouseOver(e:Dynamic)
	{
		// TODO: show tooltip
		hover = true;
		click = false;
		mode = mode;

		hint.visible = true;
	}

	public function onMouseOut(e:Dynamic)
	{
		// TODO: hide tooltip
		hover = false;
		click = false;
		mode = mode;

		hint.visible = false;
	}

	public function onMouseDown(e:Dynamic)
	{
		hover = true;
		click = true;
		mode = mode;
	}
}
