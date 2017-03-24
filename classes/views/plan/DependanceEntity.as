package classes.views.plan 
{	
	import classes.config.Config;
	
	/**
	 * non utilisée, sera insérée au plan plus tard
	 * @private
	 */
	public class DependanceEntity extends Object2D
	{
		
		public function DependanceEntity(id:int, points:Array) 
		{
			pointColor = Config.COLOR_POINTS_EXTERIEURS_DEPENDANCE;
			_alphaSurface = 1;
			_colorSurface = Config.COLOR_SURFACE_DEPENDANCE;
			radius = 4;
			lineWeight = 3;
			doCloseShape = true;
			super(id, points);
			
			_surface = new Surface(this);
			addChildAt(surface,0);
		}
		
	}

}