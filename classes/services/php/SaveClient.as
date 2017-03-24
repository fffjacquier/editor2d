package classes.services.php 
{
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.vo.ClientVO;
	import flash.net.Responder;
	
	public class SaveClient extends GetPHP 
	{
		public function SaveClient(cb:Function=null) 
		{
			super(cb);
		}

		override public function call(...rest):void
		{
			var cvo:ClientVO = rest[0];
			//AppUtils.TRACE("SaveClient::call() > cvo.id="+cvo.id);
			AppUtils.TRACE("SaveClient::call() > cvo="+cvo);
			
			if(rest.length > 0){
				_nc.call("Clients.SaveClient", new Responder(onResult, onError), cvo.id, cvo.id_orange_client, cvo.id_agence, cvo.id_civilite, cvo.nom, cvo.prenom, cvo.adresse, cvo.cp, cvo.ville, cvo.email, cvo.accepte_collecte_infos, cvo.client_orange_fixe, cvo.id_autre_operateur_fixe, cvo.telephone_fixe, cvo.client_orange_internet, cvo.id_orange_forfait_internet, cvo.id_autre_operateur_internet, cvo.id_test_eligibilite, cvo.id_livebox, cvo.id_decodeur, cvo.client_orange_mobile, cvo.id_orange_forfait_mobile, cvo.id_autre_operateur_mobile, cvo.telephone_mobile, cvo.client_orange_non, cvo.id_type_logement, cvo.id_dernier_modificateur);
			}else {
				AppUtils.TRACE("SaveClient::call() > PARAMETRES MANQUANTS :  rest.length="+rest.length+"/1");
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