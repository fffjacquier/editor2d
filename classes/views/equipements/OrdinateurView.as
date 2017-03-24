package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class OrdinateurView extends EquipementView 
	{
		
		public function OrdinateurView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
		
	}

}