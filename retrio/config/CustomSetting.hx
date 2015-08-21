package retrio.config;


class CustomSetting
{
	public var dirty:Bool;

	public var render:Dynamic;
	public var save:Dynamic;
	public var serialize:Dynamic;
	public var unserialize:Dynamic;

	public function new(data:{?render:Dynamic, ?save:Dynamic, ?serialize:Dynamic, ?unserialize:Dynamic})
	{
		this.render = data.render;
		this.save = data.save;
		this.serialize = data.serialize;
		this.unserialize = data.unserialize;
	}
}
