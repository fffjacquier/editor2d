package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class SmartphoneView extends EquipementView 
	{
		
		public function SmartphoneView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}		
	}

}