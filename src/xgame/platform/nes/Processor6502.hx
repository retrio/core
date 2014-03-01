package xgame.platform.nes;

import haxe.io.Bytes;
import haxe.io.Input;
import xgame.platform.nes.OpCode;
import haxe.ds.Vector;


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
    
    public static inline function decodeByte(byte:Int):Command
    {
        var code:OpCode;
        var mode:AddressingMode = AddressingModes.Absolute;
        var ticks:Int = 2;
        
        switch(byte) {
            case 0x00: { code=OpCodes.BRK; ticks=7; }
            case 0x01: { code=OpCodes.ORA; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x05: { code=OpCodes.ORA; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x06: { code=OpCodes.ASL; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x08: { code=OpCodes.PHP; ticks=3; }
            case 0x09: { code=OpCodes.ORA; mode=AddressingModes.Immediate; }
            case 0x0A: { code=OpCodes.ASL; mode=AddressingModes.Accumulator; }
            case 0x0D: { code=OpCodes.ORA; ticks=4; }
            case 0x0E: { code=OpCodes.ASL; ticks=6; }
            case 0x10: { code=OpCodes.BPL; mode=AddressingModes.Relative; }
            case 0x11: { code=OpCodes.ORA; mode=AddressingModes.IndirectY; ticks=5; }
            case 0x15: { code=OpCodes.ORA; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x16: { code=OpCodes.ASL; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x18: { code=OpCodes.CLC; }
            case 0x19: { code=OpCodes.ORA; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0x1D: { code=OpCodes.ORA; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0x1E: { code=OpCodes.ASL; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0x20: { code=OpCodes.JSR; ticks=6; }
            case 0x21: { code=OpCodes.AND; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x24: { code=OpCodes.BIT; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x25: { code=OpCodes.AND; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x26: { code=OpCodes.ROL; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x28: { code=OpCodes.PLP; ticks=4; }
            case 0x29: { code=OpCodes.AND; mode=AddressingModes.Immediate; }
            case 0x2A: { code=OpCodes.ROL; mode=AddressingModes.Accumulator; }
            case 0x2C: { code=OpCodes.BIT; ticks=4; }
            case 0x2D: { code=OpCodes.AND; ticks=4; }
            case 0x2E: { code=OpCodes.ROL; ticks=6; }
            case 0x30: { code=OpCodes.BMI; mode=AddressingModes.Relative; }
            case 0x31: { code=OpCodes.AND; mode=AddressingModes.IndirectY; ticks=5; }
            case 0x35: { code=OpCodes.AND; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x36: { code=OpCodes.ROL; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x38: { code=OpCodes.SEC; }
            case 0x39: { code=OpCodes.AND; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0x3D: { code=OpCodes.AND; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0x3E: { code=OpCodes.ROL; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0x40: { code=OpCodes.RTI; ticks=6; }
            case 0x41: { code=OpCodes.EOR; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x45: { code=OpCodes.EOR; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x46: { code=OpCodes.LSR; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x48: { code=OpCodes.PHA; ticks=3; }
            case 0x49: { code=OpCodes.EOR; mode=AddressingModes.Immediate; }
            case 0x4A: { code=OpCodes.LSR; mode=AddressingModes.Accumulator; }
            case 0x4C: { code=OpCodes.JMP; ticks=3; }
            case 0x4D: { code=OpCodes.EOR; ticks=4; }
            case 0x4E: { code=OpCodes.LSR; ticks=6; }
            case 0x50: { code=OpCodes.BVC; mode=AddressingModes.Relative; }
            case 0x51: { code=OpCodes.EOR; mode=AddressingModes.IndirectY; ticks=5; }
            case 0x55: { code=OpCodes.EOR; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x56: { code=OpCodes.LSR; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x58: { code=OpCodes.CLI; }
            case 0x59: { code=OpCodes.EOR; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0x5D: { code=OpCodes.EOR; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0x5E: { code=OpCodes.LSR; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0x60: { code=OpCodes.RTS; ticks=6; }
            case 0x61: { code=OpCodes.ADC; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x65: { code=OpCodes.ADC; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x66: { code=OpCodes.ROR; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0x68: { code=OpCodes.PLA; ticks=4; }
            case 0x69: { code=OpCodes.ADC; mode=AddressingModes.Immediate; }
            case 0x6A: { code=OpCodes.ROR; mode=AddressingModes.Accumulator; }
            case 0x6C: { code=OpCodes.JMP; mode=AddressingModes.Indirect; ticks=5; }
            case 0x6D: { code=OpCodes.ADC; ticks=4; }
            case 0x6E: { code=OpCodes.ROR; ticks=6; }
            case 0x70: { code=OpCodes.BVS; mode=AddressingModes.Relative; }
            case 0x71: { code=OpCodes.ADC; mode=AddressingModes.IndirectY; ticks=5; }
            case 0x75: { code=OpCodes.ADC; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x76: { code=OpCodes.ROR; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0x78: { code=OpCodes.SEI; }
            case 0x79: { code=OpCodes.ADC; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0x7D: { code=OpCodes.ADC; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0x7E: { code=OpCodes.ROR; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0x81: { code=OpCodes.STA; mode=AddressingModes.IndirectX; ticks=6; }
            case 0x84: { code=OpCodes.STY; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x85: { code=OpCodes.STA; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x86: { code=OpCodes.STX; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0x88: { code=OpCodes.DEY; }
            case 0x8A: { code=OpCodes.TXA; }
            case 0x8C: { code=OpCodes.STY; ticks=4; }
            case 0x8D: { code=OpCodes.STA; ticks=4; }
            case 0x8E: { code=OpCodes.STX; ticks=4; }
            case 0x90: { code=OpCodes.BCC; mode=AddressingModes.Relative; }
            case 0x91: { code=OpCodes.STA; mode=AddressingModes.IndirectY; ticks=6; }
            case 0x94: { code=OpCodes.STY; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x95: { code=OpCodes.STA; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0x96: { code=OpCodes.STX; mode=AddressingModes.ZeroPageY; ticks=4; }
            case 0x98: { code=OpCodes.TYA; }
            case 0x99: { code=OpCodes.STA; mode=AddressingModes.AbsoluteY; ticks=5; }
            case 0x9A: { code=OpCodes.TXS; }
            case 0x9D: { code=OpCodes.STA; mode=AddressingModes.AbsoluteX; ticks=5; }
            case 0xA0: { code=OpCodes.LDY; mode=AddressingModes.Immediate; }
            case 0xA1: { code=OpCodes.LDA; mode=AddressingModes.IndirectX; ticks=6; }
            case 0xA2: { code=OpCodes.LDX; mode=AddressingModes.Immediate; }
            case 0xA4: { code=OpCodes.LDY; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xA5: { code=OpCodes.LDA; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xA6: { code=OpCodes.LDX; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xA8: { code=OpCodes.TAY; }
            case 0xA9: { code=OpCodes.LDA; mode=AddressingModes.Immediate; }
            case 0xAA: { code=OpCodes.TAX; }
            case 0xAC: { code=OpCodes.LDY; ticks=4; }
            case 0xAD: { code=OpCodes.LDA; ticks=4; }
            case 0xAE: { code=OpCodes.LDX; ticks=4; }
            case 0xB0: { code=OpCodes.BCS; mode=AddressingModes.Relative; }
            case 0xB1: { code=OpCodes.LDA; mode=AddressingModes.IndirectY; ticks=5; }
            case 0xB4: { code=OpCodes.LDY; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0xB5: { code=OpCodes.LDA; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0xB6: { code=OpCodes.LDX; mode=AddressingModes.ZeroPageY; ticks=4; }
            case 0xB8: { code=OpCodes.CLV; }
            case 0xB9: { code=OpCodes.LDA; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0xBA: { code=OpCodes.TSX; }
            case 0xBC: { code=OpCodes.LDY; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0xBD: { code=OpCodes.LDA; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0xBE: { code=OpCodes.LDX; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0xC0: { code=OpCodes.CPY; mode=AddressingModes.Immediate; }
            case 0xC1: { code=OpCodes.CMP; mode=AddressingModes.IndirectX; ticks=6; }
            case 0xC4: { code=OpCodes.CPY; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xC5: { code=OpCodes.CMP; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xC6: { code=OpCodes.DEC; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0xC8: { code=OpCodes.INY; }
            case 0xC9: { code=OpCodes.CMP; mode=AddressingModes.Immediate; }
            case 0xCA: { code=OpCodes.DEX; }
            case 0xCC: { code=OpCodes.CPY; ticks=4; }
            case 0xCD: { code=OpCodes.CMP; ticks=4; }
            case 0xCE: { code=OpCodes.DEC; ticks=6; }
            case 0xD0: { code=OpCodes.BNE; mode=AddressingModes.Relative; }
            case 0xD1: { code=OpCodes.CMP; mode=AddressingModes.IndirectY; ticks=5; }
            case 0xD5: { code=OpCodes.CMP; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0xD6: { code=OpCodes.DEC; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0xD8: { code=OpCodes.CLD; }
            case 0xD9: { code=OpCodes.CMP; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0xDD: { code=OpCodes.CMP; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0xDE: { code=OpCodes.DEC; mode=AddressingModes.AbsoluteX; ticks=7; }
            case 0xE0: { code=OpCodes.CPX; mode=AddressingModes.Immediate; }
            case 0xE1: { code=OpCodes.SBC; mode=AddressingModes.IndirectX; ticks=6; }
            case 0xE4: { code=OpCodes.CPX; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xE5: { code=OpCodes.SBC; mode=AddressingModes.ZeroPage; ticks=3; }
            case 0xE6: { code=OpCodes.INC; mode=AddressingModes.ZeroPage; ticks=5; }
            case 0xE8: { code=OpCodes.INX; }
            case 0xE9: { code=OpCodes.SBC; mode=AddressingModes.Immediate; }
            case 0xEA: { code=OpCodes.NOP; }
            case 0xEC: { code=OpCodes.CPX; ticks=4; }
            case 0xED: { code=OpCodes.SBC; ticks=4; }
            case 0xEE: { code=OpCodes.INC; ticks=6; }
            case 0xF0: { code=OpCodes.BEQ; mode=AddressingModes.Relative; }
            case 0xF1: { code=OpCodes.SBC; mode=AddressingModes.IndirectY; ticks=5; }
            case 0xF5: { code=OpCodes.SBC; mode=AddressingModes.ZeroPageX; ticks=4; }
            case 0xF6: { code=OpCodes.INC; mode=AddressingModes.ZeroPageX; ticks=6; }
            case 0xF8: { code=OpCodes.SED; }
            case 0xF9: { code=OpCodes.SBC; mode=AddressingModes.AbsoluteY; ticks=4; }
            case 0xFD: { code=OpCodes.SBC; mode=AddressingModes.AbsoluteX; ticks=4; }
            case 0xFE: { code=OpCodes.INC; mode=AddressingModes.AbsoluteX; ticks=7; }
            
            default: code=OpCodes.NOP;
        }
        
        return Commands.newCmd(code, mode, ticks);
    }
}
