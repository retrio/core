package retrio.ui.haxeui;

import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.Image;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.controls.TabBar;
import haxe.ui.toolkit.controls.selection.ListSelector;
import haxe.ui.toolkit.data.ArrayDataSource;
import haxe.ui.toolkit.core.DisplayObjectContainer;
import haxe.ui.toolkit.core.StyleableDisplayObject;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.PopupManager;
import haxe.ui.toolkit.containers.ScrollView;
import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.containers.Grid;
import retrio.ISettingsHandler;


class ControllerSettingsPage
{
	static inline var DISABLED = "(disabled)";

	public static function render(plugin:IEmulatorFrontend, controllerImg:String, buttons:Array<Int>, buttonNames:Map<Int, String>,
								  controllerTypes:Array<Class<IController>>, container:DisplayObjectContainer)
	{
		var page = new ControllerSettingsPage(plugin, controllerImg, buttons, buttonNames, controllerTypes, container);
	}

	public static function save(plugin:ISettingsHandler) {}

	var plugin:IEmulatorFrontend;
	var controllerTypes:Array<Class<IController>>;

	var selectedController:Int = 0;
	var controllerList:TabBar;
	var inputMethodList:ListSelector;
	var lastInputMethod:String;
	var buttonMap:Map<Int, Button> = new Map();
	var buttonScroll:ScrollView;
	var buttonList:VBox;

	function new(plugin:IEmulatorFrontend, controllerImg:String, buttons:Array<Int>, buttonNames:Map<Int, String>,
				 controllerTypes:Array<Class<IController>>, container:DisplayObjectContainer)
	{
		this.plugin = plugin;
		this.controllerTypes = controllerTypes;

		var maxControllers:Int = plugin.controllers.length;

		var box = new VBox();
		box.style.percentWidth = 100;
		box.style.percentHeight = 100;

		if (maxControllers > 1)
		{
			// choose controller to configure
			controllerList = new TabBar();
			controllerList.style.percentWidth = 100;

			for (i in 0 ... maxControllers)
			{
				controllerList.addTab("Player " + (i+1));
			}
			controllerList.selectedIndex = 0;

			controllerList.onChange = function(e) {
				setSelectedController();
			}

			box.addChild(controllerList);
		}

		// input method dropdown
		var hbox = new HBox();
		hbox.style.percentWidth = 100;

		var label = new Text();
		label.text = "Input method:";
		hbox.addChild(label);

		inputMethodList = new ListSelector();
		inputMethodList.style.autoSize = true;
		var data = new ArrayDataSource();
		var cTypes = [for (c in controllerTypes) Reflect.field(c, "name")];
		data.createFromString([DISABLED].concat(cTypes).join(','));
		inputMethodList.text = cTypes[0];
		inputMethodList.dataSource = data;
		inputMethodList.onReady = function(e) {
			inputMethodList.method = 'default';
		}
		inputMethodList.onChange = function(e) {
			setInputMethod();
		}
		hbox.addChild(inputMethodList);

		box.addChild(hbox);

		var hbox = new HBox();
		hbox.style.percentWidth = 100;
		hbox.style.autoSize = true;

		// controls
		buttonScroll = new ScrollView();
		buttonScroll.style.percentWidth = 50;
		buttonScroll.style.percentHeight = 100;

		buttonList = new VBox();
		buttonList.style.percentWidth = 100;
		buttonList.style.padding = 8;
		buttonList.style.paddingRight = 16;

		for (button in buttons)
		{
			var row = new HBox();
			row.style.percentWidth = 100;
			var name = buttonNames[button];

			var label = new Text();
			label.style.percentWidth = 25;
			label.style.textAlign = "right";
			label.text = name;
			row.addChild(label);

			var btn = new Button();
			btn.style.percentWidth = 75;
			btn.text = name;
			row.addChild(btn);
			var popupButtons:Array<Dynamic> = [
				new PopupButtonInfo(PopupButton.CUSTOM, "Clear"),
				PopupButton.CANCEL
			];
			btn.onClick = function(e) {
				var popup = PopupManager.instance.showSimple("Do something...", name,
					{buttons:popupButtons},
					function(btnPressed:Dynamic) {
						switch(btnPressed) {
							case PopupButton.CUSTOM:
								plugin.controllers[selectedController].clearDefinition(button);
								btn.text = DISABLED;
							case PopupButton.CANCEL:
								plugin.controllers[selectedController].ask(null);
						}
					}
				);
				plugin.controllers[selectedController].ask(function(k:Int) {
					var c = plugin.controllers[selectedController];
					c.define(k, button);
					btn.text = c.codeName(k);
					PopupManager.instance.hidePopup(popup);
				});
			}

			buttonMap[button] = btn;

			buttonList.addChild(row);
		}

		buttonScroll.addChild(buttonList);

		buttonScroll.onClick = function(e) {
			buttonScroll.showVScroll = true;
		}

		hbox.addChild(buttonScroll);

		var img = new Image();
		img.style.percentWidth = 50;
		img.resource = controllerImg;
		hbox.addChild(img);

		box.addChild(hbox);

		container.addChild(box);

		setSelectedController();
	}

	function setSelectedController()
	{
		selectedController = (controllerList == null) ? 0 : controllerList.selectedIndex;

		var controller = plugin.controllers[selectedController];
		if (controller == null)
		{
			inputMethodList.text = lastInputMethod = DISABLED;
			setButtonListVisibility(false);
		}
		else
		{
			inputMethodList.text = lastInputMethod = Reflect.field(Type.getClass(controller), "name");
			setButtonText(controller);
		}
	}

	function setInputMethod()
	{
		if (inputMethodList.text != lastInputMethod)
		{
			lastInputMethod = inputMethodList.text;

			if (inputMethodList.text == DISABLED)
			{
				if (plugin.controllers[selectedController] != null)
				{
					plugin.removeController(selectedController);
				}
				setButtonListVisibility(false);
			}
			else
			{
				for (controllerType in controllerTypes)
				{
					if (Reflect.field(controllerType, "name") == inputMethodList.text)
					{
						if (plugin.controllers[selectedController] != null)
						{
							plugin.removeController(selectedController);
						}

						var controller = Type.createInstance(controllerType, []);
						plugin.addController(controller, selectedController);
						controller.add();
						setButtonText(controller);
						break;
					}
				}
			}
		}
	}

	function setButtonText(controller:IController)
	{
		for (i in buttonMap.keys())
		{
			var code = controller.codeForButton(i);
			var name = (code == null) ? DISABLED : controller.codeName(code);
			buttonMap[i].text = name;
		}
		setButtonListVisibility(true);
	}

	function setButtonListVisibility(visible:Bool)
	{
		buttonList.visible = visible;
		buttonScroll.disabled = buttonList.disabled = !visible;
	}
}
