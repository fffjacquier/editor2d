package classes.services.php 
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import classes.vo.ProjetVO;
	import flash.net.Responder;
	import flash.utils.getTimer;
	
	public class SaveProjet extends GetPHP 
	{
		public function SaveProjet(cb:Function=null) 
		{
			super(cb);
		}
		
		override protected function addloading():void
		{
			loading = new AlertSave(AppLabels.getString("messages_savingProcess"));
			AlertManager.addPopup(loading, Main.instance)//.addChild(_loading);
			AppUtils.appCenter(loading);
		}
		
		override public function call(...rest):void
		{
			var pvo:ProjetVO = rest[0];
			var id_vendeur:int = ApplicationModel.instance.vendeurvo.id;
			var id_agence:int = ApplicationModel.instance.vendeurvo.id_agence;
			var id_client:int = ApplicationModel.instance.clientvo.id;
			//var str_liste_projets:String = ApplicationModel.instance.clientvo.liste_id_projet;
			
			AppUtils.TRACE("SaveProjet::call() > pvo.id="+pvo.id);
			
			/*var r:RegExp = />(\t|\n|\s{2,})</gim;
			var xmlasStr:String = String(pvo.xml_plan).replace(r, "><");*/
			//AppUtils.TRACE("SaveProjet::call() xmlasString ="+ xmlasStr);
			
			// utilisation entre deux sauvegardes
			// on ne comptabilise pas le temps sur la synthese
			pvo.duree_utilisation += (getTimer() - pvo.durationBetween2Savings)/1000;
			AppUtils.TRACE("SaveProjet::call() duree_utilisation :" + pvo.duree_utilisation);
			
			pvo.durationBetween2Savings = getTimer();
			
			if(rest.length > 0){
				_nc.call("Projets.SaveProjet", new Responder(onResult, onError), pvo.id, id_vendeur, id_agence, id_client, pvo.duree_creation, pvo.duree_utilisation, pvo.nom, pvo.id_type_logement, pvo.ref_type_projet, pvo.note_memo, pvo.note_vendeur, pvo.liste_courses, pvo.xml_plan);
				//_nc.call("Projets.SaveProjet", new Responder(onResult, onError), pvo.id, id_vendeur, id_agence, id_client, pvo.duree_creation, pvo.duree_utilisation, pvo.nom, pvo.id_type_logement, pvo.ref_type_projet, pvo.note_memo, pvo.note_vendeur, pvo.liste_courses, xmlasStr);
			}else {
				AppUtils.TRACE("SaveProjet::call() > PARAMETRES MANQUANTS :  rest.length="+rest.length+"/1");
				onError(false);
			}
		}

		override protected function onResult(pResult:Object):void
		{
			//AppUtils.TRACE("SaveClient::onResult() " + pResult);
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			AppUtils.TRACE("SaveClient::onError() " + pResult);
			super.onError(pResult);
		}
	}
}