package classes.vo
{
	import classes.model.ApplicationModel;
	import classes.services.php.LoadProjet;
	import classes.services.php.SaveProjet;
	import classes.utils.AppUtils;
	
	public class ProjetVO
	{
		public var id:Number = -1;
		//public var id_agence:int;
		public var duree_creation:Number = 0;/* en secondes*/
		public var duree_utilisation:Number = 0;/* en secondes*/
		public var durationBetween2Savings:int; /* variable used to determine time spent on app before two save*/
		public var nom:String;
		public var id_type_logement:int;
		public var ref_type_projet:String;
		public var xml_plan:XML;
		
		public var note_memo:String;
		public var note_vendeur:String;
		public var liste_courses:String;
		
		private var _am:ApplicationModel = ApplicationModel.instance;
		private var _callbackSave:Function;
		private var _callbackLoad:Function;
		
		public function ProjetVO()
		{
		}
		
		//-- Sauvegarde d'un projet en base de donnée
		public function saveDb(cb:Function = null):void
		{
			_callbackSave = cb;
			AppUtils.TRACE("ProjetVo:saveDB"+ this);
			new SaveProjet(_saveDbResult).call(this);
		}
		
		//-- Chargement d'un projet depuis la base de donnée
		public function loadDb(pIdProjet:int, cb:Function = null):void
		{
			//new loadProjet(_loaddbResult).call(this);
			//id = pIdProjet;
			
			_callbackLoad = cb;
			
			new LoadProjet(_loadDbResult).call(pIdProjet);
		}
		
		//-- Callback de loadDb
		private function _loadDbResult(pResult:Object):void
		{
			if (pResult)
			{
				//-- Affecte les infos du projet
				id = pResult.id_projet;
				//id_agence = pResult.id_agence;
				duree_creation = pResult.duree_creation;
				duree_utilisation = pResult.duree_utilisation;
				nom = pResult.nom;
				id_type_logement = pResult.id_type_logement;
				ref_type_projet = pResult.ref_type_projet;
				note_memo = pResult.note_memo;
				note_vendeur = pResult.note_vendeur;
				liste_courses = pResult.liste_courses;
				xml_plan = XML(pResult.xml_plan);
				
				_am.memos = note_memo;
				_am.notes = note_vendeur;
				_am.projectLabel = nom;
				
				_am.notifyProjectvoIdUpdate();
				
				AppUtils.TRACE("ProjetVO::loadDb()::_loadDbResult() > id=" + id + "/ name=" + nom+" / "+pResult.duree_utilisation+"secs");
				AppUtils.TRACE("ProjetVO::loadDb()::_loadDbResult() > xml=" + id + "/ name=" + xml_plan);
				
				//-- Appelle le callback
				if (_callbackLoad != null) _callbackLoad();
			}
			else
			{
				AppUtils.TRACE("ProjetVO::loadDb()::_loadDbResult() > Aucun résultat trouvé !");
			}
		}
		
		//-- Callback de saveDb
		private function _saveDbResult(pResult:Object):void
		{
			if (pResult[0])
			{
				//-- Va permettre de ne plus afficher l'aide sur le 1er projet
				_am.listProjectsCopy = 1;
				
				//-- Affecte les infos du projet
				if (id === -1) {
					id = int(pResult[0]);
				}
				AppUtils.TRACE("ProjetVO::saveDb()::_savdDbResult() > id=" + id );
				_am.notifyProjectvoIdUpdate();
					
				//-- Appelle le callback
				if (_callbackSave != null) _callbackSave();
				
			}
			else
			{
				AppUtils.TRACE("ProjetVO::saveDb()::_savdDbResult() > erreur !\n"+pResult[1]);
			}
		}
		
		public function toString():String
		{
			var str:String = "----------------------------------\n"
			
			str += "-- Projet VO -----------\n";
			
			str += "id=" + id + "\n";
			//str += "id_agence=" + id_agence + "\n";
			
			str += "duree_utilisation=" + duree_utilisation + "\n";
			str += "duree_creation=" + duree_creation + "\n";
			
			str += "nom=" + nom + "\n";
			
			str += "id_type_logement=" + id_type_logement + " / ";
			str += "ref_type_projet=" + ref_type_projet + "\n";
			str += "note_memo=" + note_memo + "\n";
			str += "note_vendeur=" + note_vendeur + "\n";
			str += "liste_courses=" + liste_courses + "\n";
						
			str += "xml_plan=" + xml_plan + "\n";
			
			str += "----------------------------------\n";
						
			return str;
		}
	}
}