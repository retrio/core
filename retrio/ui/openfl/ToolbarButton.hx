package retrio.ui.openfl;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;


class ToolbarButton extends Sprite implements IButton
{
	public var hint:TextField;

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

		hint = new ButtonHint(btn.tooltip);

#if !flash
		addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		addEventListener(MouseEvent.MOUSE_UP, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.CLICK, onClick);
#end
	}

	public function onClick(e:Dynamic)
	{
		btn.onClick();
	}

	public function onMouseOver(e:Dynamic)
	{
		bmp.bitmapData = btn.getImage(true);
		hint.visible = true;
	}

	public function onMouseOut(e:Dynamic)
	{
		bmp.bitmapData = btn.getImage();
		hint.visible = false;
	}

	public function onMouseDown(e:Dynamic)
	{
		bmp.bitmapData = btn.getImage(false, true);
	}
}
