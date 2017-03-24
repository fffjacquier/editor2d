package classes.views.plan
{
	import classes.commands.MoveObjPointsCommand;
	import classes.config.Config;
	import classes.utils.GeomUtils;
	import classes.vo.PointVO;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * CornerView, classe étendant PointView, point d'angle spécifique des pièces rectangulaires.
	 */
	public class CornerView extends PointView
	{
		/**
		 * Classe étendant PointView, point d'angle spécifique des pièces rectangulaires.
		 * <p>Les cornerView n'ont pas de menu au click.</p>
		 */
		public function CornerView(p:PointVO, obj:Object2D)
		{
			super(p, obj);
			rotation = 90 * id; 
		}
		
		override public function draw(associationTest:Boolean = false):void 
		{
			var lineWeight:int;
			var radius:int;
			var color:int = 0xcccccc;
			var lineColor:int = 0;
			
			if (_pointVO.isAssociated || associationTest) {
				color = Config.COLOR_POINTS_EXTERNES_INSIDE;//Config.COLOR_YELLOW;
			}
			
			lineWeight = 1;
			graphics.clear();
			var weight:int = 4;
			//graphics.lineStyle(lineWeight, lineColor);
			graphics.beginFill(color);
			graphics.drawRect(-weight/2, - weight/2, 10, 10);
			graphics.drawRect(weight/2, weight/2, 10 - weight, 10 - weight);
			graphics.endFill();			
		}
		
		//------------ MOUSE DOWN ------------
		private var _prevPoint1:Point;
		private var _prevPoint2:Point;
		private var _pVO1:PointVO;
		private var _pVO2:PointVO;
		private var _segment1:Segment;
		private var _segment2:Segment;
		
		override protected function mouseDown():void
		{
			//_movePointCommand = new MovePointCommand(this, _pointVO.point);
			_movePointCommand = new MoveObjPointsCommand(obj2D,obj2D.points);
			obj2D.removeAllAssociations(true, true);
			obj2D.adjutSquarePoints();
			_prevMousePos = new Point(parent.mouseX, parent.mouseY);
			_prevPoint = pointVO.point;			
			var segments:Array = pointVO.segments;
			_segment1 = segments[0];
			_pVO1 = _segment1.getFriend(pointVO);
			_prevPoint1 = _pVO1.point;
			_segment2 = segments[1];
			_pVO2 = _segment2.getFriend(pointVO);			
			_prevPoint2 = _pVO2.point;			
			_count = 0;
			_measuresTimeId = setTimeout(MeasuresContainer.showMeasures,200, true);
		}
		
		//-------------- MOUSE MOVE ----------------
		private var _prevMousePos:Point;
		private var _prevPoint:Point;
		
		override protected function mouseMove():void
		{
			Segment.FRIENDS = new Array();
			_model.pointIsDragged = true;
			//Config.COLOR_ORTHO_SEGMENT = Config.COLOR_POINTS_EXTERIEURS_BALCONERY;
			//trace(this + " " + obj2D + " " + parent)
			if (!parent) return;
			var mousePos:Point = new Point(parent.mouseX, parent.mouseY);
			if (!testPointsDistance(mousePos))  mousePos = _prevMousePos;
			else  _prevMousePos = mousePos;
			
			_count++;
			
			pointVO.removeFromAssociator();
			_pVO1.removeFromAssociator();
			_pVO2.removeFromAssociator();
			
			var p:Point = GeomUtils.magnetPoint(mousePos, parent);
			_pointVO.x = p.x;
			_pointVO.y = p.y;
			
			var prevPos:Point = _pointVO.point;
			var dep:Point = _pointVO.subtract(_prevPoint); 
			
			
			if(_segment1.isQuasiHorizontal)
			{
				_pVO1.translate(0, dep.y);
			}
			else
			{
				_pVO1.translate(dep.x, 0);
			}
			
			
			if(_segment2.isQuasiHorizontal)
			{
				_pVO2.translate(0, dep.y);
			}
			else
			{
				_pVO2.translate(dep.x, 0);
			}	
			
			
			_model.notifyPointMove([_pointVO, _pVO1, _pVO2], dep);
			
			
			if (!testMoveOK())
			{
				_pointVO.setPos(_prevPoint);
				
				//dep = _prevPoint.subtract(_pointVO); 				
				_pVO1.setPos(_prevPoint1);
				_pVO2.setPos(_prevPoint2);
				
				_model.notifyPointMove([_pointVO, _pVO1, _pVO2])	
				return;
			}
			
			_prevPoint = _pointVO.point;			
			_prevPoint1 = _pVO1.point;
			_prevPoint2 = _pVO2.point;
			
		}
		
		
		
		override protected  function mouseUp():void
		{
			clearTimeout(_measuresTimeId);
			if (MeasuresContainer.isON)
			{
				MeasuresContainer.showMeasures(false);
				return;
			}
			//pas de menu
		}
		
		private function testMoveOK():Boolean
		{
			if(!_segment1.isOrtho) return false;
			if(!_segment2.isOrtho) return false;
			if(!obj2D.flipTest()) return false;
			if(!testBlocSizeOk()) return false;
		    return true;
		}
		
	}
}