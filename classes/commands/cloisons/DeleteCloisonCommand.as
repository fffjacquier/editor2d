package classes.commands.cloisons 
{
	import classes.commands.Command;
	import classes.commands.ICommand;
	import classes.model.ApplicationModel;
	import classes.views.plan.CloisonEntity;
	import classes.views.plan.Cloisons;
	import classes.views.plan.Object2D;
	
	public class DeleteCloisonCommand extends Command implements ICommand 
	{
		private var _obj2D:Object2D;
		private var _cloison:CloisonEntity;
		private var _cloisons:Cloisons;
		private var _points:Array;
		
		public function DeleteCloisonCommand(cloison:CloisonEntity) 
		{
			_cloison = cloison;
			_cloisons = cloison.cloisons;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			_points = _cloison.points;
			_cloisons.removeCloison(_cloison);
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			var ce:CloisonEntity = new CloisonEntity(0, _points);
			_cloisons.addCloison(ce);
		}
	}

}