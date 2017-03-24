package classes.commands 
{
	import classes.model.ApplicationModel;
	public class FollowingPointsCommand extends Command implements ICommand 
	{
		public function FollowingPointsCommand() 
		{
			super();
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("FollowingPointsCommand::run()");
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			trace("FollowingPointsCommand::undo()");
			//no undo here  following points will listen and do their undo points will do their undo 
		}
		
	}

}