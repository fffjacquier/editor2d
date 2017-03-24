package classes.commands.fiber 
{
	import classes.commands.Command;
	import classes.commands.ICommand;
	import classes.model.ApplicationModel;
	import classes.views.accordion.AccordionFiberArrival;
	import classes.views.plan.Bloc;
	import classes.views.plan.FiberLineEntity;
	
	public class DeleteFiberLineCommand extends Command implements ICommand 
	{
		private var _points:Array;
		private var _fiberLine:FiberLineEntity;
		private var _blocMaison:Bloc;
		
		public function DeleteFiberLineCommand(fiberLine:FiberLineEntity) 
		{
			_fiberLine = fiberLine;
			_blocMaison = _fiberLine.blocMaison;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			// FJ ajout 22/08
			if(AccordionFiberArrival.instance) AccordionFiberArrival.instance.clear();
			
			if (_fiberLine == null) return;
			
			_points = _fiberLine.points;
			_blocMaison.removeFiberline();
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			var fiberline:FiberLineEntity = new FiberLineEntity(0, _points);
			_blocMaison.addFiberline(fiberline);
		}
		
	}

}