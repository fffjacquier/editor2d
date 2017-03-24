package classes.model
{
	import classes.commands.Command;
	import classes.controls.ChangeFloorEvent;
	import classes.controls.DeleteFloorEvent;
	import classes.controls.EndMovingPieceEvent;
	import classes.controls.GlobalEventDispatcher;
	import classes.controls.HomeResizeEndEvent;
	import classes.controls.HomeResizeEvent;
	import classes.controls.NewCommandEvent;
	import classes.controls.PointMoveEndEvent;
	import classes.controls.PointMoveEvent;
	import classes.controls.PointMoveStartEvent;
	import classes.controls.SegmentMoveEvent;
	import classes.controls.UndoEvent;
	import classes.controls.UpdatePointsVOEvent;
	import classes.controls.ZoomEndEvent;
	import classes.controls.ZoomEvent;
	import classes.views.plan.Bloc;
	import classes.views.plan.Cloisons;
	import classes.views.plan.Editor2D;
	import classes.views.plan.Floor;
	import classes.views.plan.Floors;
	import classes.views.plan.MainEntity;
	import classes.views.plan.PieceEntity;
	import classes.views.plan.Pieces;
	import classes.views.plan.Segment;
	import classes.views.plan.Surface;
	import classes.vo.EditorVO;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Cette classe est un singleton global qui contient les données relatives à l'éditeur proprement dit, le dessin du plan, 
	 * des pièces et cloisons, ainsi que des détails concernant l'accordion, utilisé seulement dans l'éditeur.
	 */
	public class EditorModelLocator 
	{
		public var pointsVOArr:Array;
		//public var floors:Array;
		public var editorVO:EditorVO;
		public var zoomRegisterPoint:Point;
		public var defaultScale:Number = 1;
		
		//private var _previousFloor:Floor;
		private var _currentFloor:Floor;
		private var _currentScale:Number = defaultScale;
		private var _prevScale:Number = 1;
		private var _homeScale:Number = 1;
		public var editorIsZooming:Boolean=false;
		public var editorIsResizing:Boolean=false;
		public var pointIsDragged:Boolean=false;
		public var draggedSegment:Segment;
		public var dragDep:Point;
		public var isDrawStep:Boolean = true;
		public var pieceSegmentIsDragged:Boolean=false;
		public var homeSegmentIsDragged:Boolean = false;
		
		private static var _gd:GlobalEventDispatcher = GlobalEventDispatcher.instance;
		
		private static var _self:EditorModelLocator = new EditorModelLocator();
		public static function get instance():EditorModelLocator
		{
			return _self;
		}
		public function EditorModelLocator() 
		{
			if (_self) throw new Error( "Only one instance of EditorModelLocator can be instantiated" ); 
		}
		
		public function reset():void
		{
			_currentScale = defaultScale;
			_prevScale = 1;
			_homeScale = 1;
			zoomRegisterPoint = null;
			pointsVOArr = [];
			_currentFloor = null;
			editorVO = null;
			trace("EditorModelLocator::reset()");
		}
		
		public function get segmentIsDragged():Boolean
		{
			return (draggedSegment != null);
		}
		
		
		// --- Listen for history length
		public function notifyHistoryUpdate():void
		{
			_gd.dispatchEvent(new Event("historyEvent"));
		}
		
		public function addHistoryListener(listener:Function):void
		{
			_gd.addEventListener("historyEvent", listener);
		}
		
		public function removeHistoryListener(listener:Function):void
		{
			_gd.removeEventListener("historyEvent", listener);
		}
		
		//--- command   listeners
		
		public function addNewCommandEventListener(listener:Function):void
		{
			_gd.addEventListener(NewCommandEvent.getType(), listener);
		}
		public function removeNewCommandEventListener(listener:Function):void
		{
			_gd.removeEventListener(NewCommandEvent.getType(), listener);
		}
		public function notifyNewCommandEvent(command:Command):void
		{
			//trace("notifyNewCommandEvent");
			_gd.dispatchEvent(new NewCommandEvent(command));
		}
		
		//--- undo   listeners
		
		public function addUndoMovePointListener(listener:Function):void
		{
			_gd.addEventListener(UndoEvent.getType(), listener);
		}
		public function removeUndoMovePointListener(listener:Function):void
		{
			_gd.removeEventListener(UndoEvent.getType(), listener);
		}
		public function notifyUndoMovePointListener():void
		{
			_gd.dispatchEvent(new UndoEvent());
		}
		
		// ----------  POINTS CHANGE ---------------------
		
		//-----    points move - utilisé en mousemove   ------------------
		
		public function addPointMoveListener(listener:Function):void
		{
			_gd.addEventListener(PointMoveEvent.getType(), listener);
		}
		public function removePointMoveListener(listener:Function):void
		{
			_gd.removeEventListener(PointMoveEvent.getType(), listener);
		}
		public function notifyPointMove(points:Array, dep:Point=null):void
		{
			_gd.dispatchEvent(new PointMoveEvent(points, dep));
		}
		
		//-----    points move start - utilisé quand on commence le drag  de segments et points  au moins pour dans fibre pour supprimer les intesrections avec murs  ------------------
		
		public function addPointMoveStartListener(listener:Function):void
		{
			_gd.addEventListener(PointMoveStartEvent.getType(), listener);
		}
		public function removePointMoveStartListener(listener:Function):void
		{
			_gd.removeEventListener(PointMoveStartEvent.getType(), listener);
		}
		public function notifyPointMoveStart(points:Array):void
		{
			_gd.dispatchEvent(new PointMoveStartEvent(points));
		}
		
		//-----    points move end - utilisé en mouseup while drag de segments et points  au moins pour dans fibre afficher les intesrections avec murs  ------------------
		
		public function addPointMoveEndListener(listener:Function):void
		{
			_gd.addEventListener(PointMoveEndEvent.getType(), listener);
		}
		public function removePointMoveEndListener(listener:Function):void
		{
			_gd.removeEventListener(PointMoveEndEvent.getType(), listener);
		}
		public function notifyPointMoveEnd(points:Array):void
		{
			_gd.dispatchEvent(new PointMoveEndEvent(points));
		}
		
		//-------  utilisé 
		
		public function addPointsVOUpdateListener(listener:Function):void
		{
			_gd.addEventListener(UpdatePointsVOEvent.getType(), listener);
		}
		public function removePointsVOUpdateListener(listener:Function):void
		{
			_gd.removeEventListener(UpdatePointsVOEvent.getType(), listener);
		}
		public function notifyPointsVOUpdate():void
		{
			_gd.dispatchEvent(new UpdatePointsVOEvent());
		}
		
		// --- mode listener
		// deux modes possibles sur Editor: dessin (draw) ou installation (install-connect)
		public function addModeUpdateListener(listener:Function):void
		{
			_gd.addEventListener("modeUpdateEvent", listener);
		}
		public function removeModeUpdateListener(listener:Function):void
		{
			_gd.removeEventListener("modeUpdateEvent", listener);
		}
		public function notifyModeUpdate():void
		{
			_gd.dispatchEvent(new Event("modeUpdateEvent"));
		}
		
		//--- segments movement listeners  ---- non utilisé semble-t-il 
		public function addSegmentMoveListener(listener:Function):void
		{
			_gd.addEventListener(SegmentMoveEvent.getType(), listener);
		}
		public function removeSegmentMoveListener(listener:Function):void
		{
			_gd.removeEventListener(SegmentMoveEvent.getType(), listener);
		}
		public function notifySegmentMove(ids:Array, diffx:int, diffy:int):void
		{
			_gd.dispatchEvent(new SegmentMoveEvent(ids, diffx, diffy));
		}
		
		//--- floor methods
		public function get currentFloor():Floor
		{
			return _currentFloor;
		}
		
		public function get currentFloorId():int
		{
			if(!_currentFloor) return -10;
			return _currentFloor.id;
		}
		/*public function get previousFloor():Floor
		{
			return _previousFloor;
		}
		public function set previousFloor(floor:Floor):void
		{
			_previousFloor = floor;
		}*/
		
		//--- bloc and others methods
		public function get currentMainEntity():MainEntity
		{
			if (currentFloor == null) return null;
			return currentFloor.mainEntity;
		}
		
		public function get currentMainSurface():Surface
		{
			if(!currentMainEntity) return null;
			return currentMainEntity.surface;
		}
		
		public function get currentBlocMaison():Bloc
		{
			if (currentFloor == null) return null;
			return currentFloor.blocMaison;
		}
		
		public function get currentConnectionsLayer():Sprite
		{
			if (currentBlocMaison == null) return null;
			return currentBlocMaison.connectionsLayer;
		}
		
		public function get currentMaisonPieces():Pieces
		{
			if (currentBlocMaison == null) return null;
			return currentBlocMaison.pieces;
		}
		public function get currentMaisonCloisons():Cloisons
		{
			if (currentBlocMaison == null) return null;
			return currentBlocMaison.cloisons;
		}
		public function getFloorById(id:int):Floor
		{
			if (Editor2D.instance) {
				var floors:Floors = Editor2D.instance.floors;
				for (var i:int = 0; i < floors.floorsArr.length; i++)
				{
					var floor:Floor = floors.floorsArr[i];
					if(floor.id == id)
					{
						//AppUtils.TRACE("getFloorById" + floor.id);
						//trace("getFloorById" + floor.id);
						return floor;
					}
				}
			}
			return null;
			//return Editor2D.instance.floors.floorsArr[id];
		}
		public function set currentFloor(floor:Floor):void
		{
			if (_currentFloor == floor) return;
			
			_currentFloor = floor;
			//trace("Model::set currentFloor", _currentFloor)
			notifyFloorChange();
		}
		public function addFloorChangeListener(listener:Function):void
		{
			_gd.addEventListener(ChangeFloorEvent.getType(), listener);
		}
		public function removeFloorChangeListener(listener:Function):void
		{
			_gd.removeEventListener(ChangeFloorEvent.getType(), listener);
		}
		public function notifyFloorChange():void
		{
			_gd.dispatchEvent(new ChangeFloorEvent(_currentFloor));
		}
		
		// --- listeners for floor deletion
		public function notifyFloorDeletion(floor:Floor):void
		{
			_gd.dispatchEvent(new DeleteFloorEvent(floor));
		}
		public function addFloorDeletionListener(listener:Function):void
		{
			_gd.addEventListener(DeleteFloorEvent.getType(), listener);
		}
		public function removeFloorDeletionListener(listener:Function):void
		{
			_gd.removeEventListener(DeleteFloorEvent.getType(), listener);
		}
		
		// --------------- ZOOM EVENT ----------------
		
		public function set currentScale(scale:Number):void
		{
			_prevScale = _currentScale;
			_currentScale = scale;
			editorIsZooming = true;
			//trace("Model::currentScale " + scale)
			notifyZoomEvent(scale);
		}
		
		public function get  currentScale():Number
		{
			return _currentScale;
		}
		
		public function get  prevScale():Number
		{
			return _prevScale;
		}
		
		public function addZoomEventListener(listener:Function):void
		{
			_gd.addEventListener(ZoomEvent.getType(), listener);
		}
		public function removeZoomEventListener(listener:Function):void
		{
			_gd.removeEventListener(ZoomEvent.getType(), listener);
		}
		public function notifyZoomEvent(scale:Number):void
		{
			_gd.dispatchEvent(new ZoomEvent(scale));
		}
		
		// --------------- END ZOOM EVENT ----------------
		
		public function addZoomEndEventListener(listener:Function):void
		{
			_gd.addEventListener(ZoomEndEvent.getType(), listener);
		}
		public function removeZoomEndEventListener(listener:Function):void
		{
			_gd.removeEventListener(ZoomEndEvent.getType(), listener);
		}
		public function notifyZoomEndEvent():void
		{
			editorIsZooming = false;
			_gd.dispatchEvent(new ZoomEndEvent());
		}
		
		// --------------- HOME SCALE EVENT ----------------
		
		public function set homeScale(scale:Number):void
		{
			_homeScale = scale;
			editorIsResizing = true;
			notifyHomeResizeEvent(scale);
		}
		
		public function get  homeScale():Number
		{
			return _homeScale;
		}
		
		public function addHomeResizeEventListener(listener:Function):void
		{
			_gd.addEventListener(HomeResizeEvent.getType(), listener);
		}
		public function removeHomeResizeEventListener(listener:Function):void
		{
			_gd.removeEventListener(HomeResizeEvent.getType(), listener);
		}
		public function notifyHomeResizeEvent(scale:Number):void
		{
			_gd.dispatchEvent(new HomeResizeEvent(scale));
		}
		
		// --------------- END HOME RESIZE EVENT ----------------
		
		public function addHomeResizeEndEventListener(listener:Function):void
		{
			_gd.addEventListener(HomeResizeEndEvent.getType(), listener);
		}
		public function removeHomeResizeEndEventListener(listener:Function):void
		{
			_gd.removeEventListener(HomeResizeEndEvent.getType(), listener);
		}
		public function notifyHomeResizeEndEvent():void
		{
			editorIsResizing = false;
			_gd.dispatchEvent(new HomeResizeEndEvent());
		}
		
		// --- moving piece EndMovingPieceEvent ---
		
		public function addEndMovingPieceEventListener(listener:Function):void
		{
			_gd.addEventListener(EndMovingPieceEvent.getType(), listener);
		}
		public function removeEndMovingPieceEventListener(listener:Function):void
		{
			_gd.removeEventListener(EndMovingPieceEvent.getType(), listener);
		}
		public function notifyEndMovingPieceEvent(piece:PieceEntity):void
		{
			_gd.dispatchEvent(new EndMovingPieceEvent(piece));
		}		
	}
}