package classes.views.plan
{
	import classes.config.Config;
	import classes.utils.AppUtils;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * DrawingCursor, étend Sprite, utilisé pour le dessin de la fibre. 
	 * */
	public class DrawingCursor extends Sprite
	{
		private static var _instance:DrawingCursor;
		
		public static function get instance():DrawingCursor
		{
			return _instance;
		}
		
		/**
		 * DrawingCursor, étend Sprite, utilisé pour le dessin de la fibre. 
		 * <p>Conteneur d'un élément graphique provenent de la librairie lib.editor.swc.</p>
		 */
		public function DrawingCursor()
		{
			super();
			_instance = this;
			var icon:Sprite = new IconDessin();
			icon.x = - icon.width / 2;
			icon.y = - icon.height / 2;
			var g:Graphics = icon.graphics;
			g.beginFill(0, 0);
			g.drawRect(0, 0, icon.width, icon.height);
			g.lineStyle(2, Config.COLOR_GREY);
			g.drawCircle(icon.width / 2, icon.height / 2, 1);
			addChild(icon);
			//drawTargetMouse();
		}
		
		private function drawTargetMouse():void
		{
			/*var half:int = 5;
			var d:int = half*2;
			var g:Graphics = graphics;
			g.lineStyle(1, Config.COLOR_ORANGE);
			g.moveTo(-d + d/4, -d);
			g.lineTo(-d, -d);
			g.lineTo(-d,-d);
			g.moveTo(-d,d);
			g.lineTo(-d, d);
			g.lineTo(-d,d);
			g.moveTo(d,d);
			g.lineTo(d, d);
			g.lineTo(d,d);
			g.moveTo(d,-d);
			g.lineTo(d, -d);
			g.lineTo(d,-d);
			*/
		}
	}
}