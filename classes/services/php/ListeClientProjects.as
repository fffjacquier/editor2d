package classes.services.php 
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import flash.net.Responder;
	
	public class ListeClientProjects extends GetPHP 
	{
		
		public function ListeClientProjects(cb:Function=null) 
		{
			super(cb);
		}
		
		override protected function addloading():void
		{
			loading = new AlertSave(AppLabels.getString("messages_getProjectsList"));
			AlertManager.addPopup(loading, Main.instance)//.addChild(_loading);
			AppUtils.appCenter(loading);
		}
		
		override public function call(...rest):void
		{			
			var idClient:int = ApplicationModel.instance.clientvo.id;
			AppUtils.TRACE("ListeClientProjects::call() > idClient=" + idClient);
			//if(idClient != -1) {
				_nc.call("Clients.ListeClientProjets", new Responder(onResult, onError), idClient);
			//} else {
				//AppUtils.TRACE("ListeClientProjects::call() > ERROR");
				//onError(false);
			//}
		}
		
		override protected function onResult(pResult:Object):void
		{
			AppUtils.TRACE("ListeClientProjects::onResult() " + pResult);
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			AppUtils.TRACE("ListeClientProjects::onError() " + pResult);
			/*for (var k in pResult) {
				AppUtils.TRACE(k+" -- "+ pResult[k].id_projet);
			}*/
			super.onError(pResult);
		}
		
	}

}