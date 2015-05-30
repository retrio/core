package;

import xgame.FileWrapper;
import xgame.platform.nes.NES;


#if test
class Main
{
	static function main()
	{
		var args = Sys.args();
		var fileName = "assets/roms/nestest.nes";
		if (args.length > 0) fileName = "assets/roms/" + args[0];

		var file = FileWrapper.read(fileName);

		var nes = new NES();
		nes.loadGame(file);
		nes.cpu.pc = 0x8000;

		nes.frame();
	}
}
#else

class Main extends xgame.platform.nes.ui.OpenFLUI
{
	function new()
	{
		var nes = new NES();
		super(nes);

		var fileName = "assets/roms/duckhunt.nes";
		var file = FileWrapper.read(fileName);

		nes.loadGame(file);
	}

	static function main()
	{
		var m = new Main();
	}
}
#end
