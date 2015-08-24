package retrio.ui.openfl;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.filters.GlowFilter;
import openfl.Assets;


class ButtonHint extends TextField
{
	static var fmt:TextFormat;

	public function new(txt:String)
	{
		super();

		if (fmt == null)
		{
			fmt = new TextFormat();
			fmt.color = 0xff0000;
			fmt.size = 18;
			fmt.align = TextFormatAlign.CENTER;
			fmt.font = Assets.getFont("fonts/archivo.otf").fontName;
		}
		defaultTextFormat = fmt;

		text = txt;
		background = true;
		backgroundColor = 0x40a08080;
		border = true;
		borderColor = 0xa00000;
		autoSize = TextFieldAutoSize.LEFT;
		mouseEnabled = false;
		embedFonts = true;
		visible = false;
	}
}
