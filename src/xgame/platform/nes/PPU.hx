package xgame.platform.nes;

import haxe.ds.Vector;


class PPU
{
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

	var loopyVWrites:Int = 0;
	var loopyV:Int = 0;
	var loopyT:Int = 0;
	var loopyX:Int = 0;

	var vraminc:Int=0x1;			// increase 1 across or 32 down
	var even = true;
	var bgpattern = true;
	var sprpattern = false;
	var greyscale:Bool = false;

	var oamAddr:Int = 0;

	var scrollWrites:Int = 0;
	var scrollX:Int = 0;
	var scrollY:Int = 0;

	var bgShiftRegH:Int = 0;
	var bgShiftRegL:Int = 0;
	var bgAttrShiftRegH:Int = 0;
	var bgAttrShiftRegL:Int = 0;
	var scanline:Int = 0;
	var spriteX:Int = 0;
	var ppuregs:Vector<Int> = new Vector(8);
	var spritebgflags:Vector<Bool> = new Vector(8);
	var spriteshiftregH:Vector<Int> = new Vector(8);
	var spriteshiftregL:Vector<Int> = new Vector(8);
	var spriteXlatch:Vector<Int> = new Vector(8);
	var spritepals:Vector<Int> = new Vector(8);
	var bgcolors:Vector<Int> = new Vector(8);
	var openBus:Int = 0;
	var readBuffer:Int = 0;
	var div:Int = 0;
	var frameCount:Int = 0;
	var tileaddr:Int = 0;
	var nextattr:Int = 0;
	var linelowbits:Int = 0;
	var linehighbits:Int = 0;
	var penultimateattr:Int = 0;

	var dotcrawl:Bool = true;
	var off:Int = 0;
	var y:Int = 0;
	var index:Int = 0;
	var sprpxl:Int = 0;
	var found:Int = 0;
	var sprite0here:Bool = false;

	var enabled(get, never):Bool;
	inline function get_enabled()
	{
		return true;//Util.getbit(ppuregs[1], 3) || Util.getbit(ppuregs[1], 4);
	}

	var vblank(default, set):Bool = false;
	inline function set_vblank(b:Bool)
	{
		ppuregs[2] = Util.setbit(ppuregs[2], 7, b);
		return vblank = b;
	}

	public function new(mapper:Mapper, cpu:CPU)
	{
		this.mapper = mapper;
		mapper.ppu = this;

		this.cpu = cpu;

		for (i in 0 ... oam.length) oam[i] = 0xFF;
		for (i in 0 ... bitmap.length) bitmap[i] = 0;
		for (i in 0 ... ppuregs.length) ppuregs[i] = 0;
		for (i in 0 ... t0.length) t0[i] = 0xa0;
		for (i in 0 ... t1.length) t1[i] = 0xb0;
		for (i in 0 ... t2.length) t2[i] = 0xc0;
		for (i in 0 ... t3.length) t3[i] = 0xd0;

		bgcolors = new Vector(256);
		pal = Vector.fromArrayCopy(defaultPalette);
	}

	public function clockLine(scanline:Int)
	{
		this.scanline = scanline;
		if (scanline == 0) ++frameCount;
		var skip = (scanline == 0
			&& Util.getbit(ppuregs[1], 3)
			&& !Util.getbit(frameCount, 1)) ? 1 : 0;
		for (i in skip ... 341)
		{
			cycles = i;
			clock();
		}
	}

