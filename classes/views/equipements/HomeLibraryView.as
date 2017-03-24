package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class HomeLibraryView extends EquipementView 
	{
		
		public function HomeLibraryView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
		
	}

}