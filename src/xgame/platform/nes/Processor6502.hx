package xgame.platform.nes;

import haxe.io.Bytes;
import haxe.io.Input;
import xgame.platform.nes.OpCode;
import haxe.ds.Vector;


class CommandPool
{
    static inline var maxPoolSize=1024;
    static var pool:Vector<Command>;
    static var lastPoolLoc = -1;
    
    public static inline function get(code:OpCode, mode:AddressingMode):Command
    {
        if (pool == null)
        {
            pool = new Vector(maxPoolSize);
        }
        
        if (lastPoolLoc > -1)
        {
            var thisCode = pool[lastPoolLoc];
            thisCode.code = code;
            thisCode.mode = mode;
            return thisCode;
        }
        else
        {
            return {code:code, mode:mode};
        }
    }
    
    public static inline function recycle(cmd:Command)
    {
        if (lastPoolLoc < maxPoolSize-1) pool[++lastPoolLoc] = cmd;
        else return;
    }
}


class Processor6502
{
    var data:Bytes;
    var offset:Int;
    
    public function new(file:Bytes, offset:Int)
    {
        this.data = file;
        this.offset = offset;
        
        parseHeader();
    }
    
    function parseHeader()
    {
        var f6 = data.get(6);
        var f7 = data.get(7);
        
        var mapper = (f6 & 0xF0 >> 4) + f7 & 0xF0;
    }
    
    public inline function getByte(address:Int):Int
    {
        return data.get(address + offset);
    }
    
    public inline function getOP(address:Int):Command
    {
        return decodeByte(getByte(address));
    }
    