	public function clock()
	{
		bgpattern = Util.getbit(ppuregs[0], 4);
		sprpattern = Util.getbit(ppuregs[0], 3);
		//cycle based ppu stuff will go here
		if (cycles == 1)
		{
			if (scanline == 0)
			{
				dotcrawl = enabled;
			}
			if (scanline < 240)
			{
				bgcolors[scanline] = pal[0];
			}
		}
		if (scanline < 240 || scanline == 261)
		{
			//on all rendering lines
			if (enabled
				&& ((cycles >= 1 && cycles <= 256)
				|| (cycles >= 321 && cycles <= 336)))
			{
				//fetch background tiles, load shift registers
				bgFetch();
			}
			else if (cycles == 257 && enabled)
			{
				//horizontal bits of loopyV = loopyT
				loopyV &= ~0x41f;
				loopyV |= loopyT & 0x41f;
			}
			else if (cycles > 257 && cycles <= 341)
			{
				//clear the oam address from pxls 257-341 continuously
				ppuregs[3] = 0;
			}
			if ((cycles == 340) && enabled)
			{
				//read the same nametable byte twice
				//this signals the MMC5 to increment the scanline counter
				fetchNTByte();
				fetchNTByte();
			}
			if (cycles == 260 && enabled)
			{
				//evaluate sprites for NEXT scanline (as long as either background or sprites are enabled)
				//this does in fact happen on scanline 261 but it doesn't do anything useful
				//it's cycle 260 because that's when the first important sprite byte is read
				//actually sprite overflow should be set by sprite eval somewhat before
				//so this needs to be split into 2 parts, the eval and the data fetches
				evalSprites();
			}
			if (scanline == 261)
			{
				if (cycles == 0)
				{// turn off vblank, sprite 0, sprite overflow flags
					vblank = false;
					ppuregs[2] &= 0x9F;
				} else if (cycles >= 280 && cycles <= 304 && enabled) {
					//loopyV = (all of)loopyT for each of these cycles
					loopyV = loopyT;
				}
			}
		}
		else if (scanline == 241 && cycles == 1)
		{
			//handle vblank on / off
			vblank = true;
		}
		if (scanline < 240)
		{
			if (cycles >= 1 && cycles <= 256)
			{
				var bufferoffset = (scanline << 8) + (cycles - 1);
				//bg drawing
				if (Util.getbit(ppuregs[1], 3))
				{
					//if background is on, draw a line of that
					var isBG = drawBGPixel(bufferoffset);
					//sprite drawing
					drawSprites(scanline << 8, cycles - 1, isBG);
				}
				else
				{
					//rendering is off, so draw either the background color OR
					//if the PPU address points to the palette, draw that color instead.
					var bgcolor = ((loopyV > 0x3f00 && loopyV < 0x3fff) ? mapper.ppuRead(loopyV) : pal[0]);
					bitmap[bufferoffset] = bgcolor;
				}
				//deal with the grayscale flag
				if (Util.getbit(ppuregs[1], 0))
				{
					bitmap[bufferoffset] &= 0x30;
				}
				//handle color emphasis
				var emph = (ppuregs[1] & 0xe0) << 1;
				bitmap[bufferoffset] = (bitmap[bufferoffset] & 0x3f) | emph;

			}
		}
		//handle nmi
		if (vblank && Util.getbit(ppuregs[0], 7))
		{
			//pull NMI line on when conditions are right
			cpu.nmi = true;
		}
		else
		{
			cpu.nmi = false;
		}

		//clock CPU, once every 3 ppu cycles
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
		else if (cycles == 340)
		{
			/*scanline = (scanline + 1) % 262;
			if (scanline == 0)
			{
				++frameCount;
			}*/
		}
	}

	public inline function read(reg:Int):Int
	{
		var result:Int = 0;
		switch(reg)
		{
			case 2:
			{
				// PPUSTATUS
				even = true;
				openBus = (ppuregs[2] & 0xe0) + (openBus & 0x1f);
				vblank = false;
			}
			case 4:
			{
				// read from sprite ram
				openBus = oam[oamAddr];
			}
			case 7:
			{
				// PPUDATA
				// read is buffered and returned next time
				// unless reading from sprite memory
				if ((loopyV & 0x3fff) < 0x3f00)
				{
					openBus = readBuffer;
					readBuffer = mapper.ppuRead(loopyV & 0x3FFF);
				}
				else
				{
					readBuffer = mapper.ppuRead((loopyV & 0x3fff) - 0x1000);
					openBus = mapper.ppuRead(loopyV);
				}
				if (!enabled || scanline > 240 && scanline < 261)
				{
					loopyV += vraminc;
				}
				else
				{
					incLoopyVHoriz();
					incLoopyVVert();
				}
			}
		}
		return openBus;
	}

	public inline function write(reg:Int, data:Int)
	{
		data &= 0xFF;
		openBus = data;

		switch(reg)
		{
			case 0:
				// PPUCTRL
				//trace(StringTools.hex(data));
				ppuregs[0] = data;
				vraminc = Util.getbit(data, 2) ? 32 : 1;
				loopyT &= 0xeff;
				loopyT += (data & 3) << 10;

			case 1:
				// PPUMASK
				ppuregs[1] = data;

			case 3:
				// OAMADDR
				oamAddr = data & 0xFF;

			case 4:
				// OAMDATA
				if ((oamAddr & 3) == 2) {
					oam[oamAddr++] = (data & 0xE3);
				} else {
					oam[oamAddr++] = data;
				}
				oamAddr &= 0xff;

			case 5:
				// PPUSCROLL
				if (even) {
					// update horizontal scroll
					loopyT &= ~0x1f;
					loopyX = data & 7;
					loopyT += data >> 3;

					even = false;
				}
				else
				{
					// update vertical scroll
					loopyT &= ~0x7000;
					loopyT |= ((data & 7) << 12);
					loopyT &= ~0x3e0;
					loopyT |= (data & 0xf8) << 2;
					even = true;
				}

			case 6:
				// PPUADDR: write twice to set this register data
				if (even)
				{
					// high byte
					loopyT &= 0xc0ff;
					loopyT |= ((data & 0x3f) << 8);
					loopyT &= 0x3fff;
					even = false;
				}
				else
				{
					loopyT &= 0x7f00;
					loopyT |= data;
					loopyV = loopyT;
					even = true;
				}

			case 7:
				// PPUDATA: write to location specified by loopyV
				//memory[loopyV] = data;
				mapper.ppuWrite((loopyV & 0x3fff), data);
				if (enabled || (scanline > 240 && scanline < 261))
				{
					loopyV += vraminc;
				}
				else
				{
					//if 2007 is read during rendering PPU increments both horiz
					//and vert counters erroneously.
					if (((cycles - 1) & 7) != 7)
					{
						incLoopyVHoriz();
						incLoopyVVert();
					}
				}
		}
	}

