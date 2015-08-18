package retrio.io;

import haxe.ds.Vector;
import haxe.io.Bytes;


interface IEnvironment
{
	public function readFile(name:String, ?chdir:Bool=false):FileWrapper;
	public function fileExists(name:String):Bool;
	public function writeFile():OutputFile;
	public function saveFile(file:OutputFile, name:String, ?home:Bool=false):Void;

	public function openFileDialog(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void):Void;
	public function saveFileDialog(defaultName:String, onSuccess:String->Void):Void;
}
