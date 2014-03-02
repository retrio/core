package xgame.platform.nes;


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
        for (i in 0x8000 ... 0xBFFF)
        {
            nes.cpu.memory[i] = nes.rom.getPrgByte(0, i - 0x8000);
        }
        // load second program bank
        var bank = nes.rom.prgSize > 1 ? 1 : 0;
        for (i in 0xC000 ... 0xFFFF)
        {
            nes.cpu.memory[i] = nes.rom.getPrgByte(bank, i - 0xC000);
        }
        // load character rom
        if (nes.rom.chrSize > 0)
        {
            for (i in 0 ... 0x2000)
            {
                nes.ppu.memory[i] = nes.rom.getChrByte(0, i - 0xC000);
            }
        }
    }
}
