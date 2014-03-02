package xgame.platform.nes;

import haxe.ds.Vector;
import flash.display.BitmapData;


class PPU
{
    public static inline var RESOLUTION_X=256;
    public static inline var RESOLUTION_Y=240;
    
    public var screen:BitmapData;
    public var memory:Vector<Int>;
    public var spriteRam:Vector<Int>;
    public var statusReg:Int=0;
    
    var tiles:Vector<Vector<BitmapData>>;
    
    var ppuAddrWrites:Int=0;
    var ppuAddr:Int=0;
    
    var nameTableAddr:Int=0x2000;   // base nametable address (0x2000, 0x2400, 0x2800, 0x2c000)
    var addrInc:Int=0x1;            // increase 1 across or 32 down
    var spriteAddr:Int=0;           // sprite pattern table addr, 0x0000 or 0x1000
    var bgAddr:Int=0;               // bg pattern table addr, 0x0000 or 0x1000
    var tallSprites:Bool=false;     // if true, sprites are 8x16
    var colorExt:Bool=false;        // if true, color on EXT pins
    var vBlankNMI:Bool=false;       // if true, generate NMI at start of vblank
    
    var greyscale:Bool=false;
    var clipBg:Bool=false;
    var clipSprites:Bool=false;
    var showBg:Bool=false;
    var showSprites:Bool=false;
    var colorIntensity:Int=0;
    
    var spriteRamAddr:Int=0;
    
    var scrollWrites:Int=0;
    var scrollX:Int=0;
    var scrollY:Int=0;
    
    var palette:Vector<Vector<Int>>;
    
    public function new()
    {
        screen = new BitmapData(RESOLUTION_X, RESOLUTION_Y);
        memory = new Vector(0x4000);
        spriteRam = new Vector(0x100);
        
        palette = new Vector(defaultPalette.length);
        for (n in 0 ... defaultPalette.length)
        {
            palette[n] = new Vector(3);
            for (m in 0 ... 3)
            {
                palette[n][m] = defaultPalette[n][m];
            }
        }
    }
    
    public inline function read(ad:Int):Int
    {
        var result:Int = 0;
        switch(ad)
        {
            case 0x2002:
            {
                // PPUSTATUS
                result = statusReg;
                statusReg &= 0x7F;
            }
            case 0x2007:
            {
                // PPUDATA
                result = memory[ppuAddr];
                ppuAddr += addrInc;
            }
        }
        return result;
    }
    
    public inline function write(ad:Int, value:Int)
    {
        value &= 0xFF;
        switch(ad)
        {
            case 0x2000:
            {
                // PPUCTRL
                nameTableAddr = 0x2000 + (0x400 * value&0x3);
                addrInc = (value&0x4==1) ? 0x20 : 0x1;
                spriteAddr = (value&0x8==1) ? 0x1000 : 0x0;
                bgAddr = (value&0x10==1) ? 0x1000 : 0x0;
                tallSprites = (value&0x20==1);
                vBlankNMI = (value&0x80==1);
            }
            case 0x2001:
            {
                // PPUMASK
                greyscale = (value&0x1==1);
                clipBg = (value&0x2==1);
                clipSprites = (value&0x4==1);
                showBg = (value&0x8==1);
                showSprites = (value&0x10==1);
                colorIntensity = (value>>4);
            }
            case 0x2003:
            {
                // OAMADDR
                spriteRamAddr = value;
            }
            case 0x2004:
            {
                // OAMDATA
                spriteRam[spriteRamAddr] = value;
                spriteRamAddr = (spriteRamAddr + 1) & 0xFF;
            }
            case 0x2005:
            {
                // PPUSCROLL
                if (scrollWrites == 0)
                {
                    // horizontal
                    scrollX = value;
                }
                else
                {
                    // vertical
                    scrollY = value;
                }
            }
            case 0x2006:
            {
                // PPUADDR: write twice to set this register value
                if (ppuAddrWrites == 0)
                {
                    ppuAddr = value << 8;
                    ppuAddrWrites = 1;
                }
                else
                {
                    ppuAddr += value;
                    ppuAddrWrites = 0;
                }
            }
            case 0x2007:
            {
                // PPUDATA: write to location specified by PPUADDR
                memory[ppuAddr] = value;
                ppuAddr += addrInc;
            }
            case 0x4014:
            {
            }
            case 0x4016:
            {
            }
        }
    }
    
    static var defaultPalette=[
        [82, 82, 82],
        [0, 0, 128],
        [8, 0, 138],
        [44, 0, 126],
        [74, 0, 78],
        [80, 0, 6],
        [68, 0, 0],
        [38, 128, 0],
        [10, 32, 0],
        [0, 46, 0],
        [0, 50, 0],
        [0, 38, 10],
        [0, 28, 72],
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
        [164, 164, 164],
        [0, 56, 206],
        [52, 22, 236],
        [94, 4, 220],
        [140, 0, 176],
        [154, 0, 76],
        [144, 24, 0],
        [112, 54, 0],
        [76, 84, 0],
        [14, 108, 0],
        [0, 116, 0],
        [0, 108, 44],
        [0, 94, 132],
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
        [255, 255, 255],
        [76, 156, 255],
        [124, 120, 255],
        [166, 100, 255],
        [218, 90, 255],
        [240, 84, 192],
        [240, 106, 86],
        [214, 134, 16],
        [186, 164, 0],
        [118, 192, 0],
        [70, 204, 26],
        [46, 200, 102],
        [52, 194, 190],
        [58, 58, 58],
        [0, 0, 0],
        [0, 0, 0],
        [255, 255, 255],
        [182, 218, 255],
        [200, 202, 255],
        [218, 194, 255],
        [240, 190, 255],
        [252, 188, 238],
        [250, 194, 192],
        [242, 204, 162],
        [230, 218, 146],
        [204, 230, 142],
        [184, 238, 162],
        [174, 234, 190],
        [174, 232, 226],
        [176, 176, 176],
        [0, 0, 0],
        [0, 0, 0],
        ];
}
