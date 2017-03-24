package classes.views.menus 
{
	import classes.config.Config;
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * La classe MenuCustomRenderer étend la classe de de base MenuItemRenderer. 
	 * et y ajoute un texte et un sous texte éventuel
	 */
	public class MenuCustomRenderer extends MenuItemRenderer 
	{
		private var _subtext:String;
		
		public function MenuCustomRenderer(menuItem:MenuItem, subtext:String="") 
		{
			H = 61;
			_subtext = subtext;
			super(menuItem);
		}
		
		override protected function added(e:Event):void
		{
			super.added(e);
			
			var t:CommonTextField = new CommonTextField("helvet", Config.COLOR_ORANGE);
			t.autoSize = "left";
			t.width = 180;
			t.setText(AppLabels.getString("editor_yourAreLevel") +_menuItem.label);
			t.x = 3;
			t.y = 4;
			addChild(t);
			//trace("MenuCustomRenderer::added", t.text);
			
			if(_subtext != "") {
				var tt:CommonTextField = new CommonTextField("helvet", Config.COLOR_LIGHT_GREY);
				tt.autoSize = "left";
				tt.width = 180;
				//
				tt.setText(_subtext);
				tt.x = 3;
				tt.y = 4;
				addChild(tt);
			}
			//trace("MenuCustomRenderer::added done");
		}
		
		override protected function _onClickItem(e:MouseEvent):void
		{
			//
		}
		
	}

}