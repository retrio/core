package retrio.ui.openfl;

import flash.Memory;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Endian;
import retrio.io.IScreenBuffer;


class BitmapScreenBuffer extends Bitmap implements IScreenBuffer implements IScreencapBuffer
{
	public var screenWidth(get, never):Int;
	function get_screenWidth()
	{
		return baseWidth - clipLeft - clipRight;
	}
	public var screenHeight(get, never):Int;
	function get_screenHeight()
	{
		return baseHeight - clipTop - clipBottom;
	}

	public var clipTop(default, set):Int = 0;
	public var clipBottom(default, set):Int = 0;
	public var clipLeft(default, set):Int = 0;
	public var clipRight(default, set):Int = 0;

	function set_clipTop(y:Int)
	{
		clipTop = y;
		setClip();
		return y;
	}
	function set_clipBottom(y:Int)
	{
		clipBottom = y;
		setClip();
		return y;
	}
	function set_clipLeft(x:Int)
	{
		clipLeft = x;
		return x;
	}
	function set_clipRight(x:Int)
	{
		clipRight = x;
		return x;
	}
	function setClip()
	{
		loopStart = clipTop*baseWidth;
		loopEnd = (baseHeight-clipBottom)*baseWidth;
		r.height = baseHeight-clipBottom-clipTop;
		bmpData.fillRect(bmpData.rect, 0xff000000);
	}

	var baseWidth:Int;
	var baseHeight:Int;

	var pixels:ByteArray;

	var canvas:BitmapData;
	var bmpData:BitmapData;

	var m:Matrix = new Matrix();
	var r:Rectangle;
	var loopStart:Int = 0;
	var loopEnd:Int = 0;

	public function new(baseWidth:Int, baseHeight:Int)
	{
		super();

		this.baseWidth = baseWidth;
		this.baseHeight = baseHeight;

		r = new Rectangle(0, 0, baseWidth, baseHeight);
		bmpData = new BitmapData(baseWidth, baseHeight, false, 0);

		pixels = new ByteArray();
		pixels.endian = Endian.BIG_ENDIAN;
		pixels.clear();
		for (i in 0 ... baseWidth*baseHeight)
			pixels.writeInt(0);

		resize(baseWidth, baseHeight);
		setClip();
	}

	public inline function pset(addr:Int, value:Int):Void
	{
		Memory.setI32(addr*4, value);
	}

	public function resize(width:Int, height:Int):Void
	{
		if (canvas != null) canvas.dispose();
		canvas = new BitmapData(width, height, false, 0);

		var sx = canvas.width / screenWidth, sy = canvas.height / screenHeight;
		m.setTo(sx, 0, 0, sy, 0, 0);

		bitmapData = canvas;
	}

	public function startFrame():Void {}

	public function activate():Void
	{
		Memory.select(pixels);
	}

	public function deactivate():Void {}

	public function render():Void
	{
		pixels.position = 0;

		bmpData.lock();
		canvas.lock();
		bmpData.setPixels(r, pixels);
		canvas.draw(bmpData, m, null, null, null, false);
		canvas.unlock();
		bmpData.unlock();
	}

	public function capture():BitmapData
	{
		var capture = new BitmapData(bmpData.width, bmpData.height);
		capture.copyPixels(bmpData, capture.rect, new Point());
		return capture;
	}
}
