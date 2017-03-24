package classes.views.plan 
{
	import classes.model.EditorModelLocator;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/*
	*
	*/
	public class Floors extends Sprite 
	{
		public var floorsArr:Array = new Array();
		
		public function Floors() 
		{
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		public function addFloor(floor:Floor):void
		{
			if (floor.id == -1) {
				floorsArr.unshift(floor);
				addChildAt(floor, 0);
			} else {
				floorsArr.push(floor);
				addChild(floor);
			}
			//trace("addFloor",  floorsArr);
		}
		
		public function removeFloor(floor:Floor):void
		{
			removeChild(floor);
			var index:int = floorsArr.indexOf(floor);
			floorsArr.splice(index, 1);
			
			var m:EditorModelLocator = EditorModelLocator.instance
			if (m.editorVO != null) {
				index = m.editorVO.floorsV0s.indexOf(floor);
				m.editorVO.floorsV0s.splice(index, 1);
			}
			
			//trace("removeFloor",  floorsArr);
		}
		
		public function get length():int
		{
			return floorsArr.length;
		}
		
		public  function getFloorIndex(floor:Floor):int
		{
			return floorsArr.indexOf(floor); //milou
		}
		
		private function _removed(e:Event):void
		{
			//trace("Floors::removed", floorsArr);
			for (var i:int = 0; i < floorsArr.length; i++)
			{
				removeFloor(floorsArr[i] as Floor);
			}
			//trace("Floors::removed", floorsArr);
			
			//floorsArr = new Array();
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
	}

}