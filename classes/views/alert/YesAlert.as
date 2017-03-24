package classes.views.alert
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import flash.events.MouseEvent;
	
	public class YesAlert extends Alert
	{
		private var _alertText:String;	
		private var _yesButton:Btn;
		private var _title:String;
		
		/**
		 *  Yes alert popup - extends Alert - adds a YES button to Alert.
		 * 
		 * Used as a confirmation popup
		 * 
		 * @param text Le texte à afficher
		 * @param closeFromAlertManager Booléan 
		 */
		public function YesAlert(title:String, text:String, closeFromAlertManager:Boolean = true, func:Function = null)
		{
			_title = title;
			super(text, func, NaN, null, closeFromAlertManager);
		}				
		
		override protected function setTexts(ypos:int=NaN):void
		{				
			var icon:IconAlertYes = new IconAlertYes();
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
			
			// yes button
			_yesButton = new Btn(Config.COLOR_GREY, AppLabels.getString("buttons_ok"), null, 44, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_ORANGE);
			_yesButton.x = bg.width/2 - 22//bg.width/2 + yesButton.width/2 ;
			_yesButton.y = bg.height - 60;
			addChild(_yesButton);
			
			addDotsLine(bg.height - 22);
			
			// interactivity
			_yesButton.addEventListener(MouseEvent.CLICK, close, false, 0, true);
			_onResize();
		}
		
		override protected function close(e:MouseEvent = null):void
		{
			if (closeBool) super.close(e);
			else 
				if (parent && parent.stage) parent.removeChild(this);
				
			if (callBack != null) {
				if (params == null) callBack();
				else callBack(params);
			}
		}
		
	}
}