    public inline function decodeByte(byte:Int):Command
    {
        var code:OpCode;
        var mode:AddressingMode = AddressingModes.Absolute;
        
        switch(byte) {
            case 0x00: { code=OpCodes.BRK; }
            case 0x01: { code=OpCodes.ORA; mode=AddressingModes.IndirectX; }
            case 0x05: { code=OpCodes.ORA; mode=AddressingModes.ZeroPage; }
            case 0x06: { code=OpCodes.ASL; mode=AddressingModes.ZeroPage; }
            case 0x08: { code=OpCodes.PHP; }
            case 0x09: { code=OpCodes.ORA; mode=AddressingModes.Immediate; }
            case 0x0A: { code=OpCodes.ASL; mode=AddressingModes.Accumulator; }
            case 0x0D: { code=OpCodes.ORA; }
            case 0x0E: { code=OpCodes.ASL; }
            case 0x10: { code=OpCodes.BPL; }
            case 0x11: { code=OpCodes.ORA; mode=AddressingModes.IndirectY; }
            case 0x15: { code=OpCodes.ORA; mode=AddressingModes.ZeroPageX; }
            case 0x16: { code=OpCodes.ASL; mode=AddressingModes.ZeroPageX; }
            case 0x18: { code=OpCodes.CLC; }
            case 0x19: { code=OpCodes.ORA; mode=AddressingModes.AbsoluteY; }
            case 0x1D: { code=OpCodes.ORA; mode=AddressingModes.AbsoluteX; }
            case 0x1E: { code=OpCodes.ASL; mode=AddressingModes.AbsoluteX; }
            case 0x20: { code=OpCodes.JSR; }
            case 0x21: { code=OpCodes.AND; mode=AddressingModes.IndirectX; }
            case 0x24: { code=OpCodes.BIT; mode=AddressingModes.ZeroPage; }
            case 0x25: { code=OpCodes.AND; mode=AddressingModes.ZeroPage; }
            case 0x26: { code=OpCodes.ROL; mode=AddressingModes.ZeroPage; }
            case 0x28: { code=OpCodes.PLP; }
            case 0x29: { code=OpCodes.AND; mode=AddressingModes.Immediate; }
            case 0x2A: { code=OpCodes.ROL; mode=AddressingModes.Accumulator; }
            case 0x2C: { code=OpCodes.BIT; }
            case 0x2D: { code=OpCodes.AND; }
            case 0x2E: { code=OpCodes.ROL; }
            case 0x30: { code=OpCodes.BMI; }
            case 0x31: { code=OpCodes.AND; mode=AddressingModes.IndirectY; }
            case 0x35: { code=OpCodes.AND; mode=AddressingModes.ZeroPageX; }
            case 0x36: { code=OpCodes.ROL; mode=AddressingModes.ZeroPageX; }
            case 0x38: { code=OpCodes.SEC; }
            case 0x39: { code=OpCodes.AND; mode=AddressingModes.AbsoluteY; }
            case 0x3D: { code=OpCodes.AND; mode=AddressingModes.AbsoluteX; }
            case 0x3E: { code=OpCodes.ROL; mode=AddressingModes.AbsoluteX; }
            case 0x40: { code=OpCodes.RTI; }
            case 0x41: { code=OpCodes.EOR; mode=AddressingModes.IndirectX; }
            case 0x45: { code=OpCodes.EOR; mode=AddressingModes.ZeroPage; }
            case 0x46: { code=OpCodes.LSR; mode=AddressingModes.ZeroPage; }
            case 0x48: { code=OpCodes.PHA; }
            case 0x49: { code=OpCodes.EOR; mode=AddressingModes.Immediate; }
            case 0x4A: { code=OpCodes.LSR; mode=AddressingModes.Accumulator; }
            case 0x4C: { code=OpCodes.JMP; }
            case 0x4D: { code=OpCodes.EOR; }
            case 0x4E: { code=OpCodes.LSR; }
            case 0x50: { code=OpCodes.BVC; }
            case 0x51: { code=OpCodes.EOR; mode=AddressingModes.IndirectY; }
            case 0x55: { code=OpCodes.EOR; mode=AddressingModes.ZeroPageX; }
            case 0x56: { code=OpCodes.LSR; mode=AddressingModes.ZeroPageX; }
            case 0x58: { code=OpCodes.CLI; }
            case 0x59: { code=OpCodes.EOR; mode=AddressingModes.AbsoluteY; }
            case 0x5D: { code=OpCodes.EOR; mode=AddressingModes.AbsoluteX; }
            case 0x5E: { code=OpCodes.LSR; mode=AddressingModes.AbsoluteX; }
            case 0x60: { code=OpCodes.RTS; }
            case 0x61: { code=OpCodes.ADC; mode=AddressingModes.IndirectX; }
            case 0x65: { code=OpCodes.ADC; mode=AddressingModes.ZeroPage; }
            case 0x66: { code=OpCodes.ROR; mode=AddressingModes.ZeroPage; }
            case 0x68: { code=OpCodes.PLA; }
            case 0x69: { code=OpCodes.ADC; mode=AddressingModes.Immediate; }
            case 0x6A: { code=OpCodes.ROR; mode=AddressingModes.Accumulator; }
            case 0x6C: { code=OpCodes.JMP; mode=AddressingModes.Indirect; }
            case 0x6D: { code=OpCodes.ADC; }
            case 0x6E: { code=OpCodes.ROR; }
            case 0x70: { code=OpCodes.BVS; }
            case 0x71: { code=OpCodes.ADC; mode=AddressingModes.IndirectY; }
            case 0x75: { code=OpCodes.ADC; mode=AddressingModes.ZeroPageX; }
            case 0x76: { code=OpCodes.ROR; mode=AddressingModes.ZeroPageX; }
            case 0x78: { code=OpCodes.SEI; }
            case 0x79: { code=OpCodes.ADC; mode=AddressingModes.AbsoluteY; }
            case 0x7D: { code=OpCodes.ADC; mode=AddressingModes.AbsoluteX; }
            case 0x7E: { code=OpCodes.ROR; mode=AddressingModes.AbsoluteX; }
            case 0x81: { code=OpCodes.STA; mode=AddressingModes.IndirectX; }
            case 0x84: { code=OpCodes.STY; mode=AddressingModes.ZeroPage; }
            case 0x85: { code=OpCodes.STA; mode=AddressingModes.ZeroPage; }
            case 0x86: { code=OpCodes.STX; mode=AddressingModes.ZeroPage; }
            case 0x88: { code=OpCodes.DEY; }
            case 0x8A: { code=OpCodes.TXA; }
            case 0x8C: { code=OpCodes.STY; }
            case 0x8D: { code=OpCodes.STA; }
            case 0x8E: { code=OpCodes.STX; }
            case 0x90: { code=OpCodes.BCC; }
            case 0x91: { code=OpCodes.STA; mode=AddressingModes.IndirectY; }
            case 0x94: { code=OpCodes.STY; mode=AddressingModes.ZeroPageX; }
            case 0x95: { code=OpCodes.STA; mode=AddressingModes.ZeroPageX; }
            case 0x96: { code=OpCodes.STX; mode=AddressingModes.ZeroPageY; }
            case 0x98: { code=OpCodes.TYA; }
            case 0x99: { code=OpCodes.STA; mode=AddressingModes.AbsoluteY; }
            case 0x9A: { code=OpCodes.TXS; }
            case 0x9D: { code=OpCodes.STA; mode=AddressingModes.AbsoluteX; }
            case 0xA0: { code=OpCodes.LDY; mode=AddressingModes.Immediate; }
            case 0xA1: { code=OpCodes.LDA; mode=AddressingModes.IndirectX; }
            case 0xA2: { code=OpCodes.LDX; mode=AddressingModes.Immediate; }
            case 0xA4: { code=OpCodes.LDY; mode=AddressingModes.ZeroPage; }
            case 0xA5: { code=OpCodes.LDA; mode=AddressingModes.ZeroPage; }
            case 0xA6: { code=OpCodes.LDX; mode=AddressingModes.ZeroPage; }
            case 0xA8: { code=OpCodes.TAY; }
            case 0xA9: { code=OpCodes.LDA; mode=AddressingModes.Immediate; }
            case 0xAA: { code=OpCodes.TAX; }
            case 0xAC: { code=OpCodes.LDY; }
            case 0xAD: { code=OpCodes.LDA; }
            case 0xAE: { code=OpCodes.LDX; }
            case 0xB0: { code=OpCodes.BCS; }
            case 0xB1: { code=OpCodes.LDA; mode=AddressingModes.IndirectY; }
            case 0xB4: { code=OpCodes.LDY; mode=AddressingModes.ZeroPageX; }
            case 0xB5: { code=OpCodes.LDA; mode=AddressingModes.ZeroPageX; }
            case 0xB6: { code=OpCodes.LDX; mode=AddressingModes.ZeroPageY; }
            case 0xB8: { code=OpCodes.CLV; }
            case 0xB9: { code=OpCodes.LDA; mode=AddressingModes.AbsoluteY; }
            case 0xBA: { code=OpCodes.TSX; }
            case 0xBC: { code=OpCodes.LDY; mode=AddressingModes.AbsoluteX; }
            case 0xBD: { code=OpCodes.LDA; mode=AddressingModes.AbsoluteX; }
            case 0xBE: { code=OpCodes.LDX; mode=AddressingModes.AbsoluteY; }
            case 0xC0: { code=OpCodes.CPY; mode=AddressingModes.Immediate; }
            case 0xC1: { code=OpCodes.CMP; mode=AddressingModes.IndirectX; }
            case 0xC4: { code=OpCodes.CPY; mode=AddressingModes.ZeroPage; }
            case 0xC5: { code=OpCodes.CMP; mode=AddressingModes.ZeroPage; }
            case 0xC6: { code=OpCodes.DEC; mode=AddressingModes.ZeroPage; }
            case 0xC8: { code=OpCodes.INY; }
            case 0xC9: { code=OpCodes.CMP; mode=AddressingModes.Immediate; }
            case 0xCA: { code=OpCodes.DEX; }
            case 0xCC: { code=OpCodes.CPY; }
            case 0xCD: { code=OpCodes.CMP; }
            case 0xCE: { code=OpCodes.DEC; }
            case 0xD0: { code=OpCodes.BNE; }
            case 0xD1: { code=OpCodes.CMP; mode=AddressingModes.IndirectY; }
            case 0xD5: { code=OpCodes.CMP; mode=AddressingModes.ZeroPageX; }
            case 0xD6: { code=OpCodes.DEC; mode=AddressingModes.ZeroPageX; }
            case 0xD8: { code=OpCodes.CLD; }
            case 0xD9: { code=OpCodes.CMP; mode=AddressingModes.AbsoluteY; }
            case 0xDD: { code=OpCodes.CMP; mode=AddressingModes.AbsoluteX; }
            case 0xDE: { code=OpCodes.DEC; mode=AddressingModes.AbsoluteX; }
            case 0xE0: { code=OpCodes.CPX; mode=AddressingModes.Immediate; }
            case 0xE1: { code=OpCodes.SBC; mode=AddressingModes.IndirectX; }
            case 0xE4: { code=OpCodes.CPX; mode=AddressingModes.ZeroPage; }
            case 0xE5: { code=OpCodes.SBC; mode=AddressingModes.ZeroPage; }
            case 0xE6: { code=OpCodes.INC; mode=AddressingModes.ZeroPage; }
            case 0xE8: { code=OpCodes.INX; }
            case 0xE9: { code=OpCodes.SBC; mode=AddressingModes.Immediate; }
            case 0xEC: { code=OpCodes.CPX; }
            case 0xED: { code=OpCodes.SBC; }
            case 0xEE: { code=OpCodes.INC; }
            case 0xF0: { code=OpCodes.BEQ; }
            case 0xF1: { code=OpCodes.SBC; mode=AddressingModes.IndirectY; }
            case 0xF5: { code=OpCodes.SBC; mode=AddressingModes.ZeroPageX; }
            case 0xF6: { code=OpCodes.INC; mode=AddressingModes.ZeroPageX; }
            case 0xF8: { code=OpCodes.SED; }
            case 0xF9: { code=OpCodes.SBC; mode=AddressingModes.AbsoluteY; }
            case 0xFD: { code=OpCodes.SBC; mode=AddressingModes.AbsoluteX; }
            case 0xFE: { code=OpCodes.INC; mode=AddressingModes.AbsoluteX; }
            
            case 0xEA,0x1A,0x3A,0x5A,0x7A,0xDA,0xFA: code=OpCodes.NOP;
            case 0x04,0x14,0x24,0x34,0x44,0x54,0x64,0x74,0xD4,0xF4,0x80: code=OpCodes.NOP1;
            case 0x0C,0x1C,0x3C,0x5C,0x7C,0xDC,0xFC: code=OpCodes.NOP2;
            
            default: code=OpCodes.NOP;
        }
        
        var cmd:Command = CommandPool.get(code, mode);
        
        return cmd;
    }
}
