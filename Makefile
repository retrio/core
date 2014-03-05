cputest:
	openfl build linux -v -debug
	bin/linux64/cpp/bin/xgame > log
	diff -y --suppress-common-lines log test/cpu-test-log
