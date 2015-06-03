package strafe.emu.nes;

import haxe.ds.Vector;


class PPU implements IState
{
	static var defaultPalette=[
		0x09, 0x01, 0x00, 0x01, 0x00, 0x02, 0x02, 0x0D,
		0x08, 0x10, 0x08, 0x24, 0x00, 0x00, 0x04, 0x2C, 0x09, 0x01, 0x34, 0x03,
		0x00, 0x04, 0x00, 0x14, 0x08, 0x3A, 0x00, 0x02, 0x00, 0x20, 0x2C, 0x08
	];

	public var mapper:Mapper;
	public var cpu:CPU;

	public static inline var RESOLUTION_X=256;
	public static inline var RESOLUTION_Y=240;

	public var oam:Vector<Int> = new Vector(0x100);
	public var t0:Vector<Int> = new Vector(0x400);
	public var t1:Vector<Int> = new Vector(0x400);
	public var t2:Vector<Int> = new Vector(0x400);
	public var t3:Vector<Int> = new Vector(0x400);
	public var statusReg:Int=0;

	public var cycles:Int = 0;

	public var pal:Vector<Int> = new Vector(32);

	public var bitmap:Vector<Int> = new Vector(240 * 256);

	var vramAddr:Int = 0;
	var vramAddrTemp:Int = 0;
	var xScroll:Int = 0;
	var even = true;

	var bgPatternAddr = 0;
	var sprPatternAddr = 0;

	var oamAddr:Int = 0;

	var bgShiftRegH:Int = 0;
	var bgShiftRegL:Int = 0;
	var bgAttrShiftRegH:Int = 0;
	var bgAttrShiftRegL:Int = 0;
	var scanline:Int = 0;
	// $2000 PPUCTRL registers
	var nmiEnabled:Bool = false;
	var ntAddr:Int = 0;
	var vramInc:Int = 1;
	var tallSprites:Bool = false;
	// $2001 PPUMASK registers
	var greyscale:Bool = false;
	var bgClip:Bool = false;
	var sprClip:Bool = false;
	var bgRender:Bool = false;
	var sprRender:Bool = false;
	var emph:Int = 0;
	// $2002 PPUSTATUS registers
	var spriteOverflow:Bool = false;
	var sprite0:Bool = false;
	var vblank:Bool = false;

	var spritebgflags:Vector<Bool> = new Vector(8);
	var spriteShiftRegH:Vector<Int> = new Vector(8);
	var spriteShiftRegL:Vector<Int> = new Vector(8);
	var spriteXlatch:Vector<Int> = new Vector(8);
	var spritepals:Vector<Int> = new Vector(8);
	var openBus:Int = 0;
	var readBuffer:Int = 0;
	var div:Int = 2;
	var frameCount:Int = 0;
	var tileAddr:Int = 0;
	var tileL:Int = 0;
	var tileH:Int = 0;
	var attr:Int = 0;
	var attrH:Int = 0;
	var attrL:Int = 0;

	var off:Int = 0;
	var index:Int = 0;
	var sprpxl:Int = 0;
	var found:Int = 0;
	var sprite0here:Bool = false;

	var enabled(get, never):Bool;
	inline function get_enabled()
	{
		return bgRender || sprRender;
	}

	public function new(mapper:Mapper, cpu:CPU)
	{
		this.mapper = mapper;
		mapper.ppu = this;

		this.cpu = cpu;

		for (i in 0 ... oam.length) oam[i] = 0xFF;
		for (i in 0 ... bitmap.length) bitmap[i] = 0;
		for (i in 0 ... t0.length) t0[i] = 0x00;
		for (i in 0 ... t1.length) t1[i] = 0x00;
		for (i in 0 ... t2.length) t2[i] = 0x00;
		for (i in 0 ... t3.length) t3[i] = 0x00;

		pal = Vector.fromArrayCopy(defaultPalette);
	}

