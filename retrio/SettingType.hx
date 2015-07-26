package retrio;


enum SettingType
{
	Bool;
	Integer(min:Int, max:Int);
	Float(min:Float, max:Float);
	String(?maxLength:Int);
	Option(options:Array<Dynamic>);
	Custom(settingInfo:Dynamic);

	Section(name:String, settings:Array<Setting>)
}
