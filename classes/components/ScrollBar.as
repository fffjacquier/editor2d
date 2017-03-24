package classes.components 
{
	import classes.controls.History;
	import classes.controls.ZoomEvent;
	import classes.model.EditorModelLocator;
	import classes.utils.GeomUtils;
	import classes.views.plan.Editor2D;
	import classes.views.plan.EditorBackground;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * La classe ScrollBar est une barre de scroll vertical appliqué au contenu d'un Sprite ou d'un MovieClip
	 */
	public class ScrollBar extends MovieClip 
	{
		//clips
		private var _targetMC:DisplayObjectContainer;
		private var dragHandleMC:MovieClip;
		private var track:MovieClip;
		private var up:MovieClip;
		private var dn:MovieClip;
		//values
		private var min:int;
		private var max:int;
		private var range:int;
		private var rect:Rectangle;
		private var targetYpos:int;
		private var isUp:Boolean = false;
		private var isDown:Boolean = false;
		private var steps:int = 1;
		private var _mouseWheel:Boolean = false;
		//model
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		private static var _instance:ScrollBar;
		
		public static function get instance():ScrollBar
		{
			return _instance;
		}
		
		/**
		 * Crée une instance de ScrollBar
		 * 
		 * @param target Le container cible à scroller
		 * @param assetsClass La classe de skin à appliquer
		 */
		public function ScrollBar(target:DisplayObjectContainer, assetsClass:Class) 
		{
			_instance = this;
			
			var sb:MovieClip = new assetsClass();
			addChild(sb);
			
			dragHandleMC = sb.dragHandleMC;	
			track = sb.track;
			up = sb.up;
			dn = sb.dn;
			
			dragHandleMC.addEventListener(MouseEvent.MOUSE_DOWN, dragScroll);
			dragHandleMC.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			
			_targetMC = target;
			
			init();
		}
		
		private function init():void
		{
			min = track.y;
			max = min + track.height - dragHandleMC.height;
			
			range = max - min;
			rect = new Rectangle(dragHandleMC.x, min, 0, range);
			_onZoom();
			
			isUp = false;
			isDown = false;
			
			//up.addEventListener(Event.ENTER_FRAME, upHandler, false, 0, true);
			up.addEventListener(MouseEvent.MOUSE_DOWN, upScroll, false, 0, true);
			up.addEventListener(MouseEvent.MOUSE_UP, stopScroll, false, 0, true);
			
			//
			//dn.addEventListener(Event.ENTER_FRAME, downHandler, false, 0, true);
			dn.addEventListener(MouseEvent.MOUSE_DOWN, downScroll, false, 0, true);
			dn.addEventListener(MouseEvent.MOUSE_UP, stopScroll, false, 0, true);
			
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0, .3);
			g.drawRoundRect( -3, -8, 32, dn.y + dn.height + 16, 12);
			g.endFill();
			
			//addEventListener(MouseEvent.MOUSE_OVER, addMouseWheel);
			//addEventListener(MouseEvent.MOUSE_OUT, removeMouseWheel);
			//Editor2D.instance.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			addMouseWheel(); 
			_model.addZoomEventListener(_onZoom);
			
		}
		
		//--- Move the scroller
		//
		private function _registerZoomPoint():void
		{
			_model.zoomRegisterPoint = EditorBackground.instance.globalToLocal(GeomUtils.getGlobalEditorCenter());
			//_model.zoomRegisterPoint = GeomUtils.globalToLocal(GeomUtils.getGlobalEditorCenter(), EditorBackground.instance);
		}
		
		private function upHandler(e:Event):void 
		{
			if (isUp) {
				_mouseWheel = false;
				if (dragHandleMC.y - steps > min) 
				{
					_registerZoomPoint();
					dragHandleMC.y -= steps;
					if (dragHandleMC.y < min) 
					{
						dragHandleMC.y = min;
					}
					_model.removeZoomEventListener(_onZoom);
					doScroll();
					_model.zoomRegisterPoint = null;
					_model.addZoomEventListener(_onZoom);
				}
			}
		}
		
		//on down button enterframe 
		private function downHandler(e:Event):void 
		{  
			if (isDown) {
				_mouseWheel = false;
				if (dragHandleMC.y +steps < max) 
				{
					_registerZoomPoint();
					dragHandleMC.y += steps;
					trace("Scrollbar:: draghandleMC.y", dragHandleMC.y)
					if (dragHandleMC.y > max) 
					{
						dragHandleMC.y = max;
						stopScroll();
						return;
						
					}
					_model.removeZoomEventListener(_onZoom);
					doScroll();
					_model.zoomRegisterPoint = null;
					_model.addZoomEventListener(_onZoom);
				}
			}
		}
		
		//--- drag the scrollbar
		private function dragScroll(e:MouseEvent):void 
		{
			_mouseWheel = false;
			_registerZoomPoint();
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			dragHandleMC.startDrag(false, rect);
			addEventListener(Event.ENTER_FRAME, doScroll);
			_model.removeZoomEventListener(_onZoom);
			History.instance.clearHistory();
		}
		
		//--stop scroll in all cases 
		private function stopScroll(e:MouseEvent=null):void 
		{
			isUp = false;
			isDown = false;
			dragHandleMC.stopDrag();
			up.removeEventListener(Event.ENTER_FRAME, upHandler);
			dn.removeEventListener(Event.ENTER_FRAME, downHandler);
			up.removeEventListener(MouseEvent.MOUSE_OUT, stopScroll);
			dn.removeEventListener(MouseEvent.MOUSE_OUT, stopScroll);
			Editor2D.instance.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
			
			_model.zoomRegisterPoint = null;
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScroll);
			removeEventListener(Event.ENTER_FRAME, doScroll);
			_model.addZoomEventListener(_onZoom);
			_model.notifyZoomEndEvent();
		}
		
		private function upScroll(e:MouseEvent):void 
		{
			isUp = true;
			up.addEventListener(Event.ENTER_FRAME, upHandler, false, 0, true);
			up.addEventListener(MouseEvent.MOUSE_OUT, stopScroll, false, 0, true);
			History.instance.clearHistory();
		}
		
		private function downScroll(e:MouseEvent):void 
		{
			isDown = true;
			dn.addEventListener(MouseEvent.MOUSE_OUT, stopScroll, false, 0, true);
			dn.addEventListener(Event.ENTER_FRAME, downHandler, false, 0, true);
			Editor2D.instance.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
			History.instance.clearHistory();
		}
		
		//--- do the scroll thing to the target
		//set the scale according to the sroller position and notify zoom
		public function doScroll(e:Event=null):void
		{
			//var ratio:Number = target.max - target.min/range;
			//var newpos:Number = (dragHandleMC.y * ratio) - targetYpos;
			
			if (_targetMC is Editor2D) {
				// dispatch it
				_model.currentScale = Editor2D.SCALE_MIN - (dragHandleMC.y - max) * (Editor2D.SCALE_MAX - Editor2D.SCALE_MIN) / range;
				//pour que la grille soit tjrs la on mouse wheel
			} else {
				
				//_targetMC.y = -newpos;
			}
		}
		
		private function _onZoom(e:ZoomEvent =null):void
		{	
			var scale:int = _model.currentScale;
			//trace("ScrollBar::_onZoom", scale);
			dragHandleMC.y = max - (scale - Editor2D.SCALE_MIN) *  range / (Editor2D.SCALE_MAX - Editor2D.SCALE_MIN);
		}
		
		public function addMouseWheel(/*e:MouseEvent*/):void
		{
			//addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			Editor2D.instance.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}
		
		public function removeMouseWheel(/*e:MouseEvent*/):void
		{
			//removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			//_model.notifyZoomEndEvent();
			Editor2D.instance.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}
		
		private function _onMouseWheel(e:MouseEvent):void
		{
			//trace("mouseWheel", dragHandleMC.y, e.delta, max, min);
			_mouseWheel = true;
			
			/*if (dragHandleMC.y +e.delta < min) {
				dragHandleMC.y = min;
				return;
			}
			if (dragHandleMC.y +e.delta > max) {
				dragHandleMC.y = max;
				return;
			}*/
			if (_targetMC is Editor2D) 
			{
				History.instance.clearHistory();
				_registerZoomPoint();
				dragHandleMC.y -= e.delta;//max - (scale - Editor2D.SCALE_MIN) *  range / (Editor2D.SCALE_MAX - Editor2D.SCALE_MIN);
				if (dragHandleMC.y < min) dragHandleMC.y = min;
				if (dragHandleMC.y > max) dragHandleMC.y = max;
				_model.removeZoomEventListener(_onZoom);
				_registerZoomPoint();
				doScroll();
				_model.zoomRegisterPoint = null;
				_model.addZoomEventListener(_onZoom);
			}
		}
	}
}