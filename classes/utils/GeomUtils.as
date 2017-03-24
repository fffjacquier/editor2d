package classes.utils 
{
	import classes.config.Config;
	import classes.model.EditorModelLocator;
	import classes.views.plan.Bloc;
	import classes.views.plan.CloisonEntity;
	import classes.views.plan.Cloisons;
	import classes.views.plan.Editor2D;
	import classes.views.plan.EditorContainer;
	import classes.views.plan.Floor;
	import classes.views.plan.Grid;
	import classes.views.plan.IntersectionPoint;
	import classes.views.plan.Segment;
	import classes.vo.PointVO;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class GeomUtils 
	{
		public function GeomUtils() 
		{
		}
		
		public static function magnetPoint(point:Point, scope:DisplayObjectContainer):Point
		{
			var p:Point = localToEditor(point, scope);
			var magnetP:Point = p.clone();
			
			var gap:Number = Grid.GAP;
			//trace("GAP" + gap)
			var magnetFactor:Number = gap/2;
			var ecart:Number;
			ecart = magnetP.x % gap;
			if (ecart < magnetFactor || ecart >= gap - magnetFactor) 
			{
				magnetP.x = Math.round(magnetP.x / gap) * gap;
			}
			ecart = magnetP.y % gap;
			if (ecart < magnetFactor || ecart >= gap - magnetFactor) 
			{
				magnetP.y = Math.round(magnetP.y /gap) * gap;
			}
			
			p = localToLocal(magnetP, Editor2D.instance, scope);
			
			return p;
		}
		/**
		 * non utilisé
		 * @private 
		 */
		public static function magnetPointForResize(point:Point, scope:DisplayObjectContainer, enlarge:Boolean):Point
		{
			var p:Point = localToEditor(point, scope);
			var magnetP:Point = p.clone();
			
			var gap:Number = Grid.GAP;
			//trace("GAP" + gap)
			var magnetFactor:Number = gap/2;
			var ecart:Number;
			ecart = magnetP.x % gap;
			if (ecart < magnetFactor || ecart >= gap - magnetFactor) 
			{
				magnetP.x = enlarge ? Math.ceil(magnetP.x / gap) * gap :Math.floor(magnetP.x / gap) * gap;
			}
			ecart = magnetP.y % gap;
			if (ecart < magnetFactor || ecart >= gap - magnetFactor) 
			{
				magnetP.y = enlarge? Math.ceil(magnetP.y /gap) * gap : Math.floor(magnetP.y /gap) * gap;
			}
			
			p = localToLocal(magnetP, Editor2D.instance, scope);
			
			return p;
		}
		
		
		
		public static function magnetPointX(point:Point, scope:DisplayObjectContainer):Point
		{
			var p:Point = localToEditor(point, scope);
			var magnetP:Point = p.clone();
			
			var gap:Number = Grid.GAP;
			//trace("GAP" + gap)
			var magnetFactor:Number = gap/2;
			var ecart:Number;
			ecart = magnetP.x % gap;
			if (ecart < magnetFactor || ecart >= gap - magnetFactor) 
			{
				magnetP.x = Math.round(magnetP.x / gap) * gap;
			}
			p = localToLocal(magnetP, Editor2D.instance, scope);
			
			return p;
		}
		
		public static function magnetPointY(point:Point, scope:DisplayObjectContainer):Point
		{
			var p:Point = localToEditor(point, scope);
			var magnetP:Point = p.clone();
			
			var gap:Number = Grid.GAP;
			//trace("GAP" + gap)
			var magnetFactor:Number = gap/2;
			var ecart:Number;
			ecart = magnetP.y % gap;
			if (ecart < magnetFactor || ecart >= gap - magnetFactor) 
			{
				magnetP.y = Math.round(magnetP.y /gap) * gap;
			}
			
			p = localToLocal(magnetP, Editor2D.instance, scope);
			
			return p;
		}
		
		public static function stickToSegment(point:Point, segment:Segment):Point
		{
			var pointVO:PointVO;
			var p:Point;
			if(point is PointVO)
			{
				pointVO = point as PointVO;
				p = pointVO.point;
			}
			else
			{
				p = point;
			}
			
			var p1:PointVO = segment.p1;
			var p2:PointVO = segment.p2;
			var factor:Number = Point.distance(p1, p) / (Point.distance(p1, p) + Point.distance(p, p2));
			p = Point.interpolate(p2, p1, factor);
			if (segment.isVertical)
			{
				//trace("segment vertical " )
				p = magnetPointY(p, p1.pointView);
				p.x = p1.x;
			}
			else if (segment.isHorizontal)
			{
				//trace("segment horizontal " )
				p = magnetPointX(p, p1.pointView);
				p.y = p1.y;
			}
			else
			{
				//trace("else");
				var pointSeg:Segment;
				if (pointVO)
				{
					//trace("p is PointVO");
					
					for (var i:int = 0; i < pointVO.segments.length; i++)
					{
						pointSeg = pointVO.segments[i];
						if (pointSeg.isQuasiOrtho)
						{
							//trace("quaziOrtho");
							break;
						}
						else 
						{
							pointSeg = null;
						}
					}
					if (pointSeg)
					{
						var y:Number = segment.p2.y;
						var x:Number = segment.p2.x;
						if (pointSeg.isQuasiVertical)
						{
							//trace("quaziVertical");
							
							p.x = magnetPointX(p, p1.pointView).x;
							//p.y = y + Math.atan(segment.angle) * (p.x - x);
							//y = _y1 + Math.atan(theta) * (x - _x1);
						}
						else
						{
							//trace("quaziHorizontal");
							
							p.y = magnetPointY(p, p1.pointView).y;
							//p.x = x + (p.y - y)/ Math.atan(segment.angle);
						}
					}
				}
			}
			
			return p;
		}
		
		// local to Editor2D
		public static function localToEditor(point:Point, scope:DisplayObjectContainer):Point
		{
			var p :Point = localToLocal(point, scope, Editor2D.instance);
			return p;
		}
		
		public static function localToLocal(point:Point, fromScope:DisplayObject, toScope:DisplayObject):Point
		{
			var p :Point = fromScope.localToGlobal(point);
			p =  toScope.globalToLocal(p);
			return p;
		}
		
		public static function localToGlobal(point:Point, fromScope:DisplayObject):Point
		{
			var p :Point = localToLocal(point, fromScope, Main.instance );
			return p;
		}
		
		public static function globalToLocal(point:Point, toScope:DisplayObject):Point
		{
			var p :Point = localToLocal(point, Main.instance, toScope);
			return p;
		}
		
		public static function getGlobalEditorCenter():Point
		{
			var p:Point = new Point(Config.EDITOR_WIDTH / 2 + Config.TOOLBAR_WIDTH, Config.EDITOR_HEIGHT / 2);
			p.x += EditorContainer.instance.x - 20;
			p.y += EditorContainer.instance.y + 10;
			//return p;
			return localToGlobal(p, EditorContainer.instance);
		}
		
		/* ?? */
		public static function setZoomRegisterPoint():void
		{
 		}
		
		public static function getHittingPoints(p1:Point, p2:Point, scope:Sprite):Array //array of points
		{
			var intersectionPoints:Array = new Array();
			var floor:Floor = EditorModelLocator.instance.currentFloor;
			var sprite:Sprite;
			if(scope is Segment)
			{
				sprite = scope;
				p1 = localToLocal(p1,sprite, sprite);
				p2 = localToLocal(p2, sprite, sprite);
				(sprite as Segment).clearIntersectionPoints();
			}
			else
			{
				sprite = new Sprite();
				sprite.graphics.lineStyle(1,0);
				sprite.graphics.moveTo(p1.x, p1.y);
				sprite.graphics.lineTo(p2.x, p2.y);
				scope.addChild(sprite);
			}
			
			var angle:Number = getAngle(p1, p2);
			
			var segp1:Point;
			var segp2:Point;
			 
			var dict:Dictionary = new Dictionary();
			var p:Point;
			var interPt:IntersectionPoint;
			var intersectionPoint:IntersectionPoint;
			
			for(var i:int = 0; i < floor.blocs.length; i++)
			{			
				var bloc:Bloc = floor.blocs[i];
				var segments:Array = bloc.obj2D.segmentsArr;
				//trace("bloc nb segments : " + segments.length + " " + i + " " + bloc.obj2D); 
				//if (bloc.obj2D is BalconyEntity) continue;
				//trace("\t: " + segments.length + " " + i + " " + bloc.obj2D);
				for (var n:int = 0; n < segments.length; n++)
				{ 
					var segment:Segment = segments[n] as Segment;
					//if((! (sprite is Segment) ||  ! (sprite as Segment).isAdjacentSegment(segment) ) && sprite.hitTestObject(segment))
					if( sprite.hitTestObject(segment))
					{
						segp1  = localToLocal(segment.p1, segment, sprite);
						segp2  = localToLocal(segment.p2, segment, sprite);
						p = intersection(p1, p2, segp1, segp2);
						//trace("bloc " + segment  +  " " + segp1 + " " + segp2);
						if(p)
						{
							//trace("p", p);
							
							if(!dict[p.toString()])
							{
								intersectionPoint = new IntersectionPoint(sprite, p, angle, segment);
								dict[p.toString()] = intersectionPoint;
								intersectionPoints.push(intersectionPoint);
							}
							else
							{
								interPt = dict[p.toString()] as IntersectionPoint;
								if (interPt.mur.murPorteur)
								{
									//on ne fait rien a n'ajoute pas le point on garde l'autre 
								}
								else if(segment.murPorteur)
								{
									//on remplace le précedent par celui ci 
									interPt.remove();
									var index:int = intersectionPoints.indexOf(interPt);
									//intersectionPoints.splice(index, 1);
									intersectionPoint = new IntersectionPoint(sprite, p, angle, segment);
									dict[p.toString()] = intersectionPoint;
									intersectionPoints.splice(index,1, intersectionPoint);
								}
								else
								{
									//on ne fait rien 
								}
								
							}
							
						}
					}
				}

					
				var cloisons:Cloisons = bloc.cloisons;
				for (var k:int = 0; k < cloisons.numChildren; k++) {  
					var cloison:CloisonEntity = cloisons.getChildAt(k) as CloisonEntity;
					segments = cloison.segmentsArr;
					//trace("cloison nb segments : " + segments.length); 
					for (n = 0; n < segments.length; n++) { 
						segment = segments[n] as Segment;
						
						//if((! (sprite is Segment) ||  ! (sprite as Segment).isAdjacentSegment(segment) ) && sprite.hitTestObject(segment))
						if(sprite.hitTestObject(segment))
						{
							segp1  = localToLocal(segment.p1.point, segment, sprite);
							segp2  = localToLocal(segment.p2.point, segment, sprite);
							p = intersection(p1, p2, segp1, segp2);
							
							if(p)
							{
								//trace(p);
								
								if(!dict[p.toString()])
								{
									intersectionPoint = new IntersectionPoint(sprite, p, angle, segment);
									dict[p.toString()] = intersectionPoint;
									intersectionPoints.push(intersectionPoint);
								}
								else
								{
									interPt = dict[p.toString()] as IntersectionPoint;
									if (interPt.mur.murPorteur)
									{
										//on ne fait rien a n'ajoute pas le point on garde l'autre 
									}
									else if(segment.murPorteur)
									{
										//on remplace le précedent par celui ci 
										interPt.remove();
										index = intersectionPoints.indexOf(interPt);
										//intersectionPoints.splice(index, 1);
										intersectionPoint = new IntersectionPoint(sprite, p, angle, segment);
										dict[p.toString()] = intersectionPoint;
										intersectionPoints.splice(index,1, intersectionPoint);
									}
									else
									{
										//on ne fait rien 
									}
									
								}
							}
						}
					}
				}  
			}
			/*trace("-----------------------------------");
			//trace("distance " + Measure.pixelToMetric(Point.distance(p1, p2)));
			trace(intersectionPoints.length + " murs traversés");*/
			var mursPorteursCount:int = 0;
			for(i = 0; i< intersectionPoints.length; i++)
			{
				var intersection:IntersectionPoint = intersectionPoints[i];
				if(intersection.mur.murPorteur) mursPorteursCount++;
			}
			//trace("Nombre de murs porteurs " + mursPorteursCount);
			if(!(sprite  is Segment)) scope.removeChild(sprite);
			return intersectionPoints;
		}
		
	
		
		public static function getAngle(p1:Point, p2:Point):Number
		{
			 return Math.atan2(p2.y - p1.y, p2.x - p1.x);
		}
		
		public static function getDegreeAngle(p1:Point, p2:Point):Number
		{
			return getAngle(p1, p2) * 180 / Math.PI;
		}
		
		public static function getPente(p1:Point, p2:Point):Number
		{
			return (p2.y - p1.y) / (p2.x - p1.x);
		}
		
		public static function intersectionLinePlane(p1:Point, p2:Point, zValue:int):Point
		{
			//horirontal lane  equation: z=zValue
			var z:Number;
			z = zValue;
			return new Point(0,0);
		}
		
		public static function intersection(p1:Point, p2:Point, q1:Point, q2:Point):Point
		{
			//2 droite verticales -> pas d' intersection
			if((p1.x == p2.x)&& (q1.x == q2.x) ) return null;
			
			//q1 et q2 confondus  et p1 et p2 confondus 
			if(p1.equals(p2) && q1.equals(q2))
			{
				if(p1.equals(q1)) return p1;
				return null;
			}
			
			//p1 et p2 distincts mais q1 et q2 confondus : 
			if(!p1.equals(p2) && q1.equals(q2))
			{
				//test if q1 est entre p1 et p2
				var offset:Number = Math.abs(Point.distance(p1,q1) + Point.distance(q1, p2) - Point.distance(p1,p2)) ; 
				if(offset == 0) return q1;
				
				return null;
			}
			
			var pPente:Number = getPente(p1, p2);
			var qPente:Number = getPente(q1, q2);
			
			//formules
			//p.y  = pPente * (p.x -p1.x) + p1.y; 
			//p.y  = qPente * (p.x -q1.x) + q1.y; 
			
			var p:Point = new Point();
			
			//droite paralleles ou confondues -> pas d'intersection
			if(pPente == qPente) return null;					
			
			if(p1.x == p2.x) 
			{
				//droite p1 p2 verticale
				p.x = p1.x;
				p.y  = qPente * (p.x -q1.x) + q1.y; 			
			}			
			
			else if(q1.x == q2.x) 
			{
				//droite q1 q2 verticale
				p.x = q1.x;
				p.y  = pPente * (p.x -p1.x) + p1.y; 
					
			}
			else
			{
				p.x  = (pPente * p1.x - qPente * q1.x - p1.y + q1.y) / (pPente - qPente); 
				p.y  = qPente * (p.x -q1.x) + q1.y; 
			}
			
			if(!isBetweenPoints(p, p1, p2) || !isBetweenPoints(p, q1, q2)) return null;
			return p;
		}
		
		public static  function isBetweenPoints(p:Point, p1:Point, p2:Point):Boolean
		{
			return (Math.abs(Point.distance(p1, p)) + Math.abs(Point.distance(p, p2)) < Math.abs(Point.distance(p1, p2)) + 1) ;
		}
		
		public static function distancePointSegment(pointVO:PointVO, segment:Segment, p:Point=null, p1:Point=null, p2:Point=null):Number
		{
			if(segment != null)
			{
				p1 = segment.p1;
				p2 = segment.p2;
				p1 = localToGlobal(p1, segment.obj2D);
				p2 = localToGlobal(p2, segment.obj2D);
			}
			
			if(pointVO != null)
			{
				p = localToGlobal(pointVO.point, pointVO.obj2D);
			}
			
			//point aligné au segment
			if(Point.distance(p1, p) + Point.distance(p, p2) == Point.distance(p1, p2)) return 0;
			 
			var a:Number = Math.abs(Point.distance(p1, p));
			var b:Number = Math.abs(Point.distance(p, p2));
			var c:Number = Math.abs(Point.distance(p1, p2));
			//on cherche dans la triangle abc la hauteur du point qui se projette sur le cote c
			//d est une des parties du segment de part et d'autres du projeté, celle contigue à b
			var d:Number = (c*c + b*b -a*a) /(2 *c); 
			var h2:Number = b*b - d*d;
			if(h2 < 0) return NaN;
			return Math.sqrt(h2);
		}		
	}	
}