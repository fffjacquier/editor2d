package classes.views.items 
{
	import classes.views.plan.Surface;
	import classes.vo.BlocVO;
	
	import flash.display.MovieClip;
	
	public class BalconyItem extends PieceItem
	{
		
		public function BalconyItem() 
		{
			type = BlocVO.BLOC_BALCONY;
			//id = 1; ds le fla
			//surfaceType peut etre = à "free" ou "square" ds le fla 
			//ce qui correcpond au valeur des variables statiques TYPE_FREE  et TYPE_SQUARE de la classe views.plan.Surface
			super(id, type);
		}
		
	}

}