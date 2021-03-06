package retrio.ui.openfl;

import haxe.io.Bytes;
import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.geom.Matrix;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.utils.ByteArray;
import haxe.ui.toolkit.core.Toolkit;
import retrio.config.Setting;
import retrio.io.FileWrapper;
import retrio.io.IEnvironment;
import retrio.ui.haxeui.ErrorPopup;


@:build(retrio.macro.Optimizer.build())
class Shell extends Sprite implements IExceptionHandler
{
	static inline var MAX_WIDTH:Int = 1024;
	static inline var MAX_HEIGHT:Int = 768;
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

	var runningStack:Array<Bool> = new Array();

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

		Toolkit.init();
	}

	public function loadPlugin(name:String)
	{
		if (!_plugins.exists(name))
			throw "Unrecognized plugin: " + name;

		if (plugin != null)
		{
			unloadPlugin();
		}

		plugin = _plugins[name];
		onResize(null);
		addChildAt(plugin, 0);

		plugin.io = io;
		plugin.activate();
		plugin.loadSettings();

		if (io.fileExists(plugin.settingsFileName(), true))
		{
			Setting.unserialize(io.readFile(plugin.settingsFileName(), true).readAll().toString(), plugin.settings);
			plugin.loadSettings();
		}
	}

	@:handler(handleError) public function loadGame(f:FileWrapper)
	{
		plugin.loadGame(f);
	}

	public function initSound()
	{
		if (channel != null)
			channel.stop();

		sound = new Sound();
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, getSamples);
		channel = sound.play();
		soundPlaying = true;
	}

	public function addController(c:IController, port:Int)
	{
		return plugin.addController(c, port);
	}

	@:handler(handleError) public function onResize(e:Event)
	{
		_width = Std.int(_stage.stageWidth);
		_height = Std.int(_stage.stageHeight - TOOLBAR_HEIGHT);

		if (_width == 0 || _height == 0) return;

		if (plugin != null && plugin.emu != null)
		{
			var w = plugin.screenBuffer.screenWidth,
				h = plugin.screenBuffer.screenHeight;
			var ratio:Int = Std.int(Math.max(1,
				Math.min(Math.min(MAX_WIDTH, _width) / w,
				Math.min(MAX_HEIGHT, _height) / h)));
			var occupiedWidth:Int = Std.int(w * ratio);
			var occupiedHeight:Int = Std.int(h * ratio);
			plugin.resize(occupiedWidth, occupiedHeight);
			plugin.x = Std.int((_width - w * ratio) / 2);
			plugin.y = Std.int((_height - h * ratio) / 2);
		}

		toolbar.x = Std.int(Math.max((_width - toolbar.buttonWidth)/2, 1));
		toolbar.y = _height;
	}

	@:handler(handleFatalError) public function update(e:Dynamic)
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
		_stage.quality = flash.display.StageQuality.HIGH;
		_stage.addChild(this);
		_stage.addEventListener(Event.ENTER_FRAME, update);
		_stage.addEventListener(Event.RESIZE, onResize);
		_stage.addEventListener(Event.ACTIVATE, onActivate);
		_stage.addEventListener(Event.DEACTIVATE, onDeactivate);

		_width = Std.int(_stage.stageWidth);
		_height = Std.int(_stage.stageHeight - TOOLBAR_HEIGHT);

		createToolbar();
	}

	@:handler(handleError) function onActivate(e:Dynamic)
	{
		if (plugin == null || !loaded) return;
		if (e != null) temporaryResume();
		plugin.activate();
	}

	@:handler(handleError) function onDeactivate(e:Dynamic)
	{
		if (plugin == null || !loaded) return;
		if (e != null) temporaryPause();
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
				{img:"ff", tooltip:"Speed", clickHandler:changeSpeed},
				{img:"ff2x", tooltip:"Speed", clickHandler:changeSpeed},
				{img:"ff4x", tooltip:"Speed", clickHandler:changeSpeed},
				{img:"ff05x", tooltip:"Speed", clickHandler:changeSpeed},
			], function() return switch (speed) {
				case Normal: 0;
				case Fast2x: 1;
				case Fast4x: 2;
				case Slow: 3;
		}));
		toolbar.addButton(new ToolbarButton({img:"save", tooltip:"Save State", clickHandler:saveState}));
		toolbar.addButton(new ToolbarButton({img:"load", tooltip:"Load State", clickHandler:loadState}));
#if screenshot
		toolbar.addButton(new ToolbarButton({img:"screenshot", tooltip:"Screenshot", clickHandler:screenshot}));
#end
		toolbar.addButton(new ToggleButton([
			{img:"mute", tooltip:"Unmute", clickHandler:playSound},
			{img:"sound", tooltip:"Mute", clickHandler:pauseSound},
		], function() return (soundPlaying) ? 1 : 0));
		toolbar.addButton(new ToolbarButton({img:"settings", tooltip:"Settings", clickHandler:toggleSettings}));
		toolbar.addButton(new ToolbarButton({img:"fullscreen", tooltip:"Fullscreen", clickHandler:toggleFullScreen}));
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
		runningStack.push(running);
		running = false;
		onDeactivate(null);
	}

	function temporaryResume()
	{
		var r:Null<Bool> = runningStack.pop();
		running = r == null ? true : r;
		if (running) onActivate(null);
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

	@:handler(handleFatalError) function loadRom()
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
	@:handler(handleError) function screenshot()
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

	@:handler(handleFatalError) function reset()
	{
		if (plugin == null || !loaded) return;
		// TODO: confirm with dialog
		plugin.reset();
		running = true;
	}

	@:handler(handleError) function saveState()
	{
		if (plugin != null && plugin.emu != null && Std.is(plugin.emu, IState))
		{
			cast(plugin.emu, IEmulator).savePersistentState(1);
		}
	}

	@:handler(handleError) function loadState()
	{
		if (plugin != null && plugin.emu != null && Std.is(plugin.emu, IState))
		{
			try
			{
				cast(plugin.emu, IEmulator).loadPersistentState(1);
				plugin.loadSettings();
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
		if (!soundPlaying && sound != null)
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

	function toggleFullScreen()
	{
		_stage.displayState = _stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE ? StageDisplayState.NORMAL : StageDisplayState.FULL_SCREEN_INTERACTIVE;
	}

	var _settingsShown:Bool = false;
	function toggleSettings()
	{
		if (!_settingsShown)
		{
			temporaryPause();
			_settingsShown = true;
			toolbar.enabled = false;
			retrio.ui.haxeui.SettingsPage.show(plugin.settings, plugin, function() { _settingsShown = false; toolbar.enabled = true; temporaryResume(); });
		}
	}

	function handleError(e:Dynamic)
	{
		temporaryPause();
		ErrorPopup.show("There was an error: " + Std.string(e), temporaryResume);
	}

	function handleFatalError(e:Dynamic)
	{
		plugin.close();
		ErrorPopup.show("There was an error: " + Std.string(e));
	}
}
