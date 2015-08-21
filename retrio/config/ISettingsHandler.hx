package retrio.config;


interface ISettingsHandler
{
	public function loadSettings(?settings:Array<SettingCategory>, ?save:Bool=false):Void;
}
