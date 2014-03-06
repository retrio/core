package;

import flash.Lib;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.utils.Endian;
import xgame.platform.nes.CPU;
import xgame.platform.nes.NES;
import xgame.platform.nes.ROM;


class Main extends NES {
    public function new () {
#if flash
        var fileName = "assets/roms/nestest.nes";
#else
        var args = Sys.args();
        var fileName = "assets/roms/nestest.nes";
        if (args.length > 0) fileName = "assets/roms/" + args[0];
#end
        
        var file = openfl.Assets.getBytes(fileName);
        var rom = new ROM(file);
        
        super(rom);
        
        var bmp = new Bitmap(screen);
        addChild(bmp);
        
        /*var start = Sys.time();
        run();
        trace(cpu.ticks + " ticks");
        trace(Std.int(cpu.ticks / (Sys.time() - start) / 1000)/1000 + "MHz");*/
        
        if (StringTools.endsWith(fileName, "nestest.nes"))
        {
            // run CPU test, then quit
            cpu.pc = 0x8000;
            cpu.run(null, true);
            Lib.exit();
        }
        else
        {
            run();
        }
    }
}
