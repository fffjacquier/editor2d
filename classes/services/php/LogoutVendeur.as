package classes.services.php 
{
	import classes.resources.AppLabels;
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import flash.net.Responder;
	
	public class LogoutVendeur extends GetPHP 
	{
		public function LogoutVendeur(cb:Function=null) 
		{
			super(cb);
		}
		
		override protected function addloading():void
		{
			loading = new AlertSave(AppLabels.getString("messages_disconnecting"));
			AlertManager.addPopup(loading, Main.instance)//.addChild(_loading);
			AppUtils.appCenter(loading);
		}
		
		override public function call(...rest):void
		{
			AppUtils.TRACE("LogoutVendeur::call()");
			_nc.call("Authentification.LogoutUser", new Responder(onResult, onError));	
		}
		
		override protected function onResult(pResult:Object):void
		{
			//AppUtils.TRACE("LogoutVendeur::onResult() " + pResult);
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			//AppUtils.TRACE("LogoutVendeur::onError() " + pResult);
			super.onError(pResult);
		}
	}

}