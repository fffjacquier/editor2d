package classes.utils
{
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import flash.system.Capabilities;

	public class Measure
	{
		public static const PIXELS:String = "pixels";
		public static const METERS:String = "metres";
		public static const CENTIMETERS:String = "centimetres";
		public static const PERCENT:String = "percent";
		
		private static var _self:Measure;
		
		public var unit:String;
		public var value:Number;
		
		public function Measure()
		{
			_self = this;
		}
		public static function get instance():Measure
		{
			return _self;
		}
		
		public static function pixelToMetric(value:Number, unitstr:String = METERS):Number
		{
			var tmp:Number;
			switch(unitstr) {
				case METERS:
					tmp = (value * 0.026458333 * Capabilities.screenDPI) / 100;
					break;
				case CENTIMETERS:
					tmp = value *  0.026458333 * Capabilities.screenDPI;/*+" cm";un pouce mesure 2.54cm*/
					break;
				default:
					tmp = (value *  0.026458333 * Capabilities.screenDPI)/*+" cm";un pouce mesure 2.54cm*/
			}
			return tmp;
		}
		
		//en métres avec 2 chiffres après la virgule
		public static function roundedPixelToMetric(value:Number):Number  
		{
			return Math.round(pixelToMetric(value) * 100) / 100;
		}
		
		public static function metricToPixel(value:Number, unitstr:String = CENTIMETERS):Number
		{
			var tmp:Number;
			//trace("Measure::metricToPixel() Capabilities.screenDPI", Capabilities.screenDPI);
			//300 dpi 1cm -> 118,1125px
			switch(unitstr) {
				case METERS:
					tmp = (value * 100 / (0.026458333 * Capabilities.screenDPI)) ;
					break;
				case CENTIMETERS:
					tmp = value / (0.026458333 * Capabilities.screenDPI);  /*+" cm";un pouce mesure 2.54cm*/
					break;
				default:
					tmp = (value / (0.026458333 * Capabilities.screenDPI))     /*+" cm";un pouce mesure 2.54cm*/
			}
			return tmp;
		}
		
		public static function getUnitShort(unitstr:String):String
		{
			switch(unitstr) {
				case METERS:
					return AppLabels.getString("editor_metersShortcut");
				case CENTIMETERS:
					return "cm";
				case PIXELS:
				default:
					return "px";
			}
		}
		//en mètres a partir de pixels 
		public static function realSize(value:int):Number
		{
			return pixelToMetric(value, METERS) / EditorModelLocator.instance.currentScale;
		}
		
	}
}