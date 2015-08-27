package retrio;

import haxe.xml.Fast;
import sys.io.File;
import sys.FileSystem;
import retrio.io.FileWrapper;
import retrio.io.IO;
import retrio.io.IScreenBuffer;


class TestScreenBuffer implements IScreenBuffer
{
	var width:Int;
	var height:Int;
	var _pixels:ByteString;

	public var screenWidth(get, never):Int;
	function get_screenWidth() return width;
	public var screenHeight(get, never):Int;
	function get_screenHeight() return height;

	public var clipTop(default, set):Int = 0;
	public var clipBottom(default, set):Int = 0;
	public var clipLeft(default, set):Int = 0;
	public var clipRight(default, set):Int = 0;

	function set_clipTop(y:Int) return y;
	function set_clipBottom(y:Int) return y;
	function set_clipLeft(x:Int) return x;
	function set_clipRight(x:Int) return x;

	public function new(width:Int, height:Int)
	{
		this.width = width;
		this.height = height;

		_pixels = new ByteString(width * height);
	}

	public inline function pset(addr:Int, value:Int):Void _pixels[addr] = value;

	public function getPixels():Iterable<Int> return {iterator: _pixels.iterator};

	public function resize(width:Int, height:Int):Void {}
	public function startFrame():Void {}
	public function activate():Void {}
	public function deactivate():Void {}
	public function render():Void {}
}


class Test
{
	static inline var framesPerCycle = 60;
	static inline var maxCyclesWithoutChange = 20;

	static function runTests(emu:IEmulator)
	{
		var io = IO.defaultIO;
		emu.screenBuffer = new TestScreenBuffer(emu.width, emu.height);

		var testData = File.getContent("tests.xml");
		var fast = new Fast(Xml.parse(testData).firstElement());
		var romDir = fast.has.dir ? fast.att.dir : "assets/roms/test/";

		if (!FileSystem.exists("test_results"))
			FileSystem.createDirectory("test_results");
		else
		{
			for (file in FileSystem.readDirectory("test_results"))
				if (StringTools.endsWith(file, ".png"))
					FileSystem.deleteFile("test_results/" + file);
		}

		var hashes:Map<String, String> = new Map();
		var prevResults:Map<String, String> = new Map();
		if (FileSystem.exists("test_results/.last"))
		{
			var resultsFile = File.read("test_results/.last");
			var line:String;
			try
			{
				while ((line = resultsFile.readLine()) != null)
				{
					var parts = line.split(":");
					if (parts.length == 3)
					{
						var name = parts[0];
						var hash = parts[1];
						prevResults[name] = hash;
					}
				}
			}
			catch (e:haxe.io.Eof) {}
			resultsFile.close();
		}

		var resultsFile = File.write("test_results/.last");

		var successes = 0;
		var failures:Array<String> = [];
		var i:Int = 0;

		for (test in fast.nodes.test)
		{
			++i;
			var rom = test.att.rom;
			var hash = test.has.hash ? test.att.hash : null;
			var expFrames = test.has.frames ? Std.parseInt(test.att.frames) : 0;

			var f = io.readFile(romDir + (StringTools.endsWith(romDir, "/") ? "" : "/") + rom, true);
			emu.loadGame(f, false);

			Sys.println("\n>> Running test " + rom + (hash == null ? " (NO HASH)" : "") + "...");
			var cycles = 0;
			var frameCount = 0;
			var success = false;
			var currentHash = "";
			var lastHash = "";

			var withoutChange = Math.max(maxCyclesWithoutChange,
				test.has.frames ? (Std.parseInt(test.att.frames)/framesPerCycle) : 0);

			while (cycles < maxCyclesWithoutChange || frameCount < expFrames)
			{
				for (i in 0 ... framesPerCycle)
				{
					try
					{
						emu.frame(60);
						++frameCount;
					}
					catch(e:Dynamic)
					{
						Sys.println("ERROR: " + e);
						break;
					}
				}

				currentHash = bufferHash(emu.screenBuffer);

				if (hash != null && currentHash == hash)
				{
					success = true;
					break;
				}
				else if (currentHash != lastHash)
				{
					lastHash = currentHash;
					cycles = 0;
				}
				++cycles;
			}

			hashes[rom] = currentHash;
			if (prevResults.exists(rom) && prevResults[rom] != currentHash)
			{
				Sys.println("=> changed from last run: " + prevResults[rom]);
			}
			resultsFile.writeString(rom + ":" + currentHash + "\n" + ":" + (success ? "PASS" : "FAIL"));

			if (success)
			{
				Sys.println("passed!");
				++successes;
			}
			else
			{
				Sys.println(hash == null ? "outcome unclear, marking as failed" : "FAILED!");
				Sys.println(currentHash);

				var resultImg = "test_results/" + StringTools.lpad(Std.string(i), "0", 3) + "-" + rom + ".png";

				var pixels = emu.screenBuffer.getPixels();
				var bo = new haxe.io.BytesOutput();
				for (c in pixels)
				{
					bo.writeByte((c & 0xFF0000) >> 16);
					bo.writeByte((c & 0xFF00) >> 8);
					bo.writeByte((c & 0xFF));
				}
				var bytes = bo.getBytes();
				var handle = sys.io.File.write(resultImg);
				new format.png.Writer(handle).write(format.png.Tools.buildRGB(emu.width, emu.height, bytes));
				handle.close();

				Sys.println(resultImg);

				failures.push(rom);
			}
		}

		resultsFile.close();

		Sys.println("\n\n*** FINISHED ***\n");
		Sys.println("Succeeded:  " + successes);
		Sys.println("Failed:     " + failures.length);
		Sys.println(failures.join(' '));
	}

	static inline function bufferHash(buffer:IScreenBuffer)
	{
		var bytesSeen:Map<Int, String> = new Map();
		var byteCount:Int = 0;
		var b = new StringBuf();

		for (c in buffer.getPixels())
		{
			if (!bytesSeen.exists(c))
			{
				bytesSeen[c] = Std.string(byteCount++);
			}
			b.add(bytesSeen[c]);
		}

		return haxe.crypto.Sha1.encode(b.toString());
	}
}
