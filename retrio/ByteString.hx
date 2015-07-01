package retrio;

import haxe.io.Bytes;
import haxe.io.Input;


#if flash
typedef ContainerType = haxe.ds.Vector<Int>;
#else
typedef ContainerType = Bytes;
#end


/**
 * Platform-depenent container of bytes. Vector is significantly faster on
 * Flash, while Bytes seems slightly more efficent in C++.
 */
abstract ByteString(ContainerType)
{
	public static function fromBytes(bytes:Bytes):ByteString
	{
#if flash
		var bs = new ByteString(bytes.length);
		for (i in 0 ... bs.length) bs.set(i, bytes.get(i));
		return bs;
#else
		return cast bytes;
#end
	}

	public static function fromFile(file:FileWrapper):ByteString
	{
		return fromBytes(file.readAll());
	}

	public inline function new(length:Int)
	{
#if flash
		this = new haxe.ds.Vector(length);
#else
		this = Bytes.alloc(length);
#end
	}

	public var length(get, never):Int;
	inline function get_length() return this.length;

	@:arrayAccess public inline function get(addr:Int):Int return this.get(addr);
	public inline function set(addr:Int, value:Int):Void this.set(addr, value);
	@:arrayAccess public inline function set2(addr:Int, value:Int):Int
	{
		set(addr, value);
		return value;
	}

	public inline function fillWith(value:Int):Void
	{
#if flash
		for (i in 0 ... this.length) this.set(i, value);
#else
		this.fill(0, this.length, value);
#end
	}

	public inline function readFrom(file:Input):Void
	{
#if flash
		for (i in 0 ... this.length) this.set(i, file.readByte());
#else
		this.blit(0, file.read(this.length), 0, this.length);
#end
	}

	public inline function toString():String
	{
#if flash
		return [for (i in this) Std.string(i)].join("");
#else
		return this.toString();
#end
	}
}
