package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class SqueezeBoxView extends EquipementView 
	{
		
		public function SqueezeBoxView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
		
	}

}