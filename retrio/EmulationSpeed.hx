package retrio;


@:enum
abstract EmulationSpeed(Float) from Float to Float
{
	var Slow = 0.5;
	var Normal = 1;
	var Fast2x = 2;
	var Fast3x = 3;
	var Fast4x = 4;
}
