package classes.views.plan 
{
	import classes.controls.ResizeMaskEvent;
	import classes.controls.ZoomEvent;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	/**
	 * Echelle, élément graphique indiquant l'échelle du plan.
	 */
	public class Echelle extends Sprite 
	{
		private var _shape:Sprite;
		private var _measureTf:CommonTextField;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _xPos:int;
		
		
		/**
		 * Echelle, élément graphique indiquant l'échelle du plan en fonction du zoom. 
		 * <p>Ajoutée dans la classe Navigator</p>
		 */
		public function Echelle() 
		{
			var titleTf:CommonTextField = new CommonTextField("helvetBold", 0x999999, 11);
			titleTf.setText(AppLabels.getString("editor_scale"));
			_shape = new Sprite();
			_shape.x = titleTf.textWidth + 10;
			_shape.y = 6;
			_measureTf = new CommonTextField("helvetBold", 0x999999, 11);
			_measureTf.autoSize = "left";
			_measureTf.setText("1m");
			
			addChild(titleTf);
			addChild(_shape);
			addChild(_measureTf);
			
			//ApplicationModel.instance.addResizeMaskUpdateListener(_onEditorMaskResize);
			_onEditorMaskResize();
			
			_model.addZoomEventListener(_onZoom);
			_onZoom();
		}
		
		private function _onZoom(e:ZoomEvent=null):void
		{
			var g:Graphics = _shape.graphics;
			g.clear();
			g.beginFill(0x464646, 1);
			g.drawRect(0, 0, Grid.GAP * 10, 7);
			_measureTf.x = _shape.x + _shape.width + 3;
		}
		
		public function _onEditorMaskResize(e:ResizeMaskEvent=null):void
		{
			var bottom:int = EditorContainer.instance.maskHeight;
			y = bottom - height - 8;
			x = EditorContainer.instance.x + (e == null ? EditorContainer.instance.maskWidth+150 : e.sizevo.width) / 2 + getWidth()/2;
		}
		
		private function getWidth():int
		{
			return _shape.width + 70;
		}
	}
}