	public inline function runFrame(render:Bool)
	{
		++frameCount;
		scanline = 0;
		cycles = 0;
		for (i in 0 ... (262*341))
		{
			clock(render);
			if (++cycles > 340)
			{
				cycles = 0;
				++scanline;
			}
		}
	}

	public inline function clock(render:Bool)
	{
		var enabled = enabled;

		if (scanline < 240 || scanline == 261)
		{
			// visible scanlines
			if (enabled
				&& ((cycles >= 1 && cycles <= 256)
				|| (cycles >= 321 && cycles <= 336)))
			{
				// fetch background tiles, load shift registers
				bgFetch();
			}
			else if (cycles == 257 && enabled)
			{
				// horizontal bits of vramAddr = vramAddrTemp
				vramAddr &= ~0x41f;
				vramAddr |= vramAddrTemp & 0x41f;
			}
			else if (cycles > 257 && cycles <= 341)
			{
				// clear the oam address from pxls 257-341 continuously
				oamAddr = 0;
			}
			if ((cycles == 340) && enabled)
			{
				// read the same nametable byte twice
				// this signals the MMC5 to increment the scanline counter
				fetchNTByte();
				fetchNTByte();
			}
			if (cycles == 260 && enabled)
			{
				evalSprites();
			}
			if (scanline == 261)
			{
				if (cycles == 0)
				{
					// turn off vblank, sprite 0, sprite overflow flags
					vblank = sprite0 = spriteOverflow = false;
				}
				else if (cycles >= 280 && cycles <= 304 && enabled)
				{
					vramAddr = vramAddrTemp;
				}
			}
		}
		else if (scanline == 241 && cycles == 1)
		{
			vblank = true;
		}
		if (scanline < 240)
		{
			if (cycles >= 1 && cycles <= 256)
			{
				var bufferOffset = (scanline << 8) + (cycles - 1);
				// bg drawing
				if (bgRender)
				{
					//if background is on, draw a line of that
					var isBG = drawBGPixel(bufferOffset);
					//sprite drawing
					drawSprites(scanline << 8, cycles - 1, isBG);
				}
				else
				{
					// rendering is off, so draw either the background color OR
					// if the PPU address points to the palette, draw that color instead.
					var bgcolor = ((vramAddr > 0x3f00 && vramAddr < 0x3fff) ? mapper.ppuRead(vramAddr) : pal[0]);
					bitmap[bufferOffset] = bgcolor;
				}
				// greyscale
				if (greyscale)
				{
					bitmap[bufferOffset] &= 0x30;
				}
				// color emphasis
				bitmap[bufferOffset] = (bitmap[bufferOffset] & 0x3f) | emph;
			}
		}
		if (vblank && nmiEnabled)
		{
			// signal NMI
			cpu.nmi = true;
		}
		else
		{
			cpu.nmi = false;
		}

		// clock CPU, once every 3 PPU cycles
		div = (div + 1) % 3;
		if (div == 0)
		{
			cpu.runCycle();
			mapper.onCpuCycle(1);
		}
		if (cycles == 257)
		{
			mapper.onScanline(scanline);
		}
	}

	public inline function read(reg:Int):Int
	{
		var result:Int = 0;
		switch(reg)
		{
			case 2:
				// PPUSTATUS
				even = true;
				openBus = ((spriteOverflow ? 1 : 0) << 5) |
					((sprite0 ? 1 : 0) << 6) |
					((vblank ? 1 : 0) << 7) |
					(openBus & 0x1f);
				vblank = false;

			case 4:
				// read from sprite ram
				openBus = oam[oamAddr];

			case 7:
				// PPUDATA
				// read is buffered and returned next time
				// unless reading from sprite memory
				if ((vramAddr & 0x3fff) < 0x3f00)
				{
					openBus = readBuffer;
					readBuffer = mapper.ppuRead(vramAddr);
				}
				else
				{
					readBuffer = mapper.ppuRead((vramAddr & 0x3fff) - 0x1000);
					openBus = mapper.ppuRead(vramAddr);
				}
				if (!enabled || scanline > 240 && scanline < 261)
				{
					vramAddr += vramInc;
				}
				else
				{
					incrementX();
					incrementY();
				}

			default: {}
		}
		return openBus;
	}

