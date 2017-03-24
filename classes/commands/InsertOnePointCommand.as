package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.views.plan.Object2D;
	import classes.views.plan.Segment;
	import classes.vo.PointVO;
	import flash.geom.Point;
	
	public class InsertOnePointCommand extends Command implements ICommand 
	{
		private var _obj2D:Object2D;
		private var _point:Point;
		private var _pointVO:PointVO;
		private var _segment:Segment;
		
		public function InsertOnePointCommand(obj2d:Object2D, segment:Segment, point:Point) 
		{
			_obj2D = obj2d;
			_point = point;
			_segment = segment;
		}
		
		override public function run(callback:Function=null):void
		{
			trace("InsertOnePointCommand::run()");
			_pointVO = _obj2D.insertOnePoint(_segment, _point);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
			
			if(callback != null) callback();
		}
		
		override public function undo():void
		{
			trace("InsertOnePointCommand::undo()");
			_obj2D.removePoint(_pointVO);
		}
	}

}