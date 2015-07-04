package retrio.io;

import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;


class NativeIO implements IEnvironment
{
	var root:String;

	public function new() {}

	public function fileExists(name:String):Bool
	{
		return FileSystem.exists(pathTo(name));
	}

	public function readFile(name:String, ?newRoot=false):FileWrapper
	{
		var path:String;

		if (newRoot)
		{
			root = new Path(name).dir;
			path = name;
		}
		else path = pathTo(name);

		return new FileWrapper(sys.io.File.read(path, true), path);
	}

	public function writeFile(name:String, data:ByteString, ?append:Bool=false):Void
	{
		var out = append ? File.append(pathTo(name), true) : File.write(pathTo(name), true);
		data.writeTo(out);
	}

	public function openFileDialog(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void):Void
	{
		var filters = {count: 1, descriptions: ["ROM files"], extensions: [extensions.join(';')]};
		var result:Array<String> = systools.Dialogs.openFile("Choose a ROM file.", "", filters);
		if (result != null && result.length > 0)
			onSuccess(readFile(result[0], true));
		else
			onCancel();
	}

	public function saveFileDialog(defaultName:String, onSuccess:String->Void):Void
	{
		var result:String = systools.Dialogs.saveFile("Save file", "", "");
		if (result != null)
			onSuccess(result);
	}

	inline function pathTo(name:String):String
	{
		return Path.join([root, name]);
	}
}
