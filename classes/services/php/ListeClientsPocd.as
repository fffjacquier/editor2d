package classes.services.php 
{
	import classes.resources.AppLabels;
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import flash.net.Responder;
	
	public class ListeClientsPocd extends GetPHP 
	{
		public function ListeClientsPocd(cb:Function=null) 
		{
			super(cb);
		}
		
		override protected function addloading():void
		{
			loading = new AlertSave(AppLabels.getString("messages_getData"));
			AlertManager.addPopup(loading, Main.instance)//.addChild(_loading);
			AppUtils.appCenter(loading);
		}
		
		override public function call(...rest):void
		{
			//AppUtils.TRACE("ListeClientsPocd::call()");
			if (rest.length == 1)
			{
				var strSearch:String = rest[0];
				AppUtils.TRACE("ListeClientsPocd::call() >  search=" + strSearch);
				_nc.call("Clients.ListeClientsPocd", new Responder(onResult, onError), strSearch);
			}else {
				AppUtils.TRACE("ListeClientsPocd::call() > PARAMETRES MANQUANTS :  rest.length="+rest.length+"/1");
				onError(false);
			}
		}
		
		override protected function onResult(pResult:Object):void
		{
			AppUtils.TRACE("ListeClientsPocd::onResult() " + pResult );
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			AppUtils.TRACE("ListeClientsPocd::onError() " + pResult);
			super.onError(pResult);
		}
	}

}