package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.plan.PointView;
	import classes.vo.PointVO;
	import flash.geom.Point;
	
	public class MovePointCommand extends Command implements ICommand 
	{
		private var _startpoint:Point;
		private var _pv:PointView;
		
		public function MovePointCommand(pv:PointView, startpoint:Point) 
		{
			trace("MovePointCommand");
			super();
			_pv = pv;
			_startpoint = startpoint;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("MovePointCommand::run()");
			if (_pv.pointVO.equals(_startpoint)) return;
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			PointVO(_pv.pointVO).setPos(_startpoint)
		//	_pv.hideDragHandle();
			EditorModelLocator.instance.notifyPointMove([_pv.pointVO]);
		}
		
	}

}