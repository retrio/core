package retrio.audio;

import haxe.io.BytesOutput;
import haxe.io.Output;


class WavEncoder
{
	private var _buffer:BytesOutput = new BytesOutput();

	public function new()
	{
		_buffer.bigEndian = false;
	}

	public function writeSample(sample:Float):Void
	{
		_buffer.writeInt16(Std.int(sample * 0x7fff));
	}

	public function encode(output:Output, channels:Int=2, bits:Int=16, rate:Int=44100):Void
	{
		output.bigEndian = false;

		output.writeString("RIFF");
		output.writeInt32(_buffer.length + 44);
		output.writeString("WAVE");
		output.writeString("fmt");
		output.writeInt32(16);
		output.writeUInt16(1);
		output.writeInt16(channels);
		output.writeInt32(rate);
		output.writeInt32(rate * channels * (bits >> 3));
		output.writeUInt16(channels * (bits >> 3));
		output.writeInt16(bits);
		output.writeString("DATA");
		output.writeInt32(_buffer.length);
		output.write(_buffer.getBytes());
	}
}
