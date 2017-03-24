package classes.views.plan 
{
	import classes.config.Config;
	import flash.display.Sprite;
	
	public class MainEntity extends Object2D 
	{
		public var invalid:Boolean = false;
		
		public function MainEntity(id:int, points:Array) 
		{
			lineWeight = 5;
			pointColor = Config.COLOR_POINTS_EXTERNES_INSIDE;
			radius = 6;
			_alphaSurface = .5;
			_colorSurface = Config.COLOR_SURFACE_MAISON;
			doCloseShape = true;
			super(id, points, Surface.TYPE_FREE);
			_surface = new Surface(this);
			addChildAt(surface,0);
		}
		
		public function clone():MainEntity
		{
			var main:MainEntity = new MainEntity(1000, points);
			return main;
		}
		
		//sprite par rapport auquel sont calculées les coordonnées de poiins
		override public function get referent():Sprite
		{
			return bloc;
		}
	}
}