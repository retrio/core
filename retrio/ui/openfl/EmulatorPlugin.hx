package retrio.ui.openfl;

import haxe.Serializer;
import haxe.ds.Vector;
import flash.display.BitmapData;
import flash.display.Sprite;
import openfl.display.FPS;
import retrio.io.FileWrapper;
import retrio.io.IEnvironment;
import retrio.config.Setting;
import retrio.config.SettingCategory;
import retrio.config.GlobalSettings;


class EmulatorPlugin extends Sprite implements IEmulatorFrontend
{
	public var running:Bool = false;
	public var initialized:Bool = false;
	public var active:Bool = false;
	public var emu:IEmulator;
	public var frameSkip:Int = 0;
	public var extensions:Array<String>;
	public var settings:Array<SettingCategory>;
	public var controllers:Vector<IController>;

	public var io(default, set):IEnvironment;
	function set_io(io:IEnvironment)
	{
		emu.io = io;
		return this.io = io;
	}

	var volume:Float = 1;
	var smooth:Bool = false;

	var _time:Float = 0;
	var frameRate:Float = 60;

	var fps:FPS;

	// this is an abstract class
	function new()
	{
		super();

		mouseEnabled = mouseChildren = false;

		fps = new FPS(10, 10, 0x00ff00);
		addChild(fps);

		if (!Reflect.hasField(Type.getClass(this), "_name"))
		{
			throw "Missing plugin name: " + this;
		}
	}

	public function frame()
	{
		var _newTime = haxe.Timer.stamp();
		var elapsed = _newTime - _time;
		_time = _newTime;
		frameRate = 1/elapsed;
		if (frameRate < 1) frameRate = 60;
	}

	public function resize(width:Int, height:Int) {}

	public function loadGame(gameData:FileWrapper)
	{
		emu.loadGame(gameData);
		resetEmu();
	}

	public function start()
	{
		running = true;
		activate();
	}
	public function pause()
	{
		running = false;
		deactivate();
	}
	public function reset()
	{
		emu.reset();
	}

	public function close()
	{
		deactivate();
		running = initialized = false;
	}

	public function activate()
	{
		active = true;
	}

	public function deactivate()
	{
		active = false;
	}

	public function saveState():String
	{
		return Serializer.run(emu);
	}

	public function loadState(state:IEmulator)
	{
		deactivate();
		emu = state;
		resetEmu();
		activate();
	}

	public function capture():Null<BitmapData> return null;

	public function getSamples(e:Dynamic)
	{
		// fill with empty data
		var data = e.data;
		for (i in 0 ... 2048)
		{
			data.writeFloat(0);
			data.writeFloat(0);
		}
	}

	public function setSpeed(speed:EmulationSpeed) {}

	public function addController(controller:IController, port:Int)
	{
		controllers[port] = controller;
		controller.add();
		emu.addController(controller, port);
	}

	public function removeController(port:Int)
	{
		if (controllers[port] != null)
		{
			controllers[port].remove();
			controllers[port] = null;
		}
	}

	public function loadSettings(?settings:Array<SettingCategory>, ?save:Bool=false)
	{
		if (settings == null) settings = this.settings;
		var dirty = false;
		for (page in settings)
		{
			if (page.settings != null)
			{
				for (setting in page.settings)
				{
					setSetting(setting.id, setting.value);
					if (setting.dirty)
						dirty = true;
				}
			}
			else if (page.custom != null && page.custom.save != null)
			{
				page.custom.save(page.custom);
				if (page.custom.dirty)
					dirty = true;
			}
		}
		if (save && dirty)
		{
			saveSettings();
		}
	}

	public function setSetting(id:String, value:Dynamic):Void
	{
		switch (id)
		{
			case GlobalSettings.Volume:
				volume = cast(value, Int) / 100;

			case GlobalSettings.Smooth:
				smooth = cast(value, Bool);

			case GlobalSettings.FrameSkip:
				frameSkip = cast(value, Int);

			case GlobalSettings.ShowFPS:
				fps.visible = cast(value, Bool);

			default: {}
		}
	}

	function saveSettings()
	{
		var file = io.writeFile();
		var settingsData = Setting.serialize(settings);
		file.writeString(settingsData);
		file.save(settingsFileName(), true);
	}

	public function settingsFileName():String
	{
		return Reflect.field(Type.getClass(this), "_name") + ".settings";
	}

	function resetEmu()
	{
		emu.io = io;
		for (i in 0 ... controllers.length)
		{
			emu.addController(controllers[i], i);
		}
		loadSettings();
	}
}
