package classes.views.items 
{
	import classes.commands.cloisons.AddCloisonCommand;
	import classes.utils.GeomUtils;
	import classes.views.plan.Bloc;
	import classes.views.plan.CloisonEntity;
	import classes.views.plan.Cloisons;
	import classes.vo.BlocVO;
	import classes.vo.Shapes;
	import classes.vo.ShapeVO;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class CloisonsItem extends DraggableItem
	{
		
		public function CloisonsItem() 
		{
			type = "cloison";
			//id = 0;
			super(id, type);
		}
		
		override protected function createGhost():void
		{
			Shapes.instance.update();
			var points:Array = (Shapes.instance.cloisons[id] as ShapeVO).pointsClone;
				
			var p1:Point = (points[0] as Point) ;
			var p2:Point = (points[1] as Point) ;
			
			ghost = new CloisonEntity(0, points);
			(ghost as CloisonEntity).showMeasures(false);
			parent.addChild(ghost);
			//Editor2D.instance.addChild(ghost);
		}
		
		override protected function move(e:MouseEvent=null):void 
		{
			ghost.x = parent.mouseX
			ghost.y = parent.mouseY;
			overBloc = isOverBloc();
			
			//if(bloc) trace("CloisonsItem::move() BLOC : " + bloc.type);
		}
		
		override protected function isOverBloc():Bloc
		{
			var p:Point = GeomUtils.localToLocal(new Point(mouseX, mouseY), this, Main.instance);
			var i:int;
			var blocs:Array; 
			var bloc:Bloc;
			if (!_model.currentBlocMaison) return null;
			
			blocs = _model.currentMaisonPieces.piecesArr;
			for (i = 0; i < blocs.length ; i++)
			{
				bloc = blocs[i];
				
				if (bloc.hitTestPoint(p.x, p.y, true))
				{
					//trace("DraggableItem::isOver ", bloc.type);
				    return bloc;
				}
			}
			
			blocs = _model.currentFloor.blocs;
			for (i = 0; i < blocs.length ; i++)
			{
				bloc = blocs[i];
				
				if (bloc.hitTestPoint(p.x, p.y, true))
				{
					//trace("DraggableItem::isOver ", bloc.type);
				    return bloc;
				}
			}
			return null;
		}
		
		override protected function executeAction():void
		{
			super.executeAction();
			
			Shapes.instance.update();
			
			var bloc:Bloc = overBloc;
			
			trace("CloisonsItem::_executeAction() BLOC : " + bloc);
			trace("CloisonsItem::_executeAction() type : " + type)
			
			var mousePos :Point = new Point(mouseX, mouseY);
			var p:Point = GeomUtils.localToEditor(new Point(mouseX, mouseY), this);
			
			var points:Array;
			points = (Shapes.instance.cloisons[id] as ShapeVO).pointsClone;
			
			var cloisons:Cloisons;
			if (!bloc) return;
			if (bloc.type == BlocVO.BLOC_JARDIN) return;
			
			
			if (bloc == null) return;
			
			p = GeomUtils.localToLocal(mousePos, this, bloc);
			
			for (var i:int = 0; i < points.length; i++)
			{
				points[i].x += p.x;
				points[i].y += p.y;
			}
			
			new AddCloisonCommand(bloc.cloisons, points).run();
		}
		
	}

}