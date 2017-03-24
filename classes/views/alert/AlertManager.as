package classes.views.alert
{	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	
	/**
	 * Manages alert popup apparing or disappearing - only one alert can be in the displaylist
	 * 
	 * Creates (or not) a mouse blocker to prevent any interactivity beneath the popup
	 * Clicking on this mouse blocker, outside the popup, removes the popup
	 */
	public class AlertManager
	{
		private static var _popup:DisplayObject;
		private static var _popup2:DisplayObject;
		private static var _popupContainer:DisplayObjectContainer;
		private static var _mouseBlocker:MouseBlocker;
		private static var _mouseBlocker2:MouseBlocker;
		
		public function AlertManager()
		{
		}
		
		public static function addPopup(popup:DisplayObject, popupContainer:DisplayObjectContainer, noMouseBlocker:Boolean=false, mouseBlockerClickable:Boolean=false, mouseBlockerAlpha:Number = .6 ):void
		{
			if (_popup) removePopup();
			if (_popup2) removeSecondPopup();
			
			_popupContainer = popupContainer; 
			
			if (!noMouseBlocker) 
			{
				_mouseBlocker = new MouseBlocker(popupContainer, mouseBlockerClickable, mouseBlockerAlpha);
				_popupContainer.addChild(_mouseBlocker);
			}
			_popup = popup;			
			_popupContainer.addChild(_popup);
		}
		
		public static function removePopup():void
		{
			if(!_popup) return;
			_popupContainer.removeChild(_popup);
			_popup = null;
			removeMouseBlocker();
			_popupContainer.stage.focus = _popupContainer;
		}
		
		public static function addSecondPopup(popup:DisplayObject, popupContainer:DisplayObjectContainer, noMouseBlocker:Boolean = false, mouseBlockerClickable:Boolean = false ):void
		{
			if (_popup2) removeSecondPopup();
			_popupContainer = popupContainer; 
			
			if (!noMouseBlocker) 
			{
				_mouseBlocker2 = new MouseBlocker(popupContainer, mouseBlockerClickable);
				_popupContainer.addChild(_mouseBlocker2);
			}
			_popup2 = popup;			
			_popupContainer.addChild(_popup2);
		}
		
		public static function removeSecondPopup():void
		{
			if (!_popup2) return;
			_popupContainer.removeChild(_popup2);
			_popup2 = null;
			removeMouseBlocker2();
			_popupContainer.stage.focus = _popupContainer;
		}
		
		public static function getPopup():DisplayObject
		{
			return _popup;
		}
		
		public static function removeUpperPopup():void
		{
			if (_popup2) removeSecondPopup();
			else removePopup();
		}
		
		public static function removeMouseBlocker():void
		{
			if(!_mouseBlocker) return;
			_popupContainer.removeChild(_mouseBlocker);
			_mouseBlocker = null;
		}
		
		public static function removeMouseBlocker2():void
		{
			if(!_mouseBlocker2) return;
			_popupContainer.removeChild(_mouseBlocker2);
			_mouseBlocker2 = null;
		}
	}
}