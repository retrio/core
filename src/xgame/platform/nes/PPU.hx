package xgame.platform.nes;

import haxe.ds.Vector;
import flash.display.BitmapData;
import flash.geom.Point;


class PPU
{
    static var p0 = new Point();
    
    public static inline var RESOLUTION_X=256;
    public static inline var RESOLUTION_Y=240;
    
    public var screen:BitmapData;
    public var memory:Vector<Int>;
    public var oam:Vector<Int>;
    public var statusReg:Int=0;
    
    var nes:NES;
    var cpu:CPU;
    
    var tiles:Vector<Vector<BitmapData>>;
    var buffer:BitmapData;
    
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
    
    var oamAddr:Int=0;
    
    var scrollWrites:Int=0;
    var scrollX:Int=0;
    var scrollY:Int=0;
    
    var palette:Vector<Int>;
    
    var scanline:Int = 0;
    var spriteX:Int = 0;
    var readbuffer:Int = 0;
    var spriteShiftRegH:Vector<Int>;
    var spriteShiftRegL:Vector<Int>;
    
    public function new(nes:NES)
    {
        this.nes = nes;
        this.cpu = nes.cpu;
        
        screen = new BitmapData(RESOLUTION_X, RESOLUTION_Y);
        buffer = new BitmapData(RESOLUTION_X, RESOLUTION_Y);
        memory = new Vector(0x4000);
        oam = new Vector(0x100);
        for (i in 0 ... 0x100) oam[i] = 0xFF;
        
        palette = Vector.fromArrayCopy(defaultPalette);
        
        spriteShiftRegH = new Vector(8);
        spriteShiftRegL = new Vector(8);
        
        statusReg = 0;
    }
    
    public inline function read(reg:Int):Int
    {
        var result:Int = 0;
        switch(reg)
        {
            case 2:
            {
                // PPUSTATUS
                result = statusReg;
                statusReg &= 0x7F;
            }
            case 4:
            {
                // read from sprite ram
                result = oam[oamAddr];
            }
            case 7:
            {
                // PPUDATA
                result = memory[ppuAddr];
                ppuAddr += addrInc;
                tilesModified = true;
            }
        }
        return result;
    }
    
    public inline function write(reg:Int, data:Int)
    {
        data &= 0xFF;
        switch(reg)
        {
            case 0:
            {
                // PPUCTRL
                nameTableAddr = 0x2000 + (0x400 * data&0x3);
                addrInc = (data&0x4==1) ? 0x20 : 0x1;
                spriteAddr = (data&0x8==1) ? 0x1000 : 0x0;
                bgAddr = (data&0x10==1) ? 0x1000 : 0x0;
                tallSprites = (data&0x20==1);
                vBlankNMI = (data&0x80==1);
            }
            case 1:
            {
                // PPUMASK
                greyscale = (data&0x1==1);
                clipBg = (data&0x2==1);
                clipSprites = (data&0x4==1);
                showBg = (data&0x8==1);
                showSprites = (data&0x10==1);
                colorIntensity = (data>>4);
            }
            case 3:
            {
                // OAMADDR
                oamAddr = data;
            }
            case 4:
            {
                // OAMDATA
                oam[oamAddr] = data;
                oamAddr = (oamAddr + 1) & 0xFF;
            }
            case 5:
            {
                // PPUSCROLL
                if (scrollWrites == 0)
                {
                    // horizontal
                    scrollX = data;
                }
                else
                {
                    // vertical
                    scrollY = data;
                }
            }
            case 6:
            {
                // PPUADDR: write twice to set this register data
                if (ppuAddrWrites == 0)
                {
                    ppuAddr = data << 8;
                    ppuAddrWrites = 1;
                }
                else
                {
                    ppuAddr += data;
                    ppuAddrWrites = 0;
                }
            }
            case 7:
            {
                // PPUDATA: write to location specified by PPUADDR
                memory[ppuAddr] = data;
                ppuAddr += addrInc;
            }
            case 0x4014:
            {
            }
            case 0x4016:
            {
                // DMA (direct memory access, write CPU memory to sprite RAM)
                Vector.blit(cpu.memory, 0x100 * (data&0xFF), oam, 0, 0x100);
                cpu.ticks += 512;
            }
        }
    }
    
    public var rendering(get, never):Bool;
    function get_rendering() {
        // tells when it's ok to write to the ppu
        return (scanline >= 240) || (!showBg);
    }
    
