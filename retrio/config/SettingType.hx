package retrio.config;


enum SettingType
{
	BoolValue;
	IntValue(min:Int, max:Int);
	StringValue(maxLength:Int);
	Options(options:Array<String>);
	//Custom(settingInfo:Dynamic);
	//Section(name:String, settings:Array<Setting>);
}
