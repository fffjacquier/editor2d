package classes.views.alert 
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import com.adobe.utils.StringUtil;
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	import fl.controls.TextArea;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	/**
	 * La classe AlertMemo affiche le popup de saisie d'une note de mémo.
	 */
	public class AlertMemo extends MovieClip 
	{
		private var _memo:Memo;
		private var _title:CommonTextField;
		private var _btnAnnuler:Btn;
		private var _btnSave:Btn;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _scrollpane:ScrollPane;
		private var _ta:TextArea;
		
		/**
		 * Affiche le popup de saisie des mémos.
		 */
		public function AlertMemo() 
		{
			super();
			_memo = new Memo();
			addChild(_memo);
			
			_title = new CommonTextField("helvet35", 0xffffff, 50);
			_title.width = _memo.width - 10;
			_title.setText(AppLabels.getString("check_yourNotes"));
			addChild(_title);
			_title.x = 24.4;
			
			_btnAnnuler = new Btn(0, AppLabels.getString("buttons_cancel"), null, 116, 0xffffff, 12, 24, Btn.GRADIENT_DARK);
			addChild(_btnAnnuler);
			_btnAnnuler.x = 25;
			_btnAnnuler.y = 234;			
			_btnAnnuler.addEventListener(MouseEvent.CLICK, _annuler);
			_btnAnnuler.mouseChildren = false;
			_btnAnnuler.buttonMode = true;
			
			_btnSave = new Btn(0, AppLabels.getString("buttons_save"), null, 100, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			_btnSave.x = 125 + 25;
			_btnSave.y = 234;	
			addChild(_btnSave);
			_btnSave.addEventListener(MouseEvent.CLICK, _save);
			_btnSave.mouseChildren = false;
			_btnSave.buttonMode = true;
			
			addEventListener(Event.REMOVED_FROM_STAGE, _remove);
			
			_ta = new TextArea();
			_ta.setSize(247, 156);
			_ta.move(24, 62);
			_ta.editable = true;
			_ta.enabled = true; 
			_ta.text = AppLabels.getString("popups_typeYourText"); 
			_ta.wordWrap = true;
			_ta.horizontalScrollPolicy = ScrollPolicy.OFF;
			_ta.verticalScrollPolicy = ScrollPolicy.ON;
			_ta.textField.antiAliasType = AntiAliasType.ADVANCED;
			var ft:TextFormat = new TextFormat();
			ft.font = (new Helvet55Reg() as Font).fontName;
			ft.size = 12;
			_ta.setStyle("embedFonts", true);
			_ta.setStyle("textFormat", ft);
			_ta.drawNow();
			addChild(_ta);
			_ta.addEventListener(FocusEvent.FOCUS_IN, _focusIn, false, 0, true);
			
		}
		
		private function _focusIn(e:FocusEvent):void
		{
			//e.currentTarget.text = "";
			_ta.text = "";
		}
		
		private function _annuler(e:MouseEvent):void
		{
			AlertManager.removePopup();
		}
		
		private function _save(e:MouseEvent):void
		{
			if (_ta.text != AppLabels.getString("popups_typeYourText") && StringUtil.trim(_ta.text) != "") {
				_appmodel.memos += _ta.text +"\n\n";
				if (ApplicationModel.instance.screen === ApplicationModel.SCREEN_RECAP) {
					//force update
					_appmodel.notifyMemoUpdate();
				}
			}
			_annuler(e);
		}
		
		private function _remove(e:Event):void
		{
			_ta.removeEventListener(FocusEvent.FOCUS_IN, _focusIn);
			_btnAnnuler.removeEventListener(MouseEvent.CLICK, _annuler);
			_btnSave.removeEventListener(MouseEvent.CLICK, _save);
			removeEventListener(Event.REMOVED_FROM_STAGE, _remove);
		}
	}

}