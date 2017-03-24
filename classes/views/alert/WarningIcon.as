package classes.views.alert 
{
	import flash.display.Sprite;
	
	public class WarningIcon extends Sprite 
	{
		public var label:String;
		
		public function WarningIcon(str:String) 
		{
			label = str;
			var iconWarning:IconAttention = new IconAttention();
			addChild(iconWarning);
		}
		
	}

}