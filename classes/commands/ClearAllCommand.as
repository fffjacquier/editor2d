package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.menus.MenuContainer;
	import classes.views.plan.Editor2D;
	import classes.views.plan.Floor;
	
	public class ClearAllCommand extends Command implements ICommand 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		public function ClearAllCommand() 
		{
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			//trace("ClearAllCommand::run() ");
			if(Editor2D.instance.floors && Editor2D.instance.floors.numChildren !== 0) {
				//var floor:Floor = Editor2D.instance.floors.getChildAt(_model.currentFloor.index) as Floor;
				var floor:Floor = _model.currentFloor;
				if (floor) {
					floor.removeBlocs(true);
				}
			}
			MenuContainer.instance.closeMenu();
			ApplicationModel.instance.currentStep = ApplicationModel.STEP_SURFACE;
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.clearHistory();
		}
		
		override public function undo():void 
		{
			trace("ClearAllCommand::undo()");
		}
		
	}

}