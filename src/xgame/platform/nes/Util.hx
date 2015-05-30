package xgame.platform.nes;


class Util
{
	public static inline function getbit(val:Int, pos:Int):Bool
	{
		return ((val & (1 << pos)) != 0);
	}

	public static inline function getbitI(val:Int, pos:Int):Int {
		return ((val >> pos) & 1);
	}

	public static inline function setbit(val:Int, pos:Int, state:Bool)
	{
		return (state) ? (val | (1 << pos)) : (val & ~(1 << pos));
	}

	public static inline function reverseByte(b:Int):Int
	{
		var v = 0;
		for (i in 0 ... 7)
		{
			v <<= 1;
			v |= getbitI(b, 7-i);
		}
		return v;
	}
}
