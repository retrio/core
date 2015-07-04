package retrio.io;

import haxe.io.Bytes;
import flash.events.Event;


class FlashIO implements IEnvironment
{
	public function new() {}

	public function fileExists(name:String):Bool
	{
		// TODO
		return false;
	}

	public function readFile(name:String, ?newRoot=false):FileWrapper
	{
		// TODO
		return null;
	}

	public function writeFile(name:String, data:ByteString, ?append:Bool=false):Void
	{
		// TODO
	}

	public function openFileDialog(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void):Void
	{
		var fr = new flash.net.FileReference();
		try
		{
			fr.browse([for (x in extensions) new flash.net.FileFilter("ROM files", extensions.join(';'))]);
			fr.addEventListener(Event.SELECT, function(e:Dynamic) {
				fr.load();
			});
			fr.addEventListener(Event.COMPLETE, function(e:Dynamic) {
				onSuccess(new FileWrapper(new haxe.io.BytesInput(Bytes.ofData(fr.data)), fr.name));
				fr.cancel();
			});
			fr.addEventListener(Event.CANCEL, function(e:Dynamic) {
				onCancel();
			});
		}
		catch (e:Dynamic) {}
	}

	public function saveFileDialog(defaultName:String, onSuccess:String->Void):Void
	{
		// TODO
		/*var fr = new flash.net.FileReference();
		try
		{
			fr.browse([for (x in extensions) new flash.net.FileFilter("ROM files", extensions.join(';'))]);
			fr.addEventListener(Event.SELECT, function(e:Dynamic) {
				fr.load();
			});
			fr.addEventListener(Event.COMPLETE, function(e:Dynamic) {
				onSuccess(haxe.io.Bytes.ofData(fr.data));
				fr.cancel();
			});
		}
		catch (e:Dynamic) {}*/
	}
}
