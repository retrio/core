package strafe.platform;


class Platform
{
	static var current =
#if desktop
		new DesktopPlatform()
#elseif flash
		new FlashPlatform()
#elseif ouya
		new OuyaPlatform()
#elseif mobile
		new MobilePlatform()
#else
		throw "Unrecognized platform"
#end
	;

	public function saveFile(path:String, bytes:haxe.io.Bytes):Void	{}

	public function loadFile(path:String):FileWrapper
	{
		return FileWrapper.read(path);
	}
}
