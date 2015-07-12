package retrio.audio;

import haxe.ds.Vector;


class SoundBuffer
{
	public var length:Int = 0;

	public var last(get, set):Float;
	inline function get_last()
	{
		return this.length == 0 ? 0 : get(this.length - 1);
	}
	inline function set_last(v:Float):Float
	{
		return this.push(v);
	}

	var _data:Vector<Float>;
	var start:Int = 0;

	public function new(length:Int)
	{
		_data = new Vector(length);
		for (i in 0 ... length) _data[i] = 0;
	}

	@:arrayAccess public inline function get(i:Int):Float
	{
		return _data[(start+i) % _data.length];
	}

	@:arrayAccess public inline function set(i:Int, v:Float):Float
	{
		return _data[(start+i) % _data.length] = v;
	}

	public inline function push(v:Float):Float
	{
		return _data[(start + length++) % _data.length] = v;
	}

	public inline function pop():Float
	{
		var val = get(0);
		--length;
		if (++start >= _data.length) start -= _data.length;
		return val;
	}

	@:arrayAccess public inline function lerp(i:Float):Float
	{
		var bottom:Int = Math.floor(i);
		var top:Int = Math.ceil(i);
		var t:Float = i - bottom;
		return (1-t)*get(bottom) + (t)*get(top);
	}
}
