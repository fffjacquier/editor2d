package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.equipements.EquipementView;
	import classes.views.plan.Bloc;
	import classes.views.plan.Pieces;
	import classes.views.plan.Surface;
	import classes.vo.BlocVO;
	import classes.vo.Texture;
	import flash.geom.Point;	

	public class AddNewSurfaceCommand extends Command implements ICommand 
	{
		private var pointsArray:Array;
		private var type:String;
		private var p:Point;
		private var _mursP:Array;
		private var _coeffMurs:Array;
		private var _texture:Texture;
		private var _bloc:Bloc;
		private var _blocToRestore:Bloc;
		private var _surfaceType:String;
		private var _equipmentsArr:Array;
		
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		/**
		 * Ajoute une surface dans l'éditeur
		 * 
		 * @param arr un tableau de points correspondant aux angles de la surface
		 * @param type le type de surface, par défaut "blocMaison", autres valeurs possibles "blocPiece", "blocBalcon"...
		 * @param p un point de coords où placer le bloc
		 * @param mursPorteurs un array d'index correspondant uniquement aux segments "mursPorteurs", ex: 0,1 : le segment 0 et 1 du tableau sont des murs porteurs
		 * @param coeffMurs un array de coeff pour chaque mur, utilisé pour le calcul déperdition wifi
		 * @param texture la texture du bloc ou couleur
		 * @param surfaceType forme libre ou rectangle
		 * @param blocToRestore pour le undo
		 */
		public function AddNewSurfaceCommand(arr:Array, type:String="blocMaison", p:Point=null, mursPorteurs:Array=null, coeffMurs:Array=null, texture:Texture = null, surfaceType:String=null, blocToRestore:Bloc=null) 
		{
			pointsArray = arr;
			this.type = type;
			_mursP = mursPorteurs;
			_coeffMurs = coeffMurs;
			if(texture) _texture = texture;
			_surfaceType = surfaceType || Surface.TYPE_FREE;
			_blocToRestore = blocToRestore;
			if(_blocToRestore) _equipmentsArr = _blocToRestore.equipements.equipementsArr.concat();
			
			//trace(mursPorteurs);
			if (p != null) this.p = p;
		}
		
		override public function run(callback:Function=null):void
		{
			trace("AddNewSurfaceCommand::run()");
			if (type == BlocVO.BLOC_MAISON) 
			{
				//Editor2D.instance.addFirstFloor();
				//trace("floor:", _model.currentFloor);
				_model.currentFloor.switchBloc(pointsArray, _texture ? _texture.clone() : null);
				_bloc = _model.currentBlocMaison;
			}
			else 
			{
				_bloc = _model.currentFloor.addBloc(type, pointsArray, _mursP, _coeffMurs, _texture? _texture.clone() : null, _surfaceType);
				//newBloc.isDragging = true;
				if (p != null) 
				{
					_bloc.x = p.x;
					_bloc.y = p.y;
				}
			}
			if(_equipmentsArr)
			{
				for (var i:int = 0; i < _equipmentsArr.length; i++)
				{
					var equipement:EquipementView = _equipmentsArr[i] as EquipementView;
					trace("_equipmentsArr " + equipement);
					_bloc.equipements.addEquipement(equipement, false);
				}
			}
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void
		{
			trace("AddNewSurfaceCommand::undo() ", type, (type === BlocVO.BLOC_MAISON));
			//var blocToRemove:Bloc = _model.currentFloor.blocs.pop() as Bloc;
			if (type == BlocVO.BLOC_BALCONY || type == BlocVO.BLOC_ROOM) {
				var pieces:Pieces = _model.currentMaisonPieces;
				pieces.removeBloc(_bloc);
				if(_blocToRestore) var bloc:Bloc = _model.currentFloor.addBloc(_blocToRestore.type, _blocToRestore.points, _blocToRestore._getMurPorteursArr(_blocToRestore.obj2D), _blocToRestore.getMursCoeffArr(_blocToRestore.obj2D), _blocToRestore.texture, _blocToRestore.surfaceType);
				if (_blocToRestore) {// FJ -- patch 04/04
					for (var i:int = 0; i < _equipmentsArr.length; i++)
					{
						var equipement:EquipementView = _equipmentsArr[i] as EquipementView;
						bloc.equipements.addEquipement(equipement, false);
					}	
				}
				return;
			}
			_model.currentFloor.removeBloc(_bloc, (type === BlocVO.BLOC_MAISON));
		}
		
	}

}