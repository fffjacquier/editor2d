package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.plan.Segment;
	import flash.geom.Point;

	public class MoveSegmentCommand extends Command implements ICommand 
	{
		private var segment:Segment;
		private var _p1:Point;
		private var _p2:Point;
		
		public function MoveSegmentCommand(segment:Segment, p1:Point, p2:Point) 
		{
			this.segment = segment;
			_p1 = p1;
			_p2 = p2;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("MoveSegmentCommand::run()", _p1, _p2);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			trace("MoveSegmentCommand::undo()");
			segment.hideDragHandle();
			segment.p1.setPos(_p1);
			segment.p2.setPos(_p2);
			segment.p1.testAndAttach();
			segment.p2.testAndAttach();
			EditorModelLocator.instance.notifyPointMove([segment.p1, segment.p2]);
		}
		
	}

}