package retrio.io;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;


class NativeIO implements IEnvironment
{
	var root:String;

	public function new() {}

	public function chdir(path:String):Void
	{
		root = path;
	}

	public function fileExists(path:String, ?home:Bool=false):Bool
	{
		return FileSystem.exists(pathTo(path, home));
	}

	public function readFile(path:String, ?home:Bool=false):Null<FileWrapper>
	{
		path = pathTo(path, home);

		try
		{
			var f = new FileWrapper(sys.io.File.read(path, true), path);
			return f;
		}
		catch (e:Dynamic)
		{
			return null;
		}
	}

	public function writeFile():OutputFile
	{
		return new OutputFile(this);
	}

	public function saveFile(file:OutputFile, path:String, ?home:Bool=false)
	{
		var out = File.write(pathTo(path, home), true);
		out.write(file.getBytes());
	}

	public function openFileDialog(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void):Void
	{
		var filters = {count: 1, descriptions: ["ROM files"], extensions: [extensions.join(';')]};
		var result:Array<String> = systools.Dialogs.openFile("Choose a ROM file.", "", filters);
		if (result != null && result.length > 0)
		{
			var path = new Path(result[0]);
			chdir(path.dir);
			onSuccess(readFile(Path.withoutDirectory(result[0]), false));
		}
		else
		{
			onCancel();
		}
	}

	public function saveFileDialog(defaultpath:String, onSuccess:String->Void):Void
	{
		var result:String = systools.Dialogs.saveFile("Save file", "", "");
		if (result != null)
			onSuccess(result);
	}

	inline function pathTo(path:String, home:Bool):String
	{
		return Path.join([home ? homeDir() : root, path]);
	}

	inline function homeDir():String
	{
		// TODO
		return root;
	}
}
