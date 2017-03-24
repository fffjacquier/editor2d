package classes.vo 
{
	import classes.controls.NewCommandEvent;
	import classes.controls.UndoEvent;
	import classes.model.EditorModelLocator;
	import classes.utils.AppUtils;
	import classes.utils.GeomUtils;
	import classes.views.plan.Bloc;
	import classes.views.plan.CloisonEntity;
	import classes.views.plan.Grid;
	import classes.views.plan.Object2D;
	import classes.views.plan.PieceEntity;
	import classes.views.plan.PointView;
	import classes.views.plan.Segment;
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	/**
	 * 
	 * PointVO est la classe représentant les points virtuels délimitant les murs de la maison. 
	 * <p>Elle étend la classe Point, héritant ainsi de ses paramères x et y et toutes ses méthodes de calcul.</p>
	 * <p>Les notifications de PointMoveEvent sont à la base de toutes les changements de forme de la maison.</p>
	 * <p>Les ajouts et suppressions de points dans des segments sont distribués par l'event UpdatePointsVOEvent.</p>
	 * 
	 */	
	public class PointVO extends Point
	{
		public var z:Number = 0;
		
		public var id:int;
		private var _obj2D:Object2D;
		
		public var pointView:PointView;
		public var segments:Array = new Array();
		public var associationFactor:Number;
		public var associatorSegment:Segment;
		public var associatorPoint:PointView;
		public var associatedMeasures:Array = new Array();
		public var translation:Point;
		private var _recPoint:Point;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		
		public function PointVO(id:int,p:Point, obj2d:Object2D) 
		{
			x = p.x;
			y = p.y;
			this.id = id;
			_obj2D = obj2d;
			//trace("PointVO id", id);
			_model.addUndoMovePointListener(_onUndo);
			_model.addNewCommandEventListener(_onNewCommand);
		}
		
		public function get obj2D():Object2D
		{
			return _obj2D;
		}
		
		public function translate(obj:*, dy:Number = 0):void
		{
			if (obj is Point)
			{
				var p:Point = obj as Point
				x += p.x;
				y += p.y;
			}
			else if (obj is Number)
			{
				var dx:Number = obj;
				x += dx;
				y += dy;
			}
		}
		
		public function scale(scaleFactor:Number):void
		{
			x *= scaleFactor;
			y *= scaleFactor;
		}
		
		public function setPos(p:Point):void
		{
			x = p.x;
			y = p.y;
		}
		
		public function setPointPosition(p:Point):void
		{
			/*x = p.x;
			y = p.y;
			return;*/
			if (isAssociatedToSegment)
			{
			    var xPos:Number = x;  
			    var yPos:Number = y;  
				x = p.x;
				y = p.y;
				var factor:Number = Point.distance(associatorSegment.p1, this) / Point.distance(associatorSegment.p2, associatorSegment.p1);
				if (factor >= 1 ||  factor <= 0 || Point.distance(associatorSegment.p2, associatorSegment.p1) == 0)
				{
					x = xPos;
					y = yPos;
				}
				else
				{
					associationFactor = factor;
					//associatedSegment.setAssociatePointPos(this);
				}
			}
			else
			{
				x = p.x;
				y = p.y;
			}
		}
		
		public function setLimitedMagnetPointPosition(point:Point):Boolean
		{
			var p:Point;
			
			if (isAssociatedToSegment)
			{
			    if (associatorSegment.isVertical)
				{
					p = GeomUtils.magnetPointY(point, pointView.parent);
				}
				else if (associatorSegment.isHorizontal)
				{
					p = GeomUtils.magnetPointX(point, pointView.parent);
				}
				else
				{
					p = point;
				}
				
				var xPos:Number = x;  
			    var yPos:Number = y;  
				x = p.x;
				y = p.y;
				var factor:Number = Point.distance(associatorSegment.p1, this) / Point.distance(associatorSegment.p2, associatorSegment.p1);
				trace("factor " + factor);
				var condition:Boolean = isInPiece ? (factor >= 1 ||  factor <= 0 || Point.distance(associatorSegment.p2, associatorSegment.p1) == 0)
												  : (factor > 1  ||  factor < 0  || Point.distance(associatorSegment.p2, associatorSegment.p1) == 0);		
				if (condition)
				{
					trace("factor in inaccecceptable condition" + factor);
					x = xPos;
					y = yPos;
					return false;
				}
				else
				{
					associationFactor = factor;
					trace("in of acceptable factor range")
					return true;
				}
			}
			else
			{
				p = GeomUtils.magnetPoint(point, pointView.parent);
				x = p.x;
				y = p.y;
				return true;
			}
		}
		
		public function setMagnetPointPosition(point:Point):void
		{
			var p:Point;
				 
			if (isAssociatedToSegment)
			{
			    if (associatorSegment.isVertical)
				{
					p = GeomUtils.magnetPointY(point, pointView.parent);
				}
				else if (associatorSegment.isHorizontal)
				{
					p = GeomUtils.magnetPointX(point, pointView.parent);
				}
				else
				{
					p = point;
				}
				
				x = p.x;
				y = p.y;
				associationFactor = Point.distance(associatorSegment.p1, this) / Point.distance(associatorSegment.p2, associatorSegment.p1);
			}
			else
			{
				p = GeomUtils.magnetPoint(point, pointView.parent);
				x = p.x;
				y = p.y;
			}
		}
		
		public function setMagnetPointPositionX(point:Point):void
		{
			var p:Point = GeomUtils.magnetPointX(point, pointView.parent);
			x = p.x;
			y = p.y;
			
			if (isAssociatedToSegment)
			     associationFactor = Point.distance(associatorSegment.p1, this) / Point.distance(associatorSegment.p2, associatorSegment.p1);
		}
		
		public function setMagnetPointPositionY(point:Point):void
		{
			var p:Point = GeomUtils.magnetPointY(point, pointView.parent);
			x = p.x;
			y = p.y;
			
			if (isAssociatedToSegment)
			     associationFactor = Point.distance(associatorSegment.p1, this) / Point.distance(associatorSegment.p2, associatorSegment.p1);
		}
		
		public function stickToGrid():void
		{
			if (! pointView) return;
			if (! pointView.parent) return;
			if (!point) return;
			var p:Point = GeomUtils.magnetPoint(point, pointView.parent);
			//setPointPosition(p);
			setPos(p);
		}
		
		/**
		 * non utilisé. A voulu servir pour les bugs liés à HomeResize
		 * @private
		 */
		public function stickToGridOnResize(enlarge:Boolean, scope:DisplayObjectContainer=null):void
		{
			if (!pointView) return;
			/*trace("point " + point);
			trace("pointView " + pointView);
			trace("pointView.parent " + pointView.parent);*/
			if (!scope) scope = pointView.parent;
			var p:Point = GeomUtils.magnetPointForResize(point, scope, enlarge);
			setPointPosition(p);
		}
		
		public function get point():Point
		{
			return new Point(x, y);
		}
		
		public function get isLocked():Boolean
		{
			return pointView.isLocked;
		}
		
		public function get isActive():Boolean
		{
			if (isInPiece) return false;
			if (pointView.isDragging) return true;
			for (var i:int = 0; i < segments.length; i++)
			{
				var segment:Segment = segments[i];
				if (segment.isDragging) return true;
			}
			return false;
		}
		
		/**
		 * Détermine si ce point est associé à un point ou un segment
		 */
		public function get isAssociatedToMovement():Boolean
		{
			if (!isAssociated) return false;
			if (isAssociatedToSegment && associatorSegment.isDragging) return true;
			if (isAssociatedToPoint && associatorPoint.isDragging) return true;
			return false;
		}
		
		public function dragFriends():void
		{
			trace("dragFriend " + translation);
			//var friends:Array = new Array();
			if (!translation) return;
			if(isNaN(translation.x) || isNaN(translation.y) )return;
			if (!isAssociatedToSegment) return;
			
			for (var i:int = 0; i < segments.length; i++)
			{
				var segment:Segment = segments[i];
				var pointVO:PointVO = segment.getFriend(this);
			    if (!pointVO.isAssociated && !pointVO.pointView.isDragging 
				     && !pointVO.isInDraggingSegment && !pointVO.isLocked
					 && !pointVO.isFiendOfTwoAssociatedPoints()) 
				{
					if (Segment.FRIENDS.lastIndexOf(pointVO) == -1)
					{
						trace("do drag friends")
						Segment.FRIENDS.push(pointVO);
						pointVO.translate(translation);
					}
				}
			}
		}
		
		public function isFiendOfTwoAssociatedPoints():Boolean
		{
			if (segments.length < 2) return false;
			if (isAssociated) return false;
			if (!(segments[0] as Segment).hasAssociatedPoints &&  !(segments[1] as Segment).hasAssociatedPoints)
			    return false;
				
			return true;
		}
		
		public function removeSegment(segment:Segment):void
		{
			var index:int = segments.lastIndexOf(segment);
			segments.splice(index, 1);
		}
		
		public function removeFromAssociatorSegment():void
		{
			if (!associatorSegment) return;
			associatorSegment.removeAssociated(this);
		}
		
		public function get isAssociatedToSegment():Boolean
		{
			return (associatorSegment != null);
		}
		
		public function removeFromAssociatorPoint():void
		{
			if (!associatorPoint) return;
			associatorPoint.removeAssociated(this);
		}
		
		public function removeFromAssociator():void
		{
			if (associatorPoint)
				associatorPoint.removeAssociated(this);
				
			if (associatorSegment) 
				associatorSegment.removeAssociated(this);
		}
		
		public function get isAssociatedToPoint():Boolean
		{
			return (associatorPoint != null);
		}
		
		public function get isAssociated():Boolean
		{
			return (isAssociatedToPoint || isAssociatedToSegment);
		}
		
		public function get associatorPointVO():PointVO
		{
			return associatorPoint.pointVO;
		}
		
		public function get bloc():Bloc
		{
			if (!obj2D.bloc) return null;
			return obj2D.bloc;
		}
		
		
		public function get isInPiece():Boolean
		{
			if (!obj2D) return false;
			return obj2D.inheritFromPieceEntity;
		}
		
		
		public function get isInCloison():Boolean
		{
			if (!obj2D) return false;
			return obj2D is CloisonEntity;;
		}
		
		public function get cloison():CloisonEntity
		{
			if (isInCloison)
				return (obj2D as CloisonEntity);
				
			return null;
			
		}
		
		public function get isFirstPoint(): Boolean
		{
			if (!isInCloison) return false;
			if (!obj2D) return false;
			return obj2D.firstPoint == this;
		}
		
		public function get isLastPoint(): Boolean
		{
			if (!isInCloison) return false;
			if (!obj2D) return false;
			return obj2D.lastPoint == this;
		}
		
		public function get isExtremity():Boolean
		{
			if (!isInCloison) return false; 
			if (isLastPoint || isFirstPoint) return true;
			return false;
		}
		
		public function get isInDraggingSegment():Boolean
		{
			for (var i:int = 0; i < segments.length; i++)
			{
				var segment:Segment = segments[i];
				if (segments[i].isDragging) return true;
			}
			return false;
			
		}
		
		public function testAndFree():void
		{
			var hitSegment:Segment = pointView.detectHitSegment(GeomUtils.localToGlobal(point, pointView.parent));
			//si p1 touche un segment de bloc on l'associe a ce segment 
			if (!hitSegment && isAssociatedToSegment) removeFromAssociatorSegment();
			
			var hitPoint:PointView =  pointView.detectHitPointView(GeomUtils.localToGlobal(point, pointView.parent));
					//si p1 touche un segment de bloc on l'associe a ce segment 
			if (!hitPoint && isAssociatedToPoint) removeFromAssociatorPoint();
			
			
		}
		public function testAndAttachIfHitPoint():Boolean
		{
			if (!pointView.parent) return false;
			var hitPoint:PointView =  pointView.detectHitPointView(GeomUtils.localToGlobal(point, pointView.parent));
					//si p1 touche un segment de bloc on l'associe a ce segment 
			if (hitPoint)
			{
				AppUtils.TRACE("point " + point)
				var dist:Number = Point.distance(point,hitPoint.pointVO.point) ; 
				//AppUtils.TRACE("points dist " + dist)
				if(dist >= Grid.GAP * Grid.MAGNETISM) return false;
				if (isAssociatedToPoint)
					removeFromAssociatorPoint();
				if (isAssociatedToSegment)
					removeFromAssociatorSegment();
				
				hitPoint.pushAssociated(this);
				return true;
			}
			return false;
		}
		
		public function testAndAttachIfHitSegment():Boolean
		{
			if (!pointView.parent) return false;
			var hitSegment:Segment = pointView.detectHitSegment(GeomUtils.localToGlobal(point, pointView.parent));
			//si p1 touche un segment de bloc on l'associe a ce segment 
			if (hitSegment)
			{
				var dist:Number = GeomUtils.distancePointSegment(this, hitSegment) ; 
				//AppUtils.TRACE("point segment dist " + dist);
				if(!isNaN(dist) && dist >=  Grid.GAP * Grid.MAGNETISM) return false;
				
				if (isAssociatedToSegment)
				 removeFromAssociatorSegment();
					
				if (isAssociatedToPoint)
					removeFromAssociatorPoint();
				
				hitSegment.pushAssociated(this);
				return true;
			}
			return false;
		}
		
		public function testAndColorIfHitPoint():Boolean
		{
			var hitPoint:PointView =  pointView.detectHitPointView(GeomUtils.localToGlobal(point, pointView.parent));
					//si p1 touche un segment de bloc on l'associe a ce segment 
			if (hitPoint)
			{
			 pointView.draw(true);
			 return true;
			}
			else
			{
			  pointView.draw();
			  return false;
			}
		}
		
		public function testAndColorIfHitSegment():Boolean
		{
			var hitSegment:Segment = pointView.detectHitSegment(GeomUtils.localToGlobal(point, pointView.parent));
			//si p1 touche un segment de bloc on l'associe a ce segment 
			if (hitSegment)
			{
			  pointView.draw(true);
			  return true;
			}
			else
			{
			  pointView.draw();
			  return false;
			}
		}
		
		public function testAndAttach():Boolean
		{
			removeFromAssociator();
			if (testAndAttachIfHitPoint()) return true;
			if (!isAssociatedToPoint)  
			{
				if (testAndAttachIfHitSegment()) return true;
			}
				
			return false;
		}
		
		private function _onNewCommand(e:NewCommandEvent):void
		{
			if (_recPoint)
			{
				_recPoint = null;
			}
		}
		
		
		private function _onUndo(e:UndoEvent):void
		{
			if (_recPoint)
			{
				setPos(_recPoint);
				_model.notifyPointMove([this]);
				//le setTimeout permet d'attendre que toutes les points et segments soient repositionnés 
				//avant de tester s'ils peuvent s'ssocier à des segments ou points 2aout
				//testAndAttach();
				setTimeout(testAndAttach,100); 
				_recPoint = null;
			}
		}
		
		public function get recPoint():Point
		{
			return _recPoint;
		}
		
		public function registerRecPoint():void
		{
			_recPoint = point;
		}
		
		public function cleanup():void
		{
				_model.removeUndoMovePointListener(_onUndo);
		}
	}

}