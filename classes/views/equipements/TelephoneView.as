package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class TelephoneView extends EquipementView 
	{
		
		public function TelephoneView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
		
	}

}