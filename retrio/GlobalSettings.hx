package retrio;


@:enum
abstract GlobalSettings(String) from String to String
{
	var Volume = "volume";
	var FrameSkip = "frameskip";
	var Smooth = "smooth";
	var ShowFPS = "showfps";

	public static var settings:Array<SettingCategory> = [{
		id: "default", name: "General", settings: [
			new Setting(Volume, "Volume", IntValue(0,100), 50),
			new Setting(FrameSkip, "Frame Skip", IntValue(0,3), 0),
			new Setting(Smooth, "Smooth Scale", BoolValue, false),
			new Setting(ShowFPS, "Show FPS", BoolValue, false),
		]
	}];
}
