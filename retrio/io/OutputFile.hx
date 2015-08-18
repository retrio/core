package retrio.io;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;


class OutputFile
{
	var io:IEnvironment;
	var buffer:BytesOutput;

	public function new(io:IEnvironment)
	{
		this.io = io;
		this.buffer = new BytesOutput();
	}

	public function writeBytes(data:Bytes):Void
	{
		buffer.write(data);
	}

	public function writeByteString(data:ByteString):Void
	{
		data.writeTo(buffer);
	}

	public function writeVector(data:Vector<ByteString>):Void
	{
		for (d in data)
			d.writeTo(buffer);
	}

	public function writeString(data:String):Void
	{
		buffer.writeString(data);
	}

	public function getBytes():Bytes
	{
		return buffer.getBytes();
	}

	public function save(name:String, ?home:Bool=false):Void
	{
		io.saveFile(this, name, home);
	}
}
