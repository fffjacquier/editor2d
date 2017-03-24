package classes.views.alert 
{
	import classes.utils.AppUtils;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	
	/**
	 * La classe Info360 permet de charger le popup d'info sur un équipement.
	 */
	public class Info360 extends Sprite 
	{
		private var _loadr:Loader;
		private var _urlStr:String;
		
		/**
		 * Permet de créer le popup d'info et de loader le diaporama de l'équipement
		 * 
		 * @param	uri Le lien vers le fichier swf contenant les infos.
		 */
		public function Info360(uri:String) 
		{
			//super();
			//trace("Info360 construtoc");
			addEventListener(Event.ADDED_TO_STAGE, _added);
			
			_urlStr = uri;
			_loadr = new Loader();
			addChild(_loadr);
			AppUtils.appCenter(_loadr);
			/*_loadr.y = Main.instance.x;
			_loadr.x = Main.instance.y;*/
			_loadr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
			_loadr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onError);
			_loadr.contentLoaderInfo.addEventListener(Event.COMPLETE, _onComplete);
			_loadr.load(new URLRequest(_urlStr));
			
		}
		
		private function _onComplete(e:Event):void
		{
			var lodr:LoaderInfo = e.target as LoaderInfo;
			lodr.removeEventListener(Event.COMPLETE, _onComplete);
			lodr.removeEventListener(IOErrorEvent.IO_ERROR, _onError);
			lodr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onError);
			
			//trace("Info360 _oncomplete");
			_onResize();
		}
		
		private function _added(e:Event):void
		{
			//trace("Info360 added");
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			stage.addEventListener(Event.RESIZE, _onResize);
			
			_loadr.addEventListener(MouseEvent.CLICK, click, false, 0, true);
		}
		
		private function click(e:MouseEvent):void
		{
			if (e.target.name != "btnLeft" && e.target.name != "btnRight" && e.target.name != "obj") {
				AlertManager.removeUpperPopup();
			}
		}
		
		private function _onResize(e:Event=null):void
		{
			//trace("Info360 _onResize");
			AppUtils.appCenter(_loadr);
		}
		
		private function _onError(e:Event):void
		{
			//trace("Info360::_onError()", e);
		}
	}

}