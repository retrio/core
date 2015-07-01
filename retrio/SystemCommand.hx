package retrio;


/**
 * These are controls which are used for system actions such as saving/loading
 * states or fast forwarding. To avoid collision with existing button codes,
 * they should start from 0x8000.
 */
@:enum
abstract SystemCommand(Int) from Int to Int
{
	public static inline var BASE = 0x8000;

	var SaveState = BASE | 1;
	var LoadState = BASE | 2;
	var FastForward = BASE | 3;

}
