package retrio.ui.openfl;

import flash.display.Bitmap;
import flash.display.BitmapData;
import openfl.Assets;


class Button
{
	public var tooltip:String;

	var img:BitmapData;
	var imgHover:BitmapData;
	var imgClick:BitmapData;

	var clickHandler:Void->Void;

	public function new(def:ButtonDef)
	{
		img = Assets.getBitmapData("graphics/" + def.img + ".png");
		this.tooltip = def.tooltip;
		this.clickHandler = def.clickHandler;

		var hoverImg = "graphics/" + def.img + "-hover.png";
		if (Assets.exists(hoverImg, AssetType.IMAGE))
		{
			imgHover = Assets.getBitmapData(hoverImg);
		}

		var clickImg = "graphics/" + def.img + "-click.png";
		if (Assets.exists(clickImg, AssetType.IMAGE))
		{
			imgClick = Assets.getBitmapData(clickImg);
		}
	}

	public function getImage(?hover:Bool=false, ?click:Bool=false):BitmapData
	{
		if (click) return imgClick == null ? img : imgClick;
		else if (hover) return imgHover == null ? img : imgHover;
		else return img;
	}

	public function onClick()
	{
		if (clickHandler != null)
			clickHandler();
	}
}
