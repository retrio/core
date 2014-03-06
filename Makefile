cputest:
	openfl build neko -debug
	bin/linux64/neko/bin/xgame > test/log
	diff -y --suppress-common-lines test/log test/cpu-test-log
