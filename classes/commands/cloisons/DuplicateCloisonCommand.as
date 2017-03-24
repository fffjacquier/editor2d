package classes.commands.cloisons 
{
	import classes.commands.Command;
	import classes.commands.ICommand;
	import classes.model.ApplicationModel;
	import classes.views.plan.CloisonEntity;
	import classes.views.plan.Object2D;
	
	public class DuplicateCloisonCommand extends Command implements ICommand 
	{
		private var _obj2D:Object2D;
		private var _newCloison:CloisonEntity;
		
		public function DuplicateCloisonCommand(obj2D:Object2D) 
		{
			_obj2D = obj2D;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			var cloisonEntity:CloisonEntity = _obj2D as CloisonEntity;
			_newCloison = cloisonEntity.clone();
			cloisonEntity.cloisons.addCloison(_newCloison);
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			var cloisonEntity:CloisonEntity = _obj2D as CloisonEntity;
			cloisonEntity.cloisons.removeCloison(_newCloison);
		}
		
	}

}