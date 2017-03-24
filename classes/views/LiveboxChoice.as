package classes.views 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	/**
	 * Cet écran permet d'afficher le choix entre la Livebox2 et la Livebox Play en même temps que le choix du type de projet
	 * 
	 * @author Francois
	 */
	public class LiveboxChoice extends Sprite 
	{
		private var _title:CommonTextField;
		private var _subtitle:CommonTextField;
		private var _recaptext:CommonTextField;
 		private var _errTF:CommonTextField;
		
 		private var _tf1:TextFormat;
 		private var _tf2:TextFormat;
		private var _myFont:Font;
		private var _rbgroup:RadioButtonGroup;
		private var _rb1:RadioButton;
		private var _rb2:RadioButton;
		
		private var xpos:int;
		private var ypos:int;
		private var screedHeight:int;
		
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function LiveboxChoice() 
		{
			super();
			
			xpos = 4;
			
			_myFont = new Helvet55Bold(); 
 			_tf1 = new TextFormat();
			_tf1.font = _myFont.fontName; 
			_tf1.bold = true;
			_tf1.color = Config.COLOR_WHITE; 
			_tf1.size = 12; 
			
 			_tf2 = new TextFormat();
			_tf2.font = _myFont.fontName; 
			_tf2.bold = true;
			_tf2.color = Config.COLOR_WHITE; 
			_tf2.size = 14;
			
			_title = new CommonTextField("helvet", Config.COLOR_WHITE, 12);
			_title.width = 220;
			_title.autoSize = "left";
			_title.setText(AppLabels.getString("common_choose"));
			_title.x = xpos;
			_title.y = 5;
			
			_subtitle = new CommonTextField("helvet", Config.COLOR_WHITE);
			_subtitle.width = 218;
			_subtitle.setText(AppLabels.getString("form_yourLB"));
			_subtitle.setTextFormat(_tf2);
			_subtitle.x = xpos;
			_subtitle.y = _title.y + _title.textHeight;
			
			addEventListener(Event.REMOVED_FROM_STAGE, _remove);
			
			//AppUtils.TRACE("ProjectType "+_appmodel.projectType);
			if (_appmodel.projectType == null) {
				_display();
			} 
		}
		
		private function _display():void
		{
			addChild(_title);
			addChild(_subtitle);
			
			//addRadioButtons
			_addRadioButtons();
		}
		
		private function _addRadioButtons():void
		{
			_rbgroup = new RadioButtonGroup("liveboxChoice");
			_rbgroup.addEventListener(MouseEvent.CLICK, _clickHandler);
			
			xpos = 9;
			ypos = _subtitle.y + _subtitle.height +5;
			var esp:int = 8;
			
			// readio bouton livebox 2
			_rb1 = new RadioButton();
			_rb1.label = "Livebox 2";
			_rb1.value = "Livebox2";
			_rb1.setStyle("embedFonts", true);
			_rb1.setStyle("bold", true);
			_rb1.setStyle("textFormat", _tf1);
			_rb1.setSize(108,19);
			addChild(_rb1);
			_rb1.x = xpos;
			_rb1.y = ypos;
			_rb1.buttonMode = true;
			_rb1.group = _rbgroup;
			AppUtils.setButton(_rb1);
			AppUtils.radioButtonHack(_rb1);
			// selectionné par défaut
			_rb1.selected = true;
			_appmodel.selectedLivebox = "Livebox2";
			
			// image
			//images_x400/Livebox2.png
			var u:Loader = new Loader();
			u.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLivebox2Complete);
			u.load(new URLRequest("images_x400/Livebox2.png"));
			
			// radio bouton livebox play
			_rb2 = new RadioButton();
			_rb2.label = "Livebox Play";
			_rb2.value = "LiveboxPlay";
			_rb2.setStyle("embedFonts", true);
			_rb2.setStyle("bold", true);
			_rb2.setStyle("textFormat", _tf1); 
			_rb2.setSize(108,19);
			addChild(_rb2);
			_rb2.x = 123;
			_rb2.y = ypos;
			ypos = _rb2.y + _rb2.height +esp;
			_rb2.group = _rbgroup;
			AppUtils.setButton(_rb2);
			AppUtils.radioButtonHack(_rb2);
			
			// image
			//images_x400/LiveboxPlay.png
			u = new Loader();
			u.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLiveboxPlayComplete);
			u.load(new URLRequest("images_x400/LiveboxPlay.png"));
			
			// texte livebox2
			var screed1:CommonTextField = new CommonTextField("helvet", Config.COLOR_WHITE, 10);
			screed1.width = 100;
			screed1.setText( AppLabels.getString("editor_livebox2Screed") );
			addChild(screed1);
			screed1.x = 9;
			screed1.y = 106;
			screedHeight = screed1.height;
			trace("livebox 2", screed1.height, screed1.y)
			
			// texte livebox play
			var screed2:CommonTextField = new CommonTextField("helvet", Config.COLOR_WHITE, 10);
			screed2.width = 100;
			screed2.setText( AppLabels.getString("editor_liveboxPlayScreed") );
			addChild(screed2);
			screed2.x = 123;
			screed2.y = 106;
			trace("livebox play", screed2.height, screed2.y)
			screedHeight = Math.max(screed1.height, screed2.height);
			
			//shape1
			var shape1:Shape = new Shape();
			shape1.graphics.lineStyle(1, 0xb4b4b4);
			shape1.graphics.beginFill(0x6c6d6f);
			shape1.graphics.drawRect(_rb1.x - 4, _rb1.y, 110, screedHeight + screed1.y - _rb1.height -21);
			addChildAt(shape1, 0);
			
			//shape2
			var shape2:Shape = new Shape();
			shape2.graphics.lineStyle(1, 0xb4b4b4);
			shape2.graphics.beginFill(0x6c6d6f);
			shape2.graphics.drawRect(_rb2.x - 4, _rb2.y, 110, screedHeight + screed1.y - _rb1.height -21);
			addChildAt(shape2, 1);
		}
		
		private function _onLivebox2Complete(e:Event):void
		{
			_removeLoaderListenerAndCreateBitmap(e, _rb1.x, _rb1.y -5);
		}
		
		private function _onLiveboxPlayComplete(e:Event):void 
		{
			_removeLoaderListenerAndCreateBitmap(e, _rb2.x, _rb2.y -5);
		}
		
		private function _removeLoaderListenerAndCreateBitmap(e:Event, x:Number, y:Number):void
		{
			var u:Loader = e.currentTarget.loader as Loader;
			u.removeEventListener(Event.COMPLETE, _onLiveboxPlayComplete);
			
			var bitmap:Bitmap = e.currentTarget.content as Bitmap;
			bitmap.smoothing = true;
			bitmap.scaleX = .25
			bitmap.scaleY = .25
			
			addChild(bitmap);
			bitmap.x = x;
			bitmap.y = y;
		}
		
		private function _clickHandler(e:MouseEvent):void
		{
			//trace(e.target.selection.value);
			_appmodel.selectedLivebox = e.target.selection.value;
		}
		
		private function _remove(e:Event):void
		{
			if (_rbgroup.hasEventListener(MouseEvent.CLICK)) {
				_rbgroup.removeEventListener(MouseEvent.CLICK, _clickHandler);
			}
			removeEventListener(Event.REMOVED_FROM_STAGE, _remove);
		}
	}

}