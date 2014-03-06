package xgame.platform.nes;

import haxe.Timer;
import haxe.ds.Vector;
import flash.Lib;
import flash.utils.ByteArray;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import xgame.platform.nes.CPU;
import xgame.platform.nes.OpCode;
import xgame.platform.nes.PPU;
import xgame.platform.nes.ROM;


class NES extends Sprite
{
    // hardware components
    public var rom:ROM;
    public var cpu:CPU;
    public var ppu:PPU;
    public var mapper:Mapper;
    var screenBmp:Bitmap;
    public var screen(get, never):BitmapData;
    function get_screen()
    {
        return ppu.screen;
    }
    
    public var frameRate:Float;
    
    var timer:Timer;
    
    var ntsc:Bool=true;
    
    var scanline:Int=0;
    
    public function new(rom:ROM, frameRate:Float=60)
    {
        super();
        
        this.frameRate = frameRate;
        
        this.rom = rom;
        this.mapper = rom.mapper;
        this.cpu = new CPU(this);
        this.ppu = new PPU(this);
        
        mapper.load(this);
        
        screenBmp = new Bitmap(ppu.screen);
        addChild(screenBmp);
        
        //if (Lib.current.stage != null) onStage();
        //else Lib.current.addEventListener(Event.ADDED_TO_STAGE, onStage);
        
        cpu.init();
    }
    
    public function onStage(e:Event=null)
    {
        if (e != null) Lib.current.removeEventListener(Event.ADDED_TO_STAGE, onStage);
        Lib.current.stage.addChild(this);
    }
    
    static inline var cyclesPerSecond:Int=1790000;
    
    public function update()
    {
        cpu.run(cyclesPerSecond/frameRate);
    }
    
    public function run()
    {
        timer = new Timer(Math.floor(1000/frameRate));
        timer.run = update;
    }
}
