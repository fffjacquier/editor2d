package classes.views.plan 
{
	import classes.model.EditorModelLocator;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * DraggedObject constitue la classe de base de tous les objets de l'éditeur déplaçables par glissez-déposez.
	 * 
	 * <p>La gestion des onMouseEvent se fait dans la classe <code>Editor2D</code></p>
	 * 
	 * @see classes.views.plan.Editor2D#onMouseDownEvent()
	 */
	public class DraggedObject extends Sprite 
	{
		private var _movingCount:int;
		protected var dragCursor:MovieClip;
		public var isDragging:Boolean = false;
		protected var  _isLocked:Boolean;
		
		public function DraggedObject()
		{
			if (stage) added()
			else addEventListener(Event.ADDED_TO_STAGE, added);
		}
		
		protected function added(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, added);
		}
		
		//------------ MOUSE DOWN ------------
		private var _idShowCursor:int;
		public function onMouseDownEvent(e:MouseEvent):void
		{			
			mouseDown();
			if(dragCursor) _idShowCursor = setTimeout(_showCursor, 400);
			//addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function notifyMovementStart():void
		{
			//overrided in segments and points 
		}
		
		private function _showCursor():void
		{
			if (!dragCursor)return;
			if (!dragCursor.stage)
			{
				addChild(dragCursor);
				if(this is Editor2D) 
				{
					dragCursor.x = mouseX;
					dragCursor.y = mouseY;
				}
			}
		}
		
		protected function mouseDown():void
		{
			
		}
		
		//-------------- MOUSE MOVE ----------------
		
		public function onMouseMoveEvent(e:MouseEvent):void
		{			
			_movingCount++;
			if (_movingCount < 2) return; 
			isDragging = true;
			if (dragCursor)
			{	
				if (!dragCursor.stage)
					addChild(dragCursor);
			}
			
			if(_movingCount == 2)
			{
				notifyMovementStart();
			}
			
			mouseMove();
		}
		
		protected function mouseMove():void
		{
		}
		
		//---------------- MOUSE UP ------------------
		
		public  function onMouseUpEvent(e:MouseEvent=null):void
		{
		
			if (isDragging == false)
			{
				//action au mouse up  sans drag 
				mouseUp();
				//trace(this + " onMouseUpEvent");
			}
			else
			{
				//action au mouse up au drag 
				mouseUpWhileDrag();
				//trace(this + " mouseUpWhileDrag");
			}
			
			//action commune 
			clearTimeout(_idShowCursor);
			if (dragCursor && dragCursor.stage)
					removeChild(dragCursor);
			
			
			_movingCount = 0;
			isDragging = false;
			
		}
		
		protected function mouseUp():void
		{
		}
		
		protected function mouseUpWhileDrag():void
		{
		}
		
		public function get isLocked():Boolean
		{
			return false;
		}
		
		public function set isLocked(lock:Boolean):void
		{
			_isLocked = lock;
		}
		
		//----------------drag Cursor --------------
		
	}

}