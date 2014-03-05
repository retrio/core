package xgame.platform.nes;

import haxe.ds.Vector;
import flash.utils.ByteArray;
import xgame.platform.nes.OpCode;


class ROM
{
    public var mapper:Mapper;
    public var verticalMirror:Bool=false;
    public var fourScreenMirror:Bool=false;
    
    public var prgRom:Vector<Int>;
    public var chrRom:Vector<Int>;
    public var prgRam:Vector<Int>;
    
    public var prgSize:Int=0;               // size of PRG ROM (# of 0x4000 blocks)
    public var chrSize:Int=0;               // size of CHR ROM (# of 0x2000 blocks)
    public var prgRamSize:Int=0;            // size of PRG RAM (# of 0x2000 blocks)
    
    var mapperNumber:Int=0;
    
    public function new(file:ByteArray)
    {
        var pos = 0;
        parseHeader(file);
    }
    
    function parseHeader(file:ByteArray)
    {
        // check for "NES" at beginning of header
        var firstWord = file.readUTFBytes(3);
        if (firstWord != "NES" || file.readUnsignedByte() != 0x1A)
        {
            throw "Not in iNES format";
        }
        prgSize = file.readUnsignedByte();
        chrSize = file.readUnsignedByte();
        var f6 = file.readUnsignedByte();
        var f7 = file.readUnsignedByte();
        
        verticalMirror = (f6 & 0x1) != 0;
        fourScreenMirror = (f6 & 0x8) != 0;
        
        prgRamSize = file.readUnsignedByte();
        
        prgRom = new Vector(0x4000 * prgSize);
        chrRom = new Vector(0x2000 * chrSize);
        prgRam = new Vector(0x2000 * prgRamSize);
        
        mapperNumber = (f6 & 0xF0 >> 4) + f7 & 0xF0;
        var mapperClass = Mapper.mappers[mapperNumber];
        if (mapperClass == null)
        {
            throw ("Mapper " + mapperNumber + " is not implemented yet.");
        }
        
        trace(mapperNumber);
        
        mapper = Type.createInstance(mapperClass, []);
        
        for (i in 0...7) file.readByte();
        
        
        for (i in 0 ... prgSize) {
            for (j in 0 ... 0x4000)
            {
                prgRom[0x4000*i + j] = file.readUnsignedByte();
            }
        }
        for (i in 0 ... chrSize) {
            for (j in 0 ... 0x2000)
            {
                chrRom[0x2000*i + j] = file.readUnsignedByte();
            }
        }
    }
    
    public inline function getPrgByte(bank:Int, address:Int):Int
    {
        return prgRom[bank*0x4000 + address];
    }
    
    public inline function getChrByte(bank:Int, address:Int):Int
    {
        return chrRom[bank*0x2000 + address];
    }
}
