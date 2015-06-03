package strafe.ui.openfl.nes;

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
import strafe.emu.nes.NES;
import strafe.emu.nes.Palette;


class NESPlugin extends EmulatorPlugin
{
	static var r:Rectangle = new Rectangle(0, 0, 256, 240);

	var _stage(get, never):flash.display.Stage;
	inline function get__stage() return Lib.current.stage;

	var nes:NES;

	var bmp:Bitmap;
	var canvas:BitmapData;
	var bmpData:BitmapData;
	var m:Matrix;
	var pixels:ByteArray = new ByteArray();
	var frameCount = 0;

	public function new()
	{
		super();
		this.emu = this.nes = new NES();

		_stage.quality = flash.display.StageQuality.LOW;
		bmpData = new BitmapData(256, 240);

		pixels.endian = Endian.BIG_ENDIAN;
		pixels.clear();
		for (i in 0 ... 256*240*4)
			pixels.writeByte(0);

		Memory.select(pixels);
	}

	override public function resize(width:Int, height:Int)
	{
		if (bmp != null)
		{
			removeChild(bmp);
			canvas.dispose();
			bmp = null;
			canvas = null;
		}

		initScreen(width, height);
	}

	override public function frame()
	{
		if (!running) return;

#if perflog
		var startTime = haxe.Timer.stamp();
#end
		nes.frame(frameCount == 0);

#if perflog
		var finishTime = haxe.Timer.stamp();
		trace("FRAME TIME: " + (finishTime - startTime));
		startTime = haxe.Timer.stamp();
#end

		if (frameSkip > 0)
		{
			var skip = frameCount > 0;
			frameCount = (frameCount + 1) % (frameSkip + 1);
			if (skip) return;
		}

		var bm = nes.ppu.bitmap;
		for (i in 0 ... 256 * 240)
		{
			Memory.setI32(i*4, Palette.getColor(bm[i]));
		}

		pixels.position = 0;
		bmpData.setPixels(bmpData.rect, pixels);
		canvas.draw(bmpData, m);
#if perflog
		finishTime = haxe.Timer.stamp();
		trace("RENDER TIME: " + (finishTime - startTime));
#end
	}

	function initScreen(width:Int, height:Int)
	{
		canvas = new BitmapData(width, height);
		bmp = new Bitmap(canvas);
		addChild(bmp);

		m = new Matrix();
		m.scale(canvas.width / 256, canvas.height / 240);
	}
}