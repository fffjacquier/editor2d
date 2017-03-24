package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.views.equipements.EquipementView;
	import classes.views.plan.Bloc;
	
	public class DeleteEquipementCommand extends Command implements ICommand 
	{
		private var _bloc:Bloc;
		private var _eqView:EquipementView;
		
		public function DeleteEquipementCommand(bloc:Bloc, equipementView:EquipementView) 
		{
			_bloc = bloc;
			_eqView = equipementView;
			//TODO: cas des liveplugs et wifiextenders ajoutés en paires et mise à jour du mode de connexion de l'équipement concerné par ce mode de connexion	
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("DeleteEquipementCommand::run()", _eqView);
			_bloc.equipements.removeEquipement(_eqView);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);			
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			trace("DeleteEquipementCommand::undo()", _eqView);
			_bloc.equipements.addEquipement(_eqView);
		}
		
	}

}