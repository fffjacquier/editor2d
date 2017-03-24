package classes.components 
{
	import classes.model.ApplicationModel;
	import classes.vo.MaskSizeVO;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * La classe ScrollBarH est une scrollbar horizontale adaptée aux besoins spécifiques de l'écran synthèse.
	 */
	public class ScrollBarH extends Sprite 
	{
		private var _btnLeft:BtnFlecheScrollH;
		private var _btnRight:BtnFlecheScrollH;
		private var _target:DisplayObject;
		private var _tween:Tween;
		private var _limit:int;
		private var _w:int;
		
		public function ScrollBarH(target:DisplayObject, w:int = 548) 
		{
			_target = target;
			_w = w;
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			_limit = 240 - _target.width + 695;//taille du mask
			
			_btnLeft = new BtnFlecheScrollH();
			addChild(_btnLeft);
			_btnLeft.mouseChildren = false;
			_btnLeft.buttonMode = true;
			_btnLeft.addEventListener(MouseEvent.CLICK, _goRight);
			_btnLeft.enabled = false;
			_btnLeft.getChildAt(1).alpha = .2;
			
			_btnRight = new BtnFlecheScrollH();
			addChild(_btnRight);
			_btnRight.mouseChildren = false;
			_btnRight.buttonMode = true;
			_btnRight.rotation = 180;
			_btnRight.addEventListener(MouseEvent.CLICK, _goLeft);
			
			if (_target.width < 696) {
				_btnLeft.enabled = false;
				_btnRight.enabled = false;
				_btnLeft.getChildAt(1).alpha = .2;
				_btnRight.getChildAt(1).alpha = .2;
			}

			stage.addEventListener(Event.RESIZE, _onResize, false, 0, true);
			_onResize();
		}
		
		private function _goLeft(e:MouseEvent):void
		{
			//trace(_target.x - _w, _limit);
			if (_target.x < _limit) {
				return;
			}
			_tween = new Tween(_target, "x", Regular.easeOut, _target.x, _target.x - _w, .4, true);
			_tween.addEventListener(TweenEvent.MOTION_FINISH, _onTweenComplete, false, 0, true);
			_btnRight.removeEventListener(MouseEvent.CLICK, _goLeft);
		}
		
		private function _goRight(e:MouseEvent):void
		{
			if (_target.x >= 240) {
				return;
			}
			_tween = new Tween(_target, "x", Regular.easeOut, _target.x, _target.x + _w, .4, true);
			_tween.addEventListener(TweenEvent.MOTION_FINISH, _onTweenComplete, false, 0, true);
			_btnLeft.removeEventListener(MouseEvent.CLICK, _goRight);
		}
		
		private function _onTweenComplete(e:TweenEvent):void
		{
			_tween.removeEventListener(TweenEvent.MOTION_FINISH, _onTweenComplete);
			_tween = null;
			
			_btnRight.addEventListener(MouseEvent.CLICK, _goLeft);
			_btnLeft.addEventListener(MouseEvent.CLICK, _goRight);
			if (_target.x < _limit) {
				_btnRight.getChildAt(1).alpha = .2;
				_btnRight.buttonMode = false;
				_btnRight.enabled = false;
			} else {
				_btnRight.getChildAt(1).alpha = 1;
				_btnRight.buttonMode = true;
				_btnRight.enabled = true;
			}
			if (_target.x >= 240) {
				_btnLeft.getChildAt(1).alpha = .2;
				_btnLeft.buttonMode = false;
				_btnLeft.enabled = false;
			} else {
				_btnLeft.getChildAt(1).alpha = 1;
				_btnLeft.buttonMode = true;
				_btnLeft.enabled = true;
			}
		}
		
		private function _onResize(e:Event=null):void
		{
			var maskSize:MaskSizeVO = ApplicationModel.instance.maskSize;
			var larg:int = maskSize.width -32 -273;
			_btnRight.x = larg;
		}
		
	}

}