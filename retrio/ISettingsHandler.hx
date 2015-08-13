package retrio;


interface ISettingsHandler
{
	public function loadSettings(?settings:Array<SettingCategory>):Void;
}
