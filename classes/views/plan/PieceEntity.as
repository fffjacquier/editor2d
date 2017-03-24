package classes.views.plan 
{
	import classes.controls.HomeResizeEvent;
	import classes.controls.PointMoveEvent;
	import classes.controls.ZoomEvent;
	import classes.vo.PointVO;
	import flash.geom.Point;
	
	/**
	 *  PieceEntity est la classe de base abstraite de l'architecture des différentes pièces (classe Bloc) de la maison, extérieures ou intérieures, à savoir les balcons et les chambres, de forme libre ou forme rectangulaire.
	 */
	public class PieceEntity extends Object2D 
	{		
		public var doFollow:Boolean = false;
		
		/**
		 * PieceEntity est la classe de base abstraite de l'architecture différentes pièces qui elles sont des Bloc, 
		 * architecture dont les classes sont BalconyEntity pour les balcons et RoomEntity pour les chambres ou pièces à proprement parler.
		 * <p>Elle comporte les méthodes communes aux classe BalconyEntity et RoomEntity qui l'étendent.</p>		 
		 * <p>L'ajout des balcons, et du concept de pièces à forme rectangulaire, dans l'application, après la création des pièces à forme libre uniquement quelques mois plus tôt explique l'ambiguité entre les noms de classe PieceEntity et RomEntity
		 * Il a fallut garder le nom PieceEntity à cette classe de base pour limiter le temps de développement.</p>
		 * <p>Cette classe gère la création de ces pièces, de forme libre ou la tranformation en forme libre
		 * ou rectangulaire, ajoutées dans un calque Pieces placé dans un bloc dit "maison" ou surface principale.</p>
		 * 
		 * @param id Identifiant numerique non utilisé jusqu'ici, toujours égal à 0. a voir
		 * @param pts Array de points donnant le nombre et les positions des futurs pointVO des entités
		 * @param surfaceType Paramètre permettant dans la fonction addPoint de créer une forme libre ou rectangle
		 * @see #addPoint()
		 */
		public function PieceEntity(id:int, pts:Array, surfaceType:String) 
		{
			//keepShape = true;
			this.surfaceType = surfaceType || Surface.TYPE_FREE;
			doCloseShape = true;
			super(id, pts, surfaceType);
			
			_surface = new Surface(this);			
			addChildAt(surface, 0);
		}
		
		override protected function addPoint(point:Point):PointVO
		{
			if(!isSquare) return super.addPoint(point);
			//trace("isquare " + isSquare);
			
			var pointVO:PointVO = new PointVO(count++, point, this);
			pointsVOArr.push(pointVO);
			
			
			//création d'un pointView et ajout dans PointViewsContainer 
			var pointView:CornerView = new CornerView(pointVO, this);
			pointVO.pointView = pointView;
			pointView.x = pointVO.x;
			pointView.y = pointVO.y;
			pointsViewContainer.addPoint(pointView);	
			//pointVO.stickToGrid();
			return pointVO;
		}
		
		override public function get ownerEntity():Object2D
		{
			var pieces:Pieces = bloc.parent as Pieces;
			if (! pieces) return null;			
			return pieces.mainEntity;
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
				//if (!pointVO.isAssociatedToSegment) 
					pointVO.scale(scaleFactor);
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		override protected function _onHomeResize(e:HomeResizeEvent=null):void
		{
			var scale:Number = e.scale;
			var enlarge:Boolean = (scale > 1);
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				//if (!pointVO.isAssociatedToSegment)
				{
					pointVO.scale(scale);
				}
			}
			model.notifyPointMove(pointsVOArr);
		}
		
		
		public function followMovement(e:PointMoveEvent):void
		{
			translate(e.dep);
		}
		
		override public function cleanup():void
		{
			//trace("pieceEntity cleanup");
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.removeFromAssociator();
				pointsViewContainer.removePoint(pointVO.pointView);
			}
		}
	}
}