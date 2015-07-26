package retrio.ui.openfl;

import haxe.io.Bytes;
import flash.Lib;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.geom.Matrix;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.utils.ByteArray;


@:build(retrio.macro.Optimizer.build())
class Shell extends Sprite
{
	static inline var TOOLBAR_HEIGHT:Int = 48;

	static var _plugins:Map<String, EmulatorPlugin> = new Map();
	public static function registerPlugin(name:String, plugin:EmulatorPlugin):Bool
	{
		_plugins.set(name, plugin);
		return true;
	}

	var _stage(get, never):flash.display.Stage;
	inline function get__stage() return Lib.current.stage;

	var toolbar:Toolbar;

	var plugin:EmulatorPlugin;
	var io:IEnvironment;
	var fps:Int;
	var bmp:Bitmap;
	var canvas:BitmapData;
	var bmpData:BitmapData;

	var loaded:Bool = false;
	var running:Bool = false;
	var _running:Bool = true;

	var _m:Matrix;
	var _pixels:ByteArray = new ByteArray();
	var _draw:Float = 0;
	var _slow:Bool = false;
	var _width:Int = 0;
	var _height:Int = 0;

	var _callLater:Array<Void->Void> = new Array();

	var sound:Sound;
	var channel:SoundChannel;
	var soundPlaying:Bool = false;
	var _soundPos:Int = 0;

	var speed(default, set):EmulationSpeed = Normal;
	function set_speed(s:EmulationSpeed)
	{
		if (plugin == null) return speed = Normal;
		if (speed == s) return s;

		plugin.frameSkip = switch(s)
		{
			case Slow, Normal: 0;
			case Fast2x: 1;
			case Fast4x: 3;
		}

		plugin.setSpeed(s);

		return speed = s;
	}

	public function new(io:IEnvironment, ?fps:Int=60)
	{
		super();
#if flash
		mouseEnabled = false;
#end
		this.io = io;
		this.fps = fps;

		if (_stage != null) onStage(null);
		else Lib.current.addEventListener(Event.ADDED_TO_STAGE, onStage);
	}

	public function loadPlugin(name:String)
	{
		if (!_plugins.exists(name))
			throw "Unrecognized plugin: " + name;

		if (this.plugin != null)
		{
			unloadPlugin();
		}

		this.plugin = _plugins[name];
		this.plugin.resize(_width, _height);
		addChildAt(this.plugin, 0);

		this.plugin.emu.io = io;

		this.plugin.activate();

		//speed = Fast;
	}

	public function loadGame(f:FileWrapper)
	{
		this.plugin.loadGame(f);
	}

	public function initSound()
	{
		if (channel != null)
			channel.stop();

		sound = new Sound();
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, getSamples);
		channel = sound.play();
	}

	public function addController(c:IController, ?port:Int=null)
	{
		return plugin.emu.addController(c, port);
	}

	public function onResize(e:Event)
	{
		_width = Std.int(_stage.stageWidth);
		_height = Std.int(_stage.stageHeight - TOOLBAR_HEIGHT);

		if (_width == 0 || _height == 0) return;

		if (plugin != null)
		{
			plugin.resize(_width, _height);
		}

		toolbar.y = _height;
	}

	public function update(e:Dynamic)
	{
		if (!running) return;

		var call:(Void->Void);
		while ((call = _callLater.pop()) != null)
		{
			call();
		}

		if (plugin != null)
		{
			switch(speed)
			{
				case Slow:
					_slow = !_slow;
					if (_slow) plugin.frame();
				case Normal:
					plugin.frame();
				case Fast2x:
					@unroll for (i in 0 ... 2) plugin.frame();
				case Fast4x:
					@unroll for (i in 0 ... 4) plugin.frame();
			}
		}
	}

	function onStage(e:Event)
	{
		if (e != null) Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onStage);

		var _stage = this._stage;
		_stage.quality = flash.display.StageQuality.LOW;
		_stage.addChild(this);
		_stage.addEventListener(Event.ENTER_FRAME, update);
		_stage.addEventListener(Event.RESIZE, onResize);
		_stage.addEventListener(Event.ACTIVATE, onActivate);
		_stage.addEventListener(Event.DEACTIVATE, onDeactivate);

		_width = Std.int(_stage.stageWidth);
		_height = Std.int(_stage.stageHeight - TOOLBAR_HEIGHT);

		createToolbar();

		var fps = new openfl.display.FPS(10, 10, 0x00ff00);
		addChild(fps);
	}

	function onActivate(e:Dynamic)
	{
		if (plugin == null || !loaded) return;
		temporaryResume();
		plugin.activate();
	}

	function onDeactivate(e:Dynamic)
	{
		if (plugin == null || !loaded) return;
		temporaryPause();
		plugin.deactivate();
	}

	function onQuit()
	{
		if (plugin != null) unloadPlugin();
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
		], function() return (plugin != null && running) ? 1 : 0));
		toolbar.addButton(new ToggleButton([
				{img:"ff", tooltip:"Change Speed", clickHandler:changeSpeed},
				{img:"ff2x", tooltip:"Change Speed", clickHandler:changeSpeed},
				{img:"ff4x", tooltip:"Change Speed", clickHandler:changeSpeed},
				{img:"ff05x", tooltip:"Change Speed", clickHandler:changeSpeed},
			], function() return switch (speed) {
				case Normal: 0;
				case Fast2x: 1;
				case Fast4x: 2;
				case Slow: 3;
		}));
		toolbar.addButton(new ToolbarButton({img:"save", tooltip:"Save State", clickHandler:saveState}));
		toolbar.addButton(new ToolbarButton({img:"load", tooltip:"Load State", clickHandler:loadState}));
		toolbar.addButton(new ToolbarButton({img:"controller", tooltip:"Controls", clickHandler:null}));
