package classes.vo
{
	import classes.utils.AppUtils;
	import classes.services.php.SaveClient;
	import classes.model.ApplicationModel;
	
	//import classes.services.php.LoadClient;
	
	public class ClientVO
	{
		public var id:Number = -1;
		public var id_orange_client:String;
		
		public var id_agence:int;
		public var id_createur:int;
		public var id_dernier_modificateur:int;
		public var liste_id_projet:String /* Mise a jour en requete bases exclusivement... */
		
		public var id_civilite:int;
		public var nom:String;
		public var prenom:String;
		public var adresse:String;
		public var cp:String;
		public var ville:String;
		public var email:String;
		public var accepte_collecte_infos:int;
		public var client_orange_fixe:int;
		public var id_autre_operateur_fixe:int = -1;
		public var telephone_fixe:String;
		public var client_orange_internet:int;
		public var id_orange_forfait_internet:int = -1;
		public var id_autre_operateur_internet:int = -1;
		public var id_test_eligibilite:int;
		public var id_livebox:int = -1;
		public var id_decodeur:int = -1;
		public var client_orange_mobile:int;
		public var id_orange_forfait_mobile:int = -1;
		public var id_autre_operateur_mobile:int = -1;
		public var telephone_mobile:String;
		public var client_orange_non:int;
		public var id_type_logement:int;
		
		private var _callbackLoad:Function;
		
		public function ClientVO()
		{
			//AppUtils.TRACE("ClientVO()");
		}
		
		//-- Sauvegarde d'un client en base de donnée
		public function saveDb(cb:Function = null):void
		{
			AppUtils.TRACE("ClientVO::saveDb() > vo=" + ApplicationModel.instance.clientvo);
			new SaveClient(cb).call(this);
		}
		
		//-- Affecte a l'appmodel le VO client et affiche le formulaire d'inscription client
		public function modifierInscriptionClient():void
		{
			//-- Copie les valeurs dans le VO de l'Appmodel
			ApplicationModel.instance.clientvo = this;
			
			AppUtils.TRACE("ClientVO::modifierInscriptionClient() > id=" + ApplicationModel.instance.clientvo.id + "/ name=" + ApplicationModel.instance.clientvo.nom);
			
			//-- Affiche l'editeur
			ApplicationModel.instance.screen = ApplicationModel.SCREEN_INSCRIPTION;
		}
		
		/*
		//-- Chargement d'un client depuis la base de donnée
		public function loadDb(pIdProjet:int, cb:Function = null):void
		{
			_callbackLoad = cb;
			
			new LoadClient(_loadDbResult).call(pIdClient);
		}
		
		//-- Callback de loadDb
		private function _loadDbResult(pResult:Object):void
		{
			if (pResult)
			{
				//-- Affecte les infos du client
				id = pResult.id_client;
				id_orange_client = pResult.id_orange_client;
				
				id_agence = pResult.id_agence;
				id_createur = pResult.id_createur;
				id_dernier_modificateur = pResult.id_dernier_modificateur;
				liste_id_projet = pResult.liste_id_projet;
				
				id_civilite = pResult.id_civilite;
				nom = pResult.nom;
				prenom = pResult.prenom;
				adresse = pResult.adresse;
				cp = pResult.cp;
				ville = pResult.ville;
				email = pResult.email;
				accepte_collecte_infos = pResult.accepte_collecte_infos;
				client_orange_fixe = pResult.client_orange_fixe;
				id_autre_operateur_fixe = pResult.id_autre_operateur_fixe;
				telephone_fixe = pResult.telephone_fixe;
				client_orange_internet = pResult.client_orange_internet;
				id_orange_forfait_internet = pResult.id_orange_forfait_internet;
				id_autre_operateur_internet = pResult.id_autre_operateur_internet;
				id_test_eligibilite = pResult.id_test_eligibilite;
				id_livebox = pResult.id_livebox;
				id_decodeur = pResult.id_decodeur;
				client_orange_mobile = pResult.client_orange_mobile;
				id_orange_forfait_mobile = pResult.id_orange_forfait_mobile;
				id_autre_operateur_mobile = pResult.id_autre_operateur_mobile;
				telephone_mobile = pResult.telephone_mobile;
				client_orange_non = pResult.client_orange_non;
				
				AppUtils.TRACE("ClientVO::loadDb()::_loadDbResult() > id=" + id + "/ name=" + nom);
				
				//-- Appelle le callback
				if (_callbackLoad != null)
					_callbackLoad();
			}
			else
			{
				AppUtils.TRACE("ClientVO::loadDb()::_loadDbResult() > Aucun résultat trouvé !");
			}
		}
		*/
		
		public function toString():String
		{
			var str:String = "----------------------------------\n"
			
			str += "-- Client VO -----------\n";
			
			str += "id=" + id + " / ";
			str += "id_orange_client=" + id_orange_client + " / ";
			str += "id_agence=" + id_agence + "\n";
			
			str += "accepte_collecte_infos=" + accepte_collecte_infos + "\n";
			
			str += "id_civilite=" + id_civilite + " / ";
			str += "nom=" + nom + " / ";
			str += "prenom=" + prenom + "\n";
			
			str += "adresse=" + adresse + " / ";
			str += "cp=" + cp + " / ";
			str += "ville=" + ville + "\n";
			
			str += "email=" + email + "\n";
			
			str += "client_orange_fixe=" + client_orange_fixe + " / ";
			str += "id_autre_operateur_fixe=" + id_autre_operateur_fixe + " / ";
			str += "telephone_fixe=" + telephone_fixe + "\n";
			
			str += "client_orange_internet=" + client_orange_internet + " / ";
			str += "id_autre_operateur_internet=" + id_autre_operateur_internet + "\n";
			
			str += "id_orange_forfait_internet=" + id_orange_forfait_internet + " / ";
			str += "id_livebox=" + id_livebox + " / ";
			str += "id_decodeur=" + id_decodeur + "\n";
			
			str += "id_test_eligibilite=" + id_test_eligibilite + "\n";
			
			str += "client_orange_mobile=" + client_orange_mobile + " / ";
			str += "id_autre_operateur_mobile=" + id_autre_operateur_mobile + "\n";
			
			str += "id_orange_forfait_mobile=" + id_orange_forfait_mobile + " / ";
			str += "telephone_mobile=" + telephone_mobile + "\n";
			
			str += "client_orange_non=" + client_orange_non + "\n";
			
			str += "id_type_logement=" + id_type_logement + "\n";
			
			str += "----------------------------------\n";
			
			return str;
		}
	}
}