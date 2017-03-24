package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class LiveradioCubeView extends EquipementView 
	{
		
		public function LiveradioCubeView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}		
	}

}