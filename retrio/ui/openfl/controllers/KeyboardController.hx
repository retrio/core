package retrio.ui.openfl.controllers;

import haxe.ds.Vector;
import flash.Lib;
import flash.events.KeyboardEvent;


class KeyboardController implements IController
{
	public static var name = "Keyboard";

	static inline var MOD_SHIFT = 0x1000;
	static inline var MOD_CTRL = 0x2000;
	static inline var KEYCODE = 0xfff;

	static var keyNames:Map<Int, String> = [
		8  => "Backspace",
		9  => "Tab",
		13 => "Enter",
		15 => "Cmd",
		16 => "Shift",
		17 => "Ctrl",
		20 => "Caps Lock",
		27 => "Esc",
		32 => "Space",
		33 => "PgUp",
		34 => "PgDown",
		35 => "End",
		36 => "Home",
		37 => "Left",
		38 => "Up",
		39 => "Right",
		40 => "Down",
		45 => "Insert",
		46 => "Delete",
		106 => "Numpad *",
		107 => "Numpad +",
		108 => "Numpad Enter",
		109 => "Numpad -",
		110 => "Numpad .",
		111 => "Numpad /",

		219 => "[",
		221 => "]",
		192 => "`",
	];

	static var active:Map<KeyboardController, Bool> = new Map();

	public static function init()
	{
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownAll, false, 2);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpAll, false, 2);
	}

	static function onKeyDownAll(e:Dynamic)
	{
		for (controller in active.keys())
		{
			controller.onKeyDown(e);
		}
	}

	static function onKeyUpAll(e:Dynamic)
	{
		for (controller in active.keys())
		{
			controller.onKeyUp(e);
		}
	}

	static inline function keyCode(e:Dynamic)
	{
		var code = e.keyCode;
		if (e.ctrlKey) code |= MOD_CTRL;
		if (e.shiftKey) code |= MOD_SHIFT;
		return code;
	}

	var _pressed:Vector<Bool> = new Vector(8);
	var _keyMap:Map<Int, Int> = new Map();
	var _buttonMap:Map<Int, Int> = new Map();
	var _askCallback:Null<Int->Void> = null;

	public function new() {}

	public function add()
	{
		active[this] = true;
	}

	public function remove()
	{
		if (active.exists(this)) active.remove(this);
	}

	function onKeyDown(e:Dynamic)
	{
		var code = keyCode(e);
		if (_askCallback != null)
		{
			_askCallback(code);
			_askCallback = null;
		}
		if (_keyMap.exists(code))
		{
			_pressed[_keyMap[code]] = true;
			inputHandler(_keyMap[code]);
		}
	}

	function onKeyUp(e:Dynamic)
	{
		var code = keyCode(e);
		if (_keyMap.exists(code))
			_pressed[_keyMap[code]] = false;
	}

	public function define(keyCode:Int, button:Int)
	{
		clearDefinition(button);
		_keyMap[keyCode] = button;
		_buttonMap[button] = keyCode;
	}

	public function clearDefinition(button:Int)
	{
		if (_buttonMap.exists(button))
		{
			_keyMap.remove(_buttonMap[button]);
			_buttonMap.remove(button);
		}
	}

	public function pressed(b:Int):Bool
	{
		return _pressed[b];
	}

	public dynamic function inputHandler(e:Dynamic):Void {};

	public function ask(callback:Null<Int->Void>):Void
	{
		_askCallback = callback;
	}

	public function codeName(code:Int):String
	{
		return ((code & MOD_CTRL > 0) ? #if mac "Cmd+" #else "Ctrl+" #end : "") +
			((code & MOD_SHIFT > 0) ? "Shift+" : "") +
			keyName(code & KEYCODE);
	}

	public function codeForButton(button:Int):Null<Int>
	{
		return _buttonMap[button];
	}

	inline function keyName(char:Int)
	{
		if (char >= 112 && char <= 126) return "F" + Std.string(char - 111);
		if (char >= 96 && char <= 105) return "NUMPAD " + Std.string(char - 96);
		return keyNames.exists(char) ? keyNames.get(char) : String.fromCharCode(char);
	}

	public function getDefinitions():Map<Int, Int>
	{
		return _keyMap;
	}
}
