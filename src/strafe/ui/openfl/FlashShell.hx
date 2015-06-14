package strafe.ui.openfl;

import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;


class FlashShell extends Shell
{
	var uploadLabel:TextField;

	override public function onStage(e:Dynamic)
	{
		super.onStage(e);

		uploadLabel = new TextField();
		var tf:TextFormat = new TextFormat();
		tf.size = 24;
		uploadLabel.defaultTextFormat = tf;
		uploadLabel.text = "Click to upload a ROM.";
		uploadLabel.textColor = 0xffffff;
		//uploadLabel.x = (_width - uploadLabel.width) / 2;
		uploadLabel.y = (_height - uploadLabel.height) / 2;

		uploadLabel.autoSize = TextFieldAutoSize.CENTER;
		uploadLabel.width = _width;

		addChild(uploadLabel);

		_stage.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
	}

	function onClick(e:Dynamic)
	{
		loadRom();
	}
}
