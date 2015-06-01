package xgame.platform.nes.ui.openfl;

import flash.utils.Timer;
import flash.Lib;
import flash.Memory;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.utils.ByteArray;
import flash.utils.Endian;
import xgame.platform.nes.Palette;


class GUI extends Sprite
{
	static var r:Rectangle = new Rectangle(0, 0, 256, 240);

	var _stage(get, never):flash.display.Stage;
	inline function get__stage() return Lib.current.stage;

	var nes:NES;
	var fps:Int;
	var bmp:Bitmap;
	var canvas:BitmapData;
	var bmpData:BitmapData;
	var _m:Matrix;
	var _pixels:ByteArray = new ByteArray();
	var _draw:Float = 0;

	public function new(nes:NES, fps:Int=60)
	{
		super();
		this.nes = nes;
		this.fps = fps;

		_stage.quality = flash.display.StageQuality.LOW;
		bmpData = new BitmapData(256, 240);
		initScreen();

		if (_stage != null) onStage(null);
		else Lib.current.addEventListener(Event.ADDED_TO_STAGE, onStage);

		_pixels.endian = Endian.BIG_ENDIAN;
		_pixels.clear();
		for (i in 0 ... 256*240*4)
			_pixels.writeByte(0);

		Memory.select(_pixels);
	}

	function initScreen()
	{
		canvas = new BitmapData(_stage.stageWidth, _stage.stageHeight);
		bmp = new Bitmap(canvas);
		addChild(bmp);

		_m = new Matrix();
		_m.scale(canvas.width / 256, canvas.height / 240);
	}

	function onStage(e:Event)
	{
		if (e != null) Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onStage);

		_stage.addChild(this);
		_stage.addEventListener(Event.RESIZE, onResize);
		_stage.addEventListener(Event.ENTER_FRAME, update);
	}

	public function onResize(e:Event)
	{
		removeChild(bmp);
		canvas.dispose();
		bmp = null;
		canvas = null;

		initScreen();
	}

	public function update(e:Dynamic)
	{
#if perflog
		var startTime = haxe.Timer.stamp();
#end
		nes.frame();

#if perflog
		var finishTime = haxe.Timer.stamp();
		trace("FRAME TIME: " + (finishTime - startTime));
		startTime = haxe.Timer.stamp();
#end

		_draw += (fps / 60);
		if (_draw >= 1)
		{
			--_draw;
			var bm = nes.ppu.bitmap;
			for (i in 0 ... 256 * 240)
			{
				//_pixels.writeInt();
				Memory.setI32(i*4, Palette.getColor(bm[i]));
				/*var color = Palette.getColor(bm[i]);
				Memory.setByte(i*4, 0xFF);
				Memory.setByte(i*4+1, (color & 0xFF0000) >> 16);
				Memory.setByte(i*4+2, (color & 0xFF00) >> 8);
				Memory.setByte(i*4+3, (color & 0xFF));*/
			}

			_pixels.position = 0;
			bmpData.setPixels(bmpData.rect, _pixels);
			canvas.draw(bmpData, _m);
		}
#if perflog
		finishTime = haxe.Timer.stamp();
		trace("RENDER TIME: " + (finishTime - startTime));
#end
	}
}
