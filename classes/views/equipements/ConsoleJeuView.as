package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ConsoleJeuView extends EquipementView 
	{
		
		public function ConsoleJeuView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
		
	}

}