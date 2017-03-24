package classes.services.php 
{
	import classes.resources.AppLabels;
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import flash.net.Responder;
	
	public class LogVendeur extends GetPHP 
	{
		public function LogVendeur(cb:Function=null) 
		{
			super(cb);
		}
		
		override protected function addloading():void
		{
			loading = new AlertSave(AppLabels.getString("messages_connecting"));
			AlertManager.addPopup(loading, Main.instance)//.addChild(_loading);
			AppUtils.appCenter(loading);
		}
		
		override public function call(...rest):void
		{
			if (rest.length == 2)
			{
				var strLogin:String = rest[0];
				var strPwd:String = rest[1];
				//AppUtils.TRACE("LogVendeur::call() > log=" + strLogin + " / strPwd=" + strPwd);
				_nc.call("Identification.LogVendeur", new Responder(onResult, onError), strLogin, strPwd);	
			}else {
				AppUtils.TRACE("LogVendeur::call() >PARAMETRES MANQUANTS :  rest.length="+rest.length+"/2");
				onError(false);
			}
		}
		
		override protected function onResult(pResult:Object):void
		{
			//AppUtils.TRACE("LogVendeur::onResult() " + pResult);
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			//AppUtils.TRACE("LogVendeur::onError() " + pResult);
			super.onError(pResult);
		}
	}

}