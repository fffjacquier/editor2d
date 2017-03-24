package classes.services.php 
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import flash.net.Responder;
	
	public class LoadProjet extends GetPHP 
	{
		public function LoadProjet(cb:Function=null) 
		{
			super(cb);
		}
		
		override protected function addloading():void
		{
			loading = new AlertSave(AppLabels.getString("messages_loadingProject"));
			AlertManager.addPopup(loading, Main.instance)//.addChild(_loading);
			AppUtils.appCenter(loading);
		}
		
		override public function call(...rest):void
		{
			if (rest.length == 1)
			{
				var idProjet:int = rest[0];
				 
				AppUtils.TRACE("LoadProjet::call() > proj=" + idProjet+" / projetvo.id="+ApplicationModel.instance.projetvo.id);
				_nc.call("Projets.LoadProjet", new Responder(onResult, onError), idProjet);	
			}else {
				AppUtils.TRACE("LoadProjet::call() > PARAMETRES MANQUANTS :  rest.length="+rest.length+"/1");
				onError(false);
			}
		}
		
		override protected function onResult(pResult:Object):void
		{
			//AppUtils.TRACE("LoadProjet::onResult() " + pResult);
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			AppUtils.TRACE("LoadProjet::onError() " + pResult);
			super.onError(pResult);
		}
	}

}