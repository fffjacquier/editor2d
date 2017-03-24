package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	import flash.events.Event;
		
	public class SwitchView extends EquipementView 
	{
		
		public function SwitchView(pvo:EquipementVO) 
		{
			super(pvo);
			isConnector = true;
		}
		
	}

}