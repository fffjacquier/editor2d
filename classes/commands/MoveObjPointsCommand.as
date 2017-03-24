package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.plan.Object2D;
	import classes.vo.PointVO;
	import flash.geom.Point;
	
	public class MoveObjPointsCommand extends Command implements ICommand 
	{
		private var _startPoints:Array;
		private var _obj2D:Object2D;
		
		public function MoveObjPointsCommand(obj2D:Object2D, points:Array) 
		{
			trace("MoveObjPointsCommand");
			super();
			_obj2D = obj2D;
			_startPoints = points;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("MovePointCommand::run()");
			var changed:Boolean = false;
			for (var i:int = 0; i<_startPoints.length; i++)
			{
				if(!(_startPoints[i] as Point).equals(_obj2D.points[i] as Point)) 
				{
					changed = false;
					break;
				}
			}
				trace("changed " + changed)
			//if(changed == false) return;
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			for( var i:int = 0; i<_startPoints.length; i++)
			{
				(_obj2D.pointsVOArr[i] as PointVO).setPos(_startPoints[i]);
				
			}
			_obj2D.testAndAttachPoints();
			_obj2D.adjutSquarePoints();
		//	_pv.hideDragHandle();
			EditorModelLocator.instance.notifyPointMove(_obj2D.pointsVOArr);
		}
		
	}

}