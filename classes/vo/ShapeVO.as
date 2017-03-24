package classes.vo 
{
	import flash.geom.Point;
	
	public class ShapeVO 
	{
		public var id:int;
		public var classz:Class;
		public var points:Array;
		
		public function ShapeVO() 
		{
		}
		
		public function get pointsClone():Array
		{
			var arr:Array = new Array();
			for (var i:int = 0; i < points.length; i++)
			{
				arr.push((points[i] as Point).clone());
			}
			return arr;
		}
		
	}

}