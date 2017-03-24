package classes.views.plan 
{
	import classes.commands.fiber.DeleteFiberLineCommand;
	import classes.config.Config;
	import classes.controls.ChangeFloorEvent;
	import classes.controls.CurrentStepUpdateEvent;
	import classes.controls.History;
	import classes.controls.HomeResizeEndEvent;
	import classes.controls.HomeResizeEvent;
	import classes.controls.UpdateEquipementViewEvent;
	import classes.controls.ZoomEndEvent;
	import classes.controls.ZoomEvent;
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	import classes.vo.PointVO;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/*
		Optimisation de code 
		faite le 2aout. Activation de l'écoute du HomeResize, qui avait été supprimée dans la classe Object2D pour
	    FiberLineEntity, nous ne savons pas pourquoi. Peut être à cause du fait qu'avec la molette
	    le zoom n'a pas de endZoom et que du coup on ne pouvait faire apparaître les intersections 
		Or dans la nouvelle interface du plan, on ne peut faire de homeResize que lorsqu'on est dans la section
		modifier le plan, et là les intersections ne sont jamais plus visibles.
	*/
	
	/**
	 * FiberLineEntity  est un Object2D qui se comporte differemment des autres 
	 * dans le sens  où elle n'a pas la même interactivité avec les autres objets du plan<span>, et est ajoutée dans un sprite FiberLineContainer qui est dans le bloc maison de l'étage où est la Livebox.</span>  
	 * <p>la FiberLineEntity comme CloisonEntity n'a pas de surface et n'est pas l'armature d'un bloc.</p> 
	 * Des méthodes sont rajoutées comme principalement 
	 * <ul><li>addEndingSegment qui permet de rajouter un segment à la fin, la fibre se crée donc au tracé point par point. Chaque click dans l'éditeur ajoute un segment en fin de de la fibre.  
	 * de la fibre</li><li>displayIntersectionPoints qui permet d'afficher les points d'intersection de la fibre avec les murs</li></ul>
	 
	 * 
	 * Les coordonnées de ses points sont relatives a l'étage.
	 * Ses points et segments se déplacent comme ceux des cloisons. 
	 * <p>Elle est générée dans la classe FiberLiner</p>
	 * @see classe.view.plan.FiberLiner
	 */
	public class FiberLineEntity extends Object2D 
	{
		
		/**
		 * La fibre est unique, est est générée grâce à la classe FiberLiner. 
		 * @param id inutile
		 * @points  les 2 points créés au premier clic dans l'éditeur lorsqu'on commence le tracé de la Fibre.
		 */
		public function FiberLineEntity(id:int, points:Array) 
		{
			lineWeight = 2;
			doCloseShape = false;
			pointColor = Config.COLOR_ORANGE;
			//pointColor = Config.COLOR_WHITE;
			super(id, points);
			model.addFloorChangeListener(_onFloorChanged);
			applicationModel.addUpdateEquipementListener(_onDeleteLivebox);
			applicationModel.addCurrentStepUpdateListener(onStepUpdate);
		}
		
		override protected function onAdded(e:Event=null):void
		{
			super.onAdded(e);
			onStepUpdate();
			_onFloorChanged();
		}
		
		public function addEndingSegment(point:Point):void
		{
			var firstPoint:PointVO = lastPoint;
			var pointVO:PointVO = addPoint(point);
			addSegment(length - 1, firstPoint, pointVO);
		}
		
		private function _onFloorChanged(e:ChangeFloorEvent=null):void
		{
			visible = (model.currentFloor == floor);
			if (!model.isDrawStep && (model.currentFloor == floor) && (applicationModel.currentStep == ApplicationModel.STEP_FIBER))
			{
				unlock();
				goAtTop();
			}
			else
			{
				lock(true);
				goAtBottom();
			}
		}
		
		override protected function onStepUpdate(e:Event = null):void
		{
			//trace("onStepUpdate" + applicationModel.currentStep, ApplicationModel.STEP_FIBER);
			if (!model.isDrawStep && applicationModel.currentStep == ApplicationModel.STEP_FIBER)
			{
				unlock();
				goAtTop();
			}
			else
			{
				lock(true);
				goAtBottom();
			}
		}
		
		public function get container():Sprite
		{
			return parent as Sprite;
		}
		
		public function goAtTop():void
		{
			if(!stage) return;
			var fiberLineContainer : Sprite = parent as Sprite;
			blocMaison.setChildIndex(fiberLineContainer, blocMaison.numChildren - 1);
		}
		
		public function goAtBottom():void
		{
			if(!stage) return;
			var fiberLineContainer : Sprite = parent as Sprite;;
			var bloc:Bloc = fiberLineContainer.parent as Bloc;
			var index:int = bloc.getChildIndex(bloc.obj2D);
			bloc.setChildIndex(fiberLineContainer, index + 1);
		}
		
		public function removeFiberLine():void
		{
			new DeleteFiberLineCommand(this).run();
		}
		
		private function _onDeleteLivebox(e:UpdateEquipementViewEvent):void
		{
			if (e.item.type === "LiveboxItem" && e.action === UpdateEquipementViewEvent.ACTION_DELETE) {
				removeFiberLine();
			}
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
		
		public function displayIntersectionPoints():void
		{
			for (var i:int=0; i < segmentsArr.length; i++)
			{
				var segment:Segment = segmentsArr[i] as Segment;
				segment.hitSegmentsTest();
			}
		}
		
		public function clearIntersectionPoints():void
		{
			for (var i:int = 0; i < segmentsArr.length; i++)
			{
				var segment:Segment = segmentsArr[i] as Segment;
				segment.clearIntersectionPoints();
			}
		}
		
		override protected function onZoom(e:ZoomEvent=null):void
		{
			var prevScale:Number = model.prevScale;
			var scale:Number = model.currentScale;
			var scaleFactor:Number = scale / prevScale;
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.scale(scaleFactor);
			}
			model.notifyPointMove(pointsVOArr);
			if (!isLocked) clearIntersectionPoints();	
		}
		
		override protected function onEndZoom(e:ZoomEndEvent=null):void
		{
			super.onEndZoom(e);
			if (!isLocked) displayIntersectionPoints();			
			
		}
		
		override protected function _onHomeResize(e:HomeResizeEvent=null):void
		{
			var scale:Number = e.scale;
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.scale(scale);
			}
			model.notifyPointMove(pointsVOArr);
			if (!isLocked) clearIntersectionPoints();	
		}
		
		override protected function onHomeEndResize(e:HomeResizeEndEvent):void
		{
			super.onHomeEndResize(e);
			//if (!isLocked) displayIntersectionPoints();	//commenté le 2aout inutile
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
		
		
		override public function cleanup():void
		{
			model.removeFloorChangeListener(_onFloorChanged);
			applicationModel.removeUpdateEquipementListener(_onDeleteLivebox);
			applicationModel.removeCurrentStepUpdateListener(onStepUpdate);
			for (var i:int = 0; i < pointsVOArr.length; i++)
		    {
				var pointVO:PointVO = pointsVOArr[i];
				pointVO.removeFromAssociatorSegment();
				pointsViewContainer.removePoint(pointVO.pointView);
			}
		}
	}

}