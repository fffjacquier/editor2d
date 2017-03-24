package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	import flash.events.Event;
	
	public class MainDoorView extends EquipementView 
	{
		
		public function MainDoorView(pvo:EquipementVO) 
		{
			super(pvo);
		}
		
		override protected function drawBG(color:Number):void
		{
		}
		
		override protected function removed(e:Event):void
		{
			super.removed(e);
		}
		
	}

}