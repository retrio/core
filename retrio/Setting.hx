package retrio;


class Setting
{
	public var name:String;
	public var type:SettingType;
	public var value:Dynamic;

	public inline function new(name:String, type:SettingType, value:Dynamic)
	{
		this.name = name;
		this.type = type;
		this.value = value;
	}

	@:to public inline function toString():String
	{
		return switch(type)
		{
			case BoolValue: cast(this.value, Bool) ? "yes" : "no";
			case IntValue(a, b): Std.string(cast(this.value, Int));
			case StringValue(a): cast(this.value, String);
			case Options(a): cast(this.value, String);
			default: "";
		}
	}
}
