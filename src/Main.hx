package;

import flash.display.Sprite;
import flash.display.Bitmap;
import flash.utils.Endian;
import xgame.platform.nes.CPU;
import xgame.platform.nes.NES;

class Main extends Sprite {
    public function new () {
        super();
        
        var fileName = "assets/roms/nestest.nes";
        trace(fileName);
        
        var file = openfl.Assets.getBytes(fileName);
        var vm = new NES(file);
        
        var bmp = new Bitmap(vm.screen);
        addChild(bmp);
        
        var start = Date.now().getTime();
        vm.run();
        trace(vm.cpu.ticks + " ticks");
        trace(Std.int(vm.cpu.ticks / (Date.now().getTime() - start) / 1000)/1000 + "MHz");
    }
}
