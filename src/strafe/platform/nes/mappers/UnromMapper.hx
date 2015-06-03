package strafe.platform.nes.mappers;

import strafe.platform.nes.Mapper;


class UnromMapper extends Mapper
{
	var bank:Int = 0;

	override public function onLoad()
	{
		super.onLoad();

		for (i in 1 ... 17)
		{
			// fixed bank
			prgMap[32-i] = rom.prgSize - (0x400 * i);
		}
	}

	override public function write(addr:Int, data:Int)
	{
		if (addr < 0x8000 || addr > 0xffff)
		{
			super.write(addr, data);
		}
		else
		{
			bank = data & 0xf;
			//remap PRG bank (1st bank switchable, 2nd bank mapped to LAST bank)
			for (i in 0 ... 16)
			{
				prgMap[i] = (1024 * (i + 16 * bank)) & (rom.prgSize - 1);
			}
		}
	}
}
