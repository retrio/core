package xgame.platform.nes;
import xgame.platform.nes.mappers.NromMapper;

import haxe.ds.Vector;


enum MirrorMode
{
    H_MIRROR;
    V_MIRROR;
    SS_MIRROR0;
    SS_MIRROR1;
    FOUR_SCREEN_MIRROR;
}

class Mapper
{
    var nes:NES;
    var rom:ROM;
    
    function new()
    {
    }
    
    public static function getMapper(mapperNumber:Int):Mapper
    {
        switch (mapperNumber)
        {
            case 0: return new NromMapper();
            default: throw ("Mapper " + mapperNumber + " is not implemented yet.");
        }
    }
    
    public function load(nes:NES)
    {
        this.nes = nes;
        this.rom = nes.rom;
        
        // load first program bank
        Vector.blit(nes.rom.prgRom, 0, nes.cpu.memory, 0x8000, 0x4000);
        // load second program bank
        var bank = nes.rom.prgSize > 1 ? 1 : 0;
        Vector.blit(nes.rom.prgRom, bank*0x4000, nes.cpu.memory, 0xC000, 0x4000);
        // load character rom
        if (nes.rom.chrSize > 0)
        {
            Vector.blit(nes.rom.chrRom, 0, nes.ppu.memory, 0, 0x2000);
        }
    }
    
    public inline function read(ad:Int):Int
    {
        return nes.cpu.memory[ad];
    }
    
    public inline function write(ad:Int, value:Int)
    {
        // can't write to ROM
    }
}
