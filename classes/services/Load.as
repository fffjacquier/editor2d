package classes.services 
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import classes.utils.AppUtils;
	
	/**
	 * La classe Load est une classe de base abstraite pour loader des images ou des swf.
	 */
	public class Load
	{
		protected  var callBack:Function;
		private var _loaderInfo:LoaderInfo;
		private var leloader:MovieClip;
		
		/**
		 * Crée un loader et la fonction <code>handleContent</code> gère la suite.
		 * 
		 * @param	pFile Le nom du fichier à charger
		 * @param	pCallback Le callback de fonction à appeler à la fin du chargement
		 * @param   pLoader Le 'linkage name' du MovieClip de chargement que l'on souhaite afficher
		 */
		public function Load(pFile:String, pCallback:Function=null, pLoader:MovieClip=null)
		{
			callBack = pCallback;
			var context:LoaderContext = new LoaderContext();
			//context.parameters = { };
			context.checkPolicyFile = true;
			var loader:Loader = new Loader();			
			loader.contentLoaderInfo.addEventListener(Event.INIT, _onLoadInit);
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onIOError);
			loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, _onError);
			var url:URLRequest = new URLRequest(pFile); 	
			loader.load(url, context);
			leloader = pLoader;
			if(leloader != null) leloader.visible = true;
		}
		
		private  function _onLoadInit(e:Event):void 
		{			
			if(leloader != null) leloader.visible = false;
			_loaderInfo = LoaderInfo(e.currentTarget);
			var content:* = _loaderInfo.content;
			handleContent(content);
		}
		
		private function _onLoadComplete(e:Event):void
		{
			_loaderInfo = LoaderInfo(e.currentTarget);
			
			var content:* = _loaderInfo.content;
			handleContent(content);
		}
		
		private  function _onIOError(e:IOErrorEvent):void 
		{			
			AppUtils.TRACE("_onIOError " + e.text)
		}
		
		private  function _onError(e:ErrorEvent):void 
		{			
			AppUtils.TRACE("_onError " + e.text)
		}
		
		protected function get loaderInfo():LoaderInfo
		{
			return _loaderInfo;
		}
		
		// overriden by child classes
		protected function handleContent(content:*):void
		{
			//
		}
		
		private function _onLoadProgress(e:ProgressEvent):void 
		{	
			var loaderInfo:LoaderInfo = LoaderInfo(e.currentTarget);
			if ( loaderInfo.bytesTotal < loaderInfo.bytesLoaded) return;		
			/*_loadingCount++;			
			if (_loadingCount < 10) return;*/
			var percentage:int = Math.ceil(100 * loaderInfo.bytesLoaded / loaderInfo.bytesTotal);
			displayLoader(percentage)
		}
		
		protected function displayLoader(percentage:int):void
		{
			//AppUtils.TRACE("Load::displayLoader pourcentage: " + percentage);
			if(leloader != null) leloader.texte.text = percentage + "%";
		}
	}
}