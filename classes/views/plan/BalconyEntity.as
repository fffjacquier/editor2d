package classes.views.plan 
{
	import classes.config.Config;
	
	/**
	 * BalconyEntity, classe étendant PieceEntity, les balcons de l'éditeur. 
	 */
	public class BalconyEntity extends PieceEntity 
	{		
		/**
		 * BalconyEntity est une PieceEntity, polygone fermé.
		 * <p>Elle hérite donc de Bloc et de PieceEntity. elle diffère des autre pièces uniquement par ses couleurs</p>
		 * 
		 * @param id Identifiant numerique non utilisé jusqu'ici, toujours égal à 0. a voir
		 * @param pts Array de points donnant le nombre et les positions des futurs pointVO des entités
		 * @param surfaceType String distinguant les surfaces à forme libre des surface rectangulaires.
		 */
		public function BalconyEntity(id:int, pts:Array, surfaceType:String) 
		{
			pointColor = Config.COLOR_POINTS_EXTERIEURS_BALCONERY;
			lineWeight = 3;
			
			_alphaSurface = 1;
			_colorSurface = Config.COLOR_SURFACE_BALCONERY;
			radius = 4;
			
			super(id, pts,surfaceType);
		}
		
	}

}