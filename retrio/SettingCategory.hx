package retrio;


typedef SettingCategory = {
	var name:String;
	@:optional var settings:Array<Setting>;
	@:optional var custom:CustomSetting;
}
