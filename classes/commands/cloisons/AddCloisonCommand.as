package classes.commands.cloisons 
{
	import classes.commands.Command;
	import classes.commands.ICommand;
	import classes.model.ApplicationModel;
	import classes.views.plan.CloisonEntity;
	import classes.views.plan.Cloisons;
	
	public class AddCloisonCommand extends Command implements ICommand 
	{
		private var _cloisons:Cloisons;
		private var _points:Array;
		private var _mursP:Array;
		private var _coeffMurs:Array;
		private var _cloison:CloisonEntity;
		
		public function AddCloisonCommand(cloisons:Cloisons, points:Array, murs:Array = null, coeffMurs:Array = null)
		{
			_cloisons = cloisons;
			_points = points;
			_mursP = murs;
			_coeffMurs = coeffMurs;
			//trace("AddCloisonCommand::",murs);
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("AddCloisonCommand::run()");
			history.pushInHistory(this);
			_cloison = new CloisonEntity(0, _points);
			_cloisons.addCloison(_cloison, _mursP, _coeffMurs);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
		}
		
		override public function undo():void 
		{
			trace("AddCloisonCommand::undo()");
			if(_cloison.stage) _cloison.cloisons.removeCloison(_cloison);
		}
		
	}

}