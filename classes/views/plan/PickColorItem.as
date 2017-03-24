package classes.views.plan
{
	import classes.vo.Texture;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;	
	
	/**
	 * La classe PickColorItem correspond à l'affichage d'une couleur du menu MenuEditColorRenderer afin 
	 * de modifier la couleur d'une surface par l'ajout d'une <code>Texture</code>
	 */
	public class PickColorItem extends Sprite
	{
		private var _texture:Texture;
		private var _func:Function;
		private var _blocColor:Texture;
		private var _selectedMark:Sprite;
		public static var w:int = 25;
		
		public function PickColorItem(texture:Texture, func:Function, blocTexture:Texture)
		{
			super();
			_texture = texture;
			_func = func;
			_blocColor = blocTexture;
			var g:Graphics = graphics;
			g.lineStyle(1, 0, 0);
			g.beginFill(0xdddddd);
			g.drawRect(0, 0, w, w);
			_selectedMark = new Sprite();
			addChild(_selectedMark);
			_draw();
		}
		
		private function _draw():void
		{
			var spriteColor:Sprite = new Sprite();
			addChild(spriteColor);
			var g:Graphics = spriteColor.graphics;
			g.lineStyle(1, 0, .6);
			if(_texture.isColor)
			{
				g.beginFill(_texture.color, .4/*_texture.alfa*/);
			}
			else
			{
				//g.beginBitmapFill(...);
			}
			g.drawRect(0, 0, w, w);
			buttonMode = true;
			addEventListener(MouseEvent.CLICK, _onClick, false, 0, true);
			
			markAsSelected(_blocColor);
		}
		
		public function markAsSelected(texture:Texture):void
		{
			var g:Graphics = _selectedMark.graphics;			
			var isSelectedColor:Boolean = (texture.color == _texture.color);
			if (isSelectedColor) {
				g.lineStyle(1, 0xdddddd, 1);
				g.drawRect( -2, -2, w + 4, w + 4);
			} else {
				g.clear();
			}
		}
		
		private function _onClick(e:MouseEvent):void
		{
			if(_func != null) _func(_texture);
		}
	}
}