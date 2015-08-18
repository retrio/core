package retrio.config;


typedef CustomSetting =
{
	@:optional var render:Dynamic;
	@:optional var save:Dynamic;
	@:optional var serialize:Null<Void->Dynamic>;
	@:optional var unserialize:Null<Dynamic->Void>;
}
