package retrio.ui.openfl;

import haxe.Serializer;
import flash.display.BitmapData;
import flash.display.Sprite;
import openfl.display.FPS;


class EmulatorPlugin extends Sprite implements ISettingsHandler
{
	public var running:Bool = false;
	public var initialized:Bool = false;
	public var active:Bool = false;
	public var emu:IEmulator;
	public var frameSkip:Int = 0;
	public var extensions:Array<String>;
	public var settings:Array<SettingCategory>;

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

	public function loadGame(gameData:FileWrapper) emu.loadGame(gameData);
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

	public function setSetting(name:String, value:Dynamic):Void
	{
		switch (name)
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

	public function loadSettings(?settings:Array<SettingCategory>)
	{
		if (settings == null) settings = this.settings;
		for (page in settings)
		{
			for (setting in page.settings)
			{
				setSetting(setting.name, setting.value);
			}
		}
	}
}
