package classes.views.plan 
{
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Regular;
	
	import flash.display.Sprite;
	
	/**
	 * DragSegmentHandle, classe étendant Sprite, contenant les petites poignées invitant à déplacer les segments des Object2D.
	 */
	public class DragSegmentHandle extends Sprite
	{
		private var _segment:Segment;
		public var factor:Number;
		
		/**
		 * DragSegmentHandle, classe étendant Sprite, contenant les petites poignées invitant à  déplacer les segments des Object2D.
		 * <p>Selon que l'angle est un PointView ou un CornerView, c'est à dire qu'il s'agit d'une pièce à forme libre ou rectangulaire, son design est différent, on y ajoute donc un MovieClip différent provenant du la librairie lib/editor.swc.</p>
		 */
		public function DragSegmentHandle(segment:Segment) 
		{
			_segment = segment;
			mouseChildren = false;
		}
		
		public function get segment():Segment
		{
			return _segment;
		}
		
		public function update():void
		{
			//if(_tween)_tween.stop();
			if (numChildren > 0) removeChildAt(0);
			if (segment.obj2D is CloisonEntity && segment.obj2D.length == 2)
			{
				//trace("curseur deplacement")
				addChild(new CurseurDeplacement());
			}
			else
			{
				addChild(new TranslateSegment());
			}
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
			_tween.addEventListener(TweenEvent.MOTION_FINISH,function():void{ alpha = 1;
																				visible = false;
																			 scaleX = 1;
			                                                                 scaleY = 1;}, false, 0, true);
		}
		
		
		public function get isCurseurTranslate():Boolean
		{
			if (numChildren == 0) return false;
			if (getChildAt(0) is CurseurDeplacement) return false;
			return true;
		}
		
	}

}