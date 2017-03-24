package classes.views.plan
{
	import classes.commands.Command;
	import classes.commands.MergeCloisonsCommand;
	import classes.commands.MovePointCommand;
	import classes.config.Config;
	import classes.controls.PointMoveEvent;
	import classes.model.EditorModelLocator;
	import classes.utils.ArrayUtils;
	import classes.utils.GeomUtils;
	import classes.utils.Measure;
	import classes.utils.ObjectUtils;
	import classes.views.menus.MenuFactory;
	import classes.views.menus.MenuRenderer;
	import classes.views.plan.DraggedObject;
	import classes.vo.PointVO;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class PointView extends DraggedObject
	{
		// rollover item
		protected var _dragHandle:DragPointHandle;
		//private var _vo:PointVO;
		protected var _obj2D:Object2D;
		protected var _pointVO:PointVO;
		protected var _model:EditorModelLocator = EditorModelLocator.instance;
		protected var _dragging:Boolean = false;
		protected var _movingCount:int;
		protected var _count:int;
		private var _segmentLocked:Boolean = false ;
		public var associatedPoints:Array = new Array();
		
		public function PointView(p:PointVO, obj:Object2D) 
		{
			super();
			_obj2D = obj;
			_pointVO = p;
			x = _pointVO.x;
			y = _pointVO.y;
			_model.addPointMoveListener(_onPointMove);
		}
		
		override protected function added(e:Event = null):void
		{	
			super.added(e);
			addEventListener(Event.REMOVED_FROM_STAGE, _onRemove);
			
			draw();
			
			// roll over sprite
			_dragHandle = new DragPointHandle(this);
			addChild(_dragHandle);
			//on affiche les poignées à la création du point, sauf pour le ghost créé en draguant la piece de l'accordeon
			//ce ghost n'est pas ajouté au bloc maison donc pour lui obj2D.ownerEntity = null
			if (!((isInCloison || isInPiece) && ! obj2D.ownerEntity)) 
			{
				_dragHandle.scaleX = .5;
				_dragHandle.scaleY = .5;	
				//setTimeout(hideDragHandle, 1000);
				_dragHandle.showHide();
			}
			else 
			{
				_dragHandle.visible = false; 
			}
			addEventListener(MouseEvent.MOUSE_OVER, over)
			addEventListener(MouseEvent.MOUSE_OUT, out);
		}
		
		public function get id():int
		{
			return _pointVO.id;
		}
		
		public function draw(associationTest:Boolean = false):void 
		{
			// à ne pas confondre avec lineWeight renseigné dans objet 2D, largeur des murs
			var lineWeight:int; 
			var radius:int;
			var color:int = _obj2D.pointColor;
			if (pointVO.isExtremity) color = 0xffffff;
			//var lineColor:int = isFiber ? 0x999999 : Config.COLOR_POINTS_EXTERNES_OUTSIDE;
			var lineColor:int = isFiber ? Config.COLOR_WHITE : Config.COLOR_POINTS_EXTERNES_OUTSIDE;
			
			if (isLocked) {
				color = 0;
				lineColor = color;
			}
			if (_pointVO.isAssociated || associationTest) {
				color = Config.COLOR_POINTS_EXTERNES_INSIDE;
			}
			switch(ObjectUtils.getClassName(_obj2D))
			{
				case "MainEntity" :
					lineWeight = 3;
					radius = 6;
					break;
				case "CloisonEntity" :
				case "RoomEntity" :
				case "BalconyEntity" :
					lineWeight = 2;
					radius = 4; //2 + obj2D.pointsVOArr.indexOf(_pointVO);
					break;
				case "DependanceEntity" :
				case "GardenEntity" :
					lineWeight = 3;
					radius = 4;
					break;
				case "FiberLineEntity" :
					lineWeight = 1;
					radius = 4;
					break;
			}
			graphics.clear();
		
			//zone
			//graphics.beginFill(color, 0);
			//graphics.drawCircle( 0, 0, 5);
			graphics.lineStyle(lineWeight, lineColor);
			graphics.beginFill(color);
			graphics.drawCircle( 0, 0, radius);
			graphics.endFill();
		}
		
		private function _onPointMove(e:PointMoveEvent):void
		{
			//trace("_obj2D point " + _obj2D + " isAssociatedToPoint " + isAssociatedToPoint + " isAssociatedToSegment " + isAssociatedToSegment);
			if (!e.points) return;
			if (!_pointVO) return;
			
			if (ArrayUtils.contains(e.points, _pointVO))
			{
				//on replace juste le pointview au dessus de son point s'il bouge
				updatePosition();
			}
			
			//glu sur les points, ne concerne que points de cloisons et pieces
			if (!isInCloison && !isInPiece) return;
			if (_model.editorIsZooming) return;
			if (_model.editorIsResizing) return;
			
			//if (! (!ArrayUtils.contains(e.points, _pointVO) ||  
			//     (_obj2D is PieceEntity && _obj2D.bloc.isDragging && (_obj2D as PieceEntity).dontGlue == false))) return;
			//les points qui bougent ne doivent suivre aucun autre point 
			if (ArrayUtils.contains(e.points, _pointVO)) return;
			
			//si le point est associé à un des points qui bougent (éventuellment point d'un segment qui bouge), il doit suivre ce point 
			if (isAssociatedToPoint && ArrayUtils.contains(e.points, pointVO.associatorPointVO))
			{				
				//trace("followAssociatedPoint");
				if(!isDragging && !_pointVO.associatorPoint.isDragging) followAssociatedPoint();
				return;
			}
			
			var dep:Point = e.dep;
			var segment:Segment = _model.draggedSegment;
			if (!dep || !segment) return;
			
			/*public function set xPos(pos:int):void
			{
				//if(pos < pos4 || pos > pos1) return;
				x = pos;
				var theta:Number = 14 * Math.PI / 180;
				y = _y1 + Math.atan(theta) * (x - _x1);
			}*/
				
			
			//------------------------------------------------------------------------
			//on colle des points que si on est sur un point de cloison non associé, or de la surface de son parent et qui ne bouge pas,
			//et seulement en drag de segment ou de point 
			if (!pointVO.isAssociated) return;
			if (!isInCloison) return;
			
			//trace("bloc " + bloc + " " + hitTestObject(obj2D.bloc.surface));
			
			if (!_model.segmentIsDragged && ! _model.pointIsDragged) return;
			
			//if (_model.pointIsDragged) return;
					
			//les pieces ne doivent pas se recoller tout de suite apres deplacement
			//if (_obj2D is PieceEntity && _obj2D.bloc.isDragging && (_obj2D as PieceEntity).dontGlue) return;
		
			
		/*	if (!pointVO.isAssociatedToPoint)  //ni point ni segment
			{
				pointVO.testAndAttachIfHitPoint();
			}
			
			if (!pointVO.isAssociated)  //ni point ni segment
			{
				pointVO.testAndAttachIfHitSegment();
			}*/
		}
		
		protected function updatePosition():void
		{
			x = _pointVO.x;
			y = _pointVO.y;
		}
		
		protected function over(e:MouseEvent):void
		{
			_dragHandle.visible = true;
			if(_dragHandle.alpha != 1) _dragHandle.alpha = 1;
			_dragHandle.scaleX = _dragHandle.scaleY = 1;
		}
		
		protected function out(e:MouseEvent):void
		{
			if (_dragging) return;
			hideDragHandle();
		}
		
		protected function _onRemove(e:Event):void
		{
			_pointVO.cleanup();
			_pointVO.removeFromAssociator();
			removeAllAssociatedPoints();
			removeEventListener(Event.REMOVED_FROM_STAGE, _onRemove);
			removeEventListener(MouseEvent.MOUSE_OVER, over)
			removeEventListener(MouseEvent.MOUSE_OUT, out);
			_model.removePointMoveListener(_onPointMove);
		}
		
		// ------ public methods ------------
		public function get dragHandle():DragPointHandle
		{
			return _dragHandle;
		}
		
		public function get isCorner():Boolean
		{
			return (this is CornerView);
		}
		
		public function get isAssociatedToSegment():Boolean
		{
			return _pointVO.isAssociatedToSegment;
		}
		
		override public function get isLocked():Boolean
		{
			return _isLocked;
		}
		
		override public function set isLocked(lock:Boolean):void
		{
			if (_isLocked == lock) return;
			_isLocked = lock;
			draw();
			if (lock)
			{
				if (pointVO.isAssociated) pointVO.removeFromAssociator();
			}
			else
			{
				pointVO.testAndAttach();
			}
			
		}
		
		public function setAssociatePointPos(associatedPoint:PointVO):void
		{
			var posPoint:Point =  _pointVO.point;;
			if (associatedPoint.isInPiece  && associatedPoint.obj2D.keepShape)
			{
				//trace("setAssociatePointPos here in point")
				var t:Point = posPoint.subtract(associatedPoint.point);
				associatedPoint.obj2D.translate(t);
				//supprime le 30/05/12  a tester 
				//obj2D.testAttachedPoints();
				//obj2D.testAndAttachPoints()
				return;
			}
			associatedPoint.setPos(posPoint);
			
		}
		
		public function pushAssociated(associatedPoint:PointVO):void
		{
			//associatedPoint.pointView.draw(true);
			//on fait un seul segment de 2 segments qd c'est possible 
			//trace("pushAssociated 00 " + associatedPoint.obj2D);
			if (!associatedPoint.obj2D) return;
			if (_pointVO.isInCloison && associatedPoint.isInCloison && _obj2D.bloc == associatedPoint.obj2D.bloc
			    && _pointVO.isExtremity && associatedPoint.isExtremity)
			{
				//trace("wahou  shouldn't be here !!");
				new MergeCloisonsCommand(_pointVO, associatedPoint).run();
				return;
			}
			var prevPos:Point = associatedPoint.point;
			if (associatedPoint.isAssociatedToSegment) associatedPoint.removeFromAssociatorSegment();
			if (associatedPoint.isAssociatedToPoint) associatedPoint.removeFromAssociatorPoint();
			associatedPoints.push(associatedPoint);
			associatedPoint.associatorPoint = this;
			setAssociatePointPos(associatedPoint);
			//associatedPoint.setPos(pointVO);
			var dep:Point = associatedPoint.subtract(prevPos);
			_model.notifyPointMove([associatedPoint], dep);
			associatedPoint.pointView.draw();
			if (associatedPoint.isInCloison && this.isInCloison)
			{
				associatedPoint.cloison.backToFront();
			}
			
			if (associatedPoint.isInPiece && this.isInPiece)
			{
				associatedPoint.bloc.backToFront();
			}
		}
		
		public function removeAssociated(associatedPoint:PointVO):void
		{
			var index:int = associatedPoints.lastIndexOf(associatedPoint);
			if (index == -1) return;
			
			associatedPoints.splice(index, 1);
			associatedPoint.associatorPoint= null;
			associatedPoint.pointView.draw();
		}
		
		public function removeAllAssociatedPoints():void
		{
			if (! isAssociator) return;
			for (var i:int = 0; i < associatedPoints.length; i++)
			{
				var associatedPoint:PointVO = associatedPoints[i];
				associatedPoint.associatorPoint = null;
				associatedPoint.pointView.draw();
			}
			associatedPoints = new Array();
		}
		
		public function followAssociatedPoint():void
		{
			if (!isAssociatedToPoint) return;
			if (!_pointVO.recPoint) _pointVO.registerRecPoint();
			var prevPos:Point = _pointVO.point;
			_pointVO.setPos(_pointVO.associatorPointVO);
			var dep:Point = _pointVO.subtract(prevPos); 
			_model.notifyPointMove([_pointVO], dep);
		}
		
		public function get isAssociatedToPoint():Boolean
		{
			return _pointVO.isAssociatedToPoint;
		}
		
		public function get isAssociator():Boolean
		{
			return (associatedPoints.length != 0);
		}
		
		//------------ MOUSE DOWN ------------
		protected var _measuresTimeId:int;
		protected var _movePointCommand:Command;
		
		override protected function mouseDown():void
		{
			_movePointCommand = new MovePointCommand(this, _pointVO.point);
			if (!isLocked) pointVO.removeFromAssociator();
			_prevMousePos = new Point(parent.mouseX, parent.mouseY);
			obj2D.adjutSquarePoints();
			_prevPoint = pointVO.point;
			
			_count = 0;
			if(!isFiber) _measuresTimeId = setTimeout(MeasuresContainer.showMeasures,200, true);
		}
		
		// ---- on drag starting ----------		
		override protected function notifyMovementStart():void
		{
			if(isFiber) _model.notifyPointMoveStart([_pointVO]);
		}
		
		//-------------- MOUSE MOVE ----------------
		private var _prevMousePos:Point;
		private var _prevPoint:Point;
		
		override protected function mouseMove():void
		{
			Segment.FRIENDS = new Array();
			_model.pointIsDragged = true;
			
			if (!parent) return;
			//on impose une distance minimale entre 2 points d'un même segment
			var mousePos:Point = new Point(parent.mouseX, parent.mouseY);
			if (!testPointsDistance(mousePos))  mousePos = _prevMousePos;
			     else  _prevMousePos = mousePos;
			
			_count++;
			
			if (isInCloison || (isInPiece && !_segmentLocked ))
			{
				//on decolle le point s'il est collé à un autre point ou d'un segment 
				if (_pointVO.isAssociatedToPoint) 
					_pointVO.associatorPoint.removeAssociated(_pointVO);
				
				if (_pointVO.isAssociatedToSegment) 
					_pointVO.associatorSegment.removeAssociated(_pointVO);
				
				//si le point d'une cloison ou une piece touche un point, on le colle
				var hitPoint:PointView = detectHitPointView(GeomUtils.localToGlobal(mousePos, parent));
				
				if (hitPoint  && _count >=5)
				{
					//trace("hitpoint " + hitPoint);
					if (_pointVO.isAssociatedToPoint) 
						_pointVO.associatorPoint.removeAssociated(_pointVO);
					
					if (_pointVO.isAssociatedToSegment) 
						_pointVO.associatorSegment.removeAssociated(_pointVO);
					
					_pointVO.setPos(mousePos); //ajouté 2aout
					//_pointVO.setPos(stickPoint);
					hitPoint.pushAssociated(_pointVO);
					return;
				}
				
				//si le point d'une cloison ou une piece touche un segment, on le colle
				var hitSegment:Segment = detectHitSegment(GeomUtils.localToGlobal(mousePos, parent));
				if (hitSegment  && _count >=5)
				{
					if (_pointVO.isAssociatedToPoint) 
						_pointVO.associatorPoint.removeAssociated(_pointVO);
					
					if (_pointVO.isAssociatedToSegment) 
						_pointVO.associatorSegment.removeAssociated(_pointVO);
					
					//var stickPoint:Point = GeomUtils.stickToSegment(mousePos, hitSegment, _pointVO);
					_pointVO.setPos(mousePos);
					var stickPoint:Point = GeomUtils.stickToSegment(_pointVO, hitSegment);
					
					if (_pointVO.isAssociatedToSegment) 
					{
						if (hitSegment == _pointVO.associatorSegment)
						{
							
							prevPos = _pointVO.point;
							
							//trace("deplacement de point associé sur un segment");
							_pointVO.setPos(stickPoint);
							hitSegment.setAssociatedPointPos(_pointVO);
							hitSegment.displayMeasuresUpdate();
							dep = _pointVO.subtract(prevPos); 
							_model.notifyPointMove([_pointVO], dep);
							return;
						}
						else
						{
							_pointVO.x = stickPoint.x;
							_pointVO.y = stickPoint.y;
							_pointVO.associatorSegment.removeAssociated(_pointVO);
							hitSegment.pushAssociated(_pointVO);
						}
						
					}
					else 
					{
							if (_pointVO.isAssociatedToSegment) 
								_pointVO.associatorSegment.removeAssociated(_pointVO);
								
							_pointVO.x = stickPoint.x;
							_pointVO.y = stickPoint.y;
							hitSegment.pushAssociated(_pointVO);
					}
				
					//trace("hittest de segment")
					return;
				}
				else
				{
					
					if (_pointVO.isAssociatedToSegment) 
						_pointVO.associatorSegment.removeAssociated(_pointVO);
				}
			}
			var p:Point = GeomUtils.magnetPoint(mousePos, parent);
			_pointVO.x = p.x;
			_pointVO.y = p.y;
			
			var prevPos:Point = _pointVO.point;
			var dep:Point = _pointVO.subtract(_prevPoint); 
			//_model.notifyPointMove([_pointVO], dep);
			
			//_model.notifyPointMove([_pointVO]);
			if(isSegmentLocked)
			{
				var segments:Array = pointVO.segments;
				var segment1:Segment = segments[0];
				var pVO1:PointVO = segment1.getFriend(pointVO);
				var segment2:Segment = segments[1];
				var pVO2:PointVO = segment2.getFriend(pointVO);
				pointVO.removeFromAssociator();
				pVO1.removeFromAssociator();
				pVO2.removeFromAssociator();
				if(segment1.isQuasiHorizontal)
				{
					pVO1.translate(0, dep.y);
				}
				else
				{
					pVO1.translate(dep.x, 0);
				}
				
				
				if(segment2.isQuasiHorizontal)
				{
					pVO2.translate(0, dep.y);
				}
				else
				{
					pVO2.translate(dep.x, 0);
				}
				
				/*if(pointVO == segment1.p1 && pointVO == segment2.p2)
				{
					if(obj2D.pointsVOArr.indexOf(pVO1) < obj2D.pointsVOArr.indexOf(pVO2))
					{
						trace("cas1")
						pVO1.translate(0, dep.y);
						pVO2.translate(dep.x, 0);
					}
					else
					{
						trace("cas2")
						pVO2.translate(0, dep.y);
						pVO1.translate(dep.x, 0);
					}
					
				}
				else if(pointVO == segment2.p1 && pointVO == segment1.p2)
				{
					if(obj2D.pointsVOArr.indexOf(pVO1) < obj2D.pointsVOArr.indexOf(pVO2))
					{
						
						trace("cas3")
						pVO2.translate(0, dep.y);
						pVO1.translate(dep.x, 0);
					}
					else
					{
						trace("cas4")
						pVO1.translate(0, dep.y);
						pVO2.translate(dep.x, 0);
					}
				}
				else
				{
					_model.notifyPointMove([_pointVO], dep);
				}*/
				
				_model.notifyPointMove([_pointVO, pVO1, pVO2], dep);
			}
			else
			{
				_model.notifyPointMove([_pointVO], dep);
			}
			
			if (!testBlocSizeOk())
			{
				_pointVO.setPos(_prevPoint);
				
				dep = _prevPoint.subtract(_pointVO); 
				_model.notifyPointMove([_pointVO], dep);
				return;
			}
			
			_prevPoint = _pointVO.point;
			
		}
		
		public function testPointsDistance(pt:Point):Boolean
		{
			for (var i:int = 0; i < pointVO.segments.length; i++)
			{
				var segment:Segment = pointVO.segments[i];
				var pVO:PointVO = segment.getFriend(pointVO);
				var p1:Point = GeomUtils.localToLocal(pt, parent, EditorBackground.instance);
				var p2:Point = GeomUtils.localToLocal(pVO.point, parent, EditorBackground.instance);
				if (Measure.pixelToMetric(Point.distance(p1, p2)) < .2)
				{
					return false;
				}
			}
			
			return true;
		}
		
		public function testBlocSizeOk():Boolean
		{			
			var bounds:Rectangle;
			
			if (isInHome)
			{
				bounds = _model.currentMainEntity.surface.bg.getBounds(EditorBackground.instance);
				if (Measure.pixelToMetric(bounds.width) < 2 || Measure.pixelToMetric(bounds.height) < 2)
				return false;
			}
			
			if (isInPiece)
			{
				bounds = bloc.surface.bg.getBounds(EditorBackground.instance);
				if (Measure.pixelToMetric(bounds.width) < .8 || Measure.pixelToMetric(bounds.height) < .8)
				return false;
			}
			
			return true;
		}
		
		//---------------- MOUSE UP ------------------
		
		override protected  function mouseUp():void
		{
			clearTimeout(_measuresTimeId);
			if (MeasuresContainer.isON)
			{
				MeasuresContainer.showMeasures(false);
				return;
			}
			//pour réttacher un point qui est détaché au simple click 
			_pointVO.testAndAttach(); //0405
			
			var mousePos:Point = new Point(mouseX, mouseY);
			mousePos = GeomUtils.localToLocal(mousePos, this, EditorContainer.instance);
			
			var menu:MenuRenderer = MenuFactory.createMenu(this, EditorContainer.instance);
		}
			
		override protected  function mouseUpWhileDrag():void
		{
				_model.pointIsDragged = false;
			//Config.COLOR_ORTHO_SEGMENT = 0;
				//_model.notifyPointMove([_pointVO]);
				//fait disparaitre les displayMeasures des segments concernés en fin de mouvement d'un point 
				/*var s1:Segment = _pointVO.segments[0];
				s1.showDisplayMeasures(Editor2D.instance.displayMeasuresCheckBoxValue);
				if (_pointVO.segments.length > 1)
				{
					var s2:Segment = _pointVO.segments[1];
					s2.showDisplayMeasures(Editor2D.instance.displayMeasuresCheckBoxValue);
				}*/
				
				hideDragHandle();
				if (_pointVO.isAssociatedToSegment)
				{
					//var segment:Segment = _pointVO.associatorSegment;
					//segment.draw();
				}
				//attention risque de faire perdre l'orthogonalité en collant sur segments obliques
				if (obj2D.isSquare)
				{
					obj2D.stickToGrid(); 
					obj2D.keepShape = true;
					obj2D.testAndAttachPoints();
					obj2D.keepShape = false;
					obj2D.adjutSquarePoints();
				}
				else
				{
					_pointVO.testAndAttach();
				}
				
				clearTimeout(_measuresTimeId);
				if (MeasuresContainer.isON) MeasuresContainer.showMeasures(false);
				_movePointCommand.run();
				_movePointCommand = null;
				
				if(isFiber) _model.notifyPointMoveEnd([_pointVO]);
				//here test 
				/*for (var i:int = 0; i< segments.length; i++)
				{
					segment = segments[i] as Segment;
					segment.hitSegmentsTest();
				}*/
		}
		
		public function hideDragHandle():void
		{
			if (!_dragHandle) return;
			//if (dragHandle.stage) removeChild(dragHandle);
			//dragHandle = null;
			_dragHandle.visible = false;
			_dragHandle.scaleX = _dragHandle.scaleY = .1;
		}		
		
		public function lockPoint():void
		{
			_isLocked = true;
			//_model.removePointMoveListener(_onPointMove);
			
			draw();
		}
		
		public function unLockPoint():void
		{
			_isLocked = false;
			//_model.addPointMoveListener(_onPointMove);
			draw();
		}
		
		public function get obj2D():Object2D
		{
			return _obj2D;
		}
		
		public function get bloc():Bloc
		{
			return _obj2D.bloc;
		}
		
		public function get isInCloison():Boolean
		{
			return (_obj2D is CloisonEntity);
		}
		
		public function get isInPiece():Boolean
		{
			return (_obj2D.inheritFromPieceEntity);
		}
		
		public function get isInHome():Boolean
		{
			return (_obj2D is MainEntity);
		}
		
		public function get isFiber():Boolean
		{
			return (_obj2D is FiberLineEntity);
		}
		
		public function removePoint():void
		{
			_obj2D.removePoint(_pointVO);
		}
		
		public function get pointVO():PointVO
		{
			return _pointVO;
		}
		
		public function get segments():Array
		{
			return _pointVO.segments;
		}
		
		public function get isAssociated():Boolean
		{
			return _pointVO.isAssociated;
		}
		
		public function get isSegmentLocked():Boolean
		{
			if(!obj2D.surface) return false;
			return _segmentLocked;
		}
		
		//cloisons et pieces
		public function detectHitSegment(globalPoint:Point):Segment
		{
			if (!isInCloison && !isInPiece) return null;
			if (isAssociator) return null;
			//if (isAssociated) return null;
			var ownerEntity:Object2D = _obj2D.ownerEntity;
			if (!ownerEntity) return null;
			var hitSegment:Segment;
			var pieces:Pieces;
			var pieceEntity:PieceEntity
			//var globalPoint:Point = GeomUtils.localToGlobal(p, parent);
			//hit d'un segment du bloc owner
			
			if (ownerEntity.hitTestPoint(globalPoint.x, globalPoint.y, true))
			{
				//trace("ownerEntity hit " + ownerEntity + " " + ownerEntity.segmentsArr);
				hitSegment = ownerEntity.getHitSegment(globalPoint);
				if(hitSegment) return hitSegment;
			}
			//si le point appartient a une cloison, hit d'un segment d'une autre cloison 	
			if (isInCloison)
			{
				if (ownerEntity is MainEntity)
				{
					pieces = ownerEntity.bloc.pieces;
					if (pieces.hitTestPoint(globalPoint.x, globalPoint.y, true))
					{
						pieceEntity = pieces.getHitPiece(globalPoint);
						if (pieceEntity)
						{
							hitSegment = pieceEntity.getHitSegment(globalPoint);
							if(hitSegment) return hitSegment;
						}
					}
				}
				var cloisons:Cloisons = (_obj2D as CloisonEntity).cloisons;
				var hitCloison:CloisonEntity =  cloisons.getHitCloison(globalPoint, _obj2D as CloisonEntity);
				if (hitCloison) {
					hitSegment = hitCloison.getHitSegment(globalPoint);
					if (hitSegment) return hitSegment;
				}
			}
			//hit entre 2 pieces
			/*if (isInPiece)
			{
				
				pieces = _model.currentMaisonPieces;
				if (pieces.hitTestPoint(globalPoint.x, globalPoint.y, true))
				{
					pieceEntity = pieces.getHitPiece(globalPoint);
					if (pieceEntity && pieceEntity != _obj2D)
					{
						hitSegment = pieceEntity.getHitSegment(globalPoint);
						if(hitSegment) return hitSegment;
					}
				}
			}*/
			return null;
		}
		
		//cloisons et pieces
		public function detectHitPointView(globalPoint:Point):PointView
		{
			if (!isInCloison && !isInPiece) return null;
			if (isAssociator) return null;
			if (isAssociatedToPoint) return null;
			var ownerEntity:Object2D = _obj2D.ownerEntity;
			if (!ownerEntity) return null;
			var hitPointView:PointView;
			var pieces:Pieces;
			var pieceEntity:PieceEntity;
			
			
			//var globalPoint:Point = localToGlobal(point);
			//hit d'un segment du bloc owner
			if (ownerEntity.hitTestPoint(globalPoint.x, globalPoint.y, true))
			{
				//trace("ownerEntity hit " + ownerEntity + " " + ownerEntity.segmentsArr);
				hitPointView = ownerEntity.getHitPointView(globalPoint);
				
				if (hitPointView) 
				{
					//trace("hitPointView");
					if (hitPointView.pointVO.isAssociated) return null;
					return hitPointView;
				}
			}
			//si le point appartient a une cloison de maison, hit d'un pointview d'une autre piece 	
			if (isInCloison)
			{
				if (ownerEntity is MainEntity)
				{
					pieces = ownerEntity.bloc.pieces;
					if (pieces.hitTestPoint(globalPoint.x, globalPoint.y, true))
					{
						pieceEntity = pieces.getHitPiece(globalPoint);
						if (pieceEntity)
						{
							hitPointView = pieceEntity.getHitPointView(globalPoint);
							if (hitPointView) 
							{
								if (hitPointView.pointVO.isAssociated) return null;
								return hitPointView;
							}
						}
						
					}
				}
				
				//2 cloisons
				var cloisons:Cloisons = (_obj2D as CloisonEntity).cloisons;
				var hitCloison:CloisonEntity =  cloisons.getHitCloison(globalPoint, _obj2D as CloisonEntity);
				if (hitCloison && hitCloison != _obj2D) {
					hitPointView = hitCloison.getHitPointView(globalPoint);
					if (hitPointView) 
					{
						if (hitPointView.pointVO.isAssociated) return null;
						return hitPointView;
					}
				}
			}
			//2 pieces entre elles
			/*if (isInPiece)
			{
				pieces = _model.currentMaisonPieces;
				if (pieces.hitTestPoint(globalPoint.x, globalPoint.y, true))
				{
					pieceEntity = pieces.getHitPiece(globalPoint);
					if (pieceEntity && pieceEntity != _obj2D)
					{
						hitPointView = pieceEntity.getHitPointView(globalPoint);
						if (hitPointView) 
						{
							if (hitPointView.pointVO.isAssociated) return null;
							return hitPointView;
						}
					}
				}
			}*/
			return null;
		}
				
		
		// ------ end of public methods ------------
		
	}

}