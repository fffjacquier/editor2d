package classes.views.menus 
{
	import classes.commands.AddNewSurfaceCommand;
	import classes.config.Config;
	import classes.resources.AppLabels;
	import classes.views.alert.AlertManager;
	import classes.views.alert.YesNoAlert;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.vo.Shapes;
	import classes.vo.ShapeVO;
	import fl.controls.RadioButtonGroup;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * La classe MenuSurfaceRenderer permet d'afficher les menus particuliers des surfaces globales.
	 * Les deux menus possibles sont gérés : menu de changement de taille et menu de changement de forme.
	 */
	public class MenuSurfaceRenderer extends MenuItemRenderer 
	{
		private var group:RadioButtonGroup;
		private var _isForme:Boolean;
		private var _previousTexte:String;
		private var _longtxt:TextField;
		private var _largtxt:TextField;
		
		public function MenuSurfaceRenderer(menuItem:MenuItem, isForme:Boolean = true)
		{
			_isForme = isForme;
			super(menuItem);
			H = getHeight();
			
			var title:String = isForme ? AppLabels.getString("editor_changeShape") : AppLabels.getString("editor_changeArea");
			
			var t:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_WHITE, 12);
			t.autoSize = "left";
			t.width = 188;
			t.height = 18.5;
			t.setText(title);
			t.x = 10;
			t.y = 5;
			addChild(t);
			var netxy:int = t.y + t.textHeight + 8;
			
			if (_isForme) {
				var forme:MovieClip = new IconSurfaceLShape();
				addChild(forme);
				forme.x = 12
				forme.y = netxy
				
				var spaces:int = 45;
				forme = new DraggableIconSurfaceLShape2();
				addChild(forme);
				forme.x = 12 + spaces
				forme.y = netxy
				
				forme = new DraggableIconSurfaceLShape3();
				addChild(forme);
				forme.x = 12 + spaces*2
				forme.y = netxy
				
				forme = new DraggableIconSurfaceLShape4();
				addChild(forme);
				forme.x = 12 + spaces*3
				forme.y = netxy
				
			} else {
				var longTxt:CommonTextField = new CommonTextField("helvetBold", 0xffffff, 10);
				addChild(longTxt);
				longTxt.width = 100;
				longTxt.autoSize = "left";
				longTxt.wordWrap = false;
				longTxt.multiline = false;
				longTxt.setText(AppLabels.getString("accordion_length"));
				longTxt.x = 16
				longTxt.y = netxy
				
				longTxt = new CommonTextField("helvetBold", 0xffffff, 10);
				addChild(longTxt);
				longTxt.setText(AppLabels.getString("accordion_width"));
				longTxt.x = 80
				longTxt.y = netxy
				
				netxy += 15;
				var s:Sprite = new Sprite();
				addChild(s);
				s.y = netxy;
				s.x = 12;
				var g:Graphics = s.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0xffffff, .3);
				g.drawRoundRect(0, 0, 53, 24, 9);
				g.endFill();
				var textForM:CommonTextField = new CommonTextField("helvetBold", 0xffffff, 10);
				textForM.width = 50;
				textForM.autoSize = "left";
				textForM.setText(AppLabels.getString("editor_metersShortcut"));
				s.addChild(textForM);
				textForM.y = 5
				textForM.x = 53 - textForM.textWidth - 8;
				
				s = new Sprite();
				addChild(s);
				s.y = netxy;
				s.x = 72
				g = s.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0xffffff, .3);
				g.drawRoundRect(0, 0, 53, 24, 9);
				g.endFill();
				textForM = new CommonTextField("helvetBold", 0xffffff, 10);
				textForM.width = 50;
				textForM.autoSize = "left";
				textForM.setText(AppLabels.getString("editor_metersShortcut"));
				s.addChild(textForM);
				textForM.y = 5
				textForM.x = 53 - textForM.textWidth - 8;
				
				// champ de texte pour longueur et largeur
				var form:TextFormat = new TextFormat()
				//form.font = (new Verdana() as Font).fontName;
				form.size = 12;
				
				var mc:SmallEditableTextField = new SmallEditableTextField();
				addChild(mc);
				mc.x = 33;
				mc.y = netxy +3;
				mc.t.htmlText = "<b>8"
				//mc.t.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut, false, 0, true);
				_longtxt = mc.t;
				
				var mc2:SmallEditableTextField = new SmallEditableTextField();
				addChild(mc2);
				mc2.x = 92
				mc2.y = netxy +3;
				mc2.t.htmlText = "<b>6"
				_largtxt = mc2.t;
				//mc2.t.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut, false, 0, true);
				
				// bouton ok
				var btnok:Btn = new Btn(Config.COLOR_ORANGE, AppLabels.getString("buttons_ok"), null, 40, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_ORANGE);
				addChild(btnok);
				btnok.x = 150;
				btnok.y = netxy;
				btnok.addEventListener(MouseEvent.CLICK, _clickBtnOk, false, 0, true);
				
				MenuItemRenderer.DOCLOSE = false;
			}
		}
		
		/*override protected function added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, added);
		}*/
		
		private function _onFocusOut(e:FocusEvent):void
		{
			//trace("focus out", e.target.text);
			//var num:int = parseInt(e.target.text);
			//if (num >= 30) e.target.htmlText = "<b>30";
		}
		
		private function _clickBtnOk(e:MouseEvent):void
		{
			//trace("ok", _longtxt.text, _largtxt.text);
			/*longueur = int(_longtxt.text);
			largeur = int(_largtxt.text);*/
			var popup:YesNoAlert = new YesNoAlert(AppLabels.getString("alert_changeSurfaceSize"), AppLabels.getString("alert_changeSurfaceSizeQuestion"), _doChangeSizes, function():void{});
			AlertManager.addPopup(popup, Main.instance);
			
			/*Shapes.instance.update(int(_longtxt.text), int(_largtxt.text));
			var points:Array = (Shapes.instance.blocsMaison[0] as ShapeVO).pointsClone;
			new AddNewSurfaceCommand(points).run();*/
		}
		
		private function _doChangeSizes():void
		{
			Shapes.instance.update(int(_longtxt.text), int(_largtxt.text));
			var points:Array = (Shapes.instance.blocsMaison[0] as ShapeVO).pointsClone;
			new AddNewSurfaceCommand(points).run();
		}
		
		/*public function get longueur():int
		{
			return (_longtxt == null) ? 8 : int(_longtxt.text);
		}
		
		public function get largeur():int
		{
			return (_largtxt == null) ? 6 : int(_largtxt.text);
		}*/
		
		public function getHeight():int
		{
			//trace("MenuSurfaceRenderer::getHeight");
			return (_isForme) ? 65 : 76;
		}
		
	}

}