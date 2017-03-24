package classes.views.tooltip 
{
	import classes.views.CommonTextField;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class Tooltip extends Sprite 
	{
		private var _parentDO:DisplayObjectContainer;
		private var _timer:Timer;
		private var _fadeIn:Tween;
		private var _fadeOut:Tween;
		protected var flip:Boolean = false;
		
		public function Tooltip(parentDO:DisplayObjectContainer, str:String) 
		{
			//_parentDO = parentDO;
			_parentDO = Main.instance;
			
			var yellowcolor:Number = 0xFFD83C;			
			var tip:CommonTextField = new CommonTextField("helvetBold", 0, 10);
			tip.width = 150;
			tip.autoSize = "left"
			tip.setText(str);
			tip.y = 3;
			tip.x = /*icon.x + icon.width + */5;
			
			graphics.lineStyle();
			graphics.beginFill(yellowcolor);
			var corner:int = 10;
			graphics.drawRoundRect(0, 0, tip.x + tip.textWidth + 5, tip.height + 9, corner, corner);
			graphics.endFill();
			
			addChild(tip);
			
			var fadeIn:Tween = new Tween(this, "alpha", Regular.easeOut, 0, 1, .5, true);				
			_timer = new Timer(5000, 1);
			_timer.addEventListener(TimerEvent.TIMER, _timerHandler, false, 0, true);
           	_timer.start();
			_followMouse();
			
			//draw arrow
			graphics.lineStyle();
			graphics.beginFill(yellowcolor);
			var xstart:int, ystart:int, incr:int;
			if (_parentDO.mouseX < 750) {
				xstart = tip.x + 12, ystart = height, incr = 10;
			} else {
				xstart = tip.x + tip.textWidth -4, ystart = height, incr = 10;
			}
			graphics.moveTo(xstart, ystart);
			graphics.lineTo(xstart, ystart + incr);
			graphics.lineTo(xstart - incr, ystart);
			graphics.endFill();
			
			_parentDO.addChild(this);			
           _parentDO.stage.addEventListener(MouseEvent.MOUSE_MOVE, _followMouse);
		}
		
		private function _timerHandler(event:TimerEvent):void
		{			
			_fadeOut = new Tween(this, "alpha", Regular.easeOut, 1, 0, 0.5, true);					
			_fadeOut.addEventListener(TweenEvent.MOTION_FINISH, _endFadeOutTween); 			
		}
		
		private function _endFadeOutTween(e:TweenEvent):void
		{			
			remove();
		}
		
		public function remove():void
		{			
			if (_fadeOut) _fadeOut.removeEventListener(TweenEvent.MOTION_FINISH, _endFadeOutTween); 
			if (_timer) _timer.removeEventListener(TimerEvent.TIMER, _timerHandler);			
			if (stage != null) 
			{
				_parentDO.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _followMouse);		
				parent.removeChild(this);
			}
		}
		
		private function _followMouse(event:MouseEvent = null):void
		{
			var point:Point = new Point(_parentDO.mouseX, _parentDO.mouseY);
			if (point.x > 750) point = new Point(_parentDO.mouseX-width/2, _parentDO.mouseY);
			//trace("p", point.x, point.y, _parentDO.mouseX);
			x = int(point.x);
			y = int(point.y - height*1.3);
			
			if(event && event.buttonDown == true) remove();
		}
	}

}