package classes.views.items 
{
	import classes.vo.BlocVO;
	
	public class RoomItem extends PieceItem 
	{
		
		public function RoomItem() 
		{
			//trace("RoomItem " + id);
			type = BlocVO.BLOC_ROOM;
			//id = 0; ds le fla
			super(id, type);
		}
	}

}