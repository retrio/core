package retrio.ui.openfl;

import haxe.io.Bytes;
import flash.events.Event;


class FilePicker
{
	public static function openFile(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void)
	{
#if flash
		var fr = new flash.net.FileReference();
		try
		{
			fr.browse([for (x in extensions) new flash.net.FileFilter("ROM files", extensions.join(';'))]);
			fr.addEventListener(Event.SELECT, function(e:Dynamic) {
				fr.load();
			});
			fr.addEventListener(Event.COMPLETE, function(e:Dynamic) {
				onSuccess(new FileWrapper(new haxe.io.BytesInput(Bytes.ofData(fr.data))));
				fr.cancel();
			});
			fr.addEventListener(Event.CANCEL, function(e:Dynamic) {
				onCancel();
			});
		}
		catch (e:Dynamic) {}
#elseif sys
		var filters = {count: 1, descriptions: ["ROM files"], extensions: [extensions.join(';')]};
		var result:Array<String> = systools.Dialogs.openFile("Choose a ROM file.", "", filters);
		if (result != null && result.length > 0)
			onSuccess(FileWrapper.read(result[0]));
		else
			onCancel();
#end
	}

	public static function saveFile(defaultName:String, onSuccess:String->Void)
	{
#if flash
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
#elseif sys
		var result:String = systools.Dialogs.saveFile("Save file", "", "");
		if (result != null)
			onSuccess(result);
#end
	}
}
