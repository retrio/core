package strafe;


@:enum
abstract EmulationSpeed(Float) from Float to Float
{
	var Slow = 0.5;
	var Normal = 1;
	var Fast = 2;
}
