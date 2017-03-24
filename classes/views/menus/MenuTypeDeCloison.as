package classes.views.menus 
{
	import classes.config.Config;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.WifiUtils;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.plan.Segment;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	/**
	 * La classe MenuTypeDeCloison affiche le menu sur le type de cloison quand l'utilisateur clique sur le
	 *  menu mur porteur (et le click définit le mur comme mur porteur)
	 */
	public class MenuTypeDeCloison extends Sprite 
	{
		private var group:RadioButtonGroup;
		private var tf1:TextFormat;
		private var tf2:TextFormat;
		private var d:Dictionary;
		private var _btnValid:Btn;
		private var _errTF:CommonTextField;
		private var rb1:RadioButton;
		private var rb2:RadioButton;
		private var rb3:RadioButton;
		private var _selectedVal:String;
		private var _WIDTH:int = 150;
		private var _segment:Segment;
		
		public function MenuTypeDeCloison(segment:Segment) 
		{
			_segment = segment;
			
			d = new Dictionary(true);
			d[WifiUtils.THICKNESS_MEDIUM] = AppLabels.getString("editor_soundsFullMedium");
			d[WifiUtils.THICKNESS_THICK] = AppLabels.getString("editor_soundsFullThick");
			d[WifiUtils.THICKNESS_NSP] = AppLabels.getString("editor_dontKnow");
			
			addEventListener(Event.REMOVED_FROM_STAGE, _cleanup);
			
			var myFont:Font = new Helvet55Bold(); 
 			tf1 = new TextFormat();
			tf1.font = myFont.fontName; 
			tf1.bold = true;
			tf1.color = Config.COLOR_DARK; 
			tf1.size = 12; 
			
 			tf2 = new TextFormat();
			tf2.font = myFont.fontName; 
			tf2.bold = true;
			tf2.color = Config.COLOR_ORANGE; 
			tf2.size = 12;
			
			_addQCM();
		}
		
		private function _addQCM():void
		{
			// draw bg
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, 0x999999);
			g.beginFill(0xf8f8f8);
			
			var xpos:int = 5;
			
			// add question
			var title:CommonTextField = new CommonTextField("helvetBold");
			title.width = _WIDTH - 5;
			addChild(title);
			title.setText(AppLabels.getString("editor_wallNatureQuestion"));
			title.setTextFormat(tf2);
			title.x = xpos;
			title.y = xpos;
			
			// add the choices
			group = new RadioButtonGroup("natureCloison");
			group.addEventListener(MouseEvent.CLICK, _clickHandler);
			
			var ypos:int = 50;
			var esp:int = 4;
			
			rb1 = _rb(WifiUtils.THICKNESS_MEDIUM);
			rb1.x = xpos -3;
			rb1.y = ypos;
			ypos = rb1.y + rb1.height + esp;
			rb1.group = group;
			
			rb2 = _rb(WifiUtils.THICKNESS_THICK);
			rb2.x = xpos -3;
			rb2.y = ypos;
			ypos = rb2.y + rb2.height +esp;
			rb2.group = group;
			
			rb3 = _rb(WifiUtils.THICKNESS_NSP);
			rb3.x = xpos -3;
			rb3.y = ypos;
			ypos = rb3.y + rb3.height +esp;
			rb3.group = group;
			
			if(_segment.coeff == 3) {
				rb3.selected = true;
				_selectedVal = WifiUtils.THICKNESS_NSP;
			} else if(_segment.coeff == 7) {
				rb1.selected = true;
				_selectedVal = WifiUtils.THICKNESS_MEDIUM;
			} else if(_segment.coeff == 10) {
				rb2.selected = true;
				_selectedVal = WifiUtils.THICKNESS_THICK;
			}
			/*
			_errTF = new CommonTextField("helvetBold", 0xffcc00);
			_errTF.width = 160;
			addChild(_errTF);
			_errTF.x = xpos;
			_errTF.y = ypos;*/
			
			_btnValid = new Btn(0, AppLabels.getString("buttons_validate"), null, 68, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_ORANGE);
			addChild(_btnValid);
			_btnValid.x = _WIDTH - 68 -5;
			_btnValid.y = ypos;
			ypos = _btnValid.y + 24 + esp;
			_btnValid.addEventListener(MouseEvent.CLICK, _onValidate, false, 0, true);
			
			// fermer le fond
			g.drawRoundRect(0, 0, _WIDTH, ypos, 9);
			g.endFill();			
		}
		
		private function _clickHandler(e:MouseEvent):void
		{
			_selectedVal = (e.target.selection.value);
			/*var selectedRadioButton:RadioButton = (e.target.selection as RadioButton);
			
			rb1.setStyle("textFormat", tf1);
			rb2.setStyle("textFormat", tf1);
			rb3.setStyle("textFormat", tf1);
			
			selectedRadioButton.setStyle("textFormat", tf2);*/
			//_errTF.setText("");
		}
		
		private function _onValidate(e:MouseEvent):void
		{
			trace("_selectedVal:", _selectedVal);
			validate();
		}
		
		// add final action to segment
		public function validate():void
		{
			var k:int = WifiUtils.coeffCloison(_selectedVal);
			_segment.setCoeffAndMurPorteur(k);
		}
		
		private function _rb(val:String):RadioButton
		{
			var rb:RadioButton = new RadioButton();
			rb.label = d[val];
			rb.value = val;
			rb.setStyle("embedFonts", true);
			rb.setStyle("bold", true);
			rb.setStyle("textFormat", tf1); 
			rb.setSize(_WIDTH -1,19);
			addChild(rb);
			AppUtils.setButton(rb);
			AppUtils.radioButtonHack(rb);
			return rb;
		}
		
		private function _cleanup(e:Event):void
		{
			//trace("MenuTypeDeCloison::_cleanup()")
			if (_btnValid) _btnValid.removeEventListener(MouseEvent.CLICK, _onValidate);
			group.removeEventListener(MouseEvent.CLICK, _clickHandler);
		}
		
	}

}