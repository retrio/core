package xgame.platform.nes;

import haxe.ds.Vector;


class Mapper
{
    var nes:NES;
    
    public static var mappers = [
        0 => Mapper0,
    ];
    
    public function load(nes:NES):Void
    {
        this.nes = nes;
    }
    
    public function read(ad:Int):Int
    {
        return nes.cpu.memory[ad];
    }
    
    public function write(ad:Int, value:Int)
    {
        // can't write to ROM
    }
}

class Mapper0 extends Mapper
{
    override public function load(nes:NES)
    {
        super.load(nes);
        
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
}
