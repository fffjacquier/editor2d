package classes.services 
{
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class Request 
	{
		protected var callBack:Function;
		
		/**
		 * Classe de base pour les requetes de chargement de fichiers xml ou php
		 * 
		 * @param pFile Le nom du fichier à charger (string)
		 * @param func Le callback à faire après traitement requete (function)
		 * @param vars Par defaut null, les variables ou parametres de requete php
		 */
		public function Request(pFile:String, func:Function = null, vars:URLVariables = null)
		{
			callBack = func;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, _onEventComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, _onError);
			
			//add random var for cache
			var randomInt:String = int(Math.random() * 9999999).toString();
			var noCache:String = "noCache="+ randomInt;
			//ajouter noCache en get 
			//if(!vars && !Config.STANDALONE_MODE) file = (file.indexOf("?") == -1)?	file + "?" + noCache : 	file + "&" + noCache;
		  
			var urlRequest:URLRequest = new URLRequest(pFile);
			
			if(vars)
			{				
				vars.noCache = randomInt;
				urlRequest.method = URLRequestMethod.POST;
    			urlRequest.data = vars;    			
   				loader.dataFormat = URLLoaderDataFormat.BINARY;
			}			
			
			try {
				loader.load(urlRequest);
			} catch (e:Error) {
				AppUtils.TRACE("Request load ERROR: "+ e.message);
			}
		}
		
		private function _onEventComplete(e:Event):void 
		{
			var result:Object = e.target.data;
			
			var resultXML : XML = new XML(result);
			parseXML(resultXML);
		}
		
		protected function parseXML(resultXML:XML):void
		{
			//trace(resultXML);
		}
		
		protected function parseResult(result:*):void
		{
			//trace(result);
		}
		
		private function _onError(e:IOErrorEvent):void
		{
			//plan B pour gérer le cas où la flashvars language ne mène pas à un fichier xml
			// exemple: si je  mets 'en' au lieu de 'fr' et que le fichier labels_en.xml n'existe pas
			AppUtils.TRACE("Request _onError :" + e.text);
			//ApplicationModel.instance.language = 'fr';
			//Main.instance.initVars();
		}
		
	}

}