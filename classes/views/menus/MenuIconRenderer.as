package classes.views.menus 
{
	import classes.config.Config;
	import classes.utils.AppUtils;
	import classes.views.CommonTextField;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * La classe MenuIconRenderer est un MenuItemRenderer avec une icône (<code>MovieClip</code>)
	 */
	public class MenuIconRenderer extends MenuItemRenderer 
	{
		private var _bool:Boolean;
		protected var icon:MovieClip;
		
		public function MenuIconRenderer(menuItem:MenuItem, pbool:Boolean = true ) 
		{
			_bool = pbool;
			super(menuItem);
			H = 30;
		}
		
		override protected function added(e:Event):void
		{
			if(_bool) super.added(e);
			else removeEventListener(Event.ADDED_TO_STAGE, added);
			
			_addIcon();
			
			_addText();
			
			if (_menuItem.needInfo == 1) _addBtnInfo();
		}
		
		private function _addIcon():void
		{
			icon = _menuItem.icon;
			var s:Sprite = _drawBoundingBox(icon);
			addChild(s);
			s.y = H/2;
			s.x = 25;
			s.addEventListener(MouseEvent.MOUSE_DOWN, _onClickItem, false, 0, true);
			s.buttonMode = true;
		}
		
		private function _addBtnInfo():void
		{
			var icon:MovieClip = new IconInfo();
			AppUtils.changeColor(Config.COLOR_YELLOW, icon);
			icon.y = (H - icon.height)/2;
			icon.x = 201 - icon.width - 5;
			addChild(icon);
			icon.addEventListener(MouseEvent.CLICK, _onClickInfo, false, 0, true);
			icon.buttonMode = true;
		}
		
		private function _addText():void
		{
			var t:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_LIGHT_GREY);
			t.autoSize = "left";
			t.width = 154;
			t.height = 18.5;
			t.setText(_menuItem.label);
			//trace(t.textHeight, t.textWidth);
			var s:Sprite = _drawBoundingBox(t);
			addChild(s);
			s.x = 40//_menuItem.icon.width;
			s.y = 6;
			s.addEventListener(MouseEvent.MOUSE_DOWN, _onClickItem, false, 0, true);
			s.buttonMode = true;
			s.mouseChildren = false;
		}
		
		private function _drawBoundingBox( DO:DisplayObject ):Sprite
		{
			var s:Sprite = new Sprite();
			s.graphics.beginFill(0, 0);
			var r:Rectangle = DO.getBounds(DO);
			s.graphics.drawRect(r.x, r.y, r.width, r.height);
			s.addChild(DO);
			return s;
		}		
	}
}