	function incLoopyVVert()
	{
		var newfinescroll = (loopyV & 0x7000) + 0x1000;
		loopyV &= ~0x7000;
		if (newfinescroll > 0x7000)
		{
			//reset the fine scroll bits and increment tile address to next row
			loopyV += 32;
		}
		else
		{
			//increment the fine scroll
			loopyV += newfinescroll;
		}
		if (((loopyV >> 5) & 0x1f) == 30)
		{
			//if incrementing loopy_v to the next row pushes us into the next
			//nametable, zero the "row" bits and go to next nametable
			loopyV &= ~0x3e0;
			loopyV ^= 0x800;
		}
	}

	function incLoopyVHoriz()
	{
		//increment horizontal part of loopyv
		if ((loopyV & 0x001F) == 31) // if coarse X == 31
		{
			loopyV &= ~0x001F; // coarse X = 0
			loopyV ^= 0x0400;// switch horizontal nametable
		}
		else
		{
			loopyV += 1;// increment coarse X
		}
	}

	function bgFetch()
	{
		//fetch tiles for background
		//on real PPU this logic is repurposed for sprite fetches as well
		bgAttrShiftRegH |= ((nextattr >> 1) & 1);
		bgAttrShiftRegL |= (nextattr & 1);
		//background fetches
		switch ((cycles - 1) & 7)
		{
			case 1:
				fetchNTByte();

			case 3:
				//fetch attribute (FIX MATH)
				penultimateattr = getAttribute(((loopyV & 0xc00) + 0x23c0),
						(loopyV) & 0x1f,
						(((loopyV) & 0x3e0) >> 5));

			case 5:
				//fetch low bg byte
				linelowbits = mapper.ppuRead((tileaddr)
						+ ((loopyV & 0x7000) >> 12));

			case 7:
				//fetch high bg byte
				linehighbits = mapper.ppuRead((tileaddr) + 8
						+ ((loopyV & 0x7000) >> 12));
				bgShiftRegL |= linelowbits;
				bgShiftRegH |= linehighbits;
				nextattr = penultimateattr;
				if (cycles != 256) {
					incLoopyVHoriz();
				} else {
					incLoopyVVert();
				}

			default: {}
		}

		if (cycles >= 321 && cycles <= 336) {
			bgShiftClock();
		}
	}

	function fetchNTByte()
	{
		//fetch nt byte
		tileaddr = mapper.ppuRead(
				((loopyV & 0xc00) | 0x2000) + (loopyV & 0x3ff)) * 16
				+ (bgpattern ? 0x1000 : 0);
	}

	function drawBGPixel(bufferoffset:Int):Bool
	{
		//background drawing
		//loopyX picks bits
		var isBG:Bool;
		if (!Util.getbit(ppuregs[1], 1) && (bufferoffset & 0xff) < 8)
		{
			//left hand of screen clipping
			//(needs to be marked as BG and not cause a sprite hit)
			bitmap[bufferoffset] = pal[0];
			isBG = true;
		}
		else
		{
			var bgPix = (Util.getbitI(bgShiftRegH, -loopyX + 16) << 1)
					+ Util.getbitI(bgShiftRegL, -loopyX + 16);
			var bgPal = (Util.getbitI(bgAttrShiftRegH, -loopyX + 8) << 1)
					+ Util.getbitI(bgAttrShiftRegL, -loopyX + 8);
			isBG = (bgPix == 0);
			bitmap[bufferoffset] = (isBG ? pal[0] : pal[(bgPal << 2) + bgPix]);
		}
		bgShiftClock();
		return isBG;
	}

	function bgShiftClock()
	{
		bgShiftRegH <<= 1;
		bgShiftRegL <<= 1;
		bgAttrShiftRegH <<= 1;
		bgAttrShiftRegL <<= 1;
	}

