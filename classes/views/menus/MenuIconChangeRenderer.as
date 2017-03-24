package classes.views.menus 
{
	import flash.events.MouseEvent;
	
	/**
	 * La classe MenuIconChangeRenderer doit être utilisé lorsque l'icône  de MenuIconRenderer peut changer.
	 */
	public class MenuIconChangeRenderer extends MenuIconRenderer 
	{
		
		public function MenuIconChangeRenderer(menuItem:MenuItem, pbool:Boolean=true) 
		{
			super(menuItem, pbool);
		}
		
		override protected function _onClickItem(e:MouseEvent):void
		{
			var currentframe:int = icon.currentFrame;
			if (currentframe == 1) icon.gotoAndStop(2);
			else icon.gotoAndStop(1);
			super._onClickItem(e);
		}
		
	}

}