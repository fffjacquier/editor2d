package classes.views.menus
{
	import classes.config.Config;
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import classes.views.plan.Bloc;
	import classes.views.plan.PickColorItem;
	import classes.views.plan.Surface;
	import classes.vo.Texture;
	import flash.display.Sprite;

	/**
	 * La classe MenuEditColorRenderer étend MenuItemRenderer et permet d'afficher le menu de changement de couleur
	 *  pour les surfaces
	 */
	public class MenuEditColorRenderer extends MenuItemRenderer
	{
		private var _textures:Array = Config.TEXTURES_SURFACE;
		private var _surface:Surface;
		private var _numColumn:int = 5;
		private var _gap:int = 12;
		private var _colorsContainer:Sprite;
		
		public function MenuEditColorRenderer(bloc:Bloc, menuItem:MenuItem)
		{
			super(menuItem);
			H = 109;
			_surface = bloc.surface;
			_colorsContainer = new Sprite();
			addChild(_colorsContainer);
			_colorsContainer.y = 30;
			_colorsContainer.x = 12;
			for (var i:int = 0; i < _textures.length; i++)
			{
				var colorItem:PickColorItem = new PickColorItem(_textures[i], _setTexture, bloc.texture);
				colorItem.x = (PickColorItem.w + _gap) * (i % 5);
				colorItem.y =  (PickColorItem.w + _gap) * int(i / 5);
				_colorsContainer.addChild(colorItem);
			}
			
			var t:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_LIGHT_GREY);
			t.autoSize = "left";
			t.width = 180;
			t.setText(AppLabels.getString("editor_chooseColor"));
			t.x = 10;
			t.y = 4;
			
			addChild(t);
			
			graphics.beginFill(0xffffff, 0);
			graphics.drawRect(0, 0, width, height + 6);
		}
		
		private function _setTexture(texture:Texture):void
		{
			_surface.texture = texture;
			for (var i:int = 0; i < _textures.length; i++)
			{
				var colorItem:PickColorItem = _colorsContainer.getChildAt(i) as PickColorItem;
				colorItem.markAsSelected(texture);
			}
		}
	}
}

