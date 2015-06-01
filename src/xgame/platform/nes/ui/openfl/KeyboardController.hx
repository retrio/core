package xgame.platform.nes.ui.openfl;

import haxe.ds.Vector;
import flash.Lib;
import flash.events.KeyboardEvent;


class KeyboardController extends NESController
{
	static var defaults:Map<NESControllerButton, Int> = [
		A => 76,
		B => 75,
		Select => 9,
		Start => 13,
		Up => 87,
		Down => 83,
		Left => 65,
		Right => 68
	];

	var _pressed:Vector<Bool> = new Vector(8);
	var _keyMap:Map<Int, NESControllerButton> = new Map();

	override public function init(e:Dynamic)
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false,  2);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false,  2);
	}

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

	public function defineKey(keyCode:Int, button:NESControllerButton)
	{
		_keyMap[keyCode] = button;
	}

	override public function pressed(b:Dynamic):Bool
	{
		return _pressed[b];
	}
}
