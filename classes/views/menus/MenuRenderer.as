package classes.views.menus 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * La classe MenuRenderer permet d'afficher l'ensemble des menus d'un objet de l'éditeur
	 */
	public class MenuRenderer extends Sprite 
	{
		private var _items:Array;
		private var _itemsContainer:Sprite;
		private var _parentDO:DisplayObjectContainer;
		private var _closeBtn:Sprite;
		private var _largeur:int = 213;
		private var _bg:Shape;
		public var H:int;
		
		private static var _instance:MenuRenderer;
		public static function get instance():MenuRenderer
		{
			return _instance;
		}
		
		public function MenuRenderer(items:Array, parentDO:DisplayObjectContainer) 
		{
			_instance = this;
			_items = items;
			_parentDO = parentDO;
			//_type = type;
			
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			//trace("MenuRenderer::_added stage:", _items.length);
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _remove);
			
			_itemsContainer = new Sprite();
			addChild(_itemsContainer);
			var containerH:int;
			for (var i:int = 0; i < _items.length; i++) 
			{
				var m:MenuItemRenderer = _items[i] as MenuItemRenderer;
				m.x = 0;
				m.id = i;
				
				_itemsContainer.addChild(m);
				m.y = containerH;
				containerH += m.H;
				
				//trace("MenuRenderer::_added", _items[i], m.H);				
			}
			H = containerH +10;
		}
		
		/*public function closeMenu(e:MouseEvent=null):void
		{
			//return;
			
			// prevent losing focus for KeyBoardEvents
			stage.focus = _parentDO;
			_parentDO.removeChild(this);
		}*/
		
		private function _remove(e:Event):void
		{	
			while (_itemsContainer.numChildren > 0) {
				_itemsContainer.removeChildAt(0);
			}
			removeChild(_itemsContainer);
			removeEventListener(Event.REMOVED_FROM_STAGE, _remove);
		}
	}

}