package classes.commands.fiber
{
	import classes.commands.Command;
	import classes.commands.ICommand;
	import classes.model.ApplicationModel;
	import classes.views.accordion.AccordionFiberArrival;
	import classes.views.plan.Bloc;
	import classes.views.plan.FiberLineEntity;
	
	public class AddFiberLineCommand extends Command implements ICommand
	{
		private var _points:Array;
		private var _fiberLine:FiberLineEntity;
		private var _blocMaison:Bloc;		
		
		public function AddFiberLineCommand(blocMaison:Bloc, points:Array)
		{
			_points = points;
			_blocMaison = blocMaison;
		}
		
		override public function run(callback:Function = null):void 
		{
			trace("AddFiberLineCommand::run()");
			history.pushInHistory(this);
			_fiberLine = new FiberLineEntity(0, _points);
			_blocMaison.addFiberline(_fiberLine);
			ApplicationModel.instance.notifySaveStateUpdate(true);
		}
		
		override public function undo():void 
		{
			trace("AddFiberLineCommand::undo()");
			AccordionFiberArrival.instance.clear();
			_blocMaison.removeFiberline();
		}
	}
}




