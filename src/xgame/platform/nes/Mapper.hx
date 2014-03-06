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
    var cpu:CPU;
    var ppu:PPU;
    var cpuMemory:Vector<Int>;
    
    // this is an abstract base class
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
        this.cpu = nes.cpu;
        this.ppu = nes.ppu;
        this.cpuMemory = cpu.memory;
        
        // load first program bank
        Vector.blit(nes.rom.prgRom, 0, cpuMemory, 0x8000, 0x4000);
        // load second program bank
        var bank = nes.rom.prgSize > 1 ? 1 : 0;
        Vector.blit(nes.rom.prgRom, bank*0x4000, cpuMemory, 0xC000, 0x4000);
        // load character rom
        if (nes.rom.chrSize > 0)
        {
            Vector.blit(nes.rom.chrRom, 0, nes.ppu.memory, 0, 0x2000);
        }
    }
    
    public inline function read(addr:Int):Int
    {
        addr &= 0xFFFF;
        if (addr > 0x4020)
        {
            // cartridge space
            return cpuMemory[addr];
        }
        else if (addr < 0x2000)
        {
            // write to RAM
            return cpuMemory[addr & 0x7FF];
        }
        else if (addr < 0x4000)
        {
            // ppu, mirrored 7 bytes of io registers
            return ppu.read(0x2000 + (addr & 7));
        }
        else
        {
            // TODO: 0x4000 to 0x4020 = APU and IO registers
            return 0;
        }
    }
    
    public inline function write(addr:Int, data:Int)
    {
        if (addr > 0x4020)
        {
            // cartridge space
            cpuMemory[addr] = data;
        }
        else if (addr < 0x2000)
        {
            // write to RAM (mirrored)
            cpuMemory[addr & 0x7FF] = data;
        }
        else if (addr < 0x4000)
        {
            // ppu, mirrored 7 bytes of io registers
            ppu.write(0x2000 + (addr & 7), data);
        }
        else
        {
            // TODO: 0x4000 to 0x4020 = APU and IO registers
            switch(addr)
            {
                case 0x4016:
                    // DMA
                    ppu.write(addr, data);
            }
        }
    }
}
