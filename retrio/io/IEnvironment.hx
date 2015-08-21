package retrio.io;

import haxe.ds.Vector;
import haxe.io.Bytes;


interface IEnvironment
{
	public function chdir(path:String):Void;

	public function readFile(name:String, ?home:Bool=false):Null<FileWrapper>;
	public function fileExists(name:String, ?home:Bool=false):Bool;
	public function writeFile():OutputFile;
	public function saveFile(file:OutputFile, name:String, ?home:Bool=false):Void;

	public function openFileDialog(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void):Void;
	public function saveFileDialog(defaultName:String, onSuccess:String->Void):Void;
}
