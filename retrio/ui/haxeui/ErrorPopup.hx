package retrio.ui.haxeui;

import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.PopupManager;


class ErrorPopup
{
	public static function show(msg:String, ?callback:Void->Void=null)
	{
		Toolkit.openPopup({x:0, y:0, percentWidth:100, percentHeight:100, styleName:'popup'}, function(root:Root) {
			PopupManager.instance.showSimple(msg, "Error", {buttons: PopupButton.OK}, function(e:Dynamic) {
				if (callback != null) callback();
			});
		});
	}
}
