package retrio.ui.openfl;

import haxe.io.Bytes;
import flash.Lib;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Matrix;
import flash.utils.ByteArray;


@:build(retrio.macro.Optimizer.build())
class Shell extends Sprite
{
	static inline var TOOLBAR_HEIGHT:Int = 48;

	var _stage(get, never):flash.display.Stage;
	inline function get__stage() return Lib.current.stage;

	var toolbar:Toolbar;

	var emu:EmulatorPlugin;
	var fps:Int;
	var bmp:Bitmap;
	var canvas:BitmapData;
	var bmpData:BitmapData;

	var loaded:Bool = false;
	var running:Bool = false;

	var _m:Matrix;
	var _pixels:ByteArray = new ByteArray();
	var _draw:Float = 0;
	var _slow:Bool = false;
	var _width:Int = 0;
	var _height:Int = 0;

	var _callLater:Array<Void->Void> = new Array();

	var speed(default, set):EmulationSpeed = Normal;
	function set_speed(s:EmulationSpeed)
	{
		if (emu == null) return speed = Normal;
		if (speed == s) return s;

		emu.frameSkip = switch(s)
		{
			case Slow, Normal: 0;
			case Fast2x: 1;
			case Fast3x: 2;
			case Fast4x: 3;
		}

		return speed = s;
	}

	public function new(?fps:Int=60)
	{
		super();
#if flash
		mouseEnabled = false;
#end
		_stage.quality = flash.display.StageQuality.LOW;
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
		e.resize(_width, _height);
		addChildAt(e, 0);

		//speed = Fast;
	}

	public function loadGame(f:FileWrapper)
	{
		this.emu.loadGame(f);
	}

	public function onResize(e:Event)
	{
		_width = Std.int(_stage.stageWidth);
		_height = Std.int(_stage.stageHeight - TOOLBAR_HEIGHT);

		if (_width == 0 || _height == 0) return;

		if (emu != null)
		{
			emu.resize(_width, _height);
		}

		toolbar.y = _height;
	}

	function callLater(f:Void->Void)
	{
		_callLater.push(f);
	}

	public function update(e:Dynamic)
	{
		if (!running) return;

		var call:(Void->Void);
		while ((call = _callLater.pop()) != null)
		{
			call();
		}

		if (emu != null)
		{
			switch(speed)
			{
				case Slow:
					_slow = !_slow;
					if (_slow) emu.frame();
				case Normal:
					emu.frame();
				case Fast2x:
					@unroll for (i in 0 ... 2) emu.frame();
				case Fast3x:
					@unroll for (i in 0 ... 3) emu.frame();
				case Fast4x:
					@unroll for (i in 0 ... 4) emu.frame();
			}
		}
	}

	function onStage(e:Event)
	{
		if (e != null) Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onStage);

		_stage.addChild(this);

		_stage.addEventListener(Event.ENTER_FRAME, update);
		_stage.addEventListener(Event.RESIZE, onResize);

		createToolbar();

		var fps = new openfl.display.FPS(10, 10, 0x00ff00);
		addChild(fps);

		_width = Std.int(_stage.stageWidth);
		_height = Std.int(_stage.stageHeight - TOOLBAR_HEIGHT);
	}

	function createToolbar()
	{
		toolbar = new Toolbar();
		toolbar.y = _height;

		addChild(toolbar);

		toolbar.addButton(new ToolbarButton({img:"upload", tooltip:"Open ROM", clickHandler:loadRom}));
		toolbar.addButton(new ToolbarButton({img:"restart", tooltip:"Restart", clickHandler:reset}));
		toolbar.addButton(new ToggleButton([
			{img:"play", tooltip:"Resume", clickHandler:resume},
			{img:"pause", tooltip:"Pause", clickHandler:pause},
		], function() return (emu != null && running) ? 1 : 0));
		toolbar.addButton(new ToggleButton([
				{img:"ff", tooltip:"Change Speed", clickHandler:changeSpeed},
				{img:"ff2x", tooltip:"Change Speed", clickHandler:changeSpeed},
				{img:"ff3x", tooltip:"Change Speed", clickHandler:changeSpeed},
				{img:"ff4x", tooltip:"Change Speed", clickHandler:changeSpeed},
				{img:"ff05x", tooltip:"Change Speed", clickHandler:changeSpeed},
			], function() return switch (speed) {
				case Normal: 0;
				case Fast2x: 1;
				case Fast3x: 2;
				case Fast4x: 3;
				case Slow: 4;
		}));
		toolbar.addButton(new ToolbarButton({img:"load", tooltip:"Load State", clickHandler:null}));
		toolbar.addButton(new ToolbarButton({img:"save", tooltip:"Save State", clickHandler:null}));
		toolbar.addButton(new ToolbarButton({img:"controller", tooltip:"Controls", clickHandler:null}));
#if screenshot
		toolbar.addButton(new ToolbarButton({img:"screenshot", tooltip:"Screenshot", clickHandler:screenshot}));
#end
		toolbar.addButton(new ToolbarButton({img:"settings", tooltip:"Settings", clickHandler:null}));
	}

	function unloadPlugin()
	{
		removeChild(emu);
		emu = null;
	}

	function pause()
	{
		if (emu == null || !loaded) return;
		running = false;
	}

	function resume()
	{
		if (emu == null || !loaded) return;
		running = true;
	}

	function changeSpeed()
	{
		speed = switch(speed)
		{
			case Normal: Fast2x;
			case Fast2x: Fast3x;
			case Fast3x: Fast4x;
			case Fast4x: Slow;
			case Slow: Normal;
		}
	}

	function loadRom()
	{
		if (emu == null) return;
		FilePicker.openFile(emu.extensions, function(file:FileWrapper) {
			emu.loadGame(file);
			emu.start();
			loaded = true;
			running = true;
		});
	}

#if screenshot
	function screenshot()
	{
		if (emu == null || !loaded) return;
		var bmd = emu.capture();
		if (bmd == null) return;
		var encoded:ByteArray = bmd.encode(bmd.rect, new flash.display.PNGEncoderOptions());
		var path = "Screenshot " + Date.now().toString() + ".png";
#if flash
		var fr = new flash.net.FileReference();
		fr.save(encoded, StringTools.replace(path, ':', ''));
#elseif sys
		var file = sys.io.File.write(path, true);
		file.writeString(encoded.toString());
		file.close();
#end
	}
#end

	function reset()
	{
		if (emu == null || !loaded) return;
		// TODO: confirm with dialog
		emu.reset();
		running = true;
	}
}
