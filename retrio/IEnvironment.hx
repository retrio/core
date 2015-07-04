package retrio;

import haxe.ds.Vector;


interface IEnvironment
{
	public function readFile(name:String, ?newRoot:Bool=false):FileWrapper;
	public function writeByteStringToFile(name:String, data:ByteString):Void;
	public function writeVectorToFile(name:String, data:Vector<ByteString>):Void;
	public function fileExists(name:String):Bool;

	public function openFileDialog(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void):Void;
	public function saveFileDialog(defaultName:String, onSuccess:String->Void):Void;
}
