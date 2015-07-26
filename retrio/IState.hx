package retrio;

import haxe.io.BytesInput;


@:autoBuild(retrio.macro.SaveStateMacro.build())
interface IState
{
	public function loadState(input:BytesInput):Void;
	public function saveState():SaveState;
}
