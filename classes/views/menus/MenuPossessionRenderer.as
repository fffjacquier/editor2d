package classes.views.menus 
{
	import classes.config.Config;
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import classes.views.equipements.EquipementView;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	/**
	 * La classe MenuPossessionRenderer permet d'afficher le menu de possession de l'équipement 
	 */
	public class MenuPossessionRenderer extends MenuItemRenderer 
	{
		private var _eqView:EquipementView;
		
		public function MenuPossessionRenderer(obj:EquipementView, menuItem:MenuItem)
		{
			super(menuItem);
			H = 63;			
			_eqView = obj;
			
			var t:CommonTextField = new CommonTextField("helvet", Config.COLOR_LIGHT_GREY, 11);
			t.autoSize = "left";
			t.width = 188;
			t.height = 18.5;
			t.setHtmlText(AppLabels.getString("editor_askPossession"));
			t.x = 10;
			t.y = 5;
			
			addChild(t);
			
			//graphics.beginFill(0xffffff, 0);
			//graphics.drawRect(0, 0, width, height + 6);
			
			var tf:TextFormat = new TextFormat();
			var myFont:Font = new Helvet55Bold(); 
			tf.font = myFont.fontName; 
			tf.bold = true;
			tf.color = 0xffffff; 
			tf.size = 12; 
			
			var group:RadioButtonGroup = new RadioButtonGroup("possess");
			group.addEventListener(MouseEvent.CLICK, _clickHandler);
			
			var ypos:int = t.x + t.textHeight +5 ;
			var xpos:int = t.x;
			
			var rb1:RadioButton = new RadioButton();
			rb1.label = AppLabels.getString("buttons_yes");
			rb1.value = "true";
			rb1.setStyle("embedFonts", true);
			rb1.setStyle("bold", true);
			rb1.setStyle("textFormat", tf);
			rb1.setSize(60,19);
			addChild(rb1);
			rb1.x = xpos;
			rb1.y = ypos;
			rb1.group = group;
			_setAsButton(rb1);
			
			var rb2:RadioButton = new RadioButton();
			rb2.label = AppLabels.getString("buttons_no");
			rb2.value = "false";
			rb2.setStyle("embedFonts", true);
			rb2.setStyle("bold", true);
			rb2.setStyle("textFormat", tf);
			rb2.setSize(60,19);
			addChild(rb2);
			rb2.x = xpos + rb1.width + 5;
			rb2.y = ypos;
			rb2.group = group;
			_setAsButton(rb2);
			
			//need to add a check if the equipment could be already possessed (see Equipmentitem class) TODO
			if (_eqView.isOwned) {
				rb1.selected = true;
				rb2.selected = false;
				return;
			}
			rb1.selected = false;
			rb2.selected = true;
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
			//if(_eqView) {
			_eqView.isOwned = (e.target.selection.value == "true") ? true : false;
			//trace("isOwned ?", _eqView.isOwned);
			//}
		}
		
		public function getHeight():int
		{
			return 63;
		}
	}
}