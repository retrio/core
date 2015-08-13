import flash.display.Sprite;
package retrio.ui.openfl;


class SettingsControl extends Sprite
{
	public var setting:Setting;

	public function new(setting:Setting)
	{
		super();

		this.setting = setting;

		switch (setting.type)
		{
			case BoolValue:

			case IntValue(a,b):
			case StringValue(a):
			case Options(a):
			default: {}
		}
	}
}
