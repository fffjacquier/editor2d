package classes.views.synthese 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import fl.controls.ScrollPolicy;
	import fl.controls.TextArea;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	/**
	 * Pas utilisé. Fait parti des choses à optimiser
	 */
	public class TabMemo extends Sprite 
	{
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _title:CommonTextField;
		private var _ta:TextArea;
		private var _tb:TextArea;
		private var shape:Shape;
		
		public function TabMemo() 
		{
			var breadcumbs:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_DARK, 14);
			breadcumbs.width = 900;
			addChild(breadcumbs);
			breadcumbs.setText(AppLabels.getString("check_subTextMemo"));
			
			// add the title
			_title = new CommonTextField("helvet35", 0x333333, 30);
			addChild(_title);
			_title.width = 183 -20;
			_title.x = 10;
			_title.y = 26;
			_title.setText(AppLabels.getString("check_yourMemos"));
			
			// add the text and background and scroll
			shape = new Shape();
			addChild(shape);
			shape.x = 10;
			shape.y = 68;
			var g:Graphics = shape.graphics;
			g.clear();
			g.lineStyle(1, Config.COLOR_LIGHT_GREY);
			g.beginFill(0xffffff);
			g.drawRoundRect(0, 0, 229, 155, 15);
			g.endFill();
			_tb = new TextArea();
			_tb.setSize(240, 155);
			_tb.move(shape.x + 6, shape.y);
			_tb.editable = true;
			_tb.enabled = true; 
			_tb.wordWrap = true;
			_tb.horizontalScrollPolicy = ScrollPolicy.OFF;
			_tb.verticalScrollPolicy = ScrollPolicy.ON;
			_tb.textField.antiAliasType = AntiAliasType.ADVANCED;
			
			var ft:TextFormat = new TextFormat();
			ft.font = (new Helvet55Reg() as Font).fontName;
			ft.size = 12;
			_tb.setStyle("embedFonts", true);
			_tb.setStyle("textFormat", ft);
			_tb.drawNow();
			addChild(_tb);
			
			var str:String = (_appmodel.memos == "") ? AppLabels.getString("check_noMemo") : _appmodel.memos;
			_tb.text = str;
			_appmodel.addMemoUpdateListener(_updateMemo);
			_updateMemo();
			_tb.addEventListener(Event.CHANGE, _onChangeMemo, false, 0, true); 
			_tb.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, _prevent, false, 0, true); 
			_tb.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _prevent, false, 0, true);
			
			//add the notes title
			if (_appmodel.profilevo.acces_notesvendeur) 
			{
				_title = new CommonTextField("helvet35", 0x333333, 30);
				addChild(_title);
				_title.width = 183 -20;
				_title.x = 10;
				_title.y = 240;
				_title.setText(AppLabels.getString("check_notes"));
				//add the background
				shape = new Shape();
				addChild(shape);
				shape.x = 10;
				shape.y = 280;
				g = shape.graphics;
				g.clear();
				g.lineStyle(1, Config.COLOR_LIGHT_GREY);
				g.beginFill(0xffffff);
				g.drawRoundRect(0, 0, 229, 125, 15);
				g.endFill();
				//add the input text
				_ta = new TextArea();
				_ta.setSize(240, 125);
				_ta.move(shape.x + 6, shape.y);
				_ta.editable = true;
				_ta.enabled = true; 
				_ta.text = _appmodel.projetvo.note_vendeur || AppLabels.getString("popups_typeYourText"); 
				_ta.wordWrap = true;
				_ta.horizontalScrollPolicy = ScrollPolicy.OFF;
				_ta.verticalScrollPolicy = ScrollPolicy.ON;
				_ta.textField.antiAliasType = AntiAliasType.ADVANCED;
				_ta.setStyle("embedFonts", true);
				_ta.setStyle("textFormat", ft);
				_ta.drawNow();
				addChild(_ta);
				_ta.addEventListener(FocusEvent.FOCUS_IN, _onFocusIn, false, 0, true);
				_ta.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut, false, 0, true);
				_ta.addEventListener(Event.CHANGE, _onChange, false, 0, true); 
				_ta.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, _prevent, false, 0, true); 
				_ta.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _prevent, false, 0, true);
			}
		}
		
		private function _onFocusIn(e:FocusEvent):void
		{
			setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
		}
		
		private function _onFocusOut(e:FocusEvent):void
		{
			//setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
			_appmodel.notes = _ta.text;
			_appmodel.memos = _tb.text;
		}
		
		private function _onChange(e:Event):void
		{
			//setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
			_appmodel.notes = _ta.text;
			_appmodel.notifySaveStateUpdate(true);
		}
		
		private function _onChangeMemo(e:Event):void
		{
			//setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
			_appmodel.memos = _tb.text;
			_appmodel.notifySaveStateUpdate(true);
		}
		
		private function _prevent(kmf_event:FocusEvent):void 
		{ 
			kmf_event.preventDefault(); 
		}
		
		private function _updateMemo(e:Event=null):void
		{
			_tb.text = _appmodel.memos;
		}
		
		private function _removed(e:Event):void
		{
			if (_appmodel.profilevo && _appmodel.profilevo.acces_notesvendeur) 
			{
				if (_ta) {
					_ta.removeEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
					_ta.removeEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);
					_ta.removeEventListener(Event.CHANGE, _onChange); 
					_ta.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, _prevent); 
					_ta.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _prevent);
				}
			}
			if (_tb) {
				_tb.removeEventListener(Event.CHANGE, _onChangeMemo); 
				_tb.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, _prevent); 
				_tb.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _prevent);
			}
		}
	}
}