	public inline function write(reg:Int, data:Int)
	{
		openBus = data;

		switch(reg)
		{
			case 0:
				// PPUCTRL
				vramAddrTemp &= ~0xc00;
				vramAddrTemp += (data & 3) << 10;
				vramInc = Util.getbit(data, 2) ? 32 : 1;
				sprPatternAddr = Util.getbit(data, 3) ? 0x1000 : 0;
				bgPatternAddr = Util.getbit(data, 4) ? 0x1000 : 0;
				tallSprites = Util.getbit(data, 5);
				//ppu master/slave?
				nmiEnabled = Util.getbit(data, 7);

			case 1:
				// PPUMASK
				greyscale = Util.getbit(data, 0);
				bgClip = Util.getbit(data, 1);
				sprClip = Util.getbit(data, 2);
				bgRender = Util.getbit(data, 3);
				sprRender = Util.getbit(data, 4);
				emph = (data & 0xe0) << 1;

			case 3:
				// OAMADDR
				oamAddr = data;

			case 4:
				// OAMDATA
				if (!(enabled && scanline <= 239))
				{
					oam[oamAddr++] = data;
					oamAddr &= 0xff;
				}

			case 5:
				// PPUSCROLL
				if (even)
				{
					// update horizontal scroll
					vramAddrTemp &= ~0x1f;
					xScroll = data & 7;
					vramAddrTemp += data >> 3;
					even = false;
				}
				else
				{
					// update vertical scroll
					vramAddrTemp &= ~0x7000;
					vramAddrTemp |= ((data & 7) << 12);
					vramAddrTemp &= ~0x3e0;
					vramAddrTemp |= (data & 0xf8) << 2;
					even = true;
				}

			case 6:
				// PPUADDR: write twice to set this register data
				if (even)
				{
					// high byte
					vramAddrTemp &= 0xc0ff;
					vramAddrTemp |= ((data & 0x3f) << 8);
					vramAddrTemp &= 0x3fff;
					even = false;
				}
				else
				{
					vramAddrTemp &= 0x7f00;
					vramAddrTemp |= data;
					vramAddr = vramAddrTemp;
					//trace(StringTools.hex(vramAddr));
					even = true;
				}

			case 7:
				// PPUDATA: write to location specified by vramAddr
				mapper.ppuWrite((vramAddr & 0x3fff), data);
				if (!enabled || (scanline > 240 && scanline < 261))
				{
					vramAddr += vramInc;
				}
				else
				{
					//if 2007 is read during rendering PPU increments both horiz
					//and vert counters erroneously.
					if (((cycles - 1) & 7) != 7)
					{
						incrementX();
						incrementY();
					}
				}
		}
	}

	inline function incrementY()
	{
		var newfinescroll = (vramAddr & 0x7000) + 0x1000;
		vramAddr &= ~0x7000;
		if (newfinescroll > 0x7000)
		{
			//reset the fine scroll bits and increment tile address to next row
			vramAddr += 32;
		}
		else
		{
			vramAddr += newfinescroll;
		}
		if (((vramAddr >> 5) & 0x1f) == 30)
		{
			vramAddr &= ~0x3e0;
			vramAddr ^= 0x800;
		}
	}

	inline function incrementX()
	{
		//increment horizontal part of vramAddr
		// if coarse X == 31
		if ((vramAddr & 0x001F) == 31)
		{
			// coarse X = 0
			vramAddr &= ~0x001F;
			// switch horizontal nametable
			vramAddr ^= 0x0400;
		}
		else
		{
			// increment coarse X
			++vramAddr;
		}
	}

