package xgame.platform.nes;

import haxe.ds.Vector;
import flash.Memory;
import flash.utils.ByteArray;
import flash.display.BitmapData;
import xgame.platform.nes.CPU;
import xgame.platform.nes.OpCode;
import xgame.platform.nes.PPU;


class NES
{
    // hardware components
    public var cpu:CPU;
    public var ppu:PPU;
    public var screen(get, never):BitmapData;
    function get_screen()
    {
        return ppu.screen;
    }
    
    var cpuMemory:Vector<Int>;
    var ppuMemory:Vector<Int>;
    
    var ntsc:Bool=true;
    
    var ppuStepSize:Float=3;
    var scanline:Int=0;
    
    public function new(file:ByteArray)
    {
        this.cpu = new CPU(this, file, 0x10);
        this.ppu = new PPU(this);
        
        cpuMemory = cpu.memory;
        ppuMemory = ppu.memory;
        
        if (!ntsc) ppuStepSize = 3.2;
    }
    
    public function run()
    {
        cpu.run();
    }
}
