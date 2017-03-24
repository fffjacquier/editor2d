package classes.views.equipements 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.vo.EquipementVO;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;

	public class PriseView extends EquipementView
	{
		private var _dragHandle:CurseurDeplacement;
		private var _startpoint:Point;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _dragging:Boolean = false;
		private var _movingCount:int;
		
		public function PriseView(pvo:EquipementVO) 
		{
			super(pvo);
			if (ApplicationModel.instance.projectType === "fibre") 
			{
				setConnexion("ethernet");
			}
		}
		
		override protected function drawBG(color:Number):void
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, color);
			g.beginFill(0xffffff, 0);
			//g.drawCircle( 0, 0, 24);
			g.drawRect(-16, -16, 32, 32);
		}
		
		/*override protected function onImageComplete(e:Event):void
		{
			var lodr:LoaderInfo = e.target as LoaderInfo;
			lodr.removeEventListener(Event.COMPLETE, onImageComplete);
			
			var bitmap:Bitmap = lodr.content as Bitmap;
			bitmap.smoothing = true;
			var xscale:Number = 40/bitmap.width;
			var yscale:Number = 36/bitmap.height;
			bitmap.scaleX = xscale;
			bitmap.scaleY = yscale;
			addChild(bitmap);
			bitmap.x = -bitmap.width/2;
			bitmap.y = -bitmap.height / 2;
		}*/
		
		override protected function mouseUpWhileDrag():void
		{
			super.mouseUpWhileDrag();
			/*
			if(vo.name === "priseT") {
				// check the distance from the livebox
				var lb:LiveboxView = EquipementsLayer.getLivebox();
				if (lb == null) return;
				
				var d:Number = this.distanceLivebox();
				if (d > Config.DISTANCE_ETHERNET) {
					var popup:YesAlert = new YesAlert("cette prise est à plus de "+Config.DISTANCE_ETHERNET +"m de la Livebox. La distance doit être inférieure à "+Config.DISTANCE_ETHERNET +"m.", true, true);
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
			super.removed(e);
		}
		
	}

}