#if screenshot
		toolbar.addButton(new ToolbarButton({img:"screenshot", tooltip:"Screenshot", clickHandler:screenshot}));
#end
		toolbar.addButton(new ToolbarButton({img:"settings", tooltip:"Settings", clickHandler:null}));
	}

	function unloadPlugin()
	{
		if (plugin != null)
		{
			plugin.close();
			removeChild(plugin);
			plugin = null;
		}
	}

	function pause()
	{
		if (plugin == null || !loaded) return;
		running = false;
	}

	function resume()
	{
		if (plugin == null || !loaded) return;
		running = true;
	}

	function temporaryPause()
	{
		_running = loaded ? running : true;
		running = false;
	}

	function temporaryResume()
	{
		running = _running;
	}

	function changeSpeed()
	{
		speed = switch(speed)
		{
			case Normal: Fast2x;
			case Fast2x: Fast4x;
			case Fast4x: Slow;
			case Slow: Normal;
		}
	}

	function loadRom()
	{
		if (plugin == null) return;

		temporaryPause();
		io.openFileDialog(plugin.extensions, function(file:FileWrapper) {
			plugin.loadGame(file);
			plugin.start();
			loaded = true;
			initSound();
			resume();
		}, temporaryResume);
	}

	function callLater(f:Void->Void)
	{
		_callLater.push(f);
	}

#if screenshot
	function screenshot()
	{
		if (plugin == null || !loaded) return;
		temporaryPause();
		var bmd = plugin.capture();
		if (bmd == null) return;
		var encoded:ByteArray = bmd.encode(bmd.rect, new flash.display.PNGEncoderOptions());
		var path = "Screenshot " + Date.now().toString() + ".png";
#if flash
		var fr = new flash.net.FileReference();
		fr.save(encoded, StringTools.replace(path, ':', ''));
#elseif js
#else
		var file = sys.io.File.write(path, true);
		file.writeString(encoded.toString());
		file.close();
#end
		temporaryResume();
	}
#end

	function reset()
	{
		if (plugin == null || !loaded) return;
		// TODO: confirm with dialog
		plugin.reset();
		running = true;
	}

	function saveState()
	{
		if (plugin != null && plugin.emu != null && Std.is(plugin.emu, IState))
		{
			cast(plugin.emu, IEmulator).savePersistentState(1);
		}
	}

	function loadState()
	{
		if (plugin != null && plugin.emu != null && Std.is(plugin.emu, IState))
		{
			try
			{
				cast(plugin.emu, IEmulator).loadPersistentState(1);
			}
			catch (e:Dynamic) {}
		}
	}

	function getSamples(e:Dynamic)
	{
		if (plugin == null || !running)
		{
			// fill with empty data
			var data = e.data;
			for (i in 0 ... 0x800)
			{
				data.writeFloat(0);
				data.writeFloat(0);
			}
		}
		else
		{
			return plugin.getSamples(e);
		}
	}

	function playSound()
	{
		if (!soundPlaying)
		{
			channel = sound.play(_soundPos);
			soundPlaying = true;
		}
	}

	function pauseSound()
	{
		if (soundPlaying)
		{
			_soundPos = Std.int(channel.position);
			channel.stop();
			soundPlaying = false;
		}
	}
}
