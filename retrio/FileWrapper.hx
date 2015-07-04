package retrio;

import haxe.io.Path;
import haxe.io.Bytes;
import haxe.io.Input;


abstract FileWrapper({path:Path, data:Input})
{
	public var dir(get, never):String;
	inline function get_dir() return this.path.dir;

	public var fileName(get, never):String;
	inline function get_fileName() return this.path.file;

	public var name(get, never):String;
	inline function get_name() return Path.withoutExtension(fileName);

	public function new(input:Input, ?path:String)
	{
		this = {path:(path == null) ? null : new Path(path), data:input};
	}

	public inline function readByte():UInt return this.data.readByte();
	public inline function readBytes(n:Int):Bytes return this.data.read(n);
	public inline function readAll():Bytes return this.data.readAll();
	public inline function readString(length:Int):String return this.data.readString(length);

	@:to public inline function toInput():Input return this.data;
	@:to public inline function toString():String return this.path.toString();
}
