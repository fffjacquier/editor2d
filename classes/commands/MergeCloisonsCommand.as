package classes.commands 
{
	import classes.commands.cloisons.AddCloisonCommand;
	import classes.model.ApplicationModel;
	import classes.views.plan.CloisonEntity;
	import classes.views.plan.Cloisons;
	import classes.views.plan.Segment;
	import classes.vo.PointVO;

	public class MergeCloisonsCommand extends Command implements ICommand 
	{
		private var segment:Segment;
		private var _p1:PointVO;
		private var _p2:PointVO;
		private var _cloison1:CloisonEntity;
		private var _cloison2:CloisonEntity;
		private var _newCloison:CloisonEntity;
		private var _lastCommand:Command;
		
		public function MergeCloisonsCommand(p1:PointVO, p2:PointVO) 
		{
			_lastCommand  = history.lastCommand;
			/*if (_lastCommand is MoveSegmentCommand ||  _lastCommand is MovePointCommand || _lastCommand is AddCloisonCommand)
			{
				doNotify = false;
			}*/
			_p1 = p1;
			_p2 = p2;
			
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("MergeCloisonsCommand::run()");
			_lastCommand  = history.lastCommand;
			history.pushInHistory(this);
			
			var cloison1:CloisonEntity = _p1.obj2D as CloisonEntity;
			var cloison2:CloisonEntity = _p2.obj2D as CloisonEntity;
			_cloison1 = cloison1.clone();
			_cloison2 = cloison2.clone();
			
			if (!cloison1 || !cloison2) return;
			if (cloison1.cloisons != cloison2.cloisons) return;
			var cloisons:Cloisons = cloison2.cloisons;
			if (!cloisons) return;
			
			if (_p1.isLastPoint && _p2.isLastPoint)
			{
				cloison2.pointsVOArr.pop();
				cloison2.pointsVOArr.reverse();
			}
			else if (_p1.isLastPoint  && _p2.isFirstPoint)
			{
				cloison2.pointsVOArr.shift();
			}
			
			else if (_p1.isFirstPoint && _p2.isLastPoint)
			{
				cloison1.pointsVOArr.reverse();
				cloison2.pointsVOArr.pop();
				cloison2.pointsVOArr.reverse();
			}
			else
			{
				cloison1.pointsVOArr.reverse();
				cloison2.pointsVOArr.shift();
			}
			var arrPoints:Array = cloison1.pointsVOArr.concat(cloison2.pointsVOArr);
			_newCloison = new CloisonEntity(2000, arrPoints);
			//var cloisons:Cloisons = cloison.cloisons;
			if (!cloison2 || !cloisons) return;
			if (!cloison2.stage) return;
			cloisons.removeCloison(cloison1);
			cloisons.removeCloison(cloison2);
			cloisons.addCloison(_newCloison);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			
			if(callback != null) callback();
		}
		
		override public function undo():void 
		{
			trace("MergeCloisonsCommand::undo()");
			history.popHistory();
			
			var cloisons:Cloisons = _newCloison.cloisons;
			cloisons.removeCloison(_newCloison);
			cloisons.addCloison(_cloison1);
			if (_lastCommand is AddCloisonCommand) return;
			cloisons.addCloison(_cloison2);
			
			
		}
	}
}