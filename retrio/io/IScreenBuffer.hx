package retrio.io;


interface IScreenBuffer
{
	public var screenWidth(get, never):Int;
	public var screenHeight(get, never):Int;

	public var clipTop(default, set):Int;
	public var clipBottom(default, set):Int;
	public var clipLeft(default, set):Int;
	public var clipRight(default, set):Int;

	public function pset(addr:Int, c:Int):Void;
	public function getPixels():Iterable<Int>;

	public function resize(width:Int, height:Int):Void;
	public function startFrame():Void;
	public function activate():Void;
	public function deactivate():Void;
	public function render():Void;
}
