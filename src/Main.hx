package;

import flash.display.Sprite;
import flash.display.Bitmap;
import xgame.platform.nes.Processor6502;
import xgame.platform.nes.NES;

class Main extends Sprite {
    public function new () {
        super();
        
        var fileName = "assets/roms/Legend of Zelda.nes";
        trace(fileName);
        
        var p = new Processor6502(openfl.Assets.getBytes(fileName), 0x10);
        var vm = new NES(p);
        
        var bmp = new Bitmap(vm.screen);
        addChild(bmp);
        
#if !flash
        var start = Sys.time();
#end
        vm.run();
        trace(vm.cpuTicks + " ticks");
#if !flash
        trace(Std.int(vm.cpuTicks / (Sys.time() - start) / 1000)/1000 + "MHz");
#end
    }
}
