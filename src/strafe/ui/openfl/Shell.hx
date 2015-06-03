package strafe.ui.openfl;

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


class Shell extends Sprite
{
	static var r:Rectangle = new Rectangle(0, 0, 256, 240);

	var _stage(get, never):flash.display.Stage;
	inline function get__stage() return Lib.current.stage;

	var emu:EmulatorPlugin;
	var fps:Int;
	var bmp:Bitmap;
	var canvas:BitmapData;
	var bmpData:BitmapData;
	var _m:Matrix;
	var _pixels:ByteArray = new ByteArray();
	var _draw:Float = 0;
	var _slow:Bool = false;

	var speed(default, set):EmulationSpeed = Normal;
	function set_speed(s:EmulationSpeed)
	{
		if (emu == null) return speed = Normal;
		if (speed == s) return s;

		emu.frameSkip = switch(s)
		{
			case Slow: 0;
			case Normal: 0;
			case Fast: 1;
		}

		return speed = s;
	}

	public function new(?fps:Int=60)
	{
		super();

		_stage.quality = flash.display.StageQuality.LOW;
		bmpData = new BitmapData(256, 240);
		initScreen();

		_pixels.endian = Endian.BIG_ENDIAN;
		_pixels.clear();
		for (i in 0 ... 256*240*4)
			_pixels.writeByte(0);

		Memory.select(_pixels);

		if (_stage != null) onStage(null);
		else Lib.current.addEventListener(Event.ADDED_TO_STAGE, onStage);
	}

	public function loadPlugin(e:EmulatorPlugin)
	{
		if (this.emu != null)
		{
			unloadPlugin();
		}

		this.emu = e;
		e.resize(Std.int(width), Std.int(height));
		addChild(e);
	}

	public function loadGame(f:FileWrapper)
	{
		this.emu.loadGame(f);
	}

	public function onResize(e:Event)
	{
		if (emu != null)
		{
			emu.resize(Std.int(width), Std.int(height));
		}
	}

	public function update(e:Dynamic)
	{
		if (emu != null)
		{
			switch(speed)
			{
				case Slow:
					_slow = !_slow;
					if (_slow) emu.frame();
				case Normal:
					emu.frame();
				case Fast:
					emu.frame();
					emu.frame();
			}
		}
	}

	function onStage(e:Event)
	{
		if (e != null) Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onStage);

		_stage.addChild(this);

		_stage.addEventListener(Event.ENTER_FRAME, update);
		_stage.addEventListener(Event.RESIZE, onResize);
	}

	function unloadPlugin()
	{
		removeChild(this.emu);
		this.emu = null;
	}

	function initScreen()
	{
		canvas = new BitmapData(_stage.stageWidth, _stage.stageHeight);
		bmp = new Bitmap(canvas);
		addChild(bmp);

		_m = new Matrix();
		_m.scale(canvas.width / 256, canvas.height / 240);
	}
}
