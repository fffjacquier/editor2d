package classes.services.php 
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import flash.net.Responder;
	
	public class ListeClients extends GetPHP 
	{
		public function ListeClients(cb:Function=null) 
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
			//AppUtils.TRACE("ListeClients::call()");
			if (rest.length == 2)
			{
				var idAgence:int = ApplicationModel.instance.vendeurvo.id_agence;
				//AppUtils.TRACE(ApplicationModel.instance.vendeurvo);
				var strTri:String = rest[0];
				var strSearch:String = rest[1];
				AppUtils.TRACE("ListeClients::call() > idag=" + idAgence + " / tri=" + strTri + " / search=" + strSearch);
				_nc.call("Clients.ListeClients", new Responder(onResult, onError), idAgence, strTri, strSearch);
			}else {
				AppUtils.TRACE("ListeClients::call() > PARAMETRES MANQUANTS :  rest.length="+rest.length+"/2");
				onError(false);
			}
		}
		
		override protected function onResult(pResult:Object):void
		{
			AppUtils.TRACE("ListeClients::onResult() " + pResult );
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			AppUtils.TRACE("ListeClients::onError() " + pResult);
			super.onError(pResult);
		}
	}

}