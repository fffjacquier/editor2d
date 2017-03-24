package classes.views.plan 
{
	import classes.config.Config;
	
	public class RoomEntity extends PieceEntity 
	{		
		public function RoomEntity(id:int, points:Array, surfaceType:String) 
		{
			_alphaSurface = 1;
			_colorSurface = Config.COLOR_SURFACE_PIECE;
			pointColor = Config.COLOR_POINTS_PIECES;
			radius = 4;
			lineWeight = 3;
			super(id, points,surfaceType);
			
			//_surface = new Surface(this);
			//addChildAt(surface,0);
		}
		
	}

}