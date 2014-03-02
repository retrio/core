package xgame.platform.nes;

import haxe.ds.Vector;
import flash.Memory;
import flash.utils.ByteArray;
import flash.display.BitmapData;
import xgame.platform.nes.CPU;
import xgame.platform.nes.OpCode;
import xgame.platform.nes.PPU;
import xgame.platform.nes.ROM;


class NES
{
    // hardware components
    public var rom:ROM;
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
    
    var scanline:Int=0;
    
    public function new(rom:ROM)
    {
        this.rom = rom;
        this.cpu = new CPU(this);
        this.ppu = new PPU(this);
        
        rom.mapper.load(this);
        
        cpuMemory = cpu.memory;
        ppuMemory = ppu.memory;
    }
    
    public function run()
    {
        cpu.run();
    }
}
