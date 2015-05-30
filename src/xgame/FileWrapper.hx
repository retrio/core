package xgame;


class FileWrapper
{
	var input:FileStream;

	public static function read(path:String):FileWrapper
	{
#if openfl
		var input = openfl.Assets.getBytes(path);
#else
		var input = sys.io.File.read(path, true);
#end
		return new FileWrapper(input);
	}

	function new(input:FileStream)
	{
		this.input = input;
	}

	public inline function readByte()
	{
		return input.readByte();
	}

	public inline function readString(length:Int)
	{
		return #if openfl input.readUTFBytes(length) #else input.readString(length) #end;
	}
}
