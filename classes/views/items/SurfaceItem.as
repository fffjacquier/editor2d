package classes.views.items 
{
	import classes.commands.AddNewSurfaceCommand;
	import classes.resources.AppLabels;
	import classes.views.alert.AlertManager;
	import classes.views.alert.YesNoAlert;
	import classes.views.plan.Bloc;
	import classes.vo.Shapes;
	import classes.vo.ShapeVO;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class SurfaceItem extends DraggableItem
	{
		public var surfaceType:String;
		public function SurfaceItem(/*pid:int*/) 
		{
			type = "surface";
			surfaceType = "free";
			//id = 0;
			super(id, type);
		}
		
		override protected function executeAction():void
		{
			super.executeAction();
			
			Shapes.instance.update();
			
			if (isOverMenu) return;
			
			var bloc:Bloc = isOverBloc();
			/*trace("SurfaceItem::_executeAction() BLOC : " + bloc);
			trace("SurfaceItem::_executeAction() type : " + type)*/
			
			var mousePos :Point = new Point(mouseX, mouseY);
			// update if long and larg have been set in toolbar
			if (this.parent is AccordionItemSurface) {
				/*var lo:Number = Number((this.parent as MenuSurfaceRenderer).longueur);
				var la:Number = Number((this.parent as MenuSurfaceRenderer).largeur);*/
				var lo:Number = Number((this.parent as AccordionItemSurface).longueur.text);
				var la:Number = Number((this.parent as AccordionItemSurface).largeur.text);
				Shapes.instance.update(lo, la);
			}
			
			var points:Array;
			points = (Shapes.instance.blocsMaison[id] as ShapeVO).pointsClone;
			//trace("SurfaceItem:: current floor has maison ?", _model.currentBlocMaison)
			if (_model.currentBlocMaison) 
			{
				var popup:YesNoAlert = new YesNoAlert(AppLabels.getString("alert_surfaceReplaceTitle"), AppLabels.getString("alert_surfaceReplaceQuestion"), _addNewSurface, null, NaN, points);
				AlertManager.addPopup(popup, Main.instance);
				//AppUtils.appXCenter(popup);
			} else {
				new AddNewSurfaceCommand(points).run();
			}
		}
		
		override protected function move(e:MouseEvent=null):void 
		{
			ghost.x = parent.mouseX - ghost.width / 2;
			ghost.y = parent.mouseY - ghost.height / 2;
			overBloc = isOverBloc();
		}
		
		private function _addNewSurface(points:Array):void
		{
			new AddNewSurfaceCommand(points).run();
		}
	}

}