	/**
	 * evaluates PPU sprites for the NEXT scanline
	 */
	function evalSprites()
	{
		sprite0here = false;
		bgpattern = Util.getbit(ppuregs[0], 4);
		sprpattern = Util.getbit(ppuregs[0], 3);
		var ypos:Int = 0;
		var offset:Int = 0;
		var tilefetched:Int = 0;
		found = 0;
		var spritesize = Util.getbit(ppuregs[0], 5);
		//primary evaluation
		//need to emulate behavior when OAM address is set to nonzero here
		var spritestart = 0;
		while (spritestart < 255)
		{
			//for each sprite, first we cull the non-visible ones
			ypos = oam[spritestart];
			offset = scanline - ypos;
			if (ypos > scanline || offset > (spritesize ? 15 : 7))
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
				ppuregs[2] |= 0x20;
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
				if (Util.getbit(oamextra, 7)) {
					//if sprite is flipped vertically, reverse the offset
					offset = (spritesize ? 15 : 7) - offset;
				}
				//now correction for the fact that 8x16 tiles are 2 separate tiles
				if (offset > 7) {
					offset += 8;
				}
				//get tile address (8x16 sprites can use both pattern tbl pages but only the even tiles)
				var tilenum = oam[spritestart + 1];
				spriteFetch(spritesize, tilenum, offset, oamextra);
				++found;
			}

			spritestart += 4;
		}
		for (i in found ... 8)
		{
			//fill unused sprite registers with zeros
			spriteshiftregL[found] = 0;
			spriteshiftregH[found] = 0;
			//also, we need to do 8 reads no matter how many sprites we found
			//dummy reads are to sprite 0xff
			spriteFetch(spritesize, 0xff, 0, 0);
		}
	}

	function spriteFetch(spritesize:Bool, tilenum:Int, offset:Int, oamextra:Int)
	{
		var tilefetched:Int;
		if (spritesize)
		{
			tilefetched = ((tilenum & 1) * 0x1000)
					+ (tilenum & 0xfe) * 16;
		}
		else
		{
			tilefetched = tilenum * 16
					+ ((sprpattern) ? 0x1000 : 0);
		}
		tilefetched += offset;
		//now load up the shift registers for said sprite
		var hflip:Bool = Util.getbit(oamextra, 6);
		if (!hflip)
		{
			spriteshiftregL[found] = Util.reverseByte(mapper.ppuRead(tilefetched));
			spriteshiftregH[found] = Util.reverseByte(mapper.ppuRead(tilefetched + 8));
		}
		else
		{
			spriteshiftregL[found] = mapper.ppuRead(tilefetched);
			spriteshiftregH[found] = mapper.ppuRead(tilefetched + 8);
		}
	}

	/**
	 * draws appropriate lines of the sprites selected by sprite evaluation
	 */
	function drawSprites(bufferoffset:Int, x:Int, bgflag:Bool)
	{
		var startdraw = Util.getbit(ppuregs[1], 2) ? 0 : 8;//sprite left 8 pixels clip
		sprpxl = 0;
		index = 7;
		//per pixel in de line that could have a sprite
		var y = found - 1;
		while (y >= 0)
		{
			off = x - spriteXlatch[y];
			if (off >= 0 && off <= 8)
			{
				if ((spriteshiftregH[y] & 1) + (spriteshiftregL[y] & 1) != 0)
				{
					index = y;
					sprpxl = 2 * (spriteshiftregH[y] & 1) + (spriteshiftregL[y] & 1);
				}
				spriteshiftregH[y] >>= 1;
				spriteshiftregL[y] >>= 1;
			}
			--y;
		}
		if (sprpxl == 0 || x < startdraw || !Util.getbit(ppuregs[1], 4))
		{
			//no opaque sprite pixel here
			return;
		}

		if (sprite0here && (index == 0) && !bgflag && x < 255)
		{
			//sprite 0 hit!
			ppuregs[2] |= 0x40;
			//ppuregs[1] |= 1;//debug
		}
		//now, FINALLY, drawing.
		if (!spritebgflags[index] || bgflag)
		{
			bitmap[bufferoffset + x] = pal[spritepals[index] + sprpxl];
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
	function getAttribute(ntstart:Int, tileX:Int, tileY:Int)
	{
		var base = mapper.ppuRead(ntstart + (tileX >> 2) + 8 * (tileY >> 2));
		if (Util.getbit(tileY, 1)) {
			if (Util.getbit(tileX, 1)) {
				return (base >> 6) & 3;
			} else {
				return (base >> 4) & 3;
			}
		} else {
			if (Util.getbit(tileX, 1)) {
				return (base >> 2) & 3;
			} else {
				return base & 3;
			}
		}
	}

	static var defaultPalette=[
		0x09, 0x01, 0x00, 0x01, 0x00, 0x02, 0x02, 0x0D,
		0x08, 0x10, 0x08, 0x24, 0x00, 0x00, 0x04, 0x2C, 0x09, 0x01, 0x34, 0x03,
		0x00, 0x04, 0x00, 0x14, 0x08, 0x3A, 0x00, 0x02, 0x00, 0x20, 0x2C, 0x08
	];
}
