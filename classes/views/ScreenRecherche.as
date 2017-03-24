package classes.views
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.services.php.ListeClients;
	import classes.services.php.ListeClientsPocd;
	import classes.utils.AppUtils;
	import classes.vo.ClientVO;
	import classes.vo.ProjetVO;
	import fl.containers.ScrollPane;
	import fl.controls.ComboBox;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * Source de ce fichier dans le fla.
	 * Probablement à recoder en vue d'exclure du fla tout le clip
	 */
	public class ScreenRecherche extends Screen
	{
		private var _recherche:Recherche;
		private var _scrollpane:ScrollPane;
		private var _container:Sprite;
		private var _currentTri:String;
		private var _currentSearch:String;
		private var _tabLignesContainer:Array;
		private var _fond:Shape;
		//private var _btnAide:BtnAide;
		private var _btnColorOff:Number = 0xFFFFFF;
		private var _btnColorOn:Number = 0xFFCC00;
		
		public function ScreenRecherche()
		{
			screen = ApplicationModel.SCREEN_SEARCH;
			super();
		}
		
		override protected function _added(e:Event):void
		{
			super._added(e);
			//model.hasSeenStartPopup = false;
			//model.reset();
			_init();
		}
		
		private function _init():void
		{
			//-- Param de _recherche
			_currentTri = "";
			_currentSearch = "";
			
			//-- Nvl écran de recherche
			_recherche = new Recherche();
			_recherche.x = 55;
			_recherche.y = 75;
			
			//-- Cree le fond
			_fond = new Shape();
			_recherche.fond.addChild(_fond);
			
			//-- Ajoute le scroll
			_scrollpane = new ScrollPane();
			_scrollpane.alpha = 0;
			_scrollpane.x = 0;
			_scrollpane.y = 115;
			_recherche.addChild(_scrollpane);
			
			//-- titre
			var t:CommonTextField = new CommonTextField("helvet35", 0x999999, 40);
			t.width = 188;
			t.x = 17;
			t.setText(AppLabels.getString("search_title"));
			_recherche.addChild(t);
			
			//-- Bouton Aide //FJ déplacé dans Header.as (btn démo)
			/*_btnAide = new BtnAide();
			addChild(_btnAide);
			_btnAide.buttonMode = true;
			_btnAide.mouseChildren = false;
			_btnAide.addEventListener(MouseEvent.CLICK, _clickAide, false, 0, true);*/
			
			//-- Ecouteur de resize
			stage.addEventListener(Event.RESIZE, _onResize);
			
			//-- size le fond et le container
			_onResize();
			
			//-- Ajoute le _container de la liste de clients
			_container = new Sprite();
			_container.x = 14, _container.y = 111;
			_recherche.addChild(_container);
			
			//-- Btn de recherche		
			//_recherche.searchBox.btn_search.useHandCursor = true;
			_recherche.searchBox.btn_search.buttonMode = true;
			_recherche.searchBox.btn_search.mouseChildren = false;
			_recherche.searchBox.btn_search.addEventListener(MouseEvent.CLICK, _btnPressSearch);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyPressSearch);
			
			//-- Btn de reset de la recherche		
			_recherche.searchBox.btn_reset.visible = false;
			_recherche.searchBox.btn_reset.buttonMode = true;
			_recherche.searchBox.btn_reset.mouseChildren = false;
			_recherche.searchBox.btn_reset.addEventListener(MouseEvent.CLICK, _resetSearch);
			
			//-- Entete des colonnes
			_recherche.entete_colonnes.visible = false;
			_recherche.fond.visible = false;
			
			//-- Boutons de tri
			_recherche.entete_colonnes.btnTriDate.gotoAndStop(1);
			_recherche.entete_colonnes.btnTriDate.buttonMode = true;
			_recherche.entete_colonnes.btnTriDate.mouseChildren = false;
			_recherche.entete_colonnes.btnTriDate.addEventListener(MouseEvent.CLICK, _btnPressTri);
			_recherche.entete_colonnes.btnTriNom.gotoAndStop(2);
			//_recherche.entete_colonnes.btnTriNom.gotoAndStop(1);
			_recherche.entete_colonnes.btnTriNom.buttonMode = true;
			_recherche.entete_colonnes.btnTriNom.mouseChildren = false;
			_recherche.entete_colonnes.btnTriNom.addEventListener(MouseEvent.CLICK, _btnPressTri);
			
			//-- Btn d'actualisation
			//_recherche.btn_refresh.buttonMode = true;
			//_recherche.btn_refresh.mouseChildren = false;
			//_recherche.btn_refresh.addEventListener(MouseEvent.CLICK, _btnPressRefresh);
			
			//-- Btn inscription
			/*var bnt:Btn = new Btn(0x333333, AppLabels.getString("buttons_newClient"), null, 130);
			bnt.x = 892 -130;
			bnt.y = 22;
			_recherche.addChild(bnt);
			_recherche.btn_inscription = bnt;
			//_recherche.btn_inscription.buttonMode = true;
			//_recherche.btn_inscription.mouseChildren = false;
			_recherche.btn_inscription.addEventListener(MouseEvent.CLICK, _btnPressInscription);*/
			
			//-- Ajoute l'écran sur la scene
			addChild(_recherche);
			
			//-- Charge la liste de clients
			_tabLignesContainer = new Array();
			//_validListRequest();
			
			//-- Lance la recherche auto si en provenance du POCD
			if (ApplicationModel.instance._auth_provenance == Main.AUTH_REFERER_POCD && (ApplicationModel.instance._auth_listeClients != null && ApplicationModel.instance._auth_listeClients.length > 2)) {
				new ListeClientsPocd(_listeClientsResult).call(ApplicationModel.instance._auth_listeClients);
				
				//-- ApplicationModel.instance._auth_listeClients = "" si retour OK dans "_listeClientsResult"
			}else {
				ApplicationModel.instance._auth_listeClients = "";
			}
		}
		
		private function _onResize(e:Event = null):void
		{
			//-- Resize le fond
			_fond.graphics.clear();
			_fond.graphics.beginFill(0x111A20, 0.8);
			var large:int = 894;
			var haute:int = ApplicationModel.instance.maskSize.height - 100 -50;
			_fond.graphics.drawRoundRect(0, 0, large, haute, 15, 15);
			
			//-- Resize le container
			//_scrollpane.setSize(870, 400);
			_scrollpane.setSize(870, haute - 80);
			
			/*var b:Background = Background.instance;
			_btnAide.x = b.masq.width - 25;
			_btnAide.y = 64;*/
		}
		
		private function _btnPressTri(pEvt:MouseEvent):void
		{
			var btnTri:MovieClip = pEvt.currentTarget as MovieClip;
			
			AppUtils.TRACE("ScreenRecherche::_btnPressTri(" + btnTri.name + ") > frame=" + btnTri.currentFrame);
			
			switch (btnTri.name)
			{
				case "btnTriDate": 
					//-- tri sur "date_creation" par defaut
					if (btnTri.currentFrame == 1 || btnTri.currentFrame == 3)
					{
						btnTri.gotoAndStop(2);
						_currentTri = "date";
					}
					else if (btnTri.currentFrame == 2)
					{
						btnTri.gotoAndStop(3);
						_currentTri = "date DESC";
					}
					_recherche.entete_colonnes.btnTriNom.gotoAndStop(1);
					break;
				case "btnTriNom": 
					//-- tri sur "date_creation" par defaut
					if (btnTri.currentFrame == 1 || btnTri.currentFrame == 3)
					{
						btnTri.gotoAndStop(2);
						_currentTri = "nom";
					}
					else if (btnTri.currentFrame == 2)
					{
						btnTri.gotoAndStop(3);
						_currentTri = "nom DESC";
					}
					_recherche.entete_colonnes.btnTriDate.gotoAndStop(1);
					break;
				default: 
			}
			_validListRequest();
		}
		
		private function _btnPressSearch(pEvt:MouseEvent):void
		{
			_validSearch();
		}
		
		private function _keyPressSearch(pEvt:KeyboardEvent):void
		{
			if (pEvt.keyCode == Keyboard.ENTER)
			{
				_validSearch();
			}
		}
		
		/*private function _btnPressRefresh(pEvt:MouseEvent):void
		   {
		   //AppUtils.TRACE("ScreenRecherche::_btnPressRefresh()");
		   _validListRequest();
		 }*/
		
		private function _btnPressInscription(pEvt:MouseEvent):void
		{
			//AppUtils.TRACE("ScreenRecherche::_btnPressInscription()");
			ApplicationModel.instance.clientvo = new ClientVO();
			ApplicationModel.instance.screen = ApplicationModel.SCREEN_INSCRIPTION;
		}
		
		private function _validSearch():void
		{
			if (_recherche.searchBox.txt_recherche.text.length < 1)
			{
				//AppUtils.TRACE("searchBox > _validListRequest() chaine vide");
				_currentSearch = "";
				_recherche.searchBox.btn_reset.visible = false;
			}
			else
			{
				_recherche.searchBox.btn_reset.visible = true;
				_currentSearch = _recherche.searchBox.txt_recherche.text;
				_validListRequest();
			}
		}
		
		private function _resetSearch(pEvt:MouseEvent):void
		{
			AppUtils.TRACE("ScreenRecherche::_resetSearch()");
			if (_recherche.searchBox.txt_recherche.text.length > 0)
			{
				_recherche.searchBox.btn_reset.visible = false;
				_currentSearch = "";
				_recherche.searchBox.txt_recherche.text = "";
				
				//-- Entete des colonnes
				_recherche.entete_colonnes.visible = false;
				_recherche.fond.visible = false;
				
				//-- Cache le scrollpane
				_scrollpane.alpha = 0;
				
				//-- Efface les lignes du container
				_cleanContainer();
				
				//_validListRequest();
			}
		}
		
		private function _validListRequest():void
		{
			AppUtils.TRACE("ScreenRecherche::_validListRequest > tri=" + _currentTri + " / search=" + _currentSearch);
			
			//-- Cache la liste actuelle
			_scrollpane.alpha = 0;
			
			//-- Efface les lignes du container
			_cleanContainer();
			
			//-- Charge la liste recherchée
			if (ExternalInterface.available)
			{
				new ListeClients(_listeClientsResult).call(_currentTri, _currentSearch);
			}
			else
			{
				//-- TEMPORAIRE
				/*var vo:ClientVO = new ClientVO();
				   vo.id_client = 4;
				   vo.id_orange = "12345678";
				   vo.nom = "Caudron";
				   vo.prenom = "Vincent";
				
				   model.vendeurvo =  vo;
				 */
			}
			//model.screen = ApplicationModel.SCREEN_EDITOR;
		}
		
		private function _cleanContainer():void
		{
			//-- Msg aucun resultat
			_recherche.msg.text = "";
			
			//-- Efface les elements
			var ligneElt:LigneResultatClient;
			while (_tabLignesContainer.length > 0)
			{
				//-- recupere l'element
				ligneElt = _tabLignesContainer.pop();
				
				//AppUtils.TRACE("ScreenRecherche::_cleanContainer > " + ligneElt.name);
				
				//-- Efface les ecouteurs
				//ligneElt.comboProjets.removeEventListener(Event.CHANGE, _changeHandlerProjets);
				if(ligneElt.btn && ligneElt.btn.stage) ligneElt.btn.removeEventListener(MouseEvent.CLICK, _btnPressLigneProjet);
				ligneElt.btn_modifier.removeEventListener(MouseEvent.CLICK, _btnPressModifierClient);
				ligneElt.btn_modifier.removeEventListener(MouseEvent.ROLL_OVER, _btnRollOverModifierClient);
				ligneElt.btn_modifier.removeEventListener(MouseEvent.ROLL_OUT, _btnRollOutModifierClient);
				
				//-- retire l'elet de la scene et efface le ref
				_container.removeChild(ligneElt);
			}
		}
		
		private function _listeClientsResult(pResult:Object):void
		{
			//trace("listeClientsSearchResult !");
			//AppUtils.TRACE("ScreenRecherche::_listeClientsResult > " + pResult);
			if (pResult)
			{
				//-- Remise a zero de l'autosearch quand on vient du POCD
				ApplicationModel.instance._auth_listeClients = "";
				
				//-- Entete des colonnes
				_recherche.entete_colonnes.visible = true;
				_recherche.fond.visible = true;
				
				AppUtils.TRACE("ScreenRecherche::_listeClientsResult > nb=" + pResult.length);
				//-- Récupère la liste des clients...
				var nbResultClients:int = pResult.length;
				
				for (var i:int = 0; i < nbResultClients; i++)
				{
					var resultatClient:Array = (pResult as Array)[i];
					
					//-- Ajoute la ligne du client a la liste
					var ligneClient:LigneResultatClient = new LigneResultatClient();
					ligneClient.x = 20;
					ligneClient.y = i * 40;
					
					//--Id client de la ligne
					ligneClient.id = resultatClient[0].id_client;
					
					//-- Valeurs bases du client
					var vo:ClientVO = new ClientVO();
					
					vo.id = resultatClient[0].id_client;
					vo.id_orange_client = resultatClient[0].id_orange_client;
					
					vo.id_agence = resultatClient[0].id_agence;
					vo.id_createur = resultatClient[0].id_createur;
					vo.id_dernier_modificateur = resultatClient[0].id_dernier_modificateur;
					vo.liste_id_projet = resultatClient[0].liste_id_projet;
					//AppUtils.TRACE("\tclient id:"+ligneClient.id+" "+vo.id_agence);
					
					vo.id_civilite = resultatClient[0].id_civilite;
					vo.nom = resultatClient[0].nom;
					vo.prenom = resultatClient[0].prenom;
					vo.adresse = resultatClient[0].adresse;
					vo.cp = resultatClient[0].cp;
					vo.ville = resultatClient[0].ville;
					vo.email = resultatClient[0].email;
					vo.id_type_logement = resultatClient[0].id_type_logement;
					vo.accepte_collecte_infos = resultatClient[0].accepte_collecte_infos;
					vo.client_orange_fixe = resultatClient[0].client_orange_fixe;
					vo.id_autre_operateur_fixe = resultatClient[0].id_autre_operateur_fixe;
					vo.telephone_fixe = resultatClient[0].telephone_fixe;
					vo.client_orange_internet = resultatClient[0].client_orange_internet;
					vo.id_orange_forfait_internet = resultatClient[0].id_orange_forfait_internet;
					vo.id_autre_operateur_internet = resultatClient[0].id_autre_operateur_internet;
					vo.id_test_eligibilite = resultatClient[0].id_test_eligibilite;
					vo.id_livebox = resultatClient[0].id_livebox;
					vo.id_decodeur = resultatClient[0].id_decodeur;
					vo.client_orange_mobile = resultatClient[0].client_orange_mobile;
					vo.id_orange_forfait_mobile = resultatClient[0].id_orange_forfait_mobile;
					vo.id_autre_operateur_mobile = resultatClient[0].id_autre_operateur_mobile;
					vo.telephone_mobile = resultatClient[0].telephone_mobile;
					vo.client_orange_non = resultatClient[0].client_orange_non;
					
					ligneClient.vo = vo;
					//ligneClient.name = "client" + resultatClient[0].id_client;
					
					//-- Valeurs du client
					ligneClient.date.text = resultatClient[0].date;
					//ligneClient.heure.text = resultatClient[0].heure;
					//ligneClient.dossier.text = resultatClient[0].id_client;
					ligneClient.nom.text = resultatClient[0].nom + " " + resultatClient[0].prenom;
					//ligneClient.prenom.text = resultatClient[0].prenom;
					ligneClient.telephone.text = resultatClient[0].telephone_fixe;
					ligneClient.mobile.text = resultatClient[0].telephone_mobile;
					
					if (ligneClient.nom.text.length < 2)
					{
						ligneClient.nom.text = "-";
					}
					else if (ligneClient.nom.text.length > 23)
					{
						ligneClient.nom.text = ligneClient.nom.text.substr(0, 21) + "...";
					}
					/*if(ligneClient.prenom.text.length < 1)
					 ligneClient.prenom.text = "-";*/
					if (ligneClient.telephone.text.length < 1)
						ligneClient.telephone.text = "-";
					if (ligneClient.mobile.text.length < 1)
						ligneClient.mobile.text = "-";
					
					//-- Ajoute le combobox liste des projets
					/*var nbResultProjets:int = resultatClient[1].length;
					if (nbResultProjets > 0)
					{
						var dp:DataProvider = new DataProvider();
						dp.addItem({label: "choisissez", data: null});
						for (var j:int = 0; j < nbResultProjets; j++)
						{
							//AppUtils.TRACE("ScreenRecherche::_listeClientsResult > resultatClient[" + i + "] > projets " + resultatClient[1][j].id_client_projet + " " + resultatClient[1][j].nom);
							dp.addItem({label: resultatClient[1][j].id_projet + " : " + resultatClient[1][j].nom, data: resultatClient[1][j].id_projet});
						}
						ligneClient.comboProjets.dataProvider = dp;
						ligneClient.comboProjets.addEventListener(Event.CHANGE, _changeHandlerProjets);
					}
					else
					{
						//-- Pas de projets
						ligneClient.comboProjets.visible = false;
					}*/
					
					//-- Active le bouton nouveau projet
					ligneClient.btn_modifier.buttonMode = true;
					ligneClient.btn_modifier.mouseChildren = false;
					ligneClient.btn_modifier.addEventListener(MouseEvent.CLICK, _btnPressModifierClient);
					ligneClient.btn_modifier.addEventListener(MouseEvent.ROLL_OVER, _btnRollOverModifierClient);
					ligneClient.btn_modifier.addEventListener(MouseEvent.ROLL_OUT, _btnRollOutModifierClient);
					
					//-- Active le bouton nouveau projet
					var b:Btn = new Btn(0, AppLabels.getString("buttons_validate"), null, 68, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
					ligneClient.addChild(b);
					b.x = 602;
					b.y = 0//12;
					ligneClient.btn = b;
					//ligneClient.btn.mouseChildren = false;
					ligneClient.btn.addEventListener(MouseEvent.CLICK, _btnPressLigneProjet);
					
					//-- Stoque la ligne dans le tableau "_tabLignesContainer"
					_tabLignesContainer.push(ligneClient);
					
					//-- Ajoute la ligne au _container
					_container.addChild(ligneClient);
					
					//AppUtils.TRACE("ScreenRecherche::_listeClientsResult > resultatClient[" + i + "] : " + resultatClient[0].nom + " " + resultatClient[0].prenom + " / " + nbResultProjets + " projets");
				}
				
				//-- Mise a jour du scroll
				_scrollpane.source = _container;
				_scrollpane.verticalScrollPosition = 0;
				
				//-- Affiche le resultat
				var t:Tween = new Tween(_scrollpane, "alpha", Regular.easeOut, 0, 1, 1, true);
				
			}
			else
			{
				AppUtils.TRACE("ScreenRecherche::_listeClientsResult > PAS DE RESULTAT");
				//AppUtils.TRACE("ScreenRecherche::_listeClientsResult > pas de resultat");
				//-- Pas de résultat
				_scrollpane.alpha = 0;
				_recherche.msg.text = AppLabels.getString("search_noResult");
			}
		}
		
		private function _changeHandlerProjets(pEvt:Event):void
		{
			AppUtils.TRACE("ScreenRecherche::_changeHandlerProjets > client=" + (pEvt.currentTarget.parent as LigneResultatClient).id + " projet=" + ComboBox(pEvt.target).selectedItem.data);
			(pEvt.currentTarget.parent as LigneResultatClient).setAsCurrentProjet(ComboBox(pEvt.target).selectedItem.data);
		}
		
		private function _btnPressLigneProjet(pEvt:MouseEvent):void
		{
			//AppUtils.TRACE("ScreenRecherche::_btnPressLigneProjet > client=" + (pEvt.currentTarget.parent as LigneResultatClient).id);
			//AppUtils.TRACE("ScreenRecherche::_btnPressLigneProjet > client");
			ApplicationModel.instance.projetvo = new ProjetVO();
			//AppUtils.TRACE("ScreenRecherche::_btnPressLigneProjet projetvo.id=" + ApplicationModel.instance.projetvo.id);
			(pEvt.currentTarget.parent as LigneResultatClient).setAsCurrentClient("_btnPressLigneProjet");
		}
		
		private function _btnPressModifierClient(pEvt:MouseEvent):void
		{
			AppUtils.TRACE("ScreenRecherche::_btnPressModifierClient > client=" + (pEvt.currentTarget.parent as LigneResultatClient).id);
			(pEvt.currentTarget.parent as LigneResultatClient).modifierClient();
		}
		
		private function _btnRollOverModifierClient(pEvt:MouseEvent):void
		{
			(pEvt.currentTarget.parent.date as TextField).textColor = _btnColorOn;
			//(pEvt.currentTarget.parent.dossier as TextField).textColor = _btnColorOn;
			(pEvt.currentTarget.parent.nom as TextField).textColor = _btnColorOn;
			(pEvt.currentTarget.parent.telephone as TextField).textColor = _btnColorOn;
			(pEvt.currentTarget.parent.mobile as TextField).textColor = _btnColorOn;
		}
		
		private function _btnRollOutModifierClient(pEvt:MouseEvent):void
		{
			(pEvt.currentTarget.parent.date as TextField).textColor = _btnColorOff;
			//(pEvt.currentTarget.parent.dossier as TextField).textColor = _btnColorOff;
			(pEvt.currentTarget.parent.nom as TextField).textColor = _btnColorOff;
			(pEvt.currentTarget.parent.telephone as TextField).textColor = _btnColorOff;
			(pEvt.currentTarget.parent.mobile as TextField).textColor = _btnColorOff;
		}
		
		override protected function cleanup():void
		{
			//-- Param de _recherche
			_currentTri = "";
			_currentSearch = "";
			
			//-- Msg aucun resultat
			_recherche.msg.text = "";
			
			//-- Boutons de tri
			_recherche.entete_colonnes.btnTriDate.gotoAndStop(2);
			_recherche.entete_colonnes.btnTriDate.removeEventListener(MouseEvent.CLICK, _btnPressTri);
			_recherche.entete_colonnes.btnTriNom.gotoAndStop(1);
			_recherche.entete_colonnes.btnTriNom.removeEventListener(MouseEvent.CLICK, _btnPressTri);
			
			//-- Btn de _recherche
			_recherche.searchBox.btn_search.removeEventListener(MouseEvent.CLICK, _btnPressSearch);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _keyPressSearch);
			_recherche.searchBox.btn_reset.removeEventListener(MouseEvent.CLICK, _btnPressSearch);
			
			//-- Btn d'actualisation
			//_recherche.btn_refresh.removeEventListener(MouseEvent.CLICK, _validListRequest);
			
			//-- Btn d'inscription
			//_recherche.btn_inscription.removeEventListener(MouseEvent.CLICK, _btnPressInscription);
			
			//-- Gestion resize
			stage.removeEventListener(Event.RESIZE, _onResize);
			
			//-- Efface les lignes du container
			_cleanContainer();
			
			super.cleanup();
		}
	}
}