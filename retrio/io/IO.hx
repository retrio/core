package retrio.io;


class IO
{
	public static var defaultIO:IEnvironment =
#if sys
		new NativeIO();
#elseif flash
		new FlashIO();
#else
		throw "Unrecognized I/O environment";
#end
}
