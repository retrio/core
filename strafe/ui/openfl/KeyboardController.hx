package strafe.ui.openfl;

import haxe.ds.Vector;
import flash.Lib;
import flash.events.KeyboardEvent;
// TODO: eliminate
import strafe.emu.nes.NESControllerButton;


class KeyboardController implements IController
{
	var _pressed:Vector<Bool> = new Vector(8);
	var _keyMap:Map<Int, Int> = new Map();

	var defaults:Map<NESControllerButton, Int> = [
		A => 76,
		B => 75,
		Select => 9,
		Start => 13,
		Up => 87,
		Down => 83,
		Left => 65,
		Right => 68
	];

	public function init(e:Dynamic)
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 2);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 2);
	}

	public function remove(e:Dynamic)
	{
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
	}

	// abstract class
	public function new()
	{
		for (btn in defaults.keys())
			defineKey(defaults[btn], btn);
	}

	function onKeyDown(e:Dynamic)
	{
		var code = e.keyCode;
		if (_keyMap.exists(code))
			_pressed[_keyMap[code]] = true;
	}

	function onKeyUp(e:Dynamic)
	{
		var code = e.keyCode;
		if (_keyMap.exists(code))
			_pressed[_keyMap[code]] = false;
	}

	public function defineKey(keyCode:Int, button:Int)
	{
		_keyMap[keyCode] = button;
	}

	public function pressed(b:Dynamic):Bool
	{
		return _pressed[b];
	}
}
