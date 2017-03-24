package classes.views.items 
{
	import classes.commands.AddNewSurfaceCommand;
	import classes.utils.GeomUtils;
	import classes.views.plan.Bloc;
	import classes.views.plan.Pieces;
	import classes.views.plan.Surface;
	import classes.vo.Shapes;
	import classes.vo.ShapeVO;
	import flash.geom.Point;
	
	/**
	 * La classe PieceItem est la classe de base des différents types de pièces. Elle hérite de DraggableItem.
	 */
	public class PieceItem extends DraggableItem
	{
		public var surfaceType:String = Surface.TYPE_FREE;
		
		public function PieceItem(id:int, type:String) 
		{
			super(id, type);
			//trace(this + " :: " + type + " :: " + id);
		}
		
		override protected function createGhost():void
		{
			Shapes.instance.update();
			var points:Array = (Shapes.instance.pieces[id] as ShapeVO).pointsClone;
			//trace("id " + id);
			var p1:Point = (points[0] as Point) ;
			var p2:Point = (points[1] as Point) ;
			ghost = new Bloc(type, points,null, surfaceType);
			ghost.addChild(_cursor);
			//(ghost as Bloc).placeDragCursor(_cursor)
			//(ghost as Bloc).isDragging = true;//pour ne pas affciher le menu on mouseup
			//(ghost as CloisonEntity).showMeasures(false);
			parent.addChild(ghost);
		}
		
		override protected function executeAction():void
		{
			if(ghost && ghost.stage) parent.removeChild(ghost);
			ghost = null;
			if (isOverMenu) return;
			
			Shapes.instance.update();
			
			//var bloc:Bloc = isOverBloc();
			
			/*trace("new pieceItem::_executeAction() BLOC : " + bloc);
			trace("very new pieceItem::_executeAction() type : " + type)*/
			
			var mousePos :Point = new Point(mouseX, mouseY);
			var p:Point = GeomUtils.localToEditor(new Point(mouseX, mouseY), this);
			
			var points:Array;
			points = (Shapes.instance.pieces[id] as ShapeVO).pointsClone;
			
			//if (!bloc) return;
			//if (bloc.type != BlocVO.BLOC_MAISON) return;
			var bloc:Bloc = _model.currentBlocMaison;
			var pieces:Pieces = _model.currentMaisonPieces;
		
			p = GeomUtils.localToLocal(mousePos, this, bloc);
			
			
			for (var i:int = 0; i < points.length; i++)
			{
				points[i].x += p.x;
				points[i].y += p.y;
			}
			
			new AddNewSurfaceCommand(points, type, null, null, null, null,surfaceType).run();
		}		
	}
}