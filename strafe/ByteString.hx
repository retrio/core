package strafe;

import haxe.io.Input;


#if flash
typedef ContainerType = haxe.ds.Vector<Int>;
#else
typedef ContainerType = haxe.io.Bytes;
#end


/**
 * Platform-depenent container of bytes. Vector is significantly faster on
 * Flash, while Bytes seems slightly more efficent in C++.
 */
abstract ByteString(ContainerType)
{
	public inline function new(length:Int)
	{
#if flash
		this = new haxe.ds.Vector(length);
#else
		this = haxe.io.Bytes.alloc(length);
#end
	}

	public var length(get, never):Int;
	inline function get_length() return this.length;

	public inline function get(addr:Int)
	{
		return this.get(addr);
	}

	public inline function set(addr:Int, value:Int)
	{
		return this.set(addr, value);
	}

	public inline function fillWith(value:Int)
	{
#if flash
		for (i in 0 ... this.length) this.set(i, value);
#else
		this.fill(0, this.length, value);
#end
	}

	public inline function readFrom(file:Input)
	{
#if flash
		for (i in 0 ... this.length) this.set(i, file.readByte());
#else
		this.blit(0, file.read(this.length), 0, this.length);
#end
	}

	public inline function toString()
	{
#if flash
		return [for (i in this) Std.string(i)].join("");
#else
		return this.toString();
#end
	}
}
