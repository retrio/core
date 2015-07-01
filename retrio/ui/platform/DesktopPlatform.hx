package retrio.ui.platform;


class DesktopPlatform extends Platform
{
	override public function saveFile(path:String, bytes:haxe.io.Bytes)
	{
		sys.io.File.saveBytes(path, bytes);
	}
}
