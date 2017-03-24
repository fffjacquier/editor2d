package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class ImprimanteView extends EquipementView 
	{
		
		public function ImprimanteView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
	}

}