	inline function bgFetch()
	{
		bgShiftClock();

		bgAttrShiftRegH |= attrH;
		bgAttrShiftRegL |= attrL;

		//background fetches
		switch ((cycles - 1) & 7)
		{
			case 1:
				fetchNTByte();

			case 3:
				//fetch attribute
				attr = getAttribute(((vramAddr & 0xc00) | 0x23c0),
								(vramAddr) & 0x1f,
								(((vramAddr) & 0x3e0) >> 5));

			case 5:
				//fetch low bg byte
				tileL = mapper.ppuRead((tileAddr) + ((vramAddr & 0x7000) >> 12)) & 0xFF;

			case 7:
				//fetch high bg byte
				tileH = mapper.ppuRead((tileAddr) + ((vramAddr & 0x7000) >> 12) + 8) & 0xFF;

				bgShiftRegH |= tileH;
				bgShiftRegL |= tileL;

				attrH = (attr >> 1) & 1;
				attrL = attr & 1;

				if (cycles != 256)
				{
					incrementX();
				}
				else
				{
					incrementY();
				}

			default: {}
		}
	}

	inline function fetchNTByte()
	{
		//fetch nt byte
		tileAddr = (mapper.ppuRead(
				((vramAddr & 0xc00) | 0x2000) + (vramAddr & 0x3ff)) << 4)
				+ (bgPatternAddr);
	}

	inline function drawBGPixel(bufferOffset:Int):Bool
	{
		//background drawing
		//xScroll picks bits
		var isBG:Bool;
		if (!bgClip && (bufferOffset & 0xff) < 8)
		{
			//left hand of screen clipping
			//(needs to be marked as BG and not cause a sprite hit)
			bitmap[bufferOffset] = pal[0];
			isBG = true;
		}
		else
		{
			var bgPix = (Util.getbitI(bgShiftRegH, 16 - xScroll) << 1)
					+ Util.getbitI(bgShiftRegL, 16 - xScroll);
			var bgPal = (Util.getbitI(bgAttrShiftRegH, 8 - xScroll) << 1)
					+ Util.getbitI(bgAttrShiftRegL, 8 - xScroll);
			isBG = (bgPix == 0);
			bitmap[bufferOffset] = (isBG ? pal[0] : pal[(bgPal << 2) + bgPix]);
		}
		return isBG;
	}

	inline function bgShiftClock()
	{
		bgShiftRegH <<= 1;
		bgShiftRegL <<= 1;
		bgAttrShiftRegH <<= 1;
		bgAttrShiftRegL <<= 1;
	}

	/**
	 * evaluates PPU sprites for the NEXT scanline
	 */
	inline function evalSprites()
	{
		sprite0here = false;
		var ypos:Int = 0;
		var offset:Int = 0;
		var tilefetched:Int = 0;
		found = 0;
		//primary evaluation
		//need to emulate behavior when OAM address is set to nonzero here
		var spritestart = 0;
		while (spritestart < 255)
		{
			//for each sprite, first we cull the non-visible ones
			ypos = oam[spritestart];
			offset = scanline - ypos;
			if (ypos > scanline || offset > (tallSprites ? 15 : 7))
			{
				//sprite is out of range vertically
				spritestart += 4;
				continue;
			}
			//if we're here it's a valid renderable sprite
			if (spritestart == 0)
			{
				sprite0here = true;
			}
			//actually which sprite is flagged for sprite 0 depends on the starting
			//oam address which is, on the real thing, not necessarily zero.
			if (found >= 8)
			{
				//if more than 8 sprites, set overflow bit and STOP looking
				//todo: add "no sprite limit" option back
				spriteOverflow = true;
				break; //also the real PPU does strange stuff on sprite overflow.
			}
			else
			{
				//set up ye sprite for rendering
				var oamextra = oam[spritestart + 2];
				//bg flag
				spritebgflags[found] = Util.getbit(oamextra, 5);
				//x value
				spriteXlatch[found] = oam[spritestart + 3];
				spritepals[found] = ((oamextra & 3) + 4) * 4;
				if (Util.getbit(oamextra, 7))
				{
					//if sprite is flipped vertically, reverse the offset
					offset = (tallSprites ? 15 : 7) - offset;
				}
				//now correction for the fact that 8x16 tiles are 2 separate tiles
				if (offset > 7)
				{
					offset += 8;
				}
				//get tile address (8x16 sprites can use both pattern tbl pages but only the even tiles)
				var tilenum = oam[spritestart + 1];
				spriteFetch(tilenum, offset, oamextra);
				++found;
			}

			spritestart += 4;
		}
		for (i in found ... 8)
		{
			// fill unused sprite registers with zeros
			spriteShiftRegL[i] = 0;
			spriteShiftRegH[i] = 0;
		}
	}

