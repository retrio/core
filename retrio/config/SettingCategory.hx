package retrio.config;


typedef SettingCategory = {
	var id:String;
	var name:String;
	@:optional var settings:Array<Setting>;
	@:optional var custom:CustomSetting;
}
