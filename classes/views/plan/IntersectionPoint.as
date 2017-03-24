package classes.views.plan
{
	import classes.config.Config;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class IntersectionPoint extends Sprite
	{
		private var _position:Point;
		private var _sprite:Sprite;
		public var mur:Segment;
		
		public function IntersectionPoint(sprite:Sprite, p:Point, angle:Number, segment:Segment)
		{
			super();
			_position = p;
			_sprite = sprite;
			mur = segment;
			graphics.lineStyle(1, Config.COLOR_FIBERLINE);
			graphics.drawCircle(0, 0, 5);
			graphics.lineStyle(2, Config.COLOR_WHITE);
			graphics.drawCircle(-5, 0, 1);
			graphics.drawCircle(5, 0, 1);
			setPos(_position);
			_sprite.addChild(this);
			rotation = angle * 180 / Math.PI;
		}
		
		public function setPos(p:Point):void
		{
			x = p.x;
			y = p.y;
		}
		
		public function remove():void
		{
			if(stage) parent.removeChild(this);
		}
	}
}