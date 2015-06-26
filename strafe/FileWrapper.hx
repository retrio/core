package strafe;

import haxe.io.Bytes;
import haxe.io.Input;


abstract FileWrapper(Input) from Input to Input
{
	public static function read(path:String):FileWrapper
	{
#if sys
		return new FileWrapper(sys.io.File.read(path, true));
#elseif flash
		return new FileWrapper(new haxe.io.BytesInput(Bytes.ofData(openfl.Assets.getBytes(path))));
#else
		return null;
#end
	}

	public function new(input:Input)
	{
		this = input;
	}

	public inline function readByte():UInt return this.readByte();
	public inline function readBytes(n:Int):Bytes return this.read(n);
	public inline function readAll():Bytes return this.readAll();
	public inline function readString(length:Int):String return this.readString(length);
}