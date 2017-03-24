package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class TeleView extends EquipementView 
	{
		
		public function TeleView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
		
	}

}