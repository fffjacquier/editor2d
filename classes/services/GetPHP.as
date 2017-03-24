package classes.services 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import classes.views.alert.YesAlert;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	
	/**
	 * Classe de base pour les échanges php avec AMFPHP 1.9 installé sur le serveur
	 */
	public class GetPHP 
	{
		protected var _nc:NetConnection;
		protected var _callback:Function;
		protected var appmodel:ApplicationModel = ApplicationModel.instance;
		private var gatewayUrl:String = "./"+Config.AMF_URL;
		//private var tmp_idProject:String;
		protected var loading:Sprite;
		
		public function GetPHP(cb:Function = null) 
		{
			_callback = cb;
			
			_nc = new NetConnection();
			_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _variousErrorHandler);
			_nc.addEventListener(IOErrorEvent.IO_ERROR, _variousErrorHandler);
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _variousErrorHandler);
			_nc.addEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
			
			//-- AMF 1.9
			_nc.connect(gatewayUrl);
			addloading();
		}
		
		protected function addloading():void
		{
			loading = new AlertSave();
			AlertManager.addPopup(loading, Main.instance)//.addChild(_loading);
			AppUtils.appCenter(loading);
		}
		
		/**
		 * le code DOIT être implémenté par les classes qui héritent et étendent
		 */
		public function call(...rest):void
		{
		}
		
		private function _netStatusHandler(event:NetStatusEvent):void
		{
			AppUtils.TRACE("GetPHP::_netStatusHandler() : " + event.info.code);
		}
		
		private function _variousErrorHandler(event:NetStatusEvent):void
		{
			AppUtils.TRACE("GetPHP::_variousErrorHandler() : " + event.info.code);
		}
		
		protected function onResult(pResult:Object):void
		{
			//AppUtils.TRACE("GetPHP::onResult() >> "+ pResult );
		
			if (loading && loading.stage) {
				AlertManager.removePopup();
			}
			
			if (pResult == "SESSION_OVER")
			{
				AppUtils.TRACE("GetPHP::onError() >> SESSION_OVER >> pResult=" + pResult);
				ApplicationModel.instance.notifySessionOver();
			}
			else
			{
				if (_callback != null) _callback(pResult);
				_cleanup();
			}
			
		}
		
		protected function onError(pResult:Object):void
		{
			AppUtils.TRACE("GetPHP::onError() >> ERROR >> " + pResult);
			var popup:YesAlert = new YesAlert(AppLabels.getString("messages_error"), AppLabels.getString("messages_errorOccurred2") + pResult[0]);
			AlertManager.addPopup(popup, Main.instance);
			//AppUtils.appCenter(popup);
			_cleanup();
		}
		
		// cleanup listeners
		private function _cleanup():void
		{
			_nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, _variousErrorHandler);
			_nc.removeEventListener(IOErrorEvent.IO_ERROR, _variousErrorHandler);
			_nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _variousErrorHandler);
			_nc.removeEventListener(NetStatusEvent.NET_STATUS, _netStatusHandler);
		}
	}

}