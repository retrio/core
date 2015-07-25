package retrio.ui.openfl.controllers;

import haxe.ds.Vector;
import flash.Lib;
import flash.events.KeyboardEvent;


class KeyboardController implements IController
{
	var _pressed:Vector<Bool> = new Vector(8);
	var _keyMap:Map<Int, Int> = new Map();

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
	public function new() {}

	function onKeyDown(e:Dynamic)
	{
		var code = e.keyCode;
		if (_keyMap.exists(code))
		{
			_pressed[_keyMap[code]] = true;
			inputHandler(_keyMap[code]);
		}
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

	public dynamic function inputHandler(e:Dynamic):Void {};
}
