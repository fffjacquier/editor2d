package classes.services 
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	
	public class LoadBinary 
	{
		private var _callback:Function;
		
		public function LoadBinary(imagePath:String, func:Function) 
		{
			_callback = func;
				
			var loader:URLLoader = new URLLoader();			
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, _onLoadComplete);
			loader.load(new URLRequest(imagePath));						
		}
	 
		private function _onLoadComplete(event:Event):void
		{						
		  var byteArray:ByteArray = event.target.data as ByteArray;
		  _callback(byteArray);
		}
	}
}