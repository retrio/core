package retrio.audio;

import haxe.ds.Vector;


class LowPassFilter
{
	static inline function sinc(x:Float):Float
	{
		if (x == 0)
		{
			return 1.0;
		}
		else
		{
			var xpi = Math.PI * x;
			return Math.sin(xpi) / (xpi);
		}
	}

	var buffer:SoundBuffer;
	var cutoff:Float;
	var coefficients:Vector<Float>;
	var convolved:Float;

	public function new(inputSampleRate:Int, outputSampleRate:Int, filterOrder:Int)
	{
		buffer = new SoundBuffer(filterOrder + 1);

		cutoff = (outputSampleRate/2)/inputSampleRate;

		coefficients = new Vector(filterOrder + 1);
		var factor = 2 * cutoff;
		var halfOrder = filterOrder >> 1;
		for (i in 0 ... filterOrder)
		{
			var c = factor * sinc(factor * (i - halfOrder));
			// blackman window
			c *= 0.42 - 0.5 * Math.cos(2 * Math.PI * i / filterOrder) + 0.08 * Math.cos(4 * Math.PI * i / filterOrder);
			coefficients[i] = c;
		}
	}

	public inline function addSample(sample:Float)
	{
		buffer.push(sample);
	}

	public inline function getSample():Float
	{
		convolved = 0;
		for (i in 0 ... Std.int(Math.min(coefficients.length, buffer.length)))
		{
			convolved += buffer.get(buffer.length - i - 1) * coefficients[i];
		}

		return convolved;
	}
}
