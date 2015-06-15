package strafe.ui.openfl;

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

		text = txt;
		visible = false;
		autoSize = TextFieldAutoSize.CENTER;
		mouseEnabled = false;
		embedFonts = true;

		if (fmt == null)
		{
			fmt = new TextFormat();
			fmt.color = 0xffffff;
			//fmt.bold = true;
			fmt.size = 16;
			fmt.align = TextFormatAlign.CENTER;
			fmt.font = Assets.getFont("fonts/sigmarone.ttf").fontName;
		}
		setTextFormat(fmt);

		//filters.push(new GlowFilter(0x000000,1.0,2.0,2.0,10));
	}
}
