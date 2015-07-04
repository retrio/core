package retrio;


interface IEnvironment
{
	public function readFile(name:String, ?newRoot:Bool=false):FileWrapper;
	public function writeFile(name:String, data:ByteString, ?append:Bool=false):Void;
	public function fileExists(name:String):Bool;

	public function openFileDialog(extensions:Array<String>, onSuccess:FileWrapper->Void, ?onCancel:Void->Void):Void;
	public function saveFileDialog(defaultName:String, onSuccess:String->Void):Void;
}
