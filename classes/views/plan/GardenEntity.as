package classes.views.plan 
{
	import classes.config.Config;
	
	/**
	 * non utilisée, sera insérée au plan plus tard
	 * @private
	 */
	public class GardenEntity extends Object2D 
	{		
		public function GardenEntity(id:int, points:Array) 
		{
			_alphaSurface = .5;
			_colorSurface = Config.COLOR_SURFACE_JARDIN;
			pointColor = Config.COLOR_POINTS_EXTERIEURS_JARDIN;
			lineWeight = 0;
			doCloseShape = true;
			super(id, points);
			
			_surface = new Surface(this);
			addChildAt(surface,0);
		}
		
	}

}