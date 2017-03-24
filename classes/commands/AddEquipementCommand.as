package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.utils.ObjectUtils;
	import classes.views.equipements.EquipementView;
	import classes.views.plan.Bloc;
	
	public class AddEquipementCommand extends Command implements ICommand 
	{
		private var _bloc:Bloc;
		private var _eqView:EquipementView;
		private var _bloc2:Bloc;
		private var _eqView2:EquipementView;
		private var _pushInHistory:Boolean;
		
		public function AddEquipementCommand(bloc:Bloc, equipementView:EquipementView, bloc2:Bloc = null, equipementView2:EquipementView = null, pushInHistory:Boolean = true ) 
		{
			_bloc = bloc;
			_pushInHistory = pushInHistory;
			_eqView = equipementView;
			_eqView.uniqueId = ObjectUtils.createUID();
			if(bloc2 != null) {
				_bloc2 = bloc2;
				_eqView2 = equipementView2;
				_eqView2.uniqueId = ObjectUtils.createUID();
			}
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			//trace("AddEquipementCommand::run()", _eqView);
			_bloc.equipements.addEquipement(_eqView);
			if (_bloc2 != null) {
				_bloc2.equipements.addEquipement(_eqView2);
			}
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			
			//EquipementsLayer.traceEquipements();
			if(_pushInHistory) history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			//history.popHistory();
			//trace("AddEquipementCommand::undo()", _eqView);
			_eqView.deleteObj();
			_bloc.equipements.removeEquipement(_eqView);
			if (_bloc2 != null) {
				_eqView2.deleteObj();
				_bloc2.equipements.removeEquipement(_eqView2);
			}
		}
		
	}

}