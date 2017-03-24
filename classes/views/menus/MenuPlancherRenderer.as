package classes.views.menus 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import classes.views.plan.Floor;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	/**
	 * La classe MenuPlancherRenderer permet d'afficher le menu lié au plancher de l'étage
	 */
	public class MenuPlancherRenderer extends MenuItemRenderer 
	{
		private var group:RadioButtonGroup;
		private var _floor:Floor;
		
		public function MenuPlancherRenderer(menuItem:MenuItem, floor:Floor)
		{
			_floor = floor;
			super(menuItem);
			H = 73;	
			
			var t:CommonTextField = new CommonTextField("helvet", Config.COLOR_WHITE, 12);
			t.autoSize = "left";
			t.width = 188;
			t.height = 18.5;
			var str:String = AppLabels.getString("editor_floorNature");
			var boldStartNum:int = (str.split("<b>")[0] as String).length;
			var newstr:String = str.split("<b>")[1];
			var boldEndNum:int = boldStartNum + newstr.length;
			t.setText(str.split("<b>")[0] + newstr + str.split("<b>")[2]);			
			if (boldStartNum < boldEndNum) {
				var boldFormat:TextFormat = t.cloneFormat();
				boldFormat.font = (new Helvet55Bold() as Font).fontName;
				boldFormat.bold = true;
				t.setTextFormat(boldFormat, boldStartNum, boldEndNum);
			}
			
			t.x = 10;
			t.y = 5;
			addChild(t);
			
			var tf:TextFormat = new TextFormat();
			var myFont:Font = new Helvet55Bold(); 
			tf.font = myFont.fontName; 
			tf.bold = true;
			tf.color = Config.COLOR_WHITE; 
			tf.size = 12; 
			
			group = new RadioButtonGroup("possess");
			group.addEventListener(MouseEvent.CLICK, _clickHandler);
			
			var ypos:int = t.x + t.textHeight +5 ;
			var xpos:int = t.x;
			
			var rb1:RadioButton = new RadioButton();
			rb1.label = AppLabels.getString("editor_concrete");
			rb1.value = "beton";
			rb1.setStyle("embedFonts", true);
			rb1.setStyle("bold", true);
			rb1.setStyle("textFormat", tf);
			rb1.setSize(80,19);
			addChild(rb1);
			rb1.x = xpos;
			rb1.y = ypos;
			rb1.group = group;
			_setAsButton(rb1);
			
			var rb2:RadioButton = new RadioButton();
			rb2.label = AppLabels.getString("editor_wood");
			rb2.value = "bois";
			rb2.setStyle("embedFonts", true);
			rb2.setStyle("bold", true);
			rb2.setStyle("textFormat", tf);
			rb2.setSize(80,19);
			addChild(rb2);
			rb2.x = xpos + rb1.width + 5;
			rb2.y = ypos;
			rb2.group = group;
			_setAsButton(rb2);
			
			var isItBeton:Boolean = (_floor.plancher == "beton")
			rb2.selected = !isItBeton;
			rb1.selected = isItBeton;
		}
		
		private function _setAsButton(rb:RadioButton):void
		{
			//skin
			rb.setStyle("upIcon", RadioButtonSkinBase);
			rb.setStyle("overIcon", RadioButtonSkinBase);
			rb.setStyle("downIcon", RadioiButtonSkinDown);
			rb.setStyle("disabledIcon", RadioButtonSkinBase);
			rb.setStyle("selectedUpIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedOverIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedDownIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedDisabledIcon", RadioButtonSkinSelected);
			rb.setStyle("focusRectSkin", new Sprite());
			
			//button stuff
			rb.buttonMode = true;
			rb.useHandCursor = true;
			rb.mouseChildren = false;
		}
		
		private function _clickHandler(e:MouseEvent):void
		{
			//trace("plancher ?", group.selectedData);
			EditorModelLocator.instance.currentFloor.plancher = group.selectedData.toString();
			ApplicationModel.instance.notifySaveStateUpdate(true);
		}
		
		public function getHeight():int
		{
			//trace("menuPlancherRenderer::getHeight");
			return 73;
		}
		
	}

}