package classes.views.plan 
{
	import classes.commands.AddNewSurfaceCommand;
	import classes.commands.DeleteSurfaceCommand;
	import classes.controls.ChangeFloorEvent;
	import classes.controls.History;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.equipements.LiveboxView;
	import classes.views.EquipementsLayer;
	import classes.views.menus.MenuContainer;
	import classes.views.NomPieceView;
	import classes.vo.BlocVO;
	import classes.vo.Texture;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Floor extends Sprite 
	{
		public var id:int;/*correspond au numéro d'étage: -1 pour sous sol, 0 pour rdc, 1, 2...*/
		public var isFirstTime:Boolean = true;
		public var floorName:String;
		public var blocs:Array = new Array();
		public var labelsContainer:Sprite;
		public var fiberLineContainer:Sprite;
		public var plancher:String = AppLabels.getString("editor_concrete");/*la nature du plancher de l'étage, "beton" ou "bois"*/
		
		private var _blocMaison:Bloc/* only One instance of bloc maison per floor*/
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _maisonDefautlPos:Point;
		private var _liveboxGhost:Bitmap;
		
		public function Floor() 
		{
			//trace("Floor::constructor", _blocMaison);
			if (stage) _added()
			else addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event = null):void
		{
			//trace("Floor:added", id);
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			labelsContainer = new Sprite();
			addChild(labelsContainer);
			
			// ecoute le changement d'étage
			_model.addFloorChangeListener(_onFloorChange);
		}
		
		public function get index():int 
		{
			return Editor2D.instance.floors.getFloorIndex(this);
		}
		
		public function removeBlocs(rebuildMainsurface:Boolean = false):void
		{
			if (_blocMaison && _blocMaison.stage) {
				removeChild(_blocMaison);
				var index:int = blocs.indexOf(_blocMaison);
				blocs.splice(index, 1);
				_blocMaison = null; 
			}
			_removeLabels();
			blocs = [];
			if(rebuildMainsurface)
			{
				if(id == 0) 
				{
					Editor2D.instance.createDefaultSurface();
				}
				else
				{
					var points:Array = getClosestFloor(id)._blocMaison.points;
					new AddNewSurfaceCommand(points).run();
				}
			}
			//trace("Floor::removeBlocs", _blocMaison);
		}
		
		public function removeBloc(bloc:Bloc, isMaison:Boolean=false):void
		{
			//trace("removeBloc start", bloc, blocs);
			if (bloc && bloc.stage)
			{
				trace("Floor::removeBloc() before removeChild", bloc, bloc.type)
				var index:int = blocs.indexOf(bloc);
				blocs.splice(index, 1);
				if (bloc.type == BlocVO.BLOC_MAISON) {
					removeChild(bloc); 
					blocs = [];
				} else {
					_blocMaison.pieces.removeBloc(bloc);
				}
				// si je commente la ligne ci dessous bloc est tracé malgré le remove
				bloc = null;
				// pb, bloc is still there !!
				//if(bloc) trace("!!BIG PB!! Floor::removeBloc() after removeChild ", bloc)
				
				if (isMaison) {
					resetHasMaison();
				}
				trace("removeBloc end", blocs);
			}
		}
		
		public function switchBloc(points:Array, texture:Texture = null):void
		{			
			trace("Floor::switchBloc()", this, id, texture);
			
			//removeBlocs();
			removeBloc(_blocMaison, true);
			_removeLabels();
			_blocMaison = new Bloc(BlocVO.BLOC_MAISON, points, texture); 
			addChildAt(_blocMaison, 0);
			//GAP: taille pixels équivalente à  10 cm assigné en dur dans Grid ajustée à l'échelle
			//m: mesure pixel equivalente à un mètre
			var m:Number = Grid.GAP * 10;
			var p:Point = new Point(2 * m, m);
			_blocMaison.x = p.x;
		    _blocMaison.y  = p.y;
			//pour lundi
			//le removeBlocs a été supprimé. j'ai donc remplacé le push
			//bug des pieces qui étaient avant le blocmaison dans le xml
			// + j'aimerais ajouter fonctionalité "ajouter un point" aux extrémités de segments
			//agrandir pieces? 
			//proposition arrivee de la fibre : la mettre au dessus sans les points pour le print 
			//bug qd on clique sur un item de accordeon  isoverbloc 
		//	blocs.push(_blocMaison);
			blocs.unshift(_blocMaison);
			//trace("Floor::switchBloc() _blocMaison ", _blocMaison, blocs);
			
		}
		
		public function addBloc(type:String, points:Array, mursPorteurs:Array = null, coeffMurs:Array = null, texture:Texture = null, surfaceType:String=null):Bloc
		{
			trace("Floor::addBloc()", type, points);
			var bloc:Bloc = new Bloc(type, points, texture, surfaceType);
			if (type == BlocVO.BLOC_JARDIN) {
				addChildAt(bloc, 0);
			} else if (type == BlocVO.BLOC_ROOM || type == BlocVO.BLOC_BALCONY) {
				_blocMaison.pieces.addBloc(bloc, mursPorteurs, coeffMurs);
			} else {
				addChild(bloc);
				if (type == BlocVO.BLOC_MAISON) {
					//GAP taille pixels équivalente à  10 cm assigné en dur dans Grid
					//m mesure pixel equivalente à un mètre
					var m:Number = Grid.GAP * 10;
					var p:Point = new Point(2 * m, m);
					_blocMaison = bloc;
					_blocMaison.x = p.x;
					_blocMaison.y  = p.y;
				}
			}
			blocs.push(bloc);
			trace("blocs=", blocs)
			//addChild(_labelsContainer);
			return bloc;
		}
		
		public function addLabel(nameRoom:NomPieceView):void
		{
			labelsContainer.addChild(nameRoom);
		}
		public function removeLabel(nameRoom:NomPieceView):void
		{
			labelsContainer.removeChild(nameRoom);
		}
		private function _removeLabels():void
		{
			if (labelsContainer && labelsContainer.stage) 
			{
				// delete room names
				while (labelsContainer.numChildren > 0) {
					labelsContainer.removeChildAt(0);
				}
			}
		}
		
		public function resetHasMaison():void
		{
			_blocMaison = null;
		}
		
		public function get blocMaison():Bloc
		{
			//trace("Floor::blocMaison", _blocMaison);
			return _blocMaison;
		}
		
		public function get mainEntity():MainEntity
		{
			//trace("Floor::blocMaison", _blocMaison);
			return _blocMaison.obj2D as MainEntity;
		}
		
		public function hasEquipements():Boolean
		{
			return EquipementsLayer.hasEquipmentsOnFloor(this);
		}
		
		/**
		 * Règles du changement d'étage
		 * - la Livebox doit toujours etre visible, transparence légère si pas à l'étage en cours
		 * - tenir compte du fait de devoir masquer cloisons et pièces 
		 * - tenir compte du fait que les équipements peuvent etre dans des pièces masquées du coup
		 * - on doit voir l'étage en cours et les contours de celui immédiatement avant ou après
		 * - quand on montre les connexions, on doit pouvoir voir les modules connectés si à un autre étage (transparence)
		 *  
		 * @param e	Le ChangeFloorEvent connait le floor
		 */
		private function _onFloorChange(e:ChangeFloorEvent):void
		{
			if (e.floor == null || _blocMaison == null) return;
			
			History.instance.clearHistory();
			var menu:MenuContainer = MenuContainer.instance;
			//if (menu) menu.closeMenu();
			
			var floor:Floor = e.floor;
			var currentFloorId:int = e.floor.id;
			var lb:LiveboxView = EquipementsLayer.getLivebox();
			
			if (lb != null) var etageLB:int = lb.floorId;
			else etageLB = -10;
			
			trace("Floor::_onFloorChange() floor.id:", id, "e.floor.id:",currentFloorId, lb);
			_blocMaison.equipements.alpha = 1;
			_blocMaison.obj2D.alpha = 1;
			
			if (id === currentFloorId) {
				trace("cas1")
				//if(menu) menu.update(floor, MenuFactory.createMenu(floor, EditorContainer.instance), "floor");
				_reset();
			} else {
				if ((id === etageLB )) {
					trace("cas2", id, currentFloorId)
					//_blocMaison.alpha = .5;
					//_blocMaison.obj2D.alpha = (id > currentFloorId) ? 0 : .5;
					/*_blocMaison.obj2D.alpha = 0;
					_blocMaison.cloisons.visible = false;
					_blocMaison.obj2D.pointsViewContainer.visible = false;
					_blocMaison.equipements.visible = false;
					_blocMaison.pieces.visible = false;*/
					_blocMaison.hideAll();
					//_blocMaison.obj2D.surface.alpha = .5;
					_manageLivebox(true);
					if (_blocMaison.equipements) _blocMaison.equipements.alpha = (id > currentFloorId) ? 0.5 : 1;
					// si livebox et livebox dans une pièce FJ patch 05/07 1re partie
					if (lb != null && _liveboxInPiece()) {
						//trace(_liveboxInPiece(), lb.parentBloc.alpha, lb.parentBloc.equipements.alpha)
						lb.parentBloc.equipements.alpha = (id > currentFloorId) ? 0.5 : 1;
					} // end of patch 1
					labelsContainer.visible = false;
					mouseEnabled = false;
					mouseChildren = false;
				} else {
					trace("cas3")
					/*_blocMaison.alpha = 0;
					_blocMaison.obj2D.alpha = 0;
					_blocMaison.cloisons.visible = false;
					_blocMaison.obj2D.pointsViewContainer.visible = false;
					_blocMaison.equipements.visible = false;
					_blocMaison.pieces.visible = false;
					_blocMaison.obj2D.surface.alpha = 0;*/
					_blocMaison.hideAll();
					_manageLivebox(false);
					labelsContainer.visible = false;
					mouseEnabled = false;
					mouseChildren = false;
				}
				
				if(this == getClosestFloor(currentFloorId))
				{
					_blocMaison.alpha = 1;
					_blocMaison.obj2D.alpha = .2;
					_blocMaison.obj2D.surface.alpha = 0;
				}
			}
			
			// if there is no bloc on this floor, add the surface from the closest floor (not the previously displayed)
			if (_model.currentFloor._blocMaison == null ) {
				var closestFloor:Floor = (currentFloorId == -1) ? _model.getFloorById(0) : _model.getFloorById(currentFloorId -1);
				if (/*closestFloor && */closestFloor.blocMaison != null) {
					new AddNewSurfaceCommand(closestFloor.blocMaison.points).run();
				}
			}
		}
		
		private function getClosestFloor(floorId:int):Floor
		{
			return  (floorId == -1) ? _model.getFloorById(0) : _model.getFloorById(floorId -1);
		}
		
		private function _liveboxInPiece():Boolean
		{
			var lb:LiveboxView = EquipementsLayer.getLivebox();
			return lb.parentBloc.isPiece;
		}
		
		private function _setVisibleChildrenOf(s:Sprite, bVisible:Boolean):void
		{
			/*if (s != null) {
				var l:int = s.numChildren;
				for (var i:int = 0; i < l; i++)
				{
					s.getChildAt(i).visible = bVisible;
					//trace("_setVisibleChildrenOf", id, s, s.getChildAt(i), bVisible);
				}
			}*/
			AppUtils.setVisibleChildrenOf(s, bVisible);
		}
		
		private function _manageLivebox( bool:Boolean ):void
		{
			//trace("manageLivebox", bool);
			if(bool) { // la LB est à cet étage mais ce n'est pas l'étage affiché
				var lb:LiveboxView = EquipementsLayer.getLivebox();
				if (lb == null) return;
				if (!_liveboxInPiece() )
				{
					// on masque toutes les pieces
					//_blocMaison.pieces.visible = false;
					_blocMaison.pieces.hidePieces();
					
					//on masque tous les equipements sauf la livebox
					//_blocMaison.equipements.visible = true;
					_setVisibleChildrenOf(_blocMaison.equipements, false);
					lb.visible = true;
					trace("_manageLB", _liveboxInPiece(), lb.visible, lb.parentBloc.alpha, _blocMaison.equipements.alpha)
					
				} else {
					//on masque tous les equipements dans equipements qui sont hors pièces
					//_blocMaison.equipements.visible = false;
					_blocMaison.hideAll();
					
					//on masque toutes les pieces sauf celle de la livebox
					
					/*_blocMaison.pieces.visible = true;
					_setVisibleChildrenOf(_blocMaison.pieces, false);
					lb.parentBloc.visible = true;
					_setVisibleChildrenOf(lb.parentBloc.obj2D, false);
					_setVisibleChildrenOf(lb.parentBloc.equipements, false);
					_setVisibleChildrenOf(lb.parentBloc.cloisons, false);*/
					lb.visible = true;
					trace("_manageLB", _liveboxInPiece(), lb.visible, lb.parentBloc.alpha, _blocMaison.equipements.alpha)
				}
			}
			else // pas de LB ou LB n'est pas à cet étage et ce n'est pas l'étage affiché
			{
				// on masque toutes les pieces
//				_blocMaison.pieces.visible = false;
				_blocMaison.pieces.hidePieces();
				
				//on masque tous les equipements
				//_blocMaison.equipements.visible = false;
				_setVisibleChildrenOf(_blocMaison.equipements, false);
			}
		}
		
		/* utilisé pour les captures des étages pour l'écran de synthese et aussi le pdf */
		public function reset():void
		{
			if (_blocMaison == null) return;
			
			/*_blocMaison.equipements.alpha = 1;
			_blocMaison.obj2D.alpha = 1;
			_blocMaison.alpha = 1;
			_blocMaison.obj2D.visible = true;
			_blocMaison.obj2D.surface.alpha = 1;//.8;*/
			
			//_blocMaison.obj2D.pointsViewContainer.visible = false;
			_blocMaison.obj2D.pointsViewContainer.visible = false;
			//_blocMaison.obj2D.surface.alpha = 1;
			/*_blocMaison.cloisons.visible = true;
			_blocMaison.pieces.visible = true;
			_blocMaison.equipements.visible = true;*/
			labelsContainer.visible = true;
			//_setVisibleChildrenOf(_blocMaison.pieces, true);
			
				/*_setVisibleChildrenOf(_blocMaison.equipements, true);
				_setVisibleChildrenOf(_blocMaison.pieces, true);*/
			_blocMaison.showAll()	;
			var lb:LiveboxView = EquipementsLayer.getLivebox();
			if (lb != null) var etageLB:int = lb.floorId;
			else etageLB = -10;
			if(lb != null) {
				if (id === _model.currentFloor.id && etageLB === id) {
					//_setVisibleChildrenOf(lb.parentBloc, true);
					_setVisibleChildrenOf(lb.parentBloc.equipements, true);
					_setVisibleChildrenOf(lb.parentBloc.cloisons, true);
					_setVisibleChildrenOf(lb.parentBloc.obj2D, true);
				}
				lb.visible = true;
			}
			if(_blocMaison.fiberLine != null) _blocMaison.fiberLine.visible = true;
		}
		
		public function _reset():void
		{
			if (!_blocMaison) return;
			if (id !== _model.currentFloor.id) return;
			
			visible = true;
			_blocMaison.alpha = 1;
			var lb:LiveboxView = EquipementsLayer.getLivebox();
			if (lb != null) var etageLB:int = lb.floorId;
			else etageLB = -10;
			//_blocMaison.surface.alpha = 1;
			/*if (id === etageLB) {
				_blocMaison.obj2D.surface.alpha = .8;
			} else {
				_blocMaison.obj2D.surface.alpha = .35;
			}*/
			/*_blocMaison.obj2D.pointsViewContainer.visible = true;
			//_blocMaison.obj2D.surface.alpha = 1;
			_blocMaison.cloisons.visible = true;
			_blocMaison.pieces.visible = true;
			_blocMaison.equipements.visible = true;*/
			blocMaison.obj2D.pointsViewContainer.visible = true;
			blocMaison.showAll();
			labelsContainer.visible = true;
			//_setVisibleChildrenOf(_blocMaison.pieces, true);
			if (id === _model.currentFloor.id) {
				_setVisibleChildrenOf(_blocMaison.equipements, true);
				_setVisibleChildrenOf(_blocMaison.pieces, true);
			}
			if(lb != null) {
				if (id === _model.currentFloor.id && etageLB === id) {
					//_setVisibleChildrenOf(lb.parentBloc, true);
					// FJ patch 05 / 07 2eme partie
					lb.parentBloc.equipements.alpha = 1;// end patch 2
					_setVisibleChildrenOf(lb.parentBloc.equipements, true);
					_setVisibleChildrenOf(lb.parentBloc.cloisons, true);
					/*if (_blocMaison.equipements && _blocMaison.equipements.alpha == 0.5)
						_blocMaison.equipements.alpha = 1;*/
					_setVisibleChildrenOf(lb.parentBloc.obj2D, true);
				}
				lb.visible = true;
			}
			mouseEnabled = true;
			mouseChildren = true;
		}
		
		override public function toString():String
		{
			return "Floor :{" + floorName+"/"+name + ", " + id + ", " + index + "}";
		}
		
		public function toXML():XML
		{
			var floorNode:XML = new XML("<floor id=\""+id+"\" index=\""+index+"\" plancher=\""+ plancher +"\"></floor>");
			var floorNameXML:XML = new XML("<name><![CDATA[" + floorName + "]]></name>");
			floorNode.appendChild(floorNameXML);
			var floorData:XML = new XML();
			var blocsLen:int = blocs.length;
			if (blocsLen) {
				var blocsNode:XML = <blocs></blocs>;
				var i:int = 0
				for (; i < blocsLen; i++)
				{
					var bloc:Bloc = blocs[i] as Bloc;
					blocsNode.appendChild(bloc.toXML());
				}
				floorNode.appendChild(blocsNode);
			}
			var labels:int = labelsContainer.numChildren;
			if (labels > 0) {
				var labelsNode:XML = <labels></labels>;
				for (i = 0; i < labels; i++)
				{
					var label:NomPieceView = labelsContainer.getChildAt(i) as NomPieceView;
					labelsNode.appendChild(label.toXML());
				}
				floorNode.appendChild(labelsNode);
			}
			return floorNode;
		}
		
		public function get fiberLine():FiberLineEntity
		{
			return blocMaison.fiberLine;
		}
		
		private function _removed(e:Event):void
		{
			//removeBlocs();
			if (!_appmodel.flagForEditorDeletion) new DeleteSurfaceCommand(blocMaison).run();
			else removeBlocs();
			trace("Floor::_removed", id, _blocMaison);
			_model.removeFloorChangeListener(_onFloorChange);
			_model.notifyFloorDeletion(this);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
	}

}