	inline function spriteFetch(tilenum:Int, offset:Int, oamextra:Int)
	{
		var tilefetched:Int;
		if (tallSprites)
		{
			tilefetched = ((tilenum & 1) * 0x1000)
					+ (tilenum & 0xfe) * 16;
		}
		else
		{
			tilefetched = tilenum * 16
					+ (sprPatternAddr);
		}
		tilefetched += offset;
		//now load up the shift registers for said sprite
		var hflip:Bool = Util.getbit(oamextra, 6);
		if (!hflip)
		{
			spriteShiftRegL[found] = Util.reverseByte(mapper.ppuRead(tilefetched));
			spriteShiftRegH[found] = Util.reverseByte(mapper.ppuRead(tilefetched + 8));
		}
		else
		{
			spriteShiftRegL[found] = mapper.ppuRead(tilefetched);
			spriteShiftRegH[found] = mapper.ppuRead(tilefetched + 8);
		}
	}

	/**
	 * draws appropriate lines of the sprites selected by sprite evaluation
	 */
	inline function drawSprites(bufferOffset:Int, x:Int, bgflag:Bool)
	{
		//sprite left 8 pixels clip
		var startdraw = sprClip ? 0 : 8;
		sprpxl = 0;
		index = 7;
		//per pixel in de line that could have a sprite
		var y = found - 1;
		while (y >= 0)
		{
			off = x - spriteXlatch[y];
			if (off >= 0 && off <= 8)
			{
				if ((spriteShiftRegH[y] & 1) + (spriteShiftRegL[y] & 1) != 0)
				{
					index = y;
					sprpxl = 2 * (spriteShiftRegH[y] & 1) + (spriteShiftRegL[y] & 1);
				}
				spriteShiftRegH[y] >>= 1;
				spriteShiftRegL[y] >>= 1;
			}
			--y;
		}
		if (sprpxl == 0 || x < startdraw || !sprRender)
		{
			//no opaque sprite pixel here
		}
		else
		{
			if (sprite0here && (index == 0) && !bgflag && x < 255)
			{
				//sprite 0 hit
				sprite0 = true;
			}
			//now, FINALLY, drawing.
			if (!spritebgflags[index] || bgflag)
			{
				bitmap[bufferOffset + x] = pal[spritepals[index] + sprpxl];
			}
		}
	}

	/**
	 * Read the appropriate color attribute byte for the current tile. this is
	 * fetched 2x as often as it really needs to be, the MMC5 takes advantage of
	 * that for ExGrafix mode.
	 *
	 * @param ntstart //start of the current attribute table
	 * @param tileX //x position of tile (0-31)
	 * @param tileY //y position of tile (0-29)
	 * @return attribute table value (0-3)
	 */
	inline function getAttribute(ntstart:Int, tileX:Int, tileY:Int)
	{
		var base = mapper.ppuRead(ntstart + (tileX >> 2) + 8 * (tileY >> 2));
		if (Util.getbit(tileY, 1))
		{
			if (Util.getbit(tileX, 1))
			{
				return (base >> 6) & 3;
			}
			else
			{
				return (base >> 4) & 3;
			}
		}
		else
		{
			if (Util.getbit(tileX, 1))
			{
				return (base >> 2) & 3;
			}
			else
			{
				return base & 3;
			}
		}
	}

	public function writeState(out:haxe.io.Output)
	{
		// TODO
	}
}
