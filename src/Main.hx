package;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.utils.Endian;
import xgame.platform.nes.CPU;
import xgame.platform.nes.NES;
import xgame.platform.nes.ROM;


class Main extends Sprite {
    public function new () {
        super();
        
        var args = Sys.args();
        var fileName = "assets/roms/nestest.nes";
        if (args.length > 0) fileName = "assets/roms/" + args[0];
        trace(fileName);
        
        var file = openfl.Assets.getBytes(fileName);
        var rom = new ROM(file);
        var vm = new NES(rom);
        
        var bmp = new Bitmap(vm.screen);
        addChild(bmp);
        
        var start = Sys.time();
        vm.run();
        trace(vm.cpu.ticks + " ticks");
        trace(Std.int(vm.cpu.ticks / (Sys.time() - start) / 1000)/1000 + "MHz");
    }
}
