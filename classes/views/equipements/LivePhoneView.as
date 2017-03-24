package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class LivePhoneView extends EquipementView 
	{
		public function LivePhoneView(pvo:EquipementVO) 
		{
			super(pvo);
			isTerminal = true;
		}
		
		protected function over(e:MouseEvent):void
		{
			//
			//trace("over ", this);
		}
		
		protected function out(e:MouseEvent):void
		{
			//trace("out ", this);
		}
		
		override protected function removed(e:Event):void
		{
			super.removed(e);
			//removeEventListener(MouseEvent.MOUSE_OVER, over)
			//removeEventListener(MouseEvent.MOUSE_OUT, out);
		}
		
	}

}