package classes.views.plan 
{
	import classes.controls.ChangeFloorEvent;
	import classes.controls.History;
	import classes.controls.HomeResizeEndEvent;
	import classes.controls.HomeResizeEvent;
	import classes.controls.ZoomEndEvent;
	import classes.controls.ZoomEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.GeomUtils;
	import classes.vo.PointVO;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	
	/*  Optimisation de code
		supprimer variable inutiles mentionnées, ou alors les utiliser.
		Leur utilisation permettrait se supprimer une série de if lors du draw de pointview, 
		mais du coup le code permettant de changer le design des points sera éparpillé dans lesdifférents classes. A choisir... 
	 
		Optimisation du fonctionnement	
		
	*/
	
	/**
	 * <p>Classe de base des différents objets articulés du plan, à savoir cloisons, fibre ou architecture des surfaces.</p>
	 * <p>Il se compose de segments, points, et éventuellement surface dans le cas des blocs. 
	 * Il est l'élément de base de l'architecture de la maison, dessinant tous ses murs</p>
	 */
	public class Object2D extends Sprite
	{		
		private var _id:int;
		protected var originalPoints:Array;
		public var surfaceType:String;
		
		/**
		 * dans chaque sous classe : il s'agit de la largeur des segments, utilisée dans la méthode Segment::draw
		 */
		protected var lineWeight:int;
		
		public var pointColor:int;
		/**
		 * Indique si l'objet est fermé, cas des surfaces, ou ouvert, cas des cloisons et de la fibre.
		 */
		protected var doCloseShape:Boolean;
		protected var _surface:Surface;
		protected  var _floor:Floor;
		
		//non utilisé  à supprimer ici et ds les sous classes
		/**
		 * @private
		*/
		protected var _colorSurface:int;
		/**
		 * @private
		 */
		protected var _alphaSurface:int;
		/**
		 * @private
		 */
		protected var radius:int;
		
		
		public var measuresContainer:MeasuresContainer;
		public var pointsViewContainer:PointViewsContainer;
		public var segmentsContainer:Sprite;
		
		public var segmentsArr:Array = new Array();
		public var pointsVOArr:Array = new Array();
		
		/**
		 * Permet d'affecter un identifiant aux points
		 */
		protected var count:int;
		
		public var dontGlue:Boolean = false;
		public var keepShape:Boolean = false;
		public var isLocked:Boolean = false;
		
		
		protected var model:EditorModelLocator = EditorModelLocator.instance;
		protected var applicationModel:ApplicationModel = ApplicationModel.instance;
		
		/*  Optimisation de code
			renommer surfaceType en _surfaceType et la mettre en privé
			ajouter var surfaceType en getter public 
		
			Optimisation du fonctionnement	
		*/
		
		
		/**
		 * <p>Object2D est la classe de base des différents objets polygones constituant le plan.</p>
		 * <p>Object2D étend Sprite, elle est constituée de segments et de points.</p>
		 * <p>Ces objets peuvent être fermés et donc contenir des surfaces ou ouverts, ce sont des cloisons ou la fibre.</p>
		 * <p>Les objets fermés sont contenus dans des blocs qui eux peuvent contenirs blocs, cloisons ou la fibre.</p> 
		 * <p>Les objets ouverts sont soit des cloisons, ajoutés dans une classe cloisons qui étend Sprite 
		 * soit la fibre, contenue dans un Sprite fiberLineContainer, dans le bloc maison de l'étage où est la livebox</p>
		 * 
		 * @param id Identifiant numerique non utilisé jusqu'ici, toujours égal à 0. a voir
		 * @param pts Array de points donnant le nombre et les positions des futurs pointVO des entités
		 * @param surfaceType La forme libre ou rectangle
		 */
		public function Object2D(id:int, pts:Array, surfaceType:String=null) 
		{
			_id = id;
			this.surfaceType = surfaceType || Surface.TYPE_FREE;
			originalPoints = pts.concat();
			_floor = model.currentFloor;
			measuresContainer = new MeasuresContainer();
			addChild(measuresContainer);
			
			segmentsContainer = new Sprite();
			addChildAt(segmentsContainer, 0);
			
			pointsViewContainer = new PointViewsContainer();
			addChild(pointsViewContainer);
			
			if(stage) onAdded();
			else addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		protected function onAdded(e:Event=null):void
		{
			
			var firstPoint:PointVO = addPoint(originalPoints[0] as Point);
			var prevPoint:PointVO = firstPoint;
			var point:PointVO;
			for (var i:int = 1; i < originalPoints.length; i++)
		    {
				point = addPoint(originalPoints[i] );
				addSegment(i, prevPoint, point);
				prevPoint = point;
			}
			
			if (doCloseShape == true)
			    addSegment(i, prevPoint, firstPoint);
			
			refreshPointVOs();
			
			/*if (!(inheritFromPieceEntity) && !(this is CloisonEntity) && !(this is FiberLineEntity))
			{
				model.notifyPointMove(pointsVOArr);
				setTimeout(bloc.stickToGrid, 400);
				setTimeout(stickToGrid, 400);
			}
			else
			{
				stickToGrid();
			}*/
				
			//pour associer les points qui l'étaient lors de l'enregistrement 
			//ou en relachant un item de cloison ou piece
			if(inheritFromPieceEntity) keepShape = true;
			testAndAttachPoints();
			if(inheritFromPieceEntity) keepShape = false;

			model.addZoomEventListener(onZoom);
			model.addZoomEndEventListener(onEndZoom);
			// commenté le 2aout, pourquoi empecher les homeResize de la fibre? 
			//if(! (this is FiberLineEntity))
			{
				
				model.addHomeResizeEventListener(_onHomeResize);
				model.addHomeResizeEndEventListener(onHomeEndResize);
			}
			//applicationModel.addCurrentStepUpdateListener(onStepUpdate);
			model.addModeUpdateListener(onStepUpdate);
			onStepUpdate();//FJ -- 18/10/2012
			model.addFloorChangeListener(onFloorUpdate);
			onFloorUpdate();//FJ -- 02/07/2012 14:38
			//_onZoom();
			addEventListener(Event.REMOVED_FROM_STAGE, _onRemove);
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		protected function onZoom(e:ZoomEvent=null):void
		{
			var prevScale:Number = model.prevScale;
			var scale:Number = model.currentScale;
			var scaleFactor:Number = scale / prevScale;
			//trace("init zoom " + scaleFactor);
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.scale(scaleFactor);
				//pointVO.stickToGrid();
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		protected function onEndZoom(e:ZoomEndEvent=null):void
		{
			stickToGrid();
		}
		
		private var _enlarge:Boolean = false;
		protected function _onHomeResize(e:HomeResizeEvent=null):void
		{
			var scale:Number = e.scale;
			_enlarge = (scale > 1);
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.testAndFree();
				pointVO.scale(scale);
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		protected function onHomeEndResize(e:HomeResizeEndEvent):void
		{
			stickToGrid();
			testAndAttachPoints();
			//if (_enlarge) stickToGridEnlarge(_enlarge);
			//else stickToGrid();
		}
		
		protected function onFloorUpdate(e:ChangeFloorEvent = null):void
		{
			if(floor == model.currentFloor)
			{
				if (model.isDrawStep) unlock(true);
				else lock(true);
			}
		}
		
		protected function onStepUpdate(e:Event = null):void
		{
			if (model.isDrawStep)
			{
			    if(floor == model.currentFloor) unlock(true);
			}
			else
			{
			   lock(true);
			}
		}
		
		public function get firstPoint(): PointVO
		{
			if (!this is CloisonEntity) return null;
			return pointsVOArr[0];
		}
		
		public function get lastPoint(): PointVO
		{
			if (surface) return null;
			return pointsVOArr[length - 1];
		}
		
		public function get length():int
		{
			return pointsVOArr.length;
		}
		
		public function get surface():Surface
		{
			return _surface;
		}
		
		public function get floor():Floor
		{
			return _floor;
		}
		
		//sprite par rapport auquel sont calculées les coordonnées de poiins
		public function get referent():Sprite
		{
			return bloc;
		}
		
		public function get blocMaison():Bloc
		{
			return _floor.blocMaison;
		}
		
		protected function addPoint(point:Point):PointVO
		{
			//création d'un pointVO et ajout dans pointsVOArr
			//point = GeomUtils.magnetPoint(point , pointsViewContainer);
			var pointVO:PointVO = new PointVO(count++, point, this);
			pointsVOArr.push(pointVO);
			
			
			//création d'un pointView et ajout dans PointViewsContainer 
			var pointView:PointView = new PointView(pointVO, this);
			pointVO.pointView = pointView;
			pointView.x = pointVO.x;
			pointView.y = pointVO.y;
			pointsViewContainer.addPoint(pointView);	
			//pointVO.stickToGrid();
			return pointVO;
		}
		
		private function _addNewPointAt(index:int, point:Point):PointVO
		{
			//création d'un pointVO et ajout dans pointsVOArr
			var newPoint:PointVO = new PointVO(index, point, this);
			addPointVOAt(index, newPoint);
			
			//création d'un pointView et ajout dans PointViewsContainer 
			var pointView:PointView = new PointView(newPoint, this);
			newPoint.pointView = pointView;
			pointView.x = newPoint.x;
			pointView.y = newPoint.y;
			pointsViewContainer.addPoint(pointView);
			refreshPointVOs();
			return newPoint;
		}
		
		public function insertTwoPoints(segment:Segment, p:Point ):Array
		{
			var p1:PointVO = segment.p1;
			var p4:PointVO = segment.p2;
			var recPoint:Point = p4.point;
			
			var T:Point = Point.polar(20, segment.perpendicularAngle);
			var index:int = segmentsArr.indexOf(segment);
			var id:int = p1.id + 1;
			var p2:PointVO = _addNewPointAt(id, p);
		    p2.stickToGrid();
			addSegment(1000, p1, p2, index);
			id = p2.id + 1;
			var p3:PointVO = _addNewPointAt(id, p);
			p3.translate(T.x, T.y);
			p4.translate(T.x, T.y);
			p3.stickToGrid();
			p4.stickToGrid();
			addSegment(1001, p2, p3, index+1);			
			addSegment(1002, p3, p4, index+2);
			removeSegment(segment);
			model.notifyPointMove([p2,p3, p4]);
			testAndAttachPoints();
			return [p2, p3, p4, recPoint];
		}
		
		public function insertOnePoint(segment:Segment, p:Point ):PointVO
		{	
			var p1:PointVO = segment.p1;
			var p3:PointVO = segment.p2;
			p = GeomUtils.magnetPoint(p, p1.pointView);
			var id:int = p1.id + 1;
			var p2:PointVO = _addNewPointAt(id, p);
			//trace("Object2d::insertOnPoint() id:", p2.id);
			var T:Point = Point.polar(10, segment.perpendicularAngle);
			p2.translate(T.x, T.y);
			var index:int = segmentsArr.indexOf(segment);
			addSegment(1000, p1, p2, index);				
			addSegment(1002, p2, p3, index + 1);	
			removeSegment(segment);			
			model.notifyPointMove([p2]);
			testAndAttachPoints();
			return p2;
		}
		
		public function removePoint(p:PointVO):Segment
		{
			var p1:PointVO;
			var p2:PointVO;
			var segment1:Segment = p.segments[0];
			var segment2:Segment = p.segments[1];
			if (p == segment1.p1)
			{
				p1 = segment2.p1;
				p2 = segment1.getFriend(p);
			}
			else if (p == segment1.p2)
			{
				p1 = segment1.p1;
				p2 = segment2.getFriend(p);
			}

			removeSegment(segment1);
			removeSegment(segment2);
			pointsViewContainer.removePoint(p.pointView);			
			removePointVOAt(p.id);	
			var segment:Segment = addSegment(1000, p1, p2);	
			return segment;
		}
		
		/* Les points correspondent à l'array de PointVO
		* elle sert pour cloner les objets qui étendent objet2D (MainEntity, CloisonEntity)
		* parce qu'un Objet2D se crée à partir de simples Point(s) */
		public function get points():Array
		{
			var arr:Array = new Array();
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				arr.push(pointVO.point);
			}
			if (arr.length == 0) return originalPoints;
			return arr;
		}
		
		public function removeSegment(segment:Segment):void
		{
			var index:int = segmentsArr.lastIndexOf(segment);
			if (index == -1) return;
			segmentsArr.splice(index, 1);
			segmentsContainer.removeChild(segment);
		}
		
		
		protected function addSegment(i:int, p1:PointVO,  p2:PointVO, index:int = -1):Segment
		{
			var segment:Segment = new Segment(i, p1, p2, this, lineWeight);
			segmentsContainer.addChild(segment);
			if (index == -1)
			{
				segmentsArr.push(segment);
			}
			else
			{
				segmentsArr.splice(index, 0, segment);
			}
			
			return segment;
		}
		
		public function getPointVOAt(i:int):PointVO
		{
			return pointsVOArr[i] as PointVO;
		}
		/**
		 * n'est plus utilisé. Permettrait de changer l'index d'un PointVO
		 * @private
		 */
		public function setPointVOAt(i:int, p:PointVO):void
		{
			//if (i == 0) trace("setPointVOAt", p.xx, p.yy);
			pointsVOArr[i] = p;
			refreshPointVOs();
			model.notifyPointsVOUpdate();
		}
		
		/** 
		 * Needed for undoing the insertOnePoint action 
		 * We have to remove a pointVO without knowing its id
		 */
		public function getPointId(point:Point, segment:Segment):int
		{
			for (var i:int = 0; i < points.length; i++)
		    {
				//trace(i, points[i], point.subtract(Point.polar(-10, segment.perpendicularAngle)));
				if ((points[i].x === point.subtract(Point.polar( -10, segment.perpendicularAngle)).x &&
					points[i].y === point.subtract(Point.polar( -10, segment.perpendicularAngle)).y)) {
					//trace("ok", i);
					return i;
				}
			}
			return -1;
			//return point.id;
		}
		
		//---
		public function addPointVOAt(i:int, p:PointVO):void
		{
			pointsVOArr.splice(i, 0, p);
			refreshPointVOs();
			model.notifyPointsVOUpdate();
		}
		
		public function removePointVOAt(i:int):void
		{
			
			pointsVOArr.splice(i, 1);
			refreshPointVOs();
			model.notifyPointsVOUpdate();
			History.instance.clearHistory();
		}
		
		protected function refreshPointVOs():void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.id = i;
				if (this is CloisonEntity && pointVO.pointView)
				    pointVO.pointView.draw(); 
			}
		}
		
		
		public function hasAssociatedPoint():Boolean
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				if (pointVO.isAssociated) return true;
			}
			return false;
		}
		
		
		
		public function follow(p:PointVO, translatePoint:Point):void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				if (pointVO != p) 
				{
					//pointVO.setPointPosition(pointVO.point.add(translatePoint);
					pointVO.translate(translatePoint);
				}
				
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		public function translate(dep:Point):void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				var p:Point = pointVO.point.add(dep);
				pointVO.translate(dep.x, dep.y);
				//pointVO.stickToGrid();
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		public function stickToGrid():void
		{
			if(isSquare)
			{
				var pointVO:PointVO = pointsVOArr[0];
				var point:Point = pointVO.point;
				pointVO.stickToGrid();
				var dep : Point = pointVO.subtract(point);
				pointVO.setPos(point);
				translate(dep);
			}
			else
			{
				for (var i:int = 0; i < pointsVOArr.length; i++)
			    {
					pointVO = pointsVOArr[i];
					pointVO.stickToGrid();
				}
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		/**
		 * non utilisé
		 * @private 
		*/
		public function stickToGridEnlarge(enlarge:Boolean):void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				//pointVO.stickToGrid();
				pointVO.stickToGridOnResize(enlarge);
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		public function removeAssociatedPoints():void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				if(pointVO.isAssociatedToSegment) pointVO.removeFromAssociatorSegment();
				if(pointVO.isAssociatedToPoint) pointVO.removeFromAssociatorPoint();
			}
		}
		
		public function removeAllAssociations(alsoSegments:Boolean = false, doRegisterRecPoint:Boolean = false):void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				if(doRegisterRecPoint) pointVO.registerRecPoint()
				if(pointVO.isAssociatedToSegment) pointVO.removeFromAssociatorSegment();
				if (pointVO.isAssociatedToPoint) pointVO.removeFromAssociatorPoint();
				if (pointVO.pointView.isAssociator) pointVO.pointView.removeAllAssociatedPoints();
			}
			if (!alsoSegments) return;
			for (i = 0; i < segmentsArr.length; i++)
		    {
				var segment:Segment = segmentsArr[i];
				if (segment.hasAssociatedPoints) segment.removeAssociatedPoints();
			}
			
		
		}
		
		public function testAndAttachPoints():void
		{
			//trace("testAndAttachPoints");
			if (! this is CloisonEntity && ! inheritFromPieceEntity) return;
			if(inheritFromPieceEntity) keepShape = true;
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.testAndAttach();
			}
			if(inheritFromPieceEntity) 
			{
				keepShape = false;
				if(isSquare) adjutSquarePoints();
			}
		}
			
		public function adjutSquarePoints():void
		{
			if (!isSquare) return;
			//trace("adjutSquarePoints");
			var pointVO:PointVO = pointsVOArr[3] as PointVO;
			pointVO.stickToGrid();
			pointVO = pointsVOArr[1] as PointVO;
			pointVO.stickToGrid();
			pointsVOArr[0].x = pointsVOArr[3].x;
			pointsVOArr[2].x = pointsVOArr[1].x;
			pointsVOArr[0].y = pointsVOArr[1].y;
			pointsVOArr[2].y = pointsVOArr[3].y;
		}
		
		public function testAttachedPoints():void
		{
			if (! this is CloisonEntity && ! inheritFromPieceEntity) return;
		
			for (var i:int = 0; i < pointsVOArr.length; i++)
			{
				var pointVO:PointVO = pointsVOArr[i];
				var point:Point = pointVO.point;
				pointVO.testAndAttach();
				if(!point.equals(pointVO.point))
				{
					pointVO.removeFromAssociator();
					pointVO.setPos(point);
				}
			}
			
		}
		
		public function getHitSegment(p:Point):Segment
		{
			for (var i:int=0; i < segmentsArr.length; i++)
			{
				var segment:Segment = segmentsArr[i];
				if (segment.hitTestPoint(p.x, p.y, true))
				{
					return segment;
				}
			}
			return null;
		}
		
		public function getHitPointView(p:Point):PointView
		{
			for (var i:int=0; i < pointsVOArr.length; i++)
			{
				var pointView:PointView = pointsVOArr[i].pointView;
				if (pointView.hitTestPoint(p.x, p.y, true))
				{
					return pointView;
				}
			}
			return null;
		}
		
		public function showMeasures(doShow:Boolean = true):void
		{
			for (var i:int=0; i < segmentsArr.length; i++)
			{
				var segment:Segment = segmentsArr[i];
				segment.showDisplayMeasures(doShow);
			}
		}
		
		
		public function lock(hidePoints:Boolean = false):void
		{
			if (!hidePoints && isLocked) return;
			isLocked = true;
			for (var i:int=0; i < pointsVOArr.length; i++)
			{
				var pointView:PointView = pointsVOArr[i].pointView;
				if(!hidePoints) pointView.isLocked = true;
				else if (hidePoints) pointView.visible = false;
			}
			
			pointsViewContainer.mouseChildren = false;
			//if ( this is CloisonEntity) return;
			for (i=0; i < segmentsArr.length; i++)
			{
				var segment:Segment = segmentsArr[i] as Segment;
				segment.isLocked = true;
				if(this is FiberLineEntity) segment.clearIntersectionPoints();
			}
			segmentsContainer.mouseChildren = false;
			
		}
		
		public function unlock(hidePoints:Boolean = false):void
		{
			if (!isLocked) return;
			isLocked = false;
			for (var i:int=0; i < pointsVOArr.length; i++)
			{
				var pointView:PointView = pointsVOArr[i].pointView;
				pointView.visible = true;
				if(!hidePoints) pointView.isLocked = false;
			}
			
			for (i=0; i < segmentsArr.length; i++)
			{
				var segment:Segment = segmentsArr[i] as Segment;
				segment.isLocked = false;
				if(this is FiberLineEntity) segment.hitSegmentsTest();
			}
			segmentsContainer.mouseChildren = true;
			pointsViewContainer.mouseChildren = true;
		}
	    /** <p>Un pbjet de base du nplan est dit isAssociatedToMovement si au moins l'un de ses pointsest associé
		 * à un point ou un segment quelconque.</p> 
		 * Le savoir permet de garder en mémoire la position de tous les points associés avant le mouvement, pour le undo
		 */
		public function get isAssociatedToMovement():Boolean
		{
			if (isLocked) return false;
			var isAssos:Boolean = false;
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				if (pointVO.isAssociatedToMovement)
				{
					isAssos =  true;
				}
			}
			return isAssos;
		}
		
		public function registerRecPoints():void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.registerRecPoint();
			}	
		}
		
		
		//fir cloisons, returns the bloc in wich cloisons is 
		public function get bloc():Bloc
		{
			if(!(parent is Bloc)) return null
			return (parent as Bloc);
		}
		
		//returns false for cloisons 
		public function get hasBloc():Boolean
		{
			if(!(parent is Bloc)) return false
			return true;
		}
		
		public function get type():String
		{
			return bloc.type;
		}
		
		public function get isSquare():Boolean
		{
			if(!surface) return false;
			return( surfaceType == Surface.TYPE_SQUARE);
		}
		
		public function get inheritFromPieceEntity():Boolean
		{
			return ((this is RoomEntity) || (this is BalconyEntity));
			//return (ObjectUtils.hineritFromClass(this, PieceEntity));
		}
		
		/*
		 * les objects 2D oeuvent etre dans un bloc lui même dans un bloc owner : les pieces entity sont dans la maison principale 
		 * ils peuvent ne pas avoir de bloc mais etre dans un bloc onwer : les cloisons peuvent etre dans la maison principlae ou les poeces
		 * ou ils peuvent ne pas avoir d'owner 
		**/
		public function get ownerEntity():Object2D
		{
			return null;
		}
		
		public function flipTest():Boolean
		{
			if(!isSquare) return true;
			var arr:Array = pointsVOArr.concat();
			if(arr[0].x > arr[1].x) return false;
			if(arr[0].y > arr[3].y) return false;
			return true;
		}
		
		public function cleanup():void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointsViewContainer.removePoint(pointVO.pointView);
			}
			model.removeZoomEventListener(onZoom);
			model.removeZoomEndEventListener(onEndZoom);
			model.removeHomeResizeEventListener(_onHomeResize);
			model.removeHomeResizeEndEventListener(_onHomeResize);
		}
		
		public function remove():void
		{
			if (stage)
			parent.removeChild(this);
		}
		
		public function _onRemove(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, _onRemove);
			cleanup();
		}
	}

}