package xgame.platform.nes.ui;

import flash.utils.Timer;
import flash.Lib;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import xgame.platform.nes.NesColors;


class OpenFLUI extends Sprite
{
	static var r:Rectangle = new Rectangle(256, 240);

	var nes:NES;
	var bmp:Bitmap;
	var canvas:BitmapData;
	var bmpData:BitmapData;
	var _m:Matrix;

	public function new(nes:NES)
	{
		super();
		this.nes = nes;

		bmpData = new BitmapData(256, 240);
		canvas = new BitmapData(512, 480);
		bmp = new Bitmap(canvas);
		addChild(bmp);

		if (Lib.current.stage != null) onStage();
		else Lib.current.addEventListener(Event.ADDED_TO_STAGE, onStage);

		_m = new Matrix();
		_m.scale(2, 2);
	}

	public function onStage(e:Event=null)
	{
		if (e != null) Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onStage);
		Lib.current.stage.addChild(this);

		var timer = new Timer(1000/60);
		timer.addEventListener(TimerEvent.TIMER, update);
		timer.start();
	}

	public function update(e:Dynamic)
	{
		nes.frame();
#if ppudebug
		trace(nes.ppu.bitmap);
#end
		var bm = nes.ppu.bitmap;
		var w = Std.int(bmpData.width), h = Std.int(bmpData.height);
		//var vals:Map<Int, Int> = new Map();
		for (y in 0 ... h)
		{
			for (x in 0 ... w)
			{
				var c = bm[y*h + x];
				bmpData.setPixel(x, y, NesColors.colors[(c & 0x1c0) >> 6][c & 0x3f]);
				//if (!vals.exists(c)) vals[c] = 0;
				//vals[c] += 1;
			}
		}
		canvas.draw(bmpData, _m);
		//trace(vals);
		//bmpData.setVector(r, nes.ppu.bitmap.toArray());
	}
}
