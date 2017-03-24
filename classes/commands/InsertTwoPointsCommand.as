package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.plan.Object2D;
	import classes.views.plan.Segment;
	import classes.vo.PointVO;
	import flash.geom.Point;
	
	public class InsertTwoPointsCommand extends Command implements ICommand 
	{
		private var _obj2D:Object2D;
		private var _point:Point;
		private var _segment:Segment;
		private var _params:Array;
		
		public function InsertTwoPointsCommand(obj2d:Object2D, segment:Segment, point:Point) 
		{
			_obj2D = obj2d;
			_point = point;
			_segment = segment;
		}
		
		override public function run(callback:Function=null):void
		{
			trace("InsertTwoPointsCommand::run()");
			_params = _obj2D.insertTwoPoints(_segment, _point);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
			
			if(callback != null) callback();
		}
		
		override public function undo():void
		{
			trace("InsertTwoPointsCommand::undo()");
			_obj2D.removePoint(_params[0]);
			_obj2D.removePoint(_params[1]);
			// replace the 4th point to its initial position 
			var p4:PointVO = _params[2] as PointVO;
			p4.setPos(_params[3] as Point);
			EditorModelLocator.instance.notifyPointMove([p4]);
		}
	}

}