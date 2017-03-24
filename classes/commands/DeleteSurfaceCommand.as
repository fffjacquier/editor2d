package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	//import classes.utils.AppUtils;
	import classes.views.equipements.EquipementView;
	import classes.views.EquipementsLayer;
	import classes.views.plan.Bloc;

	public class DeleteSurfaceCommand extends Command implements ICommand
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _bloc:Bloc;
		/**
		 * utilisé pour pouvoir déplacer les equipements en cas de suppression de pièces et d'étage
		 */
		private var _equipmentsArr:Array;
		
		public function DeleteSurfaceCommand(bloc:Bloc) 
		{
			_bloc = bloc;
			_equipmentsArr = _bloc.equipements.equipementsArr.concat();
		}
		
		override public function run(callback:Function=null):void
		{
			trace("DeleteSurfaceCommand::run()");
			var i:int;
			var equipement:EquipementView;
			if (_bloc.isPiece)
			{
				_bloc.equipements.equipementsArr = new Array();
				
				if(_equipmentsArr)
				{
					for (i = 0; i < _equipmentsArr.length; i++)
					{
						equipement = _equipmentsArr[i] as EquipementView;
						_model.currentBlocMaison.equipements.addEquipement(equipement, false);
					}
				}
				//17juillet changé: ligne commentée par ligne au dessous d'elle
				//_model.currentMaisonPieces.removeBloc(_bloc);// à tester, peut etre à mettre avant si pbm
				_model.currentFloor.removeBloc(_bloc);
				
				history.pushInHistory(this);
			}
			else //bloc maison
			{ 
				_bloc.equipements.equipementsArr = new Array();
				
				// deplacement de la LB et ses modules branchés
				var floorId:int = _bloc.floorId;
				//floorId n'est jamais égal à zero, on ne détruit jamais le rez-de chaussée
				var closestFloorId:int = (floorId == -1) ? 0 : floorId - 1;
				var equipementsLayer:EquipementsLayer = _model.getFloorById(closestFloorId).blocMaison.equipements;
				if (equipementsLayer == null) return;
				for (i = 0; i < _equipmentsArr.length; i++)
				{
					equipement = _equipmentsArr[i] as EquipementView;
					// si eq attaché à la LB ou eq is LB
					if(equipement.isNearLivebox) equipementsLayer.addEquipement(equipement, false);
				}
				// fin deplacement
				
				for (i = 0; i < _equipmentsArr.length; i++)
				{
					equipement = _equipmentsArr[i] as EquipementView;
					if(equipement.isTerminal) equipement.remove();
				}
				_model.currentFloor.removeBloc(_bloc);
			}
			//AppUtils.TRACE("DeleteSurfaceCommand::NOTIFICATION SAVE STATE TRUE")
			ApplicationModel.instance.notifySaveStateUpdate(true);
			
			//history.pushInHistory(this);
		}
		
		override public function undo():void
		{
			trace("DeleteSurfaceCommand::undo()");
			var bloc:Bloc = _model.currentFloor.addBloc(_bloc.type, _bloc.points);
			if(_equipmentsArr && _bloc.isPiece)
			{
				for (var i:int = 0; i < _equipmentsArr.length; i++)
				{
					var equipement:EquipementView = _equipmentsArr[i] as EquipementView;
					trace("_equipmentsArr " + equipement);
					bloc.equipements.addEquipement(equipement);
				}
			}
		}
	}

}