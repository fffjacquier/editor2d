package classes.services 
{
	import flash.display.MovieClip;
	
	public class LoadSwf extends Load
	{
		private var _context:*;
		
		public function LoadSwf(context:*, file:String, func:Function = null, loader:MovieClip = null)
		{
			_context = context;
			super(file, func, loader);
		}
		
		override protected function handleContent(content:*):void
		{
			if(!(content is MovieClip)) return;
			var mc:MovieClip = content as MovieClip;
			//mc["initExt"](_context);
			if(callBack != null) callBack(mc);
		}
	}

}