package retrio.io;


class IO
{
	public static var defaultIO:IEnvironment =
#if sys
		new NativeIO();
#elseif flash
		new FlashIO();
#elseif js
		new Html5IO();
#else
		throw "Unrecognized I/O environment";
#end
}
