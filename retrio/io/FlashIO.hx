package retrio.io;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import flash.events.Event;
import flash.net.SharedObject;
import flash.utils.ByteArray;


class FlashIO implements IEnvironment
{
	public function new() {}

	public function fileExists(name:String):Bool
	{
		var so = SharedObject.getLocal(name);
		return Reflect.hasField(so.data, "data");
	}

	public function readFile(name:String, ?newRoot=false):FileWrapper
	{
		var so = SharedObject.getLocal(name);
		try
		{
			var f = new FileWrapper(new BytesInput(Bytes.ofData(so.data.data)));
			return f;
		}
		catch (e:Dynamic)
		{
			return null;
		}
	}

	public function writeBytesToFile(name:String, data:Bytes):Void
	{
		var so = SharedObject.getLocal(name);
		so.data.data = data.getData();
		so.flush();
	}

	public function writeByteStringToFile(name:String, data:ByteString):Void
	{
		var out = new BytesOutput();
		data.writeTo(out);
		writeBytesToFile(name, out.getBytes());
	}

	public function writeVectorToFile(name:String, data:Vector<ByteString>):Void
	{
		var out = new BytesOutput();
		for (d in data)
		{
			d.writeTo(out);
		}
		writeBytesToFile(name, out.getBytes());
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
