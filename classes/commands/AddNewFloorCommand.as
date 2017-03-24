package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.plan.Editor2D;
	import classes.views.plan.Floor;
	import classes.vo.EditorVO;
	
	public class AddNewFloorCommand extends Command implements ICommand 
	{
		private var _label:String;
		private var _id:int;
		private var _points:Array;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		public function AddNewFloorCommand(floorLabel:String, id:int, points:Array = null ) 
		{
			doNotify = false;
			_label = floorLabel;
			_id = id;
			_points = points;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			var floor:Floor = new Floor();
			floor.floorName = _label;
			floor.id = _id;
			Editor2D.instance.floors.addFloor(floor);
			//trace("AddNewFloorCommand::run() ", _label, "floor index:", floor.index, "floor id", floor.id);			
			_model.currentFloor = floor;
			
			// saving purpose
			if (_model.editorVO == null) {
				_model.editorVO = new EditorVO(ApplicationModel.instance.projectLabel);
			}
			_model.editorVO.floorsV0s.push(floor);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			
			if (callback != null) {
				if (_points != null) callback(_points);
				else callback();
			}
		}
		
		override public function undo():void
		{
			trace("AddNewFloorCommand::undo() !NOT CODED!", _label);
			//if (_model.editorVO.floorsV0s.length <= 1) return;
			
		}
	}

}