package retrio;

import haxe.Json;


class Setting
{
	public var id:String;
	public var name:String;
	public var type:SettingType;
	public var value:Dynamic;

	public static function serialize(categories:Array<SettingCategory>):String
	{
		var data:Map<String, Dynamic> = new Map();
		for (category in categories)
		{
			if (category.settings == null)
			{
				if (category.custom != null && category.custom.serialize != null)
				{
					data[category.id] = category.custom.save();
				}
			}
			else
			{
				var values:Map<String, Dynamic> = new Map();

				for (setting in category.settings)
				{
					values[setting.id] = setting.value;
				}

				data[category.id] = values;
			}
		}
		return Json.stringify(data);
	}

	public static function unserialize(serializedData:String, categories:Array<SettingCategory>):Void
	{
		var data:Dynamic = Json.parse(serializedData);
		for (field in Reflect.fields(data))
		{
			for (category in categories)
			{
				if (category.id == field)
				{
					if (category.settings == null)
					{
						if (category.custom != null && category.custom.unserialize != null)
						{
							category.custom.unserialize(Reflect.field(data, field));
						}
					}
					else
					{
						var values:Dynamic = Reflect.field(data, field);
						for (key in Reflect.fields(values))
						{
							for (setting in category.settings)
							{
								if (setting.id == key)
								{
									setting.value = Reflect.field(values, key);
								}
							}
						}
					}
				}
			}
		}
	}

	public inline function new(id:String, name:String, type:SettingType, value:Dynamic)
	{
		this.id = id;
		this.name = name;
		this.type = type;
		this.value = value;
	}

	public inline function toString():String
	{
		return Json.stringify(value);
	}
}
