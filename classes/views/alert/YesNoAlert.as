package classes.views.alert 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	/**
	 * Yes alert popup - extends Alert - adds a YES button and a NO button to Alert.
	 * 
	 * <p>Utilisé comme popup de confirmation</p>
	 */
	public class YesNoAlert extends Alert 
	{
		protected var yesButton:Btn;
		protected var noButton:Btn;
		protected var callbackNoFunction:Function;
		private var _title:String;
		
		public function YesNoAlert(title:String, text:String, func:Function = null, nofunc:Function = null, color:Number = NaN, params:*= null)
		{
			_title = title;
			super(text, func, color, params, true);	
			callbackNoFunction = nofunc;
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		override protected function setTexts(ypos:int=NaN):void
		{			
			var icon:MovieClip = new IconAlertYesNo();
			addChild(icon);
			AppUtils.insideXCenter(icon, this);
			icon.y = 7;
			
			var t:CommonTextField = new CommonTextField("helvet65", Config.COLOR_WHITE, 18);
			t.width = 320;
			addChild(t);
			t.setText(_title);
			t.x = (width - t.textWidth) / 2;
			t.y = icon.y + icon.height + ypos;
			
			super.setTexts( t.y + t.textHeight + 10);
			closeButton.removeEventListener(MouseEvent.CLICK, close);
			removeChild(closeButton);
			//AlertManager.removeMouseBlocker();
			
			var middle:int = bg.width / 2;
			
			// no button
			var col:int;
			noButton = new Btn(Config.COLOR_GREY, AppLabels.getString("buttons_no"), null, 44, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_DARK);
			noButton.x = middle + 10 ;
			noButton.y = bg.height - 60;
			addChild(noButton);
			
			// yes button
			yesButton = new Btn(Config.COLOR_GREY, AppLabels.getString("buttons_yes"), null, 44, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_ORANGE);
			yesButton.x = middle - 60//bg.width/2 + yesButton.width/2 ;
			yesButton.y = bg.height - 60;
			addChild(yesButton);
			
			addDotsLine(bg.height - 22);
			
			// interactivity
			yesButton.addEventListener(MouseEvent.CLICK, onYesClick, false, 0, true);
			noButton.addEventListener(MouseEvent.CLICK, _onNoClick, false, 0, true);
			
			_onResize();
		}
		
		protected function onYesClick(e:MouseEvent):void
		{
			close(e);
			if (callBack != null) {
				if (params == null) callBack();
				else callBack(params);
			}
		}
		
		private function _onNoClick(e:MouseEvent):void
		{
			// remove this alert
			close(e);
			if (callbackNoFunction != null) callbackNoFunction();
		}
		
		private function _removed(e:Event):void
		{
			closeButton.removeEventListener(MouseEvent.CLICK, close);
			yesButton.removeEventListener(MouseEvent.CLICK, onYesClick);
			noButton.removeEventListener(MouseEvent.CLICK, _onNoClick);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
	}

}