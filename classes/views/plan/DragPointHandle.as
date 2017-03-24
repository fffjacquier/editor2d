package classes.views.plan 
{
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Regular;
	
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
	/**
	 * DragPointHandle, classe étendant Sprite, contenant les petites poignées invitant à déplacer les angles des Object2D.
	 */
	public class DragPointHandle extends Sprite
	{
		private var _pointView:PointView
		
		/**
		 * DragPointHandle, classe étendant Sprite, contenant les petites poignées invitant à déplacer les angles des Object2D.
		 * <p>Son design provient d'un MovieClip ajouté depuis la librairie Lib/editor.swc, ce MovieClip est différent si le segment est un l'unique mur d'une cloison, car il s'agit alors du déplacement de toute la cloison et non seulement celui d'un mur.</p>
		 */
		public function DragPointHandle(pointView:PointView) 
		{
			super();
			_pointView = pointView;
			if(pointView is CornerView) addChild(new TranslateCorner());
			else addChild(new TranslatePoint());
		
			mouseChildren = false;
		}
		
		public function get pointView():PointView
		{
			return _pointView;
		}
		private var _tween:Tween;
		public function showHide():void
		{
			_tween = new Tween(this, "alpha", Regular.easeOut, 0, 1, .3, true);
			_tween.addEventListener(TweenEvent.MOTION_FINISH,_hide, false, 0, true);
		}
		
		private function _hide(e:TweenEvent):void
		{
			_tween = new Tween(this, "alpha", Regular.easeOut, 1, 0, .3, true);
			_tween.addEventListener(TweenEvent.MOTION_FINISH,function():void{alpha = 0;
																			visible = false;
																			scaleX = 0;
																			scaleY = 0;}, false, 0, true);
			
		}
	}
}