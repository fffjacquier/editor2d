package classes.views.plan 
{
	import flash.display.Sprite;
	
	public class PointViewsContainer extends Sprite 
	{
		private static var pointsViews:Array = new Array();
		
		public function PointViewsContainer() 
		{
		}
		
		public function addPoint(pointView:PointView):void
		{
			addChild(pointView);
			pointsViews.push(pointView);
		}
		
		public function removePoint(pointView:PointView):void
		{
			removeChild(pointView);
			var index:int = pointsViews.lastIndexOf(pointView);
			if (index == -1) return;
			pointsViews.splice(index, 1);
		}
		
		public static function showPointsViews(doShow:Boolean):void
		{
			for (var i:int = 0; i < pointsViews.length; i++)
			{
				var pointView:PointView = pointsViews[i] as PointView;
				pointView.visible = doShow;
			}
		}
		
		public static function update():void
		{
			showPointsViews(Editor2D.instance.displayMeasuresCheckBoxValue);
		}
	}

}