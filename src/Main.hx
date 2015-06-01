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

class Main extends xgame.platform.nes.ui.openfl.GUI
{
	function new()
	{
		var nes = new NES();
		super(nes);

		var fileName = "assets/roms/mario.nes";
		var file = FileWrapper.read(fileName);

		nes.loadGame(file);
		var controller = new xgame.platform.nes.ui.openfl.KeyboardController();
		nes.addController(controller);

#if (cpp && profile)
		cpp.vm.Profiler.start();
	}

	var _profiling:Bool = true;
	var _f = 0;
	override public function update(e:Dynamic)
	{
		super.update(e);

		if (_profiling)
		{
			_f++;
			trace(_f);
			if (_f >= 60*15)
			{
				trace("DONE");
				cpp.vm.Profiler.stop();
				_profiling = false;
			}
		}
#end
	}

	static function main()
	{
		var m = new Main();
	}
}
#end
