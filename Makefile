nestest:
	haxe -main xgame.platform.nes.NES -neko nes.n -cp src -lib openfl -lib openfl-native --macro "allowPackage('flash')"
	nekotools boot nes.n
	for i in assets/roms/*.nes; \
	do \
		echo "$$i"; \
		./nes "$$i"; \
	done
