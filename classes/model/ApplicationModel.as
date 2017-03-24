package classes.model
{
	import classes.config.Config;
	import classes.controls.CurrentClientUpdateEvent;
	import classes.controls.CurrentProjetUpdateEvent;
	import classes.controls.CurrentScreenUpdateEvent;
	import classes.controls.CurrentStepUpdateEvent;
	import classes.controls.CurrentVendeurUpdateEvent;
	import classes.controls.DeleteConnectionEvent;
	import classes.controls.GlobalEventDispatcher;
	import classes.controls.LegendeLoadedEvent;
	import classes.controls.ResizeMaskEvent;
	import classes.controls.SaveStateEvent;
	import classes.controls.SessionOverEvent;
	import classes.controls.UpdateEquipementViewEvent;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.Liste;
	import classes.views.items.ItemListePDF;
	import classes.vo.ClientVO;
	import classes.vo.ConnectionsCollection;
	import classes.vo.ConnectionVO;
	import classes.vo.EquipementVO;
	import classes.vo.listeComboClientVO;
	import classes.vo.MaskSizeVO;
	import classes.vo.ProfileVO;
	import classes.vo.ProjetVO;
	import classes.vo.VendeurVO;
	import classes.vo.VideoVO;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	/**
	 * ApplicationModel est le ModelLocator global de l'appli.
	 * 
	 * <p>C'est un Singleton accessible globalement pour des donnéees partagées ou globales.
	 * <ul>
	 * 		<li>Ne loade pas de données (ce sont les services qui le font)</li>
	 * 		<li>Ne contient pas la logique système</li>
	 * 		<li>Sert de cache aux données qui doivent être accessibles pour tous les écrans</li>
	 * 		<li>Contient les données relatvies au fonctionnement de l'application</li>
	 * 		<li>Système de notification automatique lors des changements de données vers les vues</li>
	 * </ul>
	 * </p>
	 */
	public class ApplicationModel
	{
		public var profilevo:ProfileVO;
		/**
		 * Utilisée pour charger et afficher les textes stockés dans un fichier xml externe
		 * Cette donnée est passée par une des flashvars de la page
		 * @default "fr"
		 */
		public var language:String;
		
		private var _currentProjetVO:ProjetVO;
		private var _currentVendeurVO:VendeurVO;
		private var _currentClientVO:ClientVO;
		private var _currentScreen:String;
		/** 
		 * Correspond à l'onglet actif ouvert de l'accordion
		 */
		private var _currentStep:int = 0;
		private var _maskSize:MaskSizeVO = new MaskSizeVO();
		
		public var _auth_sessionUID:String;
		public var _auth_listeClients:String;
		public var _auth_provenance:String;
		public var _auth_ecran:String;
		
		public var _url_login_internet:String = "./";
		//public var _url_login_pocd:String = "../pocd.php";
		public var _url_page_erreur:String = "./erreur.php";
			
		public static var CBNAME_TEST_ELIGIBILITE:String = "test_eligibilite";
		public static var CBNAME_ORANGE_FORFAIT_INTERNET:String = "orange_forfait_internet";
		public static var CBNAME_LIVEBOX:String = "livebox";
		public static var CBNAME_DECODEUR:String = "decodeur";
		public static var CBNAME_AUTRE_OP_INTERNET:String = "autre_operateur_internet";
		public static var CBNAME_AUTRE_OP_MOBILE:String = "autre_operateur_mobile";
		public static var CBNAME_AUTRE_OP_FIXE:String = "autre_operateur_fixe";
		
		public var _liste_combos:listeComboClientVO;
		private var _tab_combos_name:Array;
		
		private static var _gd:GlobalEventDispatcher = GlobalEventDispatcher.instance;
		public static var NOT_LOGGED_VENDEUR_ID:Number = -1;
		
		/**
		 * Valeur de <code>screen</code> pour l'écran éditeur
		 */
		public static var SCREEN_EDITOR:String = "editor";/**
		 * Valeur de <code>screen</code> pour lécran de la page d'accueil
		 */
		public static var SCREEN_HOME:String = "home";/**
		 * Valeur de <code>screen</code> pour l'écran de login
		 */
		public static var SCREEN_LOG:String = "log";/**
		 * Valeur de <code>screen</code> pour l'écran inscription
		 */
		public static var SCREEN_INSCRIPTION:String = "inscription";/**
		 * Valeur de <code>screen</code> pour lécran de la recherche
		 */
		public static var SCREEN_SEARCH:String = "search";/**
		 * Valeur de <code>screen</code> pour l'écran récap synthese
		 */
		public static var SCREEN_RECAP:String = "recap";
		/**
		 * Valeur de l'event de type UPDATE_PROJECT_TYPE_EVENT
		 */
		public static var UPDATE_PROJECT_TYPE_EVENT:String = "updateProjectTypeEvent";
		/**
		 * Le nombre d'étapes dans l'accordion (varie selon le mode dessin ou installe les équipements)
		 */
		public var steps:Array// = new Array("surface", "cloisons", "prises", "equipements");
		/**
		 * Valeur nombre entier de l'étape surface de l'accordion dans le mode dessin
		 */
		public static var STEP_SURFACE:int = 0; //pieces, cloisons
		/**
		 * Valeur nombre entier de l'étape prises de l'accordion dans le mode installation équipements
		 */
		public static var STEP_PRISES:int = 0;
		/**
		 * Valeur nombre entier de l'étape équipements autres que prises de l'accordion dans le mode installation équipements
		 */
		public static var STEP_EQUIPEMENTS:int = 1;
		/**
		 * Valeur nombre entier de l'étape arrivée de la fibre de l'accordion dans le mode installation équipements (si type projet Fibre)
		 */
		public static var STEP_FIBER:int = 2;
		/**
		 * Valeur nombre entier du type de connexion Fibre
		 */
		public static var TYPE_CONNEXION_FIBRE:int = 1;
		/**
		 * Valeur nombre entier du type de connexion ADSL
		 */
		public static var TYPE_CONNEXION_ADSL:int = 2;
		/**
		 * Valeur nombre entier du type de logement Maison
		 */
		public static var TYPE_LOGEMENT_MAISON:int = 1;
		/**
		 * Valeur nombre entier du type de logement Appartement
		 */
		public static var TYPE_LOGEMENT_APPART:int = 2;
		
		/**
		 * Dans certains cas, quand on quitte l'éditeur sans supprimer un étage, on ne doit pas supprimer sa surface, 
		 * mais juste les blocs contenus dans la surface
		 * Cette variable permet d'éviter l'affichage de messages d'erreur
		 */
		public var flagForEditorDeletion:Boolean = false;
		/**
		 * Permet de cibler à quel étage on revient dans l'éditeur 
		 * @default 0
		 */
		public var floorIdToGo:int;
		/**
		 * le label du projet donné par l'utilisateur. La valeur par défaut est dans le fichier labels_fr.xml
		 */
		public var projectLabel:String;
		/**
		 * le nom de la Livebox sélectionnée par le client lors du choix de type de projet
		 */
		public var selectedLivebox:String = "Livebox2";
		/**
		 * Un tableau qui contient les noms de chaque étage dans le bon ordre pour affichage dans la synthèse
		 */
		public var etages:Vector.<String> = new Vector.<String>();
		/**
		 * Un tableau qui fonctionne un peu de pair avec <code>etages</code> afin de déterminer l'étage de la capture écran de l'étage, 
		 * les étages pouvant ne pas être créés dans l'ordre, par ex. rdc puis 1 puis -1 puis 2
		 */
		public var floorIds:Array = new Array();
		/**
		 * Stocke les captures écran des étages afin de les rendre accessibles dans l'écran Synthese Recap alors que l'éditeur n'est 
		 * plus présent.
		 */
		public var capturesArr:Vector.<BitmapData> = new Vector.<BitmapData>();
		/**
		 * Stocke les captures écran des étages destinées à l'affichage dans le PDF alors que l'éditeur n'est 
		 * plus présent.
		 */
		public var pdfCapturesArr:Vector.<BitmapData> = new Vector.<BitmapData>();
		/**
		 * Stockage des éventuels mémos saisis par les utilsateurs
		 */
		public var memos:String = "";
		/**
		 * Stockage des notes internes saisies par les vendeurs
		 */
		public var notes:String = "";
		/**
		 * Le type de projet choisi : Fibre ou ADSL...
		 */
		public var projectType:String; //ADSL ou FIBRE
		/**
		 * Une copie du xml du plan sauvegardé localement à des fins d'enregistrement et aussi de restitution
		 */
		public var plantype:XML = null;
		/**
		 * La liste des courses est un tableau d'équipements que les utilisateurs ne possèdent pas
		 */
		public var listeDeCourses:Array;
		/**
		 * Liste des equipements non possédés mais filtrés de certains équipements comme les prises et ordonnés
		 */
		public var listeDeCoursesSynthese:Liste;
		/**
		 * un Array de tous les équipements EquipementView présents dans le plan
		 * BUT: être utilisé dans la synthese pour mettre à jour la liste de courses
		 */
		public var equipementsRecap:Array;
		/**
		 * la liste des toutes les connexions existantes
		 */
		public var connectionsCollection:ConnectionsCollection = new ConnectionsCollection();
		/**
		 * Stockage local des données des VO des équipements
		 */
		public var VOs:XML;
		/**
		 * Le numéro de la forme de base de la maison sélectionnée par le client sur la home (FUT de décembre 2012). 
		 * Par défaut égal à 0, la forme rectangle.
		 */
		public var shape:int = 0;
		/**
		 * Le nombre de projets déjà créés pour ce client (info provenant de la home). 
		 * Utilisé pour les écrans d'aide en affichage automatique.
		 */
		public var listProjectsCopy:int;
		/**
		 * Est-ce que le bouton sauvegarder est actif ou pas.
		 */
		private var _saveState:Boolean = false;
		
		private static var _self:ApplicationModel = new ApplicationModel();
		
		public static function get instance():ApplicationModel
		{
			return _self;
		}
		
		public function ApplicationModel()
		{
			if (_self)
				throw new Error("Only one instance of ApplicationModel can be instantiated");
			//else _tempListenVOs();
		}
		
		// --- Reset data
		public function reset():void
		{
			_currentStep = -1;
			//plan = null;
			etages = new Vector.<String>();
			floorIds = new Array();
			capturesArr = new Vector.<BitmapData>();
			pdfCapturesArr = new Vector.<BitmapData>();
			memos = "";
			notes = "";
			projectType = null;
			projectLabel = null;
			listeDeCourses = null;
			plantype = null;
			equipementsRecap = [];
			//trace("ApplicationModel::reset");
		}
		
		/**
		 * Récupère la liste des combos utilisés dans Iinscription nouveau client
		 */
		public function get tab_combos_name():Array 
		{
			return new Array([CBNAME_TEST_ELIGIBILITE, AppLabels.getString("form_yourEligibility")], 
												[CBNAME_ORANGE_FORFAIT_INTERNET, AppLabels.getString("form_yourAccess")], 
												[CBNAME_LIVEBOX, AppLabels.getString("form_yourLB")], 
												[CBNAME_DECODEUR, AppLabels.getString("form_yourDecoder")], 
												null, [CBNAME_AUTRE_OP_INTERNET, AppLabels.getString("form_yourInternetProvider")], 
												[CBNAME_AUTRE_OP_MOBILE, AppLabels.getString("form_yourMobileOp")], 
												[CBNAME_AUTRE_OP_FIXE, AppLabels.getString("form_yourPhoneOp")]);
		}
		
		/**
		 * Envoie un notification d'event <code>UPDATE_PROJECT_TYPE_EVENT</code>
		 */
		public function notifyProjectType():void
		{
			_gd.dispatchEvent(new Event(UPDATE_PROJECT_TYPE_EVENT));
		}
		
		/**
		 * Ajoute un écouteur d'event <code>UPDATE_PROJECT_TYPE_EVENT</code>
		 */
		public function addProjectTypeListener(listener:Function):void
		{
			_gd.addEventListener(UPDATE_PROJECT_TYPE_EVENT, listener);
		}
		
		/**
		 * Supprime l'écouteur d'event <code>UPDATE_PROJECT_TYPE_EVENT</code>
		 */
		public function removeProjectTypeListener(listener:Function):void
		{
			_gd.removeEventListener(UPDATE_PROJECT_TYPE_EVENT, listener);
		}
		
		//--- notify ajout et suppression d'objetsView
		public function notifyUpdateEquipement(item:EquipementView, action:String):void
		{
			_gd.dispatchEvent(new UpdateEquipementViewEvent(item, action));
		}
		
		public function addUpdateEquipementListener(listener:Function):void
		{
			_gd.addEventListener(UpdateEquipementViewEvent.getType(), listener);
		}
		
		public function removeUpdateEquipementListener(listener:Function):void
		{
			_gd.removeEventListener(UpdateEquipementViewEvent.getType(), listener);
		}
		
		/**
		 * Envoie une notification d'événement LegendeLoadedEvent lors de la création du PDF
		 * 
		 * @param	num
		 * @param	item
		 */
		public function notifyLegendesLoaded(num:int, item:/*BitmapData*/ItemListePDF):void
		{
			_gd.dispatchEvent(new LegendeLoadedEvent(num, item));
		}
		
		public function addLegendesLoadedListener(listener:Function):void
		{
			_gd.addEventListener(LegendeLoadedEvent.getType(), listener);
		}
		
		public function removeLegendesLoadedListener(listener:Function):void
		{
			_gd.removeEventListener(LegendeLoadedEvent.getType(), listener);
		}
		
		/**
		 * Permet de récupérer les données du VO d'un équipement
		 * 
		 * @param pName le nom du vo que l'on veut récupérer; 
		 * ce nom doit correspondre à la balise name du fichier dans bin all.xml
		 * @return renvoie un EquipementVO
		 */
		public function getVOFromXML(pName:String):EquipementVO
		{
			var e:XMLList = VOs.*.*.(name == pName);
			var vo:EquipementVO = new EquipementVO();
			vo.imagePath = e.thumbImage;
			vo.name = e.name;
			vo.screenLabel = e.screenLabel;
			vo.type = e.classz.toString();
			vo.isOrange = e.isOrange;
			vo.isConnector = AppUtils.stringToBoolean(e.isConnector);
			vo.isTerminal = AppUtils.stringToBoolean(e.isTerminal);
			//trace("getVOFromXML", vo.screenLabel, vo.isTerminal)
			vo.diaporama360 = e.diaporama360;
			vo.linkArticleShop = e.linkArticleShop;
			vo.infos = e.infos;
			vo.id = parseInt(e.id);
			vo.max = parseInt(e.max);
			if (e.data.nbPortsEthernet != undefined) {
				vo.nbPortsEthernet = parseInt(e.data.nbPortsEthernet);
			}
			if (e.modeDeConnexion != undefined) {
				vo.modesDeConnexionPossibles = String(e.modeDeConnexion).split(",");
			} 
			if (e.videos != undefined) {
				//trace(e.videos);
				var len:int = e.videos.video.length();
				vo.videosArr = [];
				for (var k:int = 0; k < len; k++) {
					var videoVO:VideoVO = new VideoVO();
					videoVO.label = e.videos.video[k].@label;
					videoVO.src = e.videos.video[k].@src;
					if(e.videos.video[k].@install != undefined) videoVO.install = e.videos.video[k].@install;
					if(e.videos.video[k].@b != undefined) videoVO.b = e.videos.video[k].@b;					
					vo.videosArr.push(videoVO);
				}
			}
			return vo;
		}
		
		// ------------------------------------------------------------------------
		// Current projet  ----------------------------------------------------------
		// ------------------------------------------------------------------------
		
		//--- get && set current vendeur vo
		public function get projetvo():ProjetVO
		{
			if (!_currentProjetVO)
			{
				_currentProjetVO = new ProjetVO();
				AppUtils.TRACE("ApplicationModel::get projetvo() CREATION VO !");
			}
			return _currentProjetVO;
		}
		
		public function set projetvo(vo:ProjetVO):void
		{
			_currentProjetVO = vo;
			notifyCurrentProjetUpdate();
		}
		
		/**
		 * Notifies all relevant listeners that the current projet has been changed
		 * and that a ProjetVO object corresponding to
		 * the new current user is available in the model
		 */
		public function notifyCurrentProjetUpdate():void
		{
			_gd.dispatchEvent(new CurrentProjetUpdateEvent());
		}
		
		/**
		 * Adds (defines) a new listener that will be notified each time when the current user is changed.
		 *
		 * Note, that the listener is only notified when the current user is changed
		 * but not when the corresponding ProjetVO is updated.
		 *
		 * @param listener	the notification function.
		 */
		public function addCurrentProjetUpdateListener(listener:Function):void
		{
			_gd.addEventListener(CurrentProjetUpdateEvent.getType(), listener);
		}
		
		/**
		 * Removes a listener previously added by an addCurrentProjetUpdateListener call
		 *
		 * @param listener the target listener
		 */
		public function removeCurrentProjetUpdateListener(listener:Function):void
		{
			_gd.removeEventListener(CurrentProjetUpdateEvent.getType(), listener);
		}
		
		// ------------------------------------------------------------------------
		// Current vendeur  ----------------------------------------------------------
		// ------------------------------------------------------------------------
		
		//--- get && set current vendeur vo
		public function get vendeurvo():VendeurVO
		{
			if (!_currentVendeurVO)
			{
				_currentVendeurVO = new VendeurVO();
				AppUtils.TRACE("ApplicationModel::get vendeurvo() CREATION VO !"+ _currentVendeurVO);
			}
			return _currentVendeurVO;
		}
		
		public function set vendeurvo(vo:VendeurVO):void
		{
			AppUtils.TRACE("ApplicationModel::vendeurvo() "+vo);
			_currentVendeurVO = vo;
			notifyCurrentVendeurUpdate();
		}
		
		/**
		 * Notifies all relevant listeners that the current vendeur has been changed
		 * and that a VendeurVO object corresponding to
		 * the new current user is available in the model
		 */
		public function notifyCurrentVendeurUpdate():void
		{
			_gd.dispatchEvent(new CurrentVendeurUpdateEvent());
		}
		
		/**
		 * Adds (defines) a new listener that will be notified each time when the current user is changed.
		 *
		 * Note, that the listener is only notified when the current user is changed
		 * but not when the corresponding VendeurVO is updated.
		 *
		 * @param listener	the notification function.
		 */
		public function addCurrentVendeurUpdateListener(listener:Function):void
		{
			_gd.addEventListener(CurrentVendeurUpdateEvent.getType(), listener);
		}
		
		/**
		 * Removes a listener previously added by an addCurrentVendeurUpdateListener call
		 *
		 * @param listener the target listener
		 */
		public function removeCurrentVendeurUpdateListener(listener:Function):void
		{
			_gd.removeEventListener(CurrentVendeurUpdateEvent.getType(), listener);
		}
		
		// ------------------------------------------------------------------------
		// Current client  ----------------------------------------------------------
		// ------------------------------------------------------------------------
		
		//--- get && set current client vo
		public function get clientvo():ClientVO
		{
			if (!_currentClientVO || _currentClientVO == null)
			{
				_currentClientVO = new ClientVO();
				AppUtils.TRACE("ApplicationModel::get clientvo() CREATION VO !");
			}
			return _currentClientVO;
		}
		
		public function set clientvo(vo:ClientVO):void
		{
			_currentClientVO = vo;
			notifyCurrentClientUpdate();
		}
		
		/**
		 * Notifies all relevant listeners that the current client has been changed
		 * and that a ClientVO object corresponding to
		 * the new current client is available in the model
		 */
		public function notifyCurrentClientUpdate():void
		{
			_gd.dispatchEvent(new CurrentClientUpdateEvent());
		}
		
		/**
		 * Adds (defines) a new listener that will be notified each time when the current user is changed.
		 *
		 * Note, that the listener is only notified when the current user is changed
		 * but not when the corresponding ClientVO is updated.
		 *
		 * @param listener the notification function.
		 */
		public function addCurrentClientUpdateListener(listener:Function):void
		{
			_gd.addEventListener(CurrentClientUpdateEvent.getType(), listener);
		}
		
		/**
		 * Removes a listener previously added by an addCurrentClientUpdateListener call
		 *
		 * @param listener the target listener
		 */
		public function removeCurrentClientUpdateListener(listener:Function):void
		{
			_gd.removeEventListener(CurrentClientUpdateEvent.getType(), listener);
		}
		
		// ------------------------------------------------------------------------
		// Session over  ----------------------------------------------------------
		// ------------------------------------------------------------------------
		/**
		 * Notifies all relevant listeners that the current session is over
		 */
		public function notifySessionOver():void
		{
			_gd.dispatchEvent(new SessionOverEvent());
		}
		
		/**
		 * Adds (defines) a new listener that will be notified when the current session is over
		 *
		 * @param listener The notification function.
		 */
		public function addSessionOverListener(listener:Function):void
		{
			_gd.addEventListener(SessionOverEvent.getType(), listener);
		}
		
		/**
		 * Removes a listener previously added by an addSessionOverListener call
		 *
		 * @param listener The target listener
		 */
		public function removeSessionOverListener(listener:Function):void
		{
			_gd.removeEventListener(SessionOverEvent.getType(), listener);
		}
		
		// ------------------------------------------------------------------------
		// Screen changes  --------------------------------------------------------
		// ------------------------------------------------------------------------
		/**
		 * Renvoie la valeur actuelle de screen, l'écran en cours d'affichage
		 * 
		 * <p>Si la valeur de screen est inchangée, aucune notification n'a lieu</p>
		 * 
		 * <p>Si la valeur de screen change, un événement de type <code>CurrentScreenUpdateEvent</code> est dispatché.</p>
		 * 
		 * <p>Une distinction est faite pour <code>flagForEditorDeletion</code> selon qu'on quitte ou qu'on arrive sur l'écran de l'éditeur</p>
		 */
		public function get screen():String
		{
			return _currentScreen;
		}
		
		/**
		 * @private
		 */
		public function set screen(label:String):void
		{
			if (_currentScreen == label)
				return;
				
			if (_currentScreen == SCREEN_EDITOR) flagForEditorDeletion = true;
			if (label == SCREEN_EDITOR) flagForEditorDeletion = false;
			_currentScreen = label;
			notifyCurrentScreenUpdate();
		}
		
		public function notifyCurrentScreenUpdate():void
		{
			_gd.dispatchEvent(new CurrentScreenUpdateEvent());
		}
		
		public function addCurrentScreenUpdateListener(listener:Function):void
		{
			_gd.addEventListener(CurrentScreenUpdateEvent.getType(), listener);
		}
		
		public function removeCurrentScreenUpdateListener(listener:Function):void
		{
			_gd.removeEventListener(CurrentScreenUpdateEvent.getType(), listener);
		}
		
		// ------------------------------------------------------------------------
		// Background Image MASK size  --------------------------------------------
		// ------------------------------------------------------------------------
		/**
		 * Returns the size of the mask depending on resolution screen
		 */
		public function get maskSize():MaskSizeVO
		{
			return _maskSize;
		}
		
		/*
		 * Calculates the size of the mask
		 */
		public function set maskSize(pMaskSizeVO:MaskSizeVO):void
		{
			var w:int = pMaskSizeVO.width;
			if (w < Config.RESOLUTION_WIDTH_MIN)
				w = Config.RESOLUTION_WIDTH_MIN;
			if (w > Config.RESOLUTION_WIDTH_MAX)
				w = Config.RESOLUTION_WIDTH_MAX;
			var h:int = pMaskSizeVO.height;
			if (h < Config.RESOLUTION_HEIGHT_MIN)
				h = Config.RESOLUTION_HEIGHT_MIN;
			if (h > Config.RESOLUTION_HEIGHT_MAX)
				h = Config.RESOLUTION_HEIGHT_MAX;
			//AppUtils.TRACE("ApplicationModel::set maskSize()" + w + " " + h);
			//trace("ApplicationModel::set maskSize()" + w + " " + h);
			var maskw:Number = Config.MASK_BG_WIDTH_MAX - (Config.RESOLUTION_WIDTH_MAX - w) * (Config.MASK_BG_WIDTH_MAX - Config.MASK_BG_WIDTH_MIN) / (Config.RESOLUTION_WIDTH_MAX - Config.RESOLUTION_WIDTH_MIN);
			var maskh:Number = Config.MASK_BG_HEIGHT_MAX - (Config.RESOLUTION_HEIGHT_MAX - h) * (Config.MASK_BG_HEIGHT_MAX - Config.MASK_BG_HEIGHT_MIN) / (Config.RESOLUTION_HEIGHT_MAX - Config.RESOLUTION_HEIGHT_MIN);
			_maskSize.width = maskw;
			_maskSize.height = maskh;
			//trace("ApplicationModel::set maskSize()" + maskw + " " + maskh);
			
			notifyResizeMaskUpdate();
		}
		
		public function notifyResizeMaskUpdate():void
		{
			_gd.dispatchEvent(new ResizeMaskEvent(_maskSize));
		}
		
		public function addResizeMaskUpdateListener(listener:Function):void
		{
			_gd.addEventListener(ResizeMaskEvent.getType(), listener);
		}
		
		public function removeResizeMaskUpdateListener(listener:Function):void
		{
			_gd.removeEventListener(ResizeMaskEvent.getType(), listener);
		}
		
		// ------------------------------------------------------------------------
		// Current toolbar step  --------------------------------------------------
		// ------------------------------------------------------------------------
		/**
		 * Renvoie la valeur courante de l'onglet ouvert dans l'accordion
		 * 
		 * <p>Si la valeur demandée est comprise entre 0 et le nombre maximal de steps de l'accordion, un event 
		 * de type <code>CurrentStepUpdateEvent</code> est dispatché.</p>
		 */
		public function get currentStep():int
		{
			return _currentStep;
		}
		
		/**
		 * @private
		 */
		public function set currentStep(step:int):void
		{
			//AppUtils.TRACE("AppModel::currentStep "+ _currentStep+" "+ step);
			if (_currentStep == step)
				return;
			
			if (_currentStep > this.steps.length - 1)
			{
				//go to screen recap
				_currentStep = STEP_SURFACE;
				screen = SCREEN_RECAP;
				return;
			}
			
			_currentStep = step;
			notifyCurrentStepUpdate();
		}
		
		public function notifyCurrentStepUpdate():void
		{
			_gd.dispatchEvent(new CurrentStepUpdateEvent(_currentStep));
		}
		
		public function addCurrentStepUpdateListener(listener:Function):void
		{
			_gd.addEventListener(CurrentStepUpdateEvent.getType(), listener);
		}
		
		public function removeCurrentStepUpdateListener(listener:Function):void
		{
			_gd.removeEventListener(CurrentStepUpdateEvent.getType(), listener);
		}
		
		// ------------------------------------------------------------------------
		// Update profilevo      --------------------------------------------------
		// ------------------------------------------------------------------------
		
		public function notifyProfileUpdate():void
		{
			_gd.dispatchEvent(new Event("ProfileUpdate"));
		}
		
		public function addProfileUpdateListener(listener:Function):void
		{
			_gd.addEventListener("ProfileUpdate", listener);
		}
		
		public function removeProfileUpdateListener(listener:Function):void
		{
			_gd.removeEventListener("ProfileUpdate", listener);
		}
		
		// ------------------------------------------------------------------------
		// Update client data    --------------------------------------------------
		// ------------------------------------------------------------------------
		
		public function notifyUpdateClientData():void
		{
			_gd.dispatchEvent(new Event("UpdateClientData"));
		}
		
		public function addClientDataUpdateListener(listener:Function):void
		{
			_gd.addEventListener("UpdateClientData", listener);
		}
		
		public function removeClientDataUpdateListener(listener:Function):void
		{
			_gd.removeEventListener("UpdateClientData", listener);
		}
		
		// ------------------------------------------------------------------------
		// Update the saveState  --------------------------------------------------
		// ------------------------------------------------------------------------
		
		public function notifySaveStateUpdate(state:Boolean):void
		{
			var previousState:Boolean = _saveState;
			_saveState = state;
			
			if (screen == SCREEN_HOME) {
				_gd.dispatchEvent(new SaveStateEvent(false));
				return;
			}
			
			// si le bouton est déjà actif sur écran editor ou récap, inutile de notifier
			if ((screen == SCREEN_EDITOR || screen == SCREEN_RECAP) && previousState && _saveState) return;
			
			//AppUtils.TRACE("MODEL::notifySaveStateUpdate " + previousState + " "+ _saveState +" "+ screen)
			
			_gd.dispatchEvent(new SaveStateEvent(state));
		}
		
		public function addSaveStateUpdateListener(listener:Function):void
		{
			_gd.addEventListener(SaveStateEvent.getType(), listener);
		}
		
		public function removeSaveStateUpdateListener(listener:Function):void
		{
			_gd.removeEventListener(SaveStateEvent.getType(), listener);
		}
		
		
		// ------------------------------------------------------------------------
		// Update the memo  -------------------------------------------------------
		// ------------------------------------------------------------------------
		
		public function notifyMemoUpdate():void
		{
			_gd.dispatchEvent(new Event("updateMemo"));
		}
		
		public function addMemoUpdateListener(listener:Function):void
		{
			_gd.addEventListener("updateMemo", listener);
		}
		
		public function removeMemoUpdateListener(listener:Function):void
		{
			_gd.removeEventListener("updateMemo", listener);
		}
		
		
		// ------------------------------------------------------------------------
		// Update the projectvo id  -----------------------------------------------
		// ------------------------------------------------------------------------
		
		public function notifyProjectvoIdUpdate():void
		{
			_gd.dispatchEvent(new Event("updateProjectvoId"));
		}
		
		public function addProjectvoIdUpdateListener(listener:Function):void
		{
			_gd.addEventListener("updateProjectvoId", listener);
		}
		
		public function removeProjectvoIdUpdateListener(listener:Function):void
		{
			_gd.removeEventListener("updateProjectvoId", listener);
		}
		
		
		// ------------------------------------------------------------------------
		// PDF is ready     -------------------------------------------------------
		// ------------------------------------------------------------------------
		
		public function notifyPDFReady():void
		{
			_gd.dispatchEvent(new Event("PDFReady"));
		}
		
		public function addPDFReadyListener(listener:Function):void
		{
			_gd.addEventListener("PDFReady", listener);
		}
		
		public function removePDFReadyListener(listener:Function):void
		{
			_gd.removeEventListener("PDFReady", listener);
		}
		
		// ------------------------------------------------------------------------
		// Notifications for Menus when the connect popup is open or close     ----
		// ------------------------------------------------------------------------
		
		public function notifyConnectPopupOpen():void
		{
			_gd.dispatchEvent(new Event("ConnectPopupOpen"));
		}	
		public function addConnectPopupOpenListener(listener:Function):void
		{
			_gd.addEventListener("ConnectPopupOpen", listener);
		}		
		public function removeConnectPopupOpenListener(listener:Function):void
		{
			_gd.removeEventListener("ConnectPopupOpen", listener);
		}	
		public function notifyConnectPopupClose():void
		{
			_gd.dispatchEvent(new Event("ConnectPopupClose"));
		}	
		public function addConnectPopupCloseListener(listener:Function):void
		{
			_gd.addEventListener("ConnectPopupClose", listener);
		}		
		public function removeConnectPopupCloseListener(listener:Function):void
		{
			_gd.removeEventListener("ConnectPopupClose", listener);
		}
		
		// ------------------------------------------------------------------------
		//  Connections removal notifications   ----
		// ------------------------------------------------------------------------
		
		public function notifyDeleteConnection(connection:ConnectionVO):void
		{
			_gd.dispatchEvent(new DeleteConnectionEvent(connection));
		}	
		public function addDeleteConnectionListener(listener:Function):void
		{
			_gd.addEventListener(DeleteConnectionEvent.getType(), listener);
		}		
		public function removeDeleteConnectionListener(listener:Function):void
		{
			_gd.removeEventListener(DeleteConnectionEvent.getType(), listener);
		}	
		
		//-- Temp 
		public function getAuthentification():void
		{
			AppUtils.TRACE("ApplicationModel::getAuthentification() >> _auth_sessionUID = " + _auth_sessionUID + "\n _auth_provenance = " + _auth_provenance + "\n _auth_ecran = " + _auth_ecran + "\n _auth_listeClients = " + _auth_listeClients);		
		}	
		
	}
}