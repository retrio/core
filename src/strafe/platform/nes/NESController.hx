package strafe.platform.nes;


class NESController implements IController
{
	var _currentBtn = 0;

	public function init(e:Dynamic) {}
	public function pressed(b:Dynamic) return false;

	public function latch()
	{
		_currentBtn = 0;
	}

	public function pop()
	{
		var val = pressed(_currentBtn) ? 0x1 : 0x0;
		++_currentBtn;
		_currentBtn &= 7;
		return val;
	}
}
