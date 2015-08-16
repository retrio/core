package retrio;


/**
 * These are controls which are used for system actions such as saving/loading
 * states or fast forwarding.
 */
@:enum
abstract SystemCommand(Int) from Int to Int
{
	public static inline var BASE = 0x1000;

	var SaveState = BASE | 1;
	var LoadState = BASE | 2;
	var Mute = BASE | 3;
	var Pause = BASE | 4;
	var Slow = BASE | 5;
	var FF2X = BASE | 6;
	var FF4X = BASE | 7;
	var Screenshot = BASE | 8;
	var Settings = BASE | 9;
	var Fullscreen = BASE | 10;
}
