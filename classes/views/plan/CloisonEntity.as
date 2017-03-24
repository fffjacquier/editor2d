package classes.views.plan 
{
	import classes.commands.cloisons.DeleteCloisonCommand;
	import classes.config.Config;
	import classes.controls.History;
	import classes.controls.HomeResizeEvent;
	import classes.controls.ZoomEvent;
	import classes.vo.PointVO;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/*
		Optimisation de fonctionnement
		Il y a une ambiguite entre cloisons de pieces et de la maison. Il faudrait pouvoir comme pour les équipements
		changer le contenant de la cloison lorsqu'on la déplace d'un bloc à l'autre, par bloc on entend les pièces et le bloc maison. 
		Cela évitera de déplacer une cloison sortie hors d'une pièce avec cette pièce. Autre effet : les cloisons d'un même bloc peuvent 
		se coller entre elles. Or il est impossible de savoir pour un utilisateur dans l'application en l'état quelles cloisons appartiennent
		au même bloc. 
	*/
	
	/**
	 * CloisonEntity, classe étendant Object2D, les cloisons de l'éditeur. 
	 */
	public class CloisonEntity extends Object2D 
	{
		/**
		 * CloisonEntity est un Object2D, polygone non fermé.
		 * <p>Les CloisonEntity n'ont pas de surface et n'ont pas de contenant propre.</p> 
		 * <p>Elles sont ajoutées dans des classe étendant Sprite nommées Cloisons, child direct d'un bloc.</p>
		 * Les coordonnées de leurs points sont relatives a ce bloc, mais elles-même sont toujours en (0, 0) par rapport au bloc  
		 * au deplacement d'une piece qui les contient, elles se déplacent avec la pièce, en réalité ce sont leurs points qui se déplacent. 
		 */
		public function CloisonEntity(id:int, points:Array) 
		{
			lineWeight = 3;
			pointColor = Config.COLOR_POINTS_CLOISONS;
			doCloseShape = false;
			super(id, points);
		}
		
		public function clone():CloisonEntity
		{
			var newPoints:Array = points;
			
			for (var i:int; i < newPoints.length; i++)
			{
				var point:Point = newPoints[i];
				//FJ : ecart augmenté ici car sinon les points se gluent entre eux 26/06
				point.x += 30;//+10
				point.y += 30;
			}
			var cloison:CloisonEntity = new CloisonEntity(1000, newPoints);
			return cloison;
		}
		
		//non utilise
		public function insertPointVO(segment:Segment, p2:PointVO):void
		{
			trace("insertPointVO");
			var p1:PointVO = segment.p1;
			var p3:PointVO = segment.p2;
			var id:int = p1.id + 1;
			addPointVOAt(id, p2);
			//var p2:PointVO = _addNewPointVOAt(id, p);
			addSegment(1000, p1, p2);				
			addSegment(1002, p2, p3);	
			removeSegment(segment);
			
			model.notifyPointMove([p2]);
		}
		
		
		override public function removePoint(p:PointVO):Segment
		{
			trace("cloison length " + pointsVOArr.length);
			
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				//trace(pointVO + " : " + pointVO.id + " : " + pointVO.segments.length);
			}
			
			//trace("p segments length " + p.segments.length);
			if (p.segments.length == 2)
			{
				var seg:Segment = super.removePoint(p);
				return  seg;
			}
			//p has just one segment, c'est une extremité de la cloison 
			var segment:Segment = p.segments[0];
			if (!segment) return null;
			removeSegment(segment);
			pointsViewContainer.removePoint(p.pointView);			
			removePointVOAt(p.id);	
			History.instance.clearHistory();
			return segment;
		}
		
		public function get cloisons():Cloisons
		{
			return parent as Cloisons;
		}
		
		public function backToFront():void
		{
			var index:int = cloisons.getChildIndex(this);
			cloisons.swapChildrenAt(index, cloisons.numChildren -1);
		}
		
		/**
		 * Le bloc dans lequel est la classe Cloisons container de cettte cloison. 
		 */ 
		override public function get bloc():Bloc
		{
			if (!cloisons) return null;
			return cloisons.bloc;
		}
		
		/**
		 * L'object2D ou entité du bloc dans lequel est inséré la cloison.
		*/
		override public function get ownerEntity():Object2D
		{
			if (!bloc) return null;
			return bloc.obj2D;
		}
		
		/**
		 * Sprite par rapport auquel sont calculées les coordonnées de points
		 */
		override public function get referent():Sprite
		{
			if(ownerEntity is MainEntity) return bloc;
			return bloc;
		}
		
		override protected function onZoom(e:ZoomEvent=null):void
		{
			var prevScale:Number = model.prevScale;
			var scale:Number = model.currentScale;
			var scaleFactor:Number = scale / prevScale;
			//trace("init zoom " + scaleFactor);
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				//trace("CloisonEntity zoom i " + i + " " + pointVO.isAssociatedToSegment)
				//if(!pointVO.isAssociatedToSegment) 
				pointVO.scale(scaleFactor);
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		override protected function _onHomeResize(e:HomeResizeEvent=null):void
		{
			//var prevScale:Number = model.prevScale;
			var scale:Number = e.scale;
			var enlarge:Boolean = (scale > 1);
			//var scaleFactor:Number = scale / prevScale;
			//trace("init zoom " + scaleFactor);
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				
				trace("CloisonEntity homeresize i " + i + " " + pointVO.isAssociatedToSegment)
				//if (!pointVO.isAssociatedToSegment)
				{
					pointVO.scale(scale);
					//pointVO.stickToGridOnResize(enlarge, this);
				}
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		public function moveWidthPiece(dep:Point):void
		{
			
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
			    pointVO.removeFromAssociator();
				pointVO.translate(dep);
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		public function removeCloison():void
		{
			new DeleteCloisonCommand(this).run();
		}
		
		override public function cleanup():void
		{
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.removeFromAssociatorSegment();
				pointsViewContainer.removePoint(pointVO.pointView);
			}
		}
	}

}