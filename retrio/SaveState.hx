package retrio;

import haxe.io.Bytes;
import haxe.io.BytesInput;


abstract SaveState(Bytes) from Bytes to Bytes
{
	public var length(get, never):Int;
	inline function get_length() return this.length;

	public inline function getInput():BytesInput
	{
		return new BytesInput(this);
	}
}
