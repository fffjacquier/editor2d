package classes.views.plan 
{
	import classes.model.EditorModelLocator;
	import classes.views.CommonTextField;
	import flash.display.Sprite;

	public class MeasuresContainer extends Sprite
	{
		private static var displayMeasures:Array = new Array();
		private static var surfaceMeasures:Array = new Array();
		public static var isON:Boolean = false;
		
		public function MeasuresContainer()
		{
		}
		
		public function addDisplayMeasure(displayMeasure:DisplayMeasure):void
		{
			addChild(displayMeasure);
			displayMeasure.visible = false;
			displayMeasures.push(displayMeasure);
		}
		
		public function removeDisplayMeasure(displayMeasure:DisplayMeasure):void
		{
			if (! displayMeasure || !displayMeasure.stage) return;
			
			removeChild(displayMeasure);
			var index:int = displayMeasures.lastIndexOf(displayMeasure);
			if (index == -1) return;
			displayMeasures.splice(index, 1);
		}
		
		public static function showMeasures(doShow:Boolean):void
		{
			if (EditorModelLocator.instance.currentScale < .6) doShow = false;
			for (var i:int = 0; i < displayMeasures.length; i++)
			{
				var displayMeasure:DisplayMeasure = displayMeasures[i] as DisplayMeasure;
				if (! displayMeasure.isOff) displayMeasure.visible = doShow;
				if (displayMeasure.segment.doesStickToSegment()) displayMeasure.visible = false;
				
			}
			
			for (i = 0; i < surfaceMeasures.length; i++)
			{
				var tf:CommonTextField = surfaceMeasures[i] as CommonTextField;
				tf.visible = doShow;
			}
			isON = doShow;
		}
		
		public static function addSurfaceMeasure(tf:CommonTextField):void
		{
			surfaceMeasures.push(tf);
		}
		
		public static function removeSurfaceMeasure(tf:CommonTextField):void
		{
			if (!tf) return;
			var index:int = surfaceMeasures.lastIndexOf(tf);
			if (index == -1) return;
			surfaceMeasures.splice(index, 1);
		}
		
		public static function update():void
		{
			showMeasures(Editor2D.instance.displayMeasuresCheckBoxValue);
		}
	}

}