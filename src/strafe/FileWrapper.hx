package strafe;

import haxe.io.Bytes;


#if sys
typedef FileType = sys.io.FileInput;
#else
typedef FileType = haxe.io.BytesInput;
#end


abstract FileWrapper(FileType) from FileType to FileType
{
	public static function read(path:String):FileWrapper
	{
#if sys
		return new FileWrapper(sys.io.File.read(path, true));
#else
		return new FileWrapper(new haxe.io.BytesInput(Bytes.ofData(openfl.Assets.getBytes(path))));
#end
	}

	function new(input:FileType)
	{
		this = input;
	}

	public inline function readByte():UInt
	{
		return this.readByte();
	}

	public inline function readBytes(n:Int):Bytes
	{
		return this.read(n);
	}

	public inline function readString(length:Int):String
	{
		return this.readString(length);
	}
}
