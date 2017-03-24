package classes.views.equipements 
{
	import classes.config.Config;
	import classes.controls.UpdateEquipementViewEvent;
	import classes.model.EditorModelLocator;
	import classes.views.EquipementsLayer;
	import classes.vo.EquipementVO;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class LiveboxView extends EquipementView 
	{
		private var _startpoint:Point;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _dragging:Boolean = false;
		private var _movingCount:int;
		
		private static var _instance:LiveboxView;
		public static function get instance():LiveboxView
		{ 
			return _instance;
		}
		
		public function LiveboxView(pvo:EquipementVO) 
		{
			if (_instance == null)
			{
				super(pvo);
				_instance = this;
				isConnector = true;
			} else {
				throw new Error("LiveBoxView should be unique!!");
			}
		}
		
		override protected function added(e:Event = null):void 
		{
			super.added(e);
			_appmodel.addUpdateEquipementListener(_update);
			
			//addEventListener(MouseEvent.MOUSE_OVER, over)
			//addEventListener(MouseEvent.MOUSE_OUT, out);
			//trace("LiveboxView::_added", vo);
		}
		
		private function _update(e:UpdateEquipementViewEvent):void
		{
			//trace("LiveboxView::_update");
			if (EquipementsLayer.isThereAConnexionToLivebox()) {
				drawBG(Config.COLOR_CONNEXION_LIVEBOX);
			} else {
				drawBG(Config.COLOR_CONNEXION_NULL);
			}
			
			if (e.action == "delete") {
				var eq:EquipementView = e.item;
				if (eq is WifiDuoView && connexionViewsAssociated.indexOf(eq) != -1) {
					var index:int = connexionViewsAssociated.indexOf(eq);
					connexionViewsAssociated.splice(index, 1);
					//EquipementsLayer.updateEquipementById(uniqueId);
				}
			}
		}
		
		override protected function drawBG(color:Number):void
		{
			/*var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, color, 0);
			g.beginFill(0xffffff, 0);
			g.drawCircle( 0, 0, 32);
			// dessiner un deuxieme contour genre 120%
			g.lineStyle(1, color, 0);
			g.beginFill(0xffffff, 0);
			g.drawCircle(0, 0, 35);*/
			
		}
		
		override protected function mouseUpWhileDrag():void
		{
			super.mouseUpWhileDrag();
			
			//check the distance from the prise
			/*var prisesnum:int = EquipementsLayer.getEquipements(PriseView);
			if (prisesnum == 0) return;
			
			// get the closest prise
			var pv:PriseView = EquipementsLayer.getClosestPrise(this);
			if (pv != null) {
				// check distance d
				var d:Number = pv.getDistance(this);
				if (d > Config.DISTANCE_ETHERNET) {
					var popup:YesAlert = new YesAlert("la Livebox est à plus de 2m de la prise la plus proche. La distance doit être inférieure à 2m.", true, true);
					AlertManager.addPopup(popup, Main.instance);
					AppUtils.appCenter(popup);
				}
			}*/
		}
		
		/*override protected function _onRollOver(e:MouseEvent):void
		{
		}*/
		
		override protected function removed(e:Event):void
		{
			//ApplicationModel.instance.livebox = null;
			super.removed(e);
			_instance = null;
		}
		
		// ------ public methods ------------
		/*public function distancePrise():int
		{
			return getDistance(
		}*/
		
		
		
	}

}