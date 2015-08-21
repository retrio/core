package retrio.ui.haxeui;

import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.controls.HSlider;
import haxe.ui.toolkit.controls.CheckBox;
import haxe.ui.toolkit.controls.Spacer;
import haxe.ui.toolkit.controls.selection.ListSelector;
import haxe.ui.toolkit.containers.ScrollView;
import haxe.ui.toolkit.containers.TabView;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.containers.Grid;
import haxe.ui.toolkit.containers.Absolute;
import haxe.ui.toolkit.core.DisplayObjectContainer;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.RootManager;
import haxe.ui.toolkit.data.ArrayDataSource;
import haxe.ui.toolkit.style.Style;
import haxe.ui.toolkit.style.StyleManager;
import haxe.ui.toolkit.themes.GradientTheme;
import retrio.config.ISettingsHandler;
import retrio.config.Setting;
import retrio.config.SettingCategory;


class SettingsPage
{
	public static function show(settings:Array<SettingCategory>, handler:ISettingsHandler, ?finishedCallback:Void->Void)
	{
		//Toolkit.theme = new GradientTheme();
		Toolkit.init();
		StyleManager.instance.addStyle("ScrollView", new Style({
			autoHideScrolls: false,
		}));

		Toolkit.openPopup({x:0, y:0, percentWidth:100, percentHeight:100, styleName:'popup'}, function(root:Root) {
			var abs = new Absolute();
			abs.style.autoSize = false;

			root.onResize = abs.onReady = function(e) {
				abs.width = Std.int(Math.min(root.width * 0.90, 800));
				abs.height = Std.int(Math.min(root.height * 0.90, 600));
				abs.x = (root.width - abs.width) / 2;
				abs.y = (root.height - abs.height) / 2;
			}

			var tabs = new TabView();
			tabs.style.percentWidth = 100;
			tabs.style.percentHeight = 100;
			tabs.style.padding = 8;

			for (page in settings)
			{
				addSettingPage(page, tabs);
			}

			abs.addChild(tabs);

			var btn = new Button();
			btn.text = "Close";
			btn.onClick = function(e) {
				handler.loadSettings(settings, true);
				RootManager.instance.destroyRoot(root);
				if (finishedCallback != null)
					finishedCallback();
			}
			abs.onResize = btn.onReady = btn.onChange = function(e) {
				btn.x = 8;
				btn.y = abs.height - btn.height - 8;
			}
			abs.addChild(btn);

			root.addChild(abs);
		});
	}

	static function addSettingPage(page:SettingCategory, parent:TabView)
	{
		var grid = new Grid();
		grid.columns = 3;
		grid.style.percentWidth = 100;
		grid.style.percentHeight = 100;

		if (page.settings != null && page.settings.length > 0)
		{
			for (control in page.settings)
			{
				addSettingControl(control, grid);
			}
		}
		else if (page.custom != null && page.custom.render != null)
		{
			page.custom.render(grid);
		}
		else
		{
			var label = new Text();
			label.text = "(no settings)";
			grid.addChild(label);
		}

		parent.addChild(grid);
		parent.setTabText(parent.pageCount - 1, page.name);
	}

	static function addSettingControl(setting:Setting, parent:DisplayObjectContainer)
	{
		var label = new Text();
		label.text = setting.name;
		parent.addChild(label);

		var spacer = new Spacer();
		spacer.width = 16;
		parent.addChild(spacer);

		switch(setting.type)
		{
			case BoolValue:
				addBoolControl(setting, parent);
			case IntValue(min, max):
				addIntControl(setting, parent, min, max);
			case StringValue(maxLength):
				addStringControl(setting, parent, maxLength);
			case Options(options):
				addOptionsControl(setting, parent, options);
		}
	}

	static function addBoolControl(setting:Setting, parent:DisplayObjectContainer)
	{
		var checkBox = new CheckBox();
		checkBox.selected = cast(setting.value, Bool);
		checkBox.onChange = function(e) {
			setting.value = checkBox.selected;
		}
		parent.addChild(checkBox);
	}

	static function addIntControl(setting:Setting, parent:DisplayObjectContainer, min:Int, max:Int)
	{
		var box = new HBox();
		box.style.percentWidth = 100;

		var slider = new HSlider();
		slider.min = min;
		slider.max = max;
		slider.pos = setting.value;
		slider.style.percentWidth = 75;
		box.addChild(slider);

		var label = new Text();
		label.text = Std.string(setting.value);
		label.style.percentWidth = 25;
		box.addChild(label);

		slider.onChange = function(e) {
			setting.value = slider.value;
			label.text = Std.string(setting.value);
		}

		parent.addChild(box);
}

	static function addStringControl(setting:Setting, parent:DisplayObjectContainer, maxLength:Int)
	{
		var input = new TextInput();
		input.text = setting.value;
		input.maxChars = maxLength;
		input.style.percentWidth = 80;
		input.onChange = function(e) {
			setting.value = input.text;
		}
		parent.addChild(input);
	}

	static function addOptionsControl(setting:Setting, parent:DisplayObjectContainer, options:Array<String>)
	{
		var list = new ListSelector();
		list.text = Std.string(setting.value);
		list.style.percentWidth = 80;

		var optionString = options.join(',');
		var data = new ArrayDataSource();
		data.createFromString(optionString);
		list.dataSource = data;

		list.onReady = function(e) {
			list.method = 'default';
		}
		list.onChange = function(e) {
			setting.value = list.text;
		}

		parent.addChild(list);
	}
}
