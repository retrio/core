package retrio.io;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.Path;


class Html5IO implements IEnvironment
{
	var root:String;

	public function new() {}

	public function fileExists(name:String):Bool
	{
		return false;
	}

	public function readFile(name:String, ?newRoot=false):FileWrapper
	{
		return null;
	}

	public function writeBytesToFile(name:String, data:Bytes):Void
	{

	}

	public function writeByteStringToFile(name:String, data:ByteString):Void
	{

	}

	public function writeVectorToFile(name:String, data:Vector<ByteString>):Void
	{

	}

	public function openFileDialog(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void):Void
	{

	}

	public function saveFileDialog(defaultName:String, onSuccess:String->Void):Void
	{

	}

	inline function pathTo(name:String):String
	{
		return null;
	}
}
