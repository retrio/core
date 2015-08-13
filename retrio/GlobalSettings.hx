package retrio;


@:enum
abstract GlobalSettings(String) from String to String
{
	var FrameSkip = "Frame Skip";
	var Smooth = "Smooth Scale";
	var Volume = "Volume";

	public static var settings:Array<SettingCategory> = [{
		name: 'General', settings: [
			new Setting(FrameSkip, IntValue(0,3), 0),
			new Setting(Smooth, BoolValue, false),
			new Setting(Volume, IntValue(0,100), 50),
		]
	}];
}
