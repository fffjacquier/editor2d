package  
{
	import classes.config.Config;
	import classes.controls.CurrentScreenUpdateEvent;
	import classes.controls.History;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.services.GetLabelsXML;
	import classes.services.php.GetAuthentification;
	import classes.services.php.GetClientFromUser;
	import classes.services.php.LoadFormContent;
	import classes.services.php.LogoutVendeur;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.YesAlert;
	import classes.views.Background;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.Header;
	import classes.views.ScreenEditor;
	import classes.views.ScreenHome;
	import classes.views.ScreenInscription;
	import classes.views.ScreenRecap;
	import classes.views.ScreenRecherche;
	import classes.vo.ClientVO;
	import classes.vo.listeBoxVO;
	import classes.vo.listeComboClientVO;
	import classes.vo.ProfileVO;
	import classes.vo.VendeurVO;
	import fl.data.DataProvider;
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	[SWF(width="1000", height="580", backgroundColor="#000000", frameRate=24)]	
	/**
	 * <code>Main</code> est la classe de base de cette application ciblée pour le player 10.0.2 sur IE7 (contrainte boutique Orange)
	 * 
	 * <p><code>Main</code> est responsable du chargement du swf et du xml des langues. 
	 * Elle écoute aussi les events <code>Event.RESIZE</code> et <code>KeyboardEvent</code> pour le control Z d'annulation de dernière action</p>
	 * 
	 * <p><code>Main</code> récupère aussi l'authentification PocD, ainsi que de récupérer depuis la base les paramètres stockés en base
	 * concernant les menus déroulants de l'écran Inscription.</p>
	 * 
	 * <p>Trois paramètres sont récupérés depuis la page html
	 * <ul>
	 *  	<li>longueur (int)</li>
	 *  	<li>largeur (int)</li>
	 *  	<li>language (String) valeur par défaut 'fr'</li>
	 * </ul>
	 * </p>
	 */
	public class Main extends Sprite
	{		
		public var header:Header;// reference au header
		public static const VERSION:String = "G1R4C0";//generated / rectifs / correction
		// valeurs pour connaitre la provenance de l'utilisateur, depuis pocd ou internet
		public static const AUTH_REFERER_POCD:String = "pocd";
		public static const AUTH_REFERER_INTERNET:String = "internet";
		
		private var _am:ApplicationModel = ApplicationModel.instance;
		private var _loading:Sprite;
		private var _simulText:CommonTextField;
		private var tim:Timer;
		private var w:int;
		private var h:int;		
		private var tab_combos_name:Array;		
		private var _popup:YesAlert;
		private var _footer:Sprite;
		
		private static var _self:Main;
		private static var _history:History = History.instance;		
		public static function get instance():Main
		{
			return _self;
		}
		
		/**
		 * <code>Main</code> est la classe de base de cette application ciblée pour le player 10.0.2 sur IE7 (contrainte boutique Orange)
		 * C'est une classe singleton; un getter public statique réfère à son instance.
		 * Elle est responsable du chargement du swf et du xml des langues.
		 * 
		 * Also listening for resize events and control+z event
		 * 
		 * Trois paramètres sont récupérés depuis la page html
		 * - longueur (int)
		 * - largeur (int)
		 * - language (String) valeur par défaut 'fr'
		 */		
		public function Main() 
		{
			if (_self == null) _self = this;
			else return;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			focusRect = false;
			stage.stageFocusRect = false;
			
			//couleur de fond 'masque'
			var s:Sprite = new Sprite();
			addChild(s)
			s.graphics.beginFill(0);
			s.graphics.drawRect( -1000, -500, 5000,	2000);
			
		 	w = root.loaderInfo.parameters.largeur;
			h = root.loaderInfo.parameters.hauteur;
			
			//VERSION = root.loaderInfo.parameters.rev;
			ApplicationModel.instance.language = root.loaderInfo.parameters.language || 'fr';
			
			preload();
		}
		
		
		// ----------------------------------------------
		// Loading functions ----------------------------
		// ----------------------------------------------
		private function preload():void
		{
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress, false, 0, true);
			loaderInfo.addEventListener(Event.COMPLETE, _onLoadComplete);
            _loading = new Sprite();
            addChild(_loading);
			AppUtils.appCenter(_loading);
		}
		
		private function _onLoadProgress(e:ProgressEvent):void
		{
			var g:Graphics = _loading.graphics;
			var percent:int = Math.floor(100*e.bytesLoaded/e.bytesTotal);
            
			g.clear();
            g.lineStyle(1, 0xff6600, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE);
            g.moveTo(0, 0);
            g.lineTo(percent, 0);
            g.endFill();
			AppUtils.appCenter(_loading);
		}
		
		private function _onLoadComplete(e:Event):void
		{
			removeChild(_loading);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			loaderInfo.removeEventListener(Event.COMPLETE, _onLoadComplete);

			initVars();
		}
		
		
		// ----------------------------------------------
		// Init function ----------------------------
		// ----------------------------------------------
		public function initVars():void
		{		
			// get labels from xml
			new GetLabelsXML(_startApp);
		}
		
		private function _startApp():void
		{	
			var bg:Background = new Background();
			addChild(bg);
			
			stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
		}		
		
		/* called by Background after the load image */
		public function addHeader():void
		{
			header = new Header();
			addChild(header);
			
			_am.addCurrentScreenUpdateListener(_onScreenUpdate);
			
			//-- Ancien fonctionnement : affiche ecran de login
			//_am.screen = ApplicationModel.SCREEN_LOG;
			//AppUtils.TRACE("isAndroid?" + root.loaderInfo.parameters.isAndroid);
			/*if(root.loaderInfo.parameters.isAndroid == "false")*/
			//stage.addEventListener(Event.RESIZE, _onResize);
			
			//-- Nouveaufonctionnement : Charge les infos de session
			if (ExternalInterface.available) {
				_getAuthentification();
			}
			else {
				//-- TEMPORAIRE for swf tests (not in html)
				var vo:VendeurVO = new VendeurVO();
				vo.id = (new Date()).getTime();
				vo.id_orange = "12345678";
				vo.id_agence = 1;
				vo.nom = "Caudron";
				vo.prenom = "Vincent";
				/*
				vo.str_profil = "#type_user:CLIENT-BOUTIQUE#commun_memo_modifier:1#commun_memo_afficher:1#commun_nom_modifier:1#";
				vo.str_profil += "inscription_acces:1#inscription_creer:1#inscription_modifier:1#inscription_eligibilite_obligatoire:0#";
				vo.str_profil += "btn_deconnexion:1#plan_acces:1#plan_creer:1#plan_sols_modifier:1#plan_sols_rub_surfaces:1#plan_install_modifier:1#";
				vo.str_profil += "plan_install_rub_prises:1#plan_install_rub_fibre:1#plan_install_rub_equipements:1#plan_install_equip_connecter:1#";
				vo.str_profil += "plan_install_equip_supprimer:1#plan_action_dernier_annuler:1#plan_etage_supprimer:1#recherche_acces:0#recherche_pdl:0#";
				vo.str_profil += "synthese_acces:1#synthese_note_afficher:0#synthese_note_modifier:0#synthese_courses_afficher:1#synthese_btn_vendeur:1#synthese_btn_email:0#synthese_btn_imprimer:0#";
				*/
				/*
				vo.str_profil = "#type_user:CLIENT-A-DOMICILE#commun_memo_modifier:1#commun_memo_afficher:1#commun_nom_modifier:1#";
				vo.str_profil += "inscription_acces:1#inscription_creer:1#inscription_modifier:1#inscription_eligibilite_obligatoire:0#";
				vo.str_profil += "btn_deconnexion:1#plan_acces:1#plan_creer:1#plan_sols_modifier:1#plan_sols_rub_surfaces:1#plan_install_modifier:1#";
				vo.str_profil += "plan_install_rub_prises:1#plan_install_rub_fibre:1#plan_install_rub_equipements:1#plan_install_equip_connecter:1#";
				vo.str_profil += "plan_install_equip_supprimer:1#plan_action_dernier_annuler:1#plan_etage_supprimer:1#recherche_acces:0#recherche_pdl:0#";
				vo.str_profil += "synthese_acces:1#synthese_note_afficher:0#synthese_note_modifier:0#synthese_courses_afficher:1#synthese_btn_vendeur:1#synthese_btn_email:1#synthese_btn_imprimer:1#";
				*/
				/**/
				vo.str_profil = "#type_user:VENDEUR#commun_memo_modifier:1#commun_memo_afficher:1#commun_nom_modifier:1#";
				vo.str_profil += "inscription_acces:1#inscription_creer:1#inscription_modifier:1#inscription_eligibilite_obligatoire:1#";
				vo.str_profil += "btn_deconnexion:1#plan_acces:1#plan_creer:1#plan_sols_modifier:1#plan_sols_rub_surfaces:1#plan_install_modifier:1#";
				vo.str_profil += "plan_install_rub_prises:1#plan_install_rub_fibre:1#plan_install_rub_equipements:1#plan_install_equip_connecter:1#";
				vo.str_profil += "plan_install_equip_supprimer:1#plan_action_dernier_annuler:1#plan_etage_supprimer:1#recherche_acces:1#recherche_pdl:1#";
				vo.str_profil += "synthese_acces:1#synthese_note_afficher:1#synthese_note_modifier:0#synthese_courses_afficher:1#synthese_btn_vendeur:1#synthese_btn_email:1#synthese_btn_imprimer:1#";
				
				
				
				_am.profilevo = new ProfileVO();
				_am.profilevo.setProfile(vo.str_profil);
				
				_am.vendeurvo = vo;				
				_getFormContent();
			}
			
			_addFooter();
			stage.addEventListener(Event.RESIZE, _onResize);
		}
		
		private function _addFooter():void
		{
			_footer = new Sprite();
			addChild(_footer);
			
			var version:CommonTextField = new CommonTextField("helvet", Config.COLOR_LIGHT_GREY, 11);
			version.autoSize = "left";
			_footer.addChild(version);
			_footer.y = Background.instance.masq.height + 10;
			version.x = 10;
			version.setText(AppLabels.getString("common_version") + " " + VERSION);
			
			var pipe:CommonTextField = new CommonTextField("helvet", Config.COLOR_ORANGE, 11);
			pipe.autoSize = "left";
			_footer.addChild(pipe);
			pipe.x = version.x + version.textWidth + 10;
			pipe.setText("|" );
			
			var terms:Btn = new Btn( -1, AppLabels.getString("common_legalTerms"), null, 116, Config.COLOR_LIGHT_GREY, 11, 24, null, false);
			_footer.addChild(terms);
			terms.x = pipe.x + pipe.textWidth;
			terms.y = version.y - 3;
			
			terms.addEventListener(MouseEvent.CLICK, _onClickTerms, false, 0, true);
		}
		
		private function _onClickTerms(e:MouseEvent):void
		{
			//navigateToURL(new URLRequest("mentions.html"), "_blank");
			if (ExternalInterface.available) ExternalInterface.call("open_mentions()");
		}
		
		private function _getAuthentification():void
		{
			//AppUtils.TRACE("Main::addHeader()::_getAuthentification()");
			
			var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			
			if (paramObj.vuid) {
				_am._auth_sessionUID = paramObj.vuid;
				AppUtils.TRACE("Main::addHeader::_sessionUID = " + _am._auth_sessionUID+" >> Charge la session...");				
				
				//-- Recuperation de l'authentification
				new GetAuthentification(_authentificationDbResult).call();
			}else {
				//-- Erreur pas de vuid !
				AppUtils.TRACE("Main::addHeader() >> ERROR >> vuid manquant");
				_popup = new YesAlert(AppLabels.getString("messages_error"), AppLabels.getString("messages_errorAuth") +" (vuid null)", true, _authentificationQuitteEditeur);
				AlertManager.addPopup(_popup, this);
				AppUtils.appCenter(_popup);
				_onResize();
			}
			
			//AppUtils.TRACE("isAndroid?" + root.loaderInfo.parameters.isAndroid);
		}
		
		// ----------------------------------------------
		// Callback Authentification --------------------
		// ----------------------------------------------
		private function _authentificationDbResult(pResult:Object):void
		{
			AppUtils.TRACE("Main::addHeader()::_authentificationDbResult() >> " + pResult);
			
			if (pResult)
			{
				if(pResult.liste_id_profil_propriete){
					
					//-- Affecte les infos d'authentification
					_am._auth_listeClients = pResult.liste_id_client;
					_am._auth_provenance = pResult.provenance;
					_am._auth_ecran = pResult.ecran;
					
					//-- Temp :aafiche les vals authentification
					_am.getAuthentification();
					
					//AppUtils.TRACE("Main::addHeader()::_authentificationDbResult() >> id_user >> " + pResult.id_user);
					
					//-- Set le vendeur VO
					var vo:VendeurVO = new VendeurVO();
					vo.id = pResult.id_user;
					vo.id_orange = pResult.id_orange;
					vo.id_agence = pResult.id_agence;
					vo.nom = pResult.nom;
					vo.prenom = pResult.prenom;
					vo.str_profil = pResult.liste_id_profil_propriete;
					_am.vendeurvo = vo;
					
					//AppUtils.TRACE("Main::addHeader()::_authentificationDbResult() >> liste_id_profil_propriete >> " + pResult.liste_id_profil_propriete);
					
					//-- Set le profile VO
					_am.profilevo = new ProfileVO();
					_am.profilevo.setProfile(pResult.liste_id_profil_propriete);
					
					//-- Gestion données combos
					if (_am._liste_combos == null)
					{
						//-- Recupère les contenu des listeBox de l'inscritpion...
						_getFormContent();
					}
					else
					{
						_nextEcran();
					}
				}else {
					//-- Erreur pas de profil !
					AppUtils.TRACE("Main::addHeader()::_authentificationDbResult() >> ERROR >> " + pResult);
					_popup = new YesAlert(AppLabels.getString("messages_error"), AppLabels.getString("messages_errorAuth") +" (profil null)", true, _authentificationQuitteEditeur);
					AlertManager.addPopup(_popup, this);
					_onResize();
				}
			}
			else
			{
				//-- Erreur pas de profil !
				AppUtils.TRACE("Main::addHeader()::_authentificationDbResult() >> ERROR >> " + pResult);
				_popup = new YesAlert(AppLabels.getString("messages_error"), AppLabels.getString("messages_errorAuth") +" (result null)", true, _authentificationQuitteEditeur);
				AlertManager.addPopup(_popup, this);
				_onResize();
			}
		}
		
		private function _getFormContent():void
		{
			AppUtils.TRACE("Main::addHeader()::_authentificationDbResult()::_getFormContent()");
			
			//-- récupère le contenu des comboxs
			//-- Charge la liste recherchée
			if (ExternalInterface.available)
			{
				new LoadFormContent(_loadFormContentResult).call();
			}
			else
			{
				//AppUtils.TRACE("_am._liste_combos ? " + _am._liste_combos);
				_am._liste_combos = new listeComboClientVO();
				
				//-- TEMPORAIRE
				tab_combos_name = _am.tab_combos_name
				var nbCombos:int = tab_combos_name.length;
				var comboName:String;
				var comboFirstLabel:String;
				var comboAutreLabel:String;
				var dp:DataProvider;
				var listeBVo:listeBoxVO;
				for (var i:int = 0; i < nbCombos; i++)
				{
					if (tab_combos_name[i] != null)
					{
						comboName = tab_combos_name[i][0];
						comboFirstLabel = tab_combos_name[i][1];
						comboAutreLabel = "Autre...";
						
						//AppUtils.TRACE("Main::_getFormContent() >\nCombo : " + comboName+" ("+comboFirstLabel+")");
						
						dp = new DataProvider();
						dp.addItem({label: comboFirstLabel, data: -1});
						for (var j:int = 1; j < 5; j++)
						{
							dp.addItem({label: "Label N°" + j, data: j});
						}
						dp.addItem({label: comboAutreLabel, data: 1});
						
						//-- Ajoute le VO a la liste des combos
						listeBVo = new listeBoxVO(comboName, comboFirstLabel, dp);
						_am._liste_combos.addListeBoxVo(listeBVo);
					}
				}
				//AppUtils.TRACE("\n_am._liste_combos = " + _am._liste_combos);
				
				//-- Affiche le bon écran (si recherche, on effectue une recherche sur les id_clients stockés dans _am._auth_listeClients...)
				_nextEcran();
			}
		}
		
		private function _loadFormContentResult(pResult:Object):void
		{
			//trace("listeClientsSearchResult !");
			AppUtils.TRACE("Main::_getFormContent()::_loadFormContentResult > nbResultClients=" + pResult.length);
			
			if (pResult)
			{
				_am._liste_combos = new listeComboClientVO;
				
				//-- recuperation des infos des combos
				//-- Eligibilite, Forfait Orange Internet, Livebox, Decodeur, Forfait Orange Mobile, Autre operateur internet, Autre operateur mobile, Autre operateur fixe
				tab_combos_name = _am.tab_combos_name
				
				//-- Pour chaque retour, 1 combo...
				var nbCombos:int = pResult.length;
				var comboName:String;
				var comboFirstLabel:String;
				var comboAutreLabel:String;
				var resultatCombo:Array;
				var nbResultCombo:int;
				var dp:DataProvider;
				var listeBVo:listeBoxVO;
				
				for (var i:int = 0; i < nbCombos; i++)
				{
					if (tab_combos_name[i] != null)
					{
						//-- Param du combo
						comboName = tab_combos_name[i][0];
						comboFirstLabel = tab_combos_name[i][1];
						
						//AppUtils.TRACE("Main::_loadFormContentResult >\nCombo : " + comboName+" ("+comboFirstLabel+")");
						
						dp = new DataProvider();
						dp.addItem({label: comboFirstLabel, data: -1});
						
						//-- Retour de la base
						resultatCombo = (pResult as Array)[i];
						nbResultCombo = resultatCombo.length;
						
						//AppUtils.TRACE("Main::_loadFormContentResult > Combo : " + comboName + " (" + comboFirstLabel + ") > nb=" + nbResultCombo);
						
						if (nbResultCombo > 0)
						{
							for (var j:int = 0; j < nbResultCombo; j++)
							{
								if (resultatCombo[j].id == 1)
								{
									comboAutreLabel = resultatCombo[j].nom;
								}
								else
								{
									dp.addItem({label: resultatCombo[j].nom, data: resultatCombo[j].id});
								}
							}
							dp.addItem({label: comboAutreLabel, data: 1});
						}
						
						//-- Ajoute le VO a la liste des combos
						listeBVo = new listeBoxVO(comboName, comboFirstLabel, dp);
						_am._liste_combos.addListeBoxVo(listeBVo);
					}
				}
				
				//-- Affiche le bon écran (si recherche, on effectue une recherche sur les id_clients stockés dans _am._auth_listeClients...)
				_nextEcran();
			}
			else
			{
				//-- Erreur pas de retour de la base pour les liste box !
				AppUtils.TRACE("Main::_getFormContent()::_loadFormContentResult >> ERROR >> " + pResult);
				_popup = new YesAlert(AppLabels.getString("messages_error"), AppLabels.getString("messages_errorGettingData") + " (listeBox null)", true, _authentificationQuitteEditeur);
				AlertManager.addPopup(_popup, this);
				_onResize();
			}
		}
		
		/**
		 * Ecran suivant après l'authentification et rapatriement des données listesBox
		 */
		private function _nextEcran():void
		{
			AppUtils.TRACE("Main::_nextEcran()"+_am.profilevo.user_profile);
			
			//-- Affiche le bon écran (si recherche, on effectue une recherche sur les id_clients stockés dans _am._auth_listeClients...)
			if (_am.profilevo.recherche_acces == 1)
			{
				_am.screen = ApplicationModel.SCREEN_SEARCH;
				ApplicationModel.instance.notifyProfileUpdate();
			}
			else
			{
				if (_am.profilevo.user_profile == "CLIENT-A-DOMICILE") {
					if (!ExternalInterface.available) {
						_am.clientvo = new ClientVO();
						_am.screen = ApplicationModel.SCREEN_HOME;
						ApplicationModel.instance.notifyProfileUpdate();
					} else {
						AppUtils.TRACE("_nextEcran::vendeurvo id="+_am.vendeurvo.id);
						new GetClientFromUser(_onGetClient).call(_am.vendeurvo.id);
					}
				} else {
					_am.clientvo = new ClientVO();
					_am.screen = ApplicationModel.SCREEN_INSCRIPTION;
					ApplicationModel.instance.notifyProfileUpdate();
				}
			}
			if (!ExternalInterface.available) _onResize();
		}
		
		private function _onGetClient(pResult:Object):void
		{
			if (pResult)
			{				
				AppUtils.TRACE("Main::_onGetClient > nom prenom=" + pResult.nom +"$"+pResult.prenom +"$ "+_am.vendeurvo.prenom+" "+_am.vendeurvo.nom);
				//-- Récupère la liste des clients... (Devrait être égal à 1 pour le FUT 12/2012)
				//var nbResultClients:int = pResult.length;
				
				//-- Valeurs bases du client
				var vo:ClientVO = new ClientVO();
				
				vo.id = pResult.id_client;
				vo.id_orange_client = pResult.id_orange_client;
				
				vo.id_agence = pResult.id_agence;
				vo.id_createur = pResult.id_createur;
				vo.id_dernier_modificateur = pResult.id_dernier_modificateur;
				vo.liste_id_projet = pResult.liste_id_projet;
				vo.id_civilite = pResult.id_civilite;
				
				// Modif temporaire pour le FUT de décembre 2012 (profile CLIENT-A-DOMICILE)
				vo.nom = pResult.nom || _am.vendeurvo.nom;
				AppUtils.TRACE("$"+pResult.prenom+"$ "+(pResult.prenom == "")+" "+ (pResult.prenom == null))
				vo.prenom = (pResult.prenom == "") ? _am.vendeurvo.prenom : pResult.prenom;
				
				vo.adresse = pResult.adresse;
				vo.cp = pResult.cp;
				vo.ville = pResult.ville;
				vo.email = pResult.email;
				vo.id_type_logement = pResult.id_type_logement;
				vo.accepte_collecte_infos = pResult.accepte_collecte_infos;
				vo.client_orange_fixe = pResult.client_orange_fixe;
				vo.id_autre_operateur_fixe = pResult.id_autre_operateur_fixe;
				vo.telephone_fixe = pResult.telephone_fixe;
				vo.client_orange_internet = pResult.client_orange_internet;
				vo.id_orange_forfait_internet = pResult.id_orange_forfait_internet;
				vo.id_autre_operateur_internet = pResult.id_autre_operateur_internet;
				vo.id_test_eligibilite = pResult.id_test_eligibilite;
				vo.id_livebox = pResult.id_livebox;
				vo.id_decodeur = pResult.id_decodeur;
				vo.client_orange_mobile = pResult.client_orange_mobile;
				vo.id_orange_forfait_mobile = pResult.id_orange_forfait_mobile;
				vo.id_autre_operateur_mobile = pResult.id_autre_operateur_mobile;
				vo.telephone_mobile = pResult.telephone_mobile;
				vo.client_orange_non = pResult.client_orange_non;
				
				// afffectation du vo au model
				_am.clientvo = vo;
				_am.notifyUpdateClientData();
				// redirection vers la home
				_am.screen = ApplicationModel.SCREEN_HOME;
				ApplicationModel.instance.notifyProfileUpdate();
			}
			else
			{
				AppUtils.TRACE("Main::_onGetClient > PAS DE RESULTAT client pour ce vendeur!");
			}
		}
		
		/**
		* Logout et quitte editeur
		*/
		public function _authentificationQuitteEditeur():void
		{
			AppUtils.TRACE("Main::_authentificationDbResult::_authentificationQuitteEditeur() >> provenance >> " + _am._auth_provenance);
			
			//-- Appel AMF LogoutClient
			if (ExternalInterface.available)
			{
				AppUtils.TRACE("Main::_authentificationQuitteEditeur()");
				new LogoutVendeur(_logoutResult).call();
			}
			else
			{
				_logoutResult(true);
			}
		}
		
		private function _logoutResult(pResult:Object):void
		{
			//-- Remise a zero
			_am.reset();
			_am.vendeurvo = null;
			_am.clientvo = null;
			_am.projetvo = null;
			_am.profilevo = null;
			
			//back to first screen
			//_am.screen = ApplicationModel.SCREEN_LOG;
			
			EditorModelLocator.instance.reset();
			
			//-- Redirection
			var request:URLRequest;
			if (pResult)
			{
				AppUtils.TRACE("Main::_authentificationDbResult::_authentificationQuitteEditeur()::_logoutResult > Déconnexion session OK !");
				request = new URLRequest(_am._url_login_internet);
			}else {
				AppUtils.TRACE("Main::_authentificationDbResult::_authentificationQuitteEditeur()::_logoutResult > Pbm de fin de session !");
				request = new URLRequest(_am._url_page_erreur);
			}
			
			try {
				navigateToURL(request, '_self');
			} catch (e:Error) {
				trace("Error occurred!");
			}			
		}
		
		/**
		 * Ecouteur du changement d'écran
		 * 
		 * @param e CurrentScreenUpdateEvent
		 */
		private function _onScreenUpdate(e:CurrentScreenUpdateEvent):void
		{
			var screen:String = _am.screen;
			switch(screen) {
				/*case ApplicationModel.SCREEN_LOG:
					addChild(new ScreenLog());
					break;*/	
				case ApplicationModel.SCREEN_HOME:
					addChild(new ScreenHome());
					break;
				case ApplicationModel.SCREEN_EDITOR:
					addChild(new ScreenEditor());
					break;
				case ApplicationModel.SCREEN_INSCRIPTION:
					addChild(new ScreenInscription());
					break;
				case ApplicationModel.SCREEN_SEARCH:
					addChild(new ScreenRecherche());
					break;
				case ApplicationModel.SCREEN_RECAP:
					addChild(new ScreenRecap());
					break;
			}
		}
		
		private function __pushHomeScreen(e:TimerEvent):void
		{	
			_am.screen = ApplicationModel.SCREEN_LOG;
		}
		
		private function __hide():void
		{
			removeChild(_simulText);
		}
		
		
		/**
		 * Ecouteur du resize
		 * 
		 * @param e Event
		 */
		private function _onResize(e:Event=null):void
		{
			var ww:int, hh:int, bgw:int, bgh:int;
            if (ExternalInterface.available) 
			{
				ww = ExternalInterface.call("detectWidth");
				hh = ExternalInterface.call("detectHeight");
			} else {
				ww = stage.stageWidth;
				hh = stage.stageHeight;
			}
			//trace("Main::_onResize()", ww, hh);
			//AppUtils.TRACE("Main::_onResize() "+ww+" "+ hh);
			Background.instance.update(ww, hh);
			
			//Probably place to use the code in ApplicationModel set maskSize ? TODO
			var w:int = ww;
			if (w < Config.RESOLUTION_WIDTH_MIN) w = Config.RESOLUTION_WIDTH_MIN;
			if (w > Config.RESOLUTION_WIDTH_MAX) w = Config.RESOLUTION_WIDTH_MAX;
			var h:int = hh;
			if (h < Config.RESOLUTION_HEIGHT_MIN) h = Config.RESOLUTION_HEIGHT_MIN;
			if (h > Config.RESOLUTION_HEIGHT_MAX) h = Config.RESOLUTION_HEIGHT_MAX;
			bgw = Config.MASK_BG_WIDTH_MAX - (Config.RESOLUTION_WIDTH_MAX - w) * (Config.MASK_BG_WIDTH_MAX - Config.MASK_BG_WIDTH_MIN) / (Config.RESOLUTION_WIDTH_MAX - Config.RESOLUTION_WIDTH_MIN);
			bgh = Config.MASK_BG_HEIGHT_MAX - (Config.RESOLUTION_HEIGHT_MAX - h) * (Config.MASK_BG_HEIGHT_MAX - Config.MASK_BG_HEIGHT_MIN) / (Config.RESOLUTION_HEIGHT_MAX - Config.RESOLUTION_HEIGHT_MIN);
			
			x = int((ww - bgw) / 2) //-5;
			y = int((hh - bgh) / 2) //-39;
			
			if(_footer) _footer.y = Background.instance.masq.height + 8;
			
			//trace("Main::onResize() " +"x", x, "y", y);
		}
		
		
		/**
		* Key listener, Ecouteur du Control Z pour la gestion de l'annulation des actions
		* 
		*/
		private function _onKeyUp(e:KeyboardEvent):void
		{
			//trace("Main::_onKeyUp()");//loosing focus when using removeChild on buttons / sprites
			
			if (e.ctrlKey && e.keyCode === 90) {
				//trace("Main::_onKeyUp() ctrl + Z");
				if (_am.screen == ApplicationModel.SCREEN_EDITOR) {
					_history.popHistory();
					EditorModelLocator.instance.notifyUndoMovePointListener();
				}
			}
		}
	}

}