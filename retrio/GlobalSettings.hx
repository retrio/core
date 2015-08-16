package retrio;


@:enum
abstract GlobalSettings(String) from String to String
{
	var Volume = "Volume";
	var FrameSkip = "Frame Skip";
	var Smooth = "Smooth Scale";
	var ShowFPS = "Show FPS";

	public static var settings:Array<SettingCategory> = [{
		name: 'General', settings: [
			new Setting(Volume, IntValue(0,100), 50),
			new Setting(FrameSkip, IntValue(0,3), 0),
			new Setting(Smooth, BoolValue, false),
			new Setting(ShowFPS, BoolValue, false),
		]
	}];
}
