package classes.views.alert 
{
	import classes.config.Config;
	import classes.resources.AppLabels;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.equipements.EquipementView;
	import classes.views.EquipementsLayer;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * La classe SwitchAlert permet d'afficher une alerte qui explique que la présence d'un switch 
	 * va être nécessaire dans l'installation
	 */
	public class SwitchAlert extends Sprite 
	{
		private var _WIDTH:int = 405;
		private var _HEIGHT:int = 60;
		private var _group:RadioButtonGroup;
		private var _btnOk:Btn;
		private var _subSprite:Sprite;
		private var _eq:EquipementView;
		
		public function SwitchAlert(eq:EquipementView) 
		{
			_eq = eq;
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			var g:Graphics = graphics
			g.clear();
			g.lineStyle(1, 0x999999);
			g.beginFill(0xfcfcfc);
			g.drawRoundRect(0, 0, _WIDTH, _HEIGHT, 12);
			g.endFill();
			
			var the_label:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_ORANGE, 12);
			the_label.width = _WIDTH - 50;
			the_label.embedFonts = true;
			var label:String = AppLabels.getString("equipments_noPortAvailable");
			the_label.setHtmlText(label);
			addChild(the_label);
			the_label.x = 8
			the_label.y = 1;
			
			//ajout info btn
			var btnI:IconInfo = new IconInfo();
			addChild(btnI);
			btnI.addEventListener(MouseEvent.CLICK, _info, false, 0, true);
			btnI.x = the_label.x + the_label.textWidth + 20;
			btnI.y = the_label.y + the_label.textHeight - 12//- btnI.height//3;
			
			var xpos:int = 0;
			var ypos:int = 35;
			
			_addSubtext();
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
		
		private function _info(e:MouseEvent):void
		{
			trace("click info switch");
		}
		
		/*private function _clickOk(e:MouseEvent):void
		{
			_btnOk.removeEventListener(MouseEvent.CLICK, _clickOk);
			if (_btnOk && _btnOk.stage) removeChild(_btnOk);
			
			_addSubtext();
		}*/
		
		private function _addSubtext():void
		{
			var moduleName:String;
			if (_eq.vo.type == "LiveboxItem") {
				moduleName = AppLabels.getString("equipments_theLivebox");
			} else if (_eq.vo.type == "LivePlugItem") {
				moduleName = AppLabels.getString("equipments_theLiveplugHD");
			} else if (_eq.vo.type == "WifiDuoItem") {
				moduleName = AppLabels.getString("equipments_theLiveplugWiFi");
			} else if (_eq.vo.type == "WifiExtenderItem") {
				moduleName = AppLabels.getString("equipments_theWiFiExtender");
			}
			var ss:String = AppLabels.getString("equipments_adviceSwitchOn") + moduleName + AppLabels.getString("equipments_adviceSwitchEnd");
			// s'il y a un décodeur sur la ligne
			if(EquipementsLayer.isThereDecodeurConnected()) {
				ss += AppLabels.getString("equipments_adviceSwitchVideoQuality");
			}
			_subSprite = new Sprite();
			addChild(_subSprite);
			
			// add text
			var t:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_DARK);
			_subSprite.addChild(t);
			t.width = 400;
			t.setText(ss);
			
			// position _subSprite
			_subSprite.x = 8;
			_subSprite.y = 20;
			
			var g:Graphics = graphics;
			// draw the bg
			g.clear();
			g.lineStyle(1, 0x999999);
			g.beginFill(0xfcfcfc);
			g.drawRoundRect(0, 0, _WIDTH + 12, _subSprite.y + _subSprite.height + 10, 12);
			g.endFill();
			
			if (!EquipementsLayer.isThereDecodeurConnected()) {
				y += 38;
			}
		}
		
		private function _removeSubtext():void
		{
			if (_subSprite && _subSprite.stage) removeChild(_subSprite);
		}
		
		private function _removed(e:Event):void
		{
			//clean
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}

}