package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class TabletteView extends EquipementView 
	{
		
		public function TabletteView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
	}

}