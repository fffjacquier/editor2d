package classes.services.php 
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import flash.net.Responder;
	
	public class GetAuthentification extends GetPHP 
	{
		
		public function GetAuthentification(cb:Function=null) 
		{
			super(cb);
		}
		
		override protected function addloading():void
		{
			loading = new AlertSave(AppLabels.getString("messages_checkAuth"));
			AlertManager.addPopup(loading, Main.instance)//.addChild(_loading);
			AppUtils.appCenter(loading);
		}
		
		override public function call(...rest):void
		{			
			var idSession:String = ApplicationModel.instance._auth_sessionUID;
			AppUtils.TRACE("GetAuthentification::call() > _auth_sessionUID=" + idSession);
			_nc.call("Authentification.GetSession", new Responder(onResult, onError), idSession);
		}
		
		override protected function onResult(pResult:Object):void
		{
			AppUtils.TRACE("GetAuthentification::onResult() " + pResult);
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			AppUtils.TRACE("GetAuthentification::onError() " + pResult);
			/*for (var k in pResult) {
				AppUtils.TRACE(k+" -- "+ pResult[k].id_projet);
			}*/
			super.onError(pResult);
		}
		
	}

}