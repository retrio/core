nestest:
	haxe -main xgame.platform.nes.NES -neko nes.n -cp src
	nekotools boot nes.n
	./nes nestest.nes
