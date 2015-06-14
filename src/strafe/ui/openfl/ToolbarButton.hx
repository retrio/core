package strafe.ui.openfl;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;


class ToolbarButton extends Sprite
{
	var bmp:Bitmap;
	var btn:Button;

	public function new(def:ButtonDef)
	{
		super();

		btn = new Button(def);
		var img = btn.getImage();

		addChild(bmp = new Bitmap(img));
		width = img.width;
		height = img.height;

		this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		this.addEventListener(MouseEvent.MOUSE_UP, onMouseOver);
		this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		this.addEventListener(MouseEvent.CLICK, onClick);
	}

	function onClick(e:Dynamic)
	{
		btn.onClick();
	}

	function onMouseOver(e:Dynamic)
	{
		// TODO: show tooltip
		bmp.bitmapData = btn.getImage(true);
	}

	function onMouseOut(e:Dynamic)
	{
		// TODO: hide tooltip
		bmp.bitmapData = btn.getImage();
	}

	function onMouseDown(e:Dynamic)
	{
		bmp.bitmapData = btn.getImage(false, true);
	}
}
