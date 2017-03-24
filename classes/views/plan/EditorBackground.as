package classes.views.plan 
{
	import classes.controls.ZoomEvent;
	import classes.model.EditorModelLocator;
	import classes.utils.GeomUtils;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * EditorBackground est un Sprite vide ajouté dans l'Editor2D dont le scale prend la valeur réelle définie par le zoom. 
	 * <p>Il sert ainsi à donner une vraie mesure physique de l'étendue à l'écran de l' Editor2D qui lui n'est jamais scalé, ni zoomé.
	 * En pratique, il sert de référent pour les methodes localToGlobal ou globalToLocal, getBounds des objets du plan.</p> 
	 */	
	public class EditorBackground extends Sprite 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		private static var _instance:EditorBackground;
		public static function get instance():EditorBackground
		{
			return _instance;
		}
		
		/**
		 * EditorBackground est un Sprite vide ajouté dans l'Editor2D dont le scale prend la valeur réelle définie par le zoom. 
		 * <p>Il sert ainsi à donner une vraie mesure physique de l'étendue à l'écran de l' Editor2D qui lui n'est jamais scalé, ni zoomé.
		 * En pratique, il sert de référent pour les methodes localToGlobal ou globalToLocal, getBounds des objets du plan.</p> 
		 * <p>C'est est un singleton, un getter public statique réfère à son instance.</p>
		 */	
		public function EditorBackground() 
		{
			_instance = this;
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			_model.addZoomEventListener(_onZoom);
			_onZoom();
		}
		
		private function _onZoom(e:ZoomEvent=null):void
		{
			var scale:Number = EditorModelLocator.instance.currentScale;
			scaleX = scale;
			scaleY = scale;
			//trace("EditorBackground::_onZoom() width " + width);
			Editor2D.instance.x = 0;
			Editor2D.instance.y = 0;
			
			var registerPoint:Point = _model.zoomRegisterPoint;
			if (!registerPoint) return;
			var mewRegisterPoint:Point =  localToGlobal(registerPoint);
			//var mewRegisterPoint:Point =  GeomUtils.localToGlobal(registerPoint, this);
			var editorCenter:Point = GeomUtils.getGlobalEditorCenter();
			Editor2D.instance.x = editorCenter.x -  mewRegisterPoint.x;
			Editor2D.instance.y = editorCenter.y - mewRegisterPoint.y;
			/*trace("Editor2D.instance.x  " + Editor2D.instance.x );
			trace("Editor2D.instance.y  " + Editor2D.instance.y );
			trace("registerPoint  " + registerPoint);
			trace("mewRegisterPoint  " + mewRegisterPoint);
			trace("editorCenter  " + editorCenter);
			
			trace("---------------------------------------------");*/
		}
		
		private function _removed(e:Event):void
		{
			_model.removeZoomEventListener(_onZoom);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
	}

}