    static inline var cyclesToScanline:Float = 113+2/3;
    var ticks:Float = 0;
    public inline function run(ticks:Float=1)
    {
        this.ticks += ticks;
        while (this.ticks > cyclesToScanline)
        {
            //drawScanline();
            this.ticks -= cyclesToScanline;
        }
    }
    
    var tilesModified:Bool=true;
    static var p:Point=new Point();
    inline function drawScanline()
    {
        if (scanline == 0 && tilesModified)
        {
            //preloadTiles();
        }
        
        scanline += 1;
        
        if (scanline == 240)
        {
            scanline = 0;
            render();
            // vblank
            statusReg |= 0x80;
            statusReg ^= (statusReg & 0x40);
            ticks -= 20;
        }
        
        var bgcolor = palette[memory[0x3F00]&0x3F];
        
        if (showBg && (scanline%8==0))
        {
            // draw the background one tile at a time
            var x0 = scrollX&7;
            var y0 = scrollY&7;
            var sx = (scrollX>>3)%64;
            var sy = ((scrollY+scanline)>>3)%30;
            for (x in 0 ... 32)
            {
                p.x = (x<<3)-x0;
                p.y = scanline-y0;
                buffer.copyPixels(tiles[sy][sx], tiles[sy][sx].rect, p);
            }
        }
        if (showSprites)
        {
            
        }
    }
    
    public inline function render()
    {
        trace('render');
        screen.copyPixels(buffer, buffer.rect, p0);
        buffer.fillRect(buffer.rect, 0);
    }
    
    inline function preloadTiles()
    {
        var nameTable:Int = 0x2000;
        var nameTable2:Int = nameTable == 0x2000 ? 0x2400 : 0x2000;
        
        for (y in 0 ... 240)
        {
            var ydiv = y>>3;
            var y7 = y&7;
            var a0 = nameTable + (ydiv<<5);
            var a1 = nameTable + 0x3C0 + ((y>>5)<<3);
            var y0 = (((y>>4)&0x1)<<2);
            var x0 = 0;
            for (x in 0 ... 64)
            {
                var sqColor = memory[a1];
                var colUpper = ((((sqColor>>(y0+x0)))&03)<<2);
                if (x % 4 == 3) a1 += 1;
                if (x % 2 == 1) x0 ^= 2;
                var patadr = (memory[a0+x]<<4) + y7;
                var b1 = memory[bgAddr+patadr];
                var b2 = memory[bgAddr+patadr+8];
                for (xi in 0 ... 8)
                {
                    var colLower = (b1>>(7-xi))&0x1;
                    colLower |= ((b2>>(7-xi))&0x1)<<1;
                    var cpos = 0x3F00+(colUpper+colLower);
                    if (cpos % 4 == 0) cpos = 0x3F00;
                    var color = memory[cpos]&0x3F;
                    tiles[ydiv][x].setPixel(xi,y7,palette[color]);
                }
            }
        }
    }
    
    static var defaultPalette=[
        82, 82, 82,
        0, 0, 128,
        8, 0, 138,
        44, 0, 126,
        74, 0, 78,
        80, 0, 6,
        68, 0, 0,
        38, 128, 0,
        10, 32, 0,
        0, 46, 0,
        0, 50, 0,
        0, 38, 10,
        0, 28, 72,
        0, 0, 0,
        0, 0, 0,
        0, 0, 0,
        164, 164, 164,
        0, 56, 206,
        52, 22, 236,
        94, 4, 220,
        140, 0, 176,
        154, 0, 76,
        144, 24, 0,
        112, 54, 0,
        76, 84, 0,
        14, 108, 0,
        0, 116, 0,
        0, 108, 44,
        0, 94, 132,
        0, 0, 0,
        0, 0, 0,
        0, 0, 0,
        255, 255, 255,
        76, 156, 255,
        124, 120, 255,
        166, 100, 255,
        218, 90, 255,
        240, 84, 192,
        240, 106, 86,
        214, 134, 16,
        186, 164, 0,
        118, 192, 0,
        70, 204, 26,
        46, 200, 102,
        52, 194, 190,
        58, 58, 58,
        0, 0, 0,
        0, 0, 0,
        255, 255, 255,
        182, 218, 255,
        200, 202, 255,
        218, 194, 255,
        240, 190, 255,
        252, 188, 238,
        250, 194, 192,
        242, 204, 162,
        230, 218, 146,
        204, 230, 142,
        184, 238, 162,
        174, 234, 190,
        174, 232, 226,
        176, 176, 176,
        0, 0, 0,
        0, 0, 0,
        ];
}
