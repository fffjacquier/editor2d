package classes.views.menus 
{
	import classes.commands.CommandParameters;
	import classes.commands.ICommand;
	import classes.config.Config;
	import com.warmforestflash.drawing.DottedLine;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * La classe de base d'un menu
	 */
	public class MenuItemRenderer extends Sprite 
	{
		protected var _menuItem:MenuItem; // data
		public var id:int;
		public var H:int = 0;
		public static var DOCLOSE:Boolean = true;
		public static var DO_MOUSE_UP:Function;
		
		public function MenuItemRenderer(menuItem:MenuItem) 
		{
			super();
			_menuItem = menuItem;
			
			addEventListener(Event.ADDED_TO_STAGE, added);
		}
		
		protected function added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, added);
			_addDottedLine();
		}
		
		protected function _onClickInfo(e:MouseEvent):void
		{
			//open popup
			trace("_onClickInfo", this);
		}
		
		protected function _onClickItem(e:MouseEvent):void
		{
			var command:* = _menuItem.command;
			trace("MenuItemRenderer::_onClickItem", DOCLOSE, command);
			if (command is Class) 
			{
				var params:CommandParameters = _menuItem.commandParameters;
				trace("params:", params, params.toString(), params is null);
				if (params) (new command(params) as ICommand).run(_closeMenu);
				else (new command() as ICommand).run(_closeMenu);
			} 
			else if (command is Function) 
			{
				(command as Function)();
				if (DOCLOSE)
				{
					_closeMenu(e);
				}
				else
				{
					DOCLOSE = true;
				}
				
				if (DO_MOUSE_UP != null)
				{
					addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
					stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
				}
			}
			else
			{
				trace("else case");
			}
		}
		
		private function _closeMenu(e:MouseEvent=null):void
		{
			trace("MenuItemRenderer::_closeMenu()");
			MenuContainer.instance.closeMenu();
		}
		
		private function _onMouseUp(e:MouseEvent):void
		{
			if (DO_MOUSE_UP != null) 
			{
				DO_MOUSE_UP();
				DO_MOUSE_UP = null;
				return;
			}
			removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
		}
		
		protected function _addDottedLine():void
		{
			var s:Shape = new DottedLine(201 - 15, 1, Config.COLOR_LIGHT_GREY, 1, 1.3, 2);
			addChild(s);
			s.x = 15/2;
			s.y = H-1;
		}
		
		public function isLivephone():Boolean
		{
			return false;
		}
		
		public function get item():MenuItem
		{
			return _menuItem;
		}
		
	}

}