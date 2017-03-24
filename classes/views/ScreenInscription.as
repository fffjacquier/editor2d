package classes.views
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.FormUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.YesNoAlert;
	import classes.vo.ClientVO;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Cette classe fait partie de editeur.swc, les sources sont dans le fla.
	 * Affiche et gère l'écran d'inscription d'un nouveau client et d'édition d'un client existant.
	 */
	public class ScreenInscription extends Screen
	{
		private var _am:ApplicationModel = ApplicationModel.instance;
		
		private var _inscription:Inscription;		
		private var _textColorOff:Number = 0xFFFFFF;
		private var _textColorOn:Number = 0xFF9900;
		private var _titreColorOff:Number = 0xFFFFFF;
		private var _titreColorOn:Number = 0xFFCC00;
		private var f_12:Font = new Helvet55Reg();
		private var tf_11_bold:TextFormat = new TextFormat();
		private var tf_11_bold_selected:TextFormat = new TextFormat();
		private var tf_12_bold:TextFormat = new TextFormat();
		private var tf_12_bold_selected:TextFormat = new TextFormat();
		private var tf_12:TextFormat = new TextFormat();
		private var titre_12:TextFormat = new TextFormat();
		private var titre_12_oblig:TextFormat = new TextFormat();
		private var titre_12_bold:TextFormat = new TextFormat();
		private var tf_12_combos:TextFormat = new TextFormat();
		
		private var tab_combos_name:Array;
		private var tab_checkbox_name:Array = new Array("accepte_collecte_info", "client_orange_fixe", "client_orange_internet", "client_orange_mobile", "client_orange_non");
		private var tab_radio_name:Array = new Array("civilite1", "civilite2", "civilite3", "type_logement1", "type_logement2");
		private var tab_champs_name:Array = new Array("nom", "prenom", "adresse", "cp", "ville", "telephone_fixe", "telephone_mobile", "email");
		private var elt_alpha:Number = 0.3;
		
		public function ScreenInscription()
		{
			screen = ApplicationModel.SCREEN_INSCRIPTION;
			tab_combos_name = _am.tab_combos_name
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
			_inscription = new Inscription();
			addChild(_inscription);
			_inscription.x = 55;
			_inscription.y = 75;
			
			//-- titre
			var t:CommonTextField = new CommonTextField("helvet35", 0x999999, 40);
			t.width = 500;
			t.x = 17;
			t.setText(AppLabels.getString("form_title"));
			_inscription.addChild(t);
			
			//-- Btn recherche
			/*var btnSearch:Btn = new Btn(0x333333, AppLabels.getString("buttons_searchClient"), null, 130);
			_inscription.addChild(btnSearch);
			btnSearch.x = 892 -130;
			btnSearch.y = 22;
			_inscription.btn_recherche = btnSearch;
			_inscription.btn_recherche.visible = (model.profilevo.acces_recherche);
			_inscription.btn_recherche.buttonMode = true;
			_inscription.btn_recherche.mouseChildren = false;
			_inscription.btn_recherche.addEventListener(MouseEvent.CLICK, _btnPressRecherche);*/
			
			//--Test si nouvelle inscription ou modification
			AppUtils.TRACE("ScreenInscription::_init > clientvo.id = " + _am.clientvo.id);
			
			//-- Btn effacer
			var btnReset:Btn = new Btn(0, AppLabels.getString("buttons_erase"), null, 61, 0xffffff, 12, 24, Btn.GRADIENT_DARK);
			_inscription.addChild(btnReset);
			btnReset.x = 892 -80 -80;
			btnReset.y = 344;
			_inscription.btn_reset = btnReset;
			
			//-- Btn save
			var btnSave:Btn = new Btn(0, AppLabels.getString("buttons_validate"), null, 70, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			_inscription.addChild(btnSave);
			btnSave.x = 892 -80;
			btnSave.y = 344;
			_inscription.btn_save = btnSave;
			
			//-- Affiche le formulaire
			_formEtat("INIT");
		
			//-- set values to checkbox and radiobuttons
			_inscription.chp_accepte_collecte_info.label = AppLabels.getString("form_accept");
			_inscription.chp_client_orange_fixe.label = AppLabels.getString("form_phoneCustomer");
			_inscription.chp_client_orange_internet.label = AppLabels.getString("form_internetCustomer");
			_inscription.chp_client_orange_mobile.label = AppLabels.getString("form_mobileCustomer");
			_inscription.chp_client_orange_non.label = AppLabels.getString("form_notCustomer");
			_inscription.chp_civilite2.label = AppLabels.getString("common_madam");
			_inscription.chp_civilite1.label = AppLabels.getString("common_miss");
			_inscription.chp_civilite3.label = AppLabels.getString("common_mister");
			_inscription.chp_type_logement2.label = AppLabels.getString("form_flat");
			_inscription.chp_type_logement1.label = AppLabels.getString("form_house");
			
			//-- valeurs champs de texte
			_inscription.chp_nom_titre.text = AppLabels.getString("form_lastname");
			_inscription.chp_prenom_titre.text = AppLabels.getString("form_firstname");
			_inscription.chp_adresse_titre.text = AppLabels.getString("form_address");
			_inscription.chp_cp_titre.text = AppLabels.getString("form_postalCode");
			_inscription.chp_ville_titre.text = AppLabels.getString("form_city");
			_inscription.chp_telephone_fixe_titre.text = AppLabels.getString("form_phone");
			_inscription.chp_telephone_mobile_titre.text = AppLabels.getString("form_mobile");
			_inscription.chp_email_titre.text = AppLabels.getString("form_email");
			
			//-- restricts
			_inscription.chp_ville.restrict = "^0-9";
			//-- TEMP
			/*_inscription.chp_nom.text = "Nom " + String(new Date().getTime());
			_inscription.chp_prenom.text = "Prénom";
			_inscription.chp_adresse.text = "45 rue du Parc";
			_inscription.chp_cp.text = "12345";
			_inscription.chp_ville.text = "Ville";
			_inscription.chp_email.text = "toto@titi.com";*/
		}
		
		/*private function _btnPressRecherche(pEvt:MouseEvent):void
		{
			//AppUtils.TRACE("ScreenRecherche::_btnPressInscription()");
			model.screen = ApplicationModel.SCREEN_SEARCH;
		}*/
		
		private function _initListBoxes():void
		{
			//trace("listeClientsSearchResult !");
			AppUtils.TRACE("ScreenInscription::_initListBoxes > nbCombos=" + tab_combos_name.length);
			
			//-- recuperation des infos des combos
			//-- Eligibilite, Forfait Orange Internet, Livebox, Decodeur, Forfait Orange Mobile, Autre operateur internet, Autre operateur mobile, Autre operateur fixe
			
			//-- Pour chaque retour, 1 combo...
			var nbCombos:int = tab_combos_name.length;
			var comboName:String;
			var comboBoxListe:ComboBox;
			var comboFirstLabel:String;
			var comboAutreLabel:String;
			var resultatCombo:Array;
			var nbResultCombo:int;
			//var dp:DataProvider;
			
			for (var i:int = 0; i < nbCombos; i++)
			{
				if (tab_combos_name[i] != null)
				{
					
					//-- Param du combo
					comboName =  tab_combos_name[i][0];
					comboBoxListe = _inscription["chp_" + comboName];
					
					//-- Applique le sytle au combo
					/*comboBoxListe.setStyle("embedFonts", true);
					   comboBoxListe.setStyle("textFormat", tf_12_combos);
					   comboBoxListe.setStyle("disabledTextFormat", tf_12_combos);
					   comboBoxListe.dropdown.setStyle("embedFonts", true);
					   comboBoxListe.dropdown.setRendererStyle("textFormat", tf_12_combos);
					 comboBoxListe.dropdown.setRendererStyle("disabledTextFormat", tf_12_combos);*/
					
					//-- Affecte le data provider a la listbox				
					comboBoxListe.dataProvider = _am._liste_combos.getListeBoxDp(comboName);
					comboBoxListe.selectedIndex = 0;
				}
			}
			
			/*//-- Mise a jour du scroll
			   _scrollpane.source = _container;
			   _scrollpane.verticalScrollPosition = 0;
			 */
			
			//-- Charge les données du clientVO si modification
			if (_am.clientvo.id != -1)
			{
				_loadClientVO2Form(_am.clientvo);
			}
		}
		
		private function _initFormStyle():void
		{
			//trace("f_12.fontName=" + f_12.fontName)
			
			tf_11_bold.font = f_12.fontName;
			tf_11_bold.color = _textColorOff;
			tf_11_bold.size = 12;
			tf_11_bold.bold = true;
			
			tf_11_bold_selected.font = f_12.fontName;
			tf_11_bold_selected.color = _textColorOn;
			tf_11_bold_selected.size = 12;
			tf_11_bold_selected.bold = true;
			
			tf_12_bold.font = f_12.fontName;
			tf_12_bold.color = _textColorOff;
			tf_12_bold.size = 13;
			tf_12_bold.bold = true;
			
			tf_12_bold_selected.font = f_12.fontName;
			tf_12_bold_selected.color = _textColorOn;
			tf_12_bold_selected.size = 13;
			tf_12_bold_selected.bold = true;
			
			/*
			   tf_12.font = f_12.fontName;
			   tf_12.color = _textColorOff;
			   tf_12.size = 13;
			 */
			
			tf_12.font = f_12.fontName;
			tf_12.color = _titreColorOff;
			tf_12.size = 12;
			
			titre_12.font = f_12.fontName;
			titre_12.color = _titreColorOff;
			titre_12.size = 12;
			
			titre_12_bold.font = f_12.fontName;
			titre_12_bold.color = _titreColorOn;
			titre_12_bold.size = 12;
			titre_12_bold.bold = true;
			
			titre_12_oblig.font = f_12.fontName;
			titre_12_oblig.color = _titreColorOn;
			titre_12_oblig.size = 12;
			
			tf_12_combos.font = f_12.fontName;
			tf_12_combos.color = 0x000000;
			tf_12_combos.size = 13;
			tf_12_combos.bold = true;
		}
		
		private function _setFormStyle():void
		{
			//-- Accepte la collecte d'info
			_inscription.chp_accepte_collecte_info.setStyle("embedFonts", true);
			_inscription.chp_accepte_collecte_info.setStyle("textFormat", tf_11_bold);
			
			//-- Type de client
			_inscription.chp_client_orange_fixe.setStyle("embedFonts", true);
			_inscription.chp_client_orange_fixe.setStyle("textFormat", tf_12_bold);
			_inscription.chp_client_orange_fixe.setStyle("disabledTextFormat", tf_12_bold);
			_inscription.chp_client_orange_mobile.setStyle("embedFonts", true);
			_inscription.chp_client_orange_mobile.setStyle("textFormat", _inscription.chp_client_orange_fixe.getStyle("textFormat"));
			_inscription.chp_client_orange_mobile.setStyle("disabledTextFormat", tf_12_bold);
			_inscription.chp_client_orange_internet.setStyle("embedFonts", true);
			_inscription.chp_client_orange_internet.setStyle("textFormat", _inscription.chp_client_orange_fixe.getStyle("textFormat"));
			_inscription.chp_client_orange_internet.setStyle("disabledTextFormat", tf_12_bold);
			_inscription.chp_client_orange_non.setStyle("embedFonts", true);
			_inscription.chp_client_orange_non.setStyle("textFormat", _inscription.chp_client_orange_fixe.getStyle("textFormat"));
			_inscription.chp_client_orange_non.setStyle("disabledTextFormat", tf_12_bold);
			
			//-- Civilite
			_inscription.chp_civilite1.setStyle("embedFonts", true);
			_inscription.chp_civilite1.setStyle("textFormat", tf_11_bold);
			_inscription.chp_civilite2.setStyle("embedFonts", true);
			_inscription.chp_civilite2.setStyle("textFormat", _inscription.chp_civilite1.getStyle("textFormat"));
			_inscription.chp_civilite2.setStyle("disabledTextFormat", _inscription.chp_civilite1.getStyle("textFormat"));
			_inscription.chp_civilite3.setStyle("embedFonts", true);
			_inscription.chp_civilite3.setStyle("textFormat", _inscription.chp_civilite1.getStyle("textFormat"));
			_inscription.chp_civilite3.setStyle("disabledTextFormat", _inscription.chp_civilite1.getStyle("textFormat"));
			
			//-- Nom adresse...
			_inscription.chp_nom.embedFonts = true;
			_inscription.chp_prenom.embedFonts = true;
			_inscription.chp_adresse.embedFonts = true;
			_inscription.chp_cp.embedFonts = true;
			_inscription.chp_ville.embedFonts = true;
			_inscription.chp_telephone_fixe.embedFonts = true;
			_inscription.chp_telephone_mobile.embedFonts = true;
			_inscription.chp_email.embedFonts = true;
			
			_inscription.chp_nom_titre.embedFonts = true;
			_inscription.chp_prenom_titre.embedFonts = true;
			_inscription.chp_adresse_titre.embedFonts = true;
			_inscription.chp_cp_titre.embedFonts = true;
			_inscription.chp_ville_titre.embedFonts = true;
			_inscription.chp_telephone_fixe_titre.embedFonts = true;
			_inscription.chp_telephone_mobile_titre.embedFonts = true;
			_inscription.chp_email_titre.embedFonts = true;
			
			_inscription.chp_nom.setTextFormat(tf_12);
			_inscription.chp_prenom.setTextFormat(tf_12);
			_inscription.chp_adresse.setTextFormat(tf_12);
			_inscription.chp_cp.setTextFormat(tf_12);
			_inscription.chp_ville.setTextFormat(tf_12);
			_inscription.chp_telephone_fixe.setTextFormat(tf_12);
			_inscription.chp_telephone_mobile.setTextFormat(tf_12);
			_inscription.chp_email.setTextFormat(tf_12);
			
			_inscription.chp_nom_titre.setTextFormat(titre_12);
			_inscription.chp_prenom_titre.setTextFormat(titre_12);
			_inscription.chp_adresse_titre.setTextFormat(titre_12);
			_inscription.chp_cp_titre.setTextFormat(titre_12);
			_inscription.chp_ville_titre.setTextFormat(titre_12);
			_inscription.chp_telephone_fixe_titre.setTextFormat(titre_12);
			_inscription.chp_telephone_mobile_titre.setTextFormat(titre_12);
			_inscription.chp_email_titre.setTextFormat(titre_12);
			
			_inscription.chp_nom.selectable = false;
			_inscription.chp_prenom.selectable = false;
			_inscription.chp_adresse.selectable = false;
			_inscription.chp_cp.selectable = false;
			_inscription.chp_ville.selectable = false;
			_inscription.chp_telephone_fixe.selectable = false;
			_inscription.chp_telephone_mobile.selectable = false;
			_inscription.chp_email.selectable = false;
			
			//-- Champs numeraires...
			_inscription.chp_cp.restrict = "0-9";
			_inscription.chp_cp.maxChars = 5;
			_inscription.chp_telephone_fixe.restrict = "0-9";
			_inscription.chp_telephone_fixe.maxChars = 10;
			_inscription.chp_telephone_mobile.restrict = "0-9";
			_inscription.chp_telephone_mobile.maxChars = 10;
			
			//-- Type de logement
			_inscription.chp_type_logement1.setStyle("embedFonts", true);
			_inscription.chp_type_logement1.setStyle("textFormat", _inscription.chp_civilite1.getStyle("textFormat"));
			_inscription.chp_type_logement1.setStyle("disabledTextFormat", _inscription.chp_civilite1.getStyle("textFormat"));
			_inscription.chp_type_logement2.setStyle("embedFonts", true);
			_inscription.chp_type_logement2.setStyle("textFormat", _inscription.chp_civilite1.getStyle("textFormat"));
			_inscription.chp_type_logement2.setStyle("disabledTextFormat", _inscription.chp_civilite1.getStyle("textFormat"));
			
			//-- Comboboxs
			//-- Setstyle ds le "_loadFormContentResult"
			
			//-- Mesg d'erreur
			_inscription.msg_erreur.embedFonts = true;
			_inscription.msg_erreur.setTextFormat(titre_12_bold);
		}
		
		private function _setTabIndex():void
		{
			//-- Desactive les tabulations sur les boutons checkboxes
			_inscription.chp_accepte_collecte_info.tabEnabled = false;
			_inscription.chp_client_orange_fixe.tabEnabled = false;
			_inscription.chp_client_orange_mobile.tabEnabled = false;
			_inscription.chp_client_orange_internet.tabEnabled = false;
			_inscription.chp_client_orange_non.tabEnabled = false;
			
			//-- Desactive les tabulations sur les radiobuttons
			_inscription.chp_type_logement1.tabEnabled = false;
			_inscription.chp_type_logement2.tabEnabled = false;
			_inscription.chp_civilite1.tabEnabled = false;
			_inscription.chp_civilite2.tabEnabled = false;
			_inscription.chp_civilite3.tabEnabled = false;
			
			//-- Desactive les tabulations sur les comboboxes
			var nbCombos:int = tab_combos_name.length;
			for (var i:int = 0; i < nbCombos; i++)
			{
				if (tab_combos_name[i] != null)
				{
					//AppUtils.TRACE("ScreenInscritpion::_setTabIndex() > chp_" + tab_combos_name[i][0]);
					_inscription["chp_" + tab_combos_name[i][0]].tabEnabled = false;
				}
			}
			
			//-- Ordre de tabulation sur les champs de test
			_inscription.chp_nom.tabIndex = 1;
			_inscription.chp_prenom.tabIndex = 2;
			_inscription.chp_adresse.tabIndex = 3;
			_inscription.chp_cp.tabIndex = 4;
			_inscription.chp_ville.tabIndex = 5;
			_inscription.chp_telephone_fixe.tabIndex = 6;
			_inscription.chp_telephone_mobile.tabIndex = 7;
			_inscription.chp_email.tabIndex = 8;
			
			//-- Focus sur la champ nom
			_setFormFirstFieldFocus();
		}
		
		//-- Focus sur le champs nom
		private function _setFormFirstFieldFocus():void
		{
			//-- Focus sur la champ nom
			stage.focus = _inscription.chp_nom;
			_inscription.chp_nom.setSelection(0, 0);
		}
		
		//-- Focus sur le champs nom
		private function _loadClientVO2Form(pClientVO:ClientVO):void
		{
			AppUtils.TRACE("ScreenInscritpion::_loadClientVO2Form() > " + pClientVO);
			
			//-- Affecte les valeurs des checkboxes
			if (pClientVO.accepte_collecte_infos == 1)
			{
				_inscription.chp_accepte_collecte_info.selected = true;
				changeHandlerCheckboxByName(_inscription.chp_accepte_collecte_info);
				
				//-- Affiche le formulaire
				_formEtat("SHOW");
			}
			
			if (pClientVO.client_orange_fixe == 1)
			{
				_inscription.chp_client_orange_fixe.selected = true;
				changeHandlerCheckboxByName(_inscription.chp_client_orange_fixe);
			}
			else
			{
				//pClientVO.id_autre_operateur_fixe = _inscription.chp_autre_operateur_fixe.selectedItem.data;
				selectComoboboxFromValue(_inscription.chp_autre_operateur_fixe, pClientVO.id_autre_operateur_fixe);
			}
			
			if (pClientVO.client_orange_internet == 1)
			{
				_inscription.chp_client_orange_internet.selected = true;
				changeHandlerCheckboxByName(_inscription.chp_client_orange_internet);
				
				selectComoboboxFromValue(_inscription.chp_orange_forfait_internet, pClientVO.id_orange_forfait_internet);
				selectComoboboxFromValue(_inscription.chp_livebox, pClientVO.id_livebox);
				selectComoboboxFromValue(_inscription.chp_decodeur, pClientVO.id_decodeur);
			}
			else
			{
				selectComoboboxFromValue(_inscription.chp_autre_operateur_internet, pClientVO.id_autre_operateur_internet);
			}
			
			if (pClientVO.client_orange_mobile == 1)
			{
				_inscription.chp_client_orange_mobile.selected = true;
				changeHandlerCheckboxByName(_inscription.chp_client_orange_mobile);
			}
			else
			{
				selectComoboboxFromValue(_inscription.chp_autre_operateur_mobile, pClientVO.id_autre_operateur_mobile);
			}
			
			if (pClientVO.client_orange_non == 1)
			{
				_inscription.chp_client_orange_non.selected = true;
				changeHandlerCheckboxByName(_inscription.chp_client_orange_non);
				
				selectComoboboxFromValue(_inscription.chp_autre_operateur_fixe, pClientVO.id_autre_operateur_fixe);
				selectComoboboxFromValue(_inscription.chp_autre_operateur_internet, pClientVO.id_autre_operateur_internet);
				selectComoboboxFromValue(_inscription.chp_autre_operateur_mobile, pClientVO.id_autre_operateur_mobile);
			}
			
			selectComoboboxFromValue(_inscription.chp_test_eligibilite, pClientVO.id_test_eligibilite);
			
			//-- Affecte les valeurs des radiobuttons
			AppUtils.TRACE("ScreenInscription::selectComoboboxFromValue() > Radiobuttons : id_civilite=" + pClientVO.id_civilite + " / type_logement" + pClientVO.id_type_logement);
			
			if (pClientVO.id_civilite && pClientVO.id_civilite != -1)
			{
				var rbg_civilite:RadioButtonGroup = RadioButtonGroup.getGroup("chp_civilite");
				rbg_civilite.selectedData = pClientVO.id_civilite;
				_inscription["chp_civilite" + pClientVO.id_civilite].selected = true;
				AppUtils.TRACE("ScreenInscription::selectComoboboxFromValue() > Radiobuttons : id_civilite=" + pClientVO.id_civilite);
			}
			
			if (pClientVO.id_type_logement && pClientVO.id_type_logement != -1)
			{
				var rbg_type_logement:RadioButtonGroup = RadioButtonGroup.getGroup("chp_type_logement");
				rbg_type_logement.selectedData = pClientVO.id_type_logement;
				_inscription["chp_type_logement" + pClientVO.id_type_logement].selected = true;
				AppUtils.TRACE("ScreenInscription::selectComoboboxFromValue() > Radiobuttons : type_logement" + pClientVO.id_type_logement);
			}
			
			//-- Affecte les valeurs des champs de texte
			if (pClientVO.nom)
				_inscription.chp_nom.text = pClientVO.nom;
			if (pClientVO.prenom)
				_inscription.chp_prenom.text = pClientVO.prenom;
			if (pClientVO.adresse)
				_inscription.chp_adresse.text = pClientVO.adresse;
			if (pClientVO.cp)
				_inscription.chp_cp.text = pClientVO.cp;
			if (pClientVO.ville)
				_inscription.chp_ville.text = pClientVO.ville;
			if (pClientVO.telephone_fixe)
				_inscription.chp_telephone_fixe.text = pClientVO.telephone_fixe;
			if (pClientVO.telephone_mobile)
				_inscription.chp_telephone_mobile.text = pClientVO.telephone_mobile;
			if (pClientVO.email)
				_inscription.chp_email.text = pClientVO.email;
		}
		
		private function selectComoboboxFromValue(pCombobox:ComboBox, pValue:int):void
		{
			var cb_length:int = pCombobox.length;
			var cb_item:Object;
			
			if (cb_length > 0 && pValue != -1)
			{
				for (var i:int = 0; i < cb_length; i++)
				{
					cb_item = pCombobox.getItemAt(i);
					//AppUtils.TRACE("ScreenInscription::selectComoboboxFromValue(" + pCombobox.name + ", " + pValue + ") > i=" + i + " / " + cb_item.data);
					if (cb_item.data == pValue)
					{
						//AppUtils.TRACE("ScreenInscription::selectComoboboxFromValue(" + pCombobox.name + ", " + pValue + ") > TROUVE : i=" + i + " / " + cb_item.data);
						pCombobox.selectedIndex = i;
						pCombobox.selectedItem = cb_item;
						break;
					}
				}
			}
		}
		
		private function _setFormListeners():void
		{
			//-- Checkbox accepte_collecte_info
			_inscription.chp_accepte_collecte_info.addEventListener(Event.CHANGE, _changeHandlerCheckbox);
			
			//-- Checkbox type client
			_inscription.chp_client_orange_fixe.addEventListener(Event.CHANGE, _changeHandlerCheckbox);
			_inscription.chp_client_orange_mobile.addEventListener(Event.CHANGE, _changeHandlerCheckbox);
			_inscription.chp_client_orange_internet.addEventListener(Event.CHANGE, _changeHandlerCheckbox);
			_inscription.chp_client_orange_non.addEventListener(Event.CHANGE, _changeHandlerCheckbox);
			
			//-- Radiobuttons
			/*_inscription.chp_civilite1.addEventListener(Event.CHANGE, _changeHandlerRadiobutton);
			   _inscription.chp_civilite2.addEventListener(Event.CHANGE, _changeHandlerRadiobutton);
			   _inscription.chp_civilite3.addEventListener(Event.CHANGE, _changeHandlerRadiobutton);
			   _inscription.chp_type_logement1.addEventListener(Event.CHANGE, _changeHandlerRadiobutton);
			 _inscription.chp_type_logement2.addEventListener(Event.CHANGE, _changeHandlerRadiobutton);*/
			RadioButtonGroup.getGroup("chp_civilite").addEventListener(Event.CHANGE, _changeHandlerRadiobutton);
			RadioButtonGroup.getGroup("chp_type_logement").addEventListener(Event.CHANGE, _changeHandlerRadiobutton);
			
			//-- Btn Nv projet
			/*_inscription.btn_nv_projet.addEventListener(MouseEvent.CLICK, _newProject);
			   _inscription.btn_nv_projet.buttonMode = true;
			 _inscription.btn_nv_projet.mouseChildren = false;*/
			
			//-- Btn Effacer
			_inscription.btn_reset.addEventListener(MouseEvent.CLICK, _resetForm);
			_inscription.btn_reset.addEventListener(MouseEvent.CLICK, _resetForm);
			//_inscription.btn_reset.buttonMode = true;
			//_inscription.btn_reset.mouseChildren = false;
			
			//-- Btn save
			_inscription.btn_save.addEventListener(MouseEvent.CLICK, _saveClient);
			//_inscription.btn_save.buttonMode = true;
			//_inscription.btn_save.mouseChildren = false;
		
			//-- Btn retour editeur
		/*_inscription.btn_retour_projet.addEventListener(MouseEvent.CLICK, _saveAndBackEditor);
		   _inscription.btn_retour_projet.buttonMode = true;
		   _inscription.btn_retour_projet.mouseChildren = false;
		
		   if (_am.projetvo.id == -1) {
		   _inscription.btn_retour_projet.visible = false;
		 }*/ /*if (_am.clientvo.id == -1)
		   {
		   _inscription.btn_save.visible = false;
		   //_inscription.btn_retour_projet.visible = false;
		   _inscription.btn_reset.x = 703;
		   } else {
		   _inscription.btn_reset.x = 552;
		 }*/
		}
		
		/*private function _newProject(e:MouseEvent):void
		   {
		   //new CreateVendorProject(_goEditor).call();
		   _goEditor("nouveau");
		 }*/
		
		/*private function _saveAndBackEditor(e:MouseEvent):void
		   {
		   _goEditor("editeur");
		 }*/
		
		private function _saveClient(e:MouseEvent):void
		{
			//model.screen = ApplicationModel.SCREEN_HOME;
			_saveClientVOAndGoHome();
		}
		
		private function _resetForm(e:MouseEvent):void
		{
			/*AppUtils.TRACE("ScreenInscription::_resetForm()");
			 _formEtat("RESET");*/
			var popup:YesNoAlert = new YesNoAlert(AppLabels.getString("messages_warning"), AppLabels.getString("messages_confirmDataDeletion"), _doReset, _noReset, NaN, null);
			AlertManager.addPopup(popup, Main.instance);
			//AppUtils.appCenter(popup);
		}
		
		private function _doReset():void
		{
			_formEtat("RESET");
		}
		
		private function _noReset():void
		{
			AlertManager.removePopup();
		}
		
		private function _changeHandlerCheckbox(pEvt:Event):void
		{
			changeHandlerCheckboxByName(pEvt.currentTarget as CheckBox);
		}
		
		private function changeHandlerCheckboxByName(pCheckbox:CheckBox):void
		{
			AppUtils.TRACE("ScreenInscription::changeHandlerCheckboxByName(" + pCheckbox.name + ")");
			
			var tf_normal:TextFormat = tf_12_bold;
			var tf_selected:TextFormat = tf_12_bold_selected;
			
			switch (pCheckbox.name)
			{
				case "chp_accepte_collecte_info": 
					//-- Typo differente (taille 11)
					tf_normal = tf_11_bold;
					tf_selected = tf_11_bold_selected;
					
					if (pCheckbox.selected)
					{
						//-- Affiche le formulaire
						_formEtat("SHOW");
						
						//-- Highlight le fond des champs obligatoires
						_inscription.chp_nom_fond.gotoAndStop(3);
						_inscription.chp_nom_titre.setTextFormat(titre_12_oblig);
						
						//-- Affiche la combo d'eligibilite
						_inscription.chp_test_eligibilite.visible = true;
						
						//-- Affiche les infos du bas
						_inscription.info_bas.visible = true;
						
						//-- Highlight erreur eligibilite
						_inscription.chp_eligibilite_fond.visible = true;
						
						//-- Message d'erreur
						_inscription.msg_erreur.visible = true;
						
						//-- Btn Effacer
						_inscription.btn_reset.enabled = true;
						_inscription.btn_reset.alpha = 1;
					}
					else
					{
						//-- Cache le formulaire
						_formEtat("HIDE");
						
						//-- Reset le fond des champs obligatoires
						_inscription.chp_nom_fond.gotoAndStop(1);
						_inscription.chp_nom_titre.setTextFormat(titre_12);
						
						//-- Cache les infos du bas
						_inscription.info_bas.visible = false;
						
						//-- Highlight erreur eligibilite
						_inscription.chp_eligibilite_fond.visible = false;
						
						//-- Message d'erreur
						_inscription.msg_erreur.visible = false;
						
						//-- Btn Effacer
						_inscription.btn_reset.enabled = false;
						_inscription.btn_reset.alpha = elt_alpha;
					}
					break;
				case "chp_client_orange_fixe": 
					if (pCheckbox.selected)
					{
						//-- Deselectionne la check no client orange
						//_inscription.chp_client_orange_non.selected = false;
					}
					break;
				case "chp_client_orange_internet": 
					if (pCheckbox.selected)
					{
						//-- Deselectionne la check no client orange
						//_inscription.chp_client_orange_non.selected = false;
					}
					break;
				case "chp_client_orange_mobile": 
					if (pCheckbox.selected)
					{
						//-- Deselectionne la check no client orange
						//_inscription.chp_client_orange_non.selected = false;
					}
					break;
				case "chp_client_orange_non": 
					if (pCheckbox.selected)
					{
						//-- Deselectionne les checks clients orange
						_inscription.chp_client_orange_fixe.selected = false;
						_inscription.chp_client_orange_mobile.selected = false;
						_inscription.chp_client_orange_internet.selected = false;
						_inscription.chp_client_orange_fixe.setStyle("textFormat", tf_normal);
						_inscription.chp_client_orange_fixe.setStyle("disabledTextFormat", tf_normal);
						_inscription.chp_client_orange_mobile.setStyle("textFormat", tf_normal);
						_inscription.chp_client_orange_mobile.setStyle("disabledTextFormat", tf_normal);
						_inscription.chp_client_orange_internet.setStyle("textFormat", tf_normal);
						_inscription.chp_client_orange_internet.setStyle("disabledTextFormat", tf_normal);
					}
					else
					{
					}
					break;
				default: 
			}
			
			//-- Change la couleur du texte
			if (pCheckbox.selected)
			{
				pCheckbox.setStyle("textFormat", tf_selected);
				pCheckbox.setStyle("disabledTextFormat", tf_selected);
			}
			else
			{
				pCheckbox.setStyle("textFormat", tf_normal);
				pCheckbox.setStyle("disabledTextFormat", tf_normal);
			}
			
			//-- recalcul l'affichage des éléments du formulaire
			
			//-- Selectionne la check no client orange
			if (_inscription.chp_client_orange_fixe.selected || _inscription.chp_client_orange_internet.selected || _inscription.chp_client_orange_mobile.selected)
			{
				_inscription.chp_client_orange_non.selected = false;
				_inscription.chp_client_orange_non.setStyle("textFormat", tf_normal);
				_inscription.chp_client_orange_non.setStyle("disabledTextFormat", tf_normal);
			}
			else
			{
				//_inscription.chp_client_orange_non.selected = true;
				//_inscription.chp_client_orange_non.setStyle("textFormat", tf_selected);
			}
			
			//-- Affiche ou non les combo
			var etatElt:Boolean;
			
			//-- Combos internet et autre operateur internet
			if (_inscription.chp_client_orange_internet.selected)
				etatElt = true;
			else
				etatElt = false;
			_inscription.chp_orange_forfait_internet.visible = etatElt;
			_inscription.chp_livebox.visible = etatElt;
			_inscription.chp_decodeur.visible = etatElt;
			_inscription.chp_autre_operateur_internet.visible = !etatElt;
			
			//-- Combos autre operateur fixe
			if (_inscription.chp_client_orange_fixe.selected)
				etatElt = false;
			else
				etatElt = true;
			_inscription.chp_autre_operateur_fixe.visible = etatElt;
			
			//-- Combos autre operateur mobile
			if (_inscription.chp_client_orange_mobile.selected)
				etatElt = false;
			else
				etatElt = true;
			_inscription.chp_autre_operateur_mobile.visible = etatElt;
			
			//-- Positionne les combos autre operateur
			var currentComboPos:Number = 97;
			
			if (_inscription.chp_autre_operateur_fixe.visible)
			{
				_inscription.chp_autre_operateur_fixe.y = currentComboPos;
				currentComboPos += _inscription.chp_autre_operateur_fixe.height + 10;
			}
			if (_inscription.chp_autre_operateur_internet.visible)
			{
				_inscription.chp_autre_operateur_internet.y = currentComboPos;
				currentComboPos += _inscription.chp_autre_operateur_fixe.height + 10;
			}
			if (_inscription.chp_autre_operateur_mobile.visible)
			{
				_inscription.chp_autre_operateur_mobile.y = currentComboPos;
				currentComboPos += _inscription.chp_autre_operateur_fixe.height + 10;
			}
			
			//-- Fond des champs obligatoires
			if (_inscription.chp_client_orange_fixe.selected || _inscription.chp_client_orange_internet.selected)
			{
				_inscription.chp_telephone_fixe_fond.gotoAndStop(3);
				_inscription.chp_telephone_fixe_titre.setTextFormat(titre_12_oblig);
			}
			else
			{
				_inscription.chp_telephone_fixe_fond.gotoAndStop(1);
				_inscription.chp_telephone_fixe_titre.setTextFormat(titre_12);
			}
			if (_inscription.chp_client_orange_mobile.selected)
			{
				_inscription.chp_telephone_mobile_fond.gotoAndStop(3);
				_inscription.chp_telephone_mobile_titre.setTextFormat(titre_12_oblig);
			}
			else
			{
				_inscription.chp_telephone_mobile_fond.gotoAndStop(1);
				_inscription.chp_telephone_mobile_titre.setTextFormat(titre_12);
			}
		}
		
		private function _changeHandlerRadiobutton(pEvt:Event):void
		{
			//AppUtils.TRACE("ScreenInscription::_changeHandlerRadiobutton() > " + pEvt.currentTarget.name);
			var tf_normal:TextFormat = tf_11_bold;
			var tf_selected:TextFormat = tf_11_bold_selected;
			
			var groupBtns:RadioButtonGroup = RadioButtonGroup.getGroup(pEvt.currentTarget.name);
			var nbGroupBtn:int = groupBtns.numRadioButtons;
			var btnRadio:RadioButton;
			
			//AppUtils.TRACE("ScreenInscription::_changeHandlerRadiobutton() > " + pEvt.currentTarget.name + " > selectedData = "+groupBtns.selectedData);
			
			for (var i:int = 0; i < nbGroupBtn; i++)
			{
				btnRadio = groupBtns.getRadioButtonAt(i);
				if (btnRadio.selected)
				{
					btnRadio.setStyle("textFormat", tf_selected);
					btnRadio.setStyle("disabledTextFormat", tf_selected);
				}
				else
				{
					btnRadio.setStyle("textFormat", tf_normal);
					btnRadio.setStyle("disabledTextFormat", tf_normal);
				}
			}
		}
		
		//---------------------------------------------------
		//-- Gère l'état du formulaire
		//---------------------------------------------------
		
		private function _formEtat(pEtat:String = "HIDE"):void
		{
			switch (pEtat)
			{
				case "INIT": 
					/*	//-- Cache les infos du bas
					   _inscription.info_bas.visible = false;
					
					   //-- Cache les selectbox internet
					   _inscription.chp_orange_forfait_internet.visible = false;
					   _inscription.chp_livebox.visible = false;
					   _inscription.chp_decodeur.visible = false;
					
					   //-- Btn Effacer
					   _inscription.btn_reset.enabled = false;
					   _inscription.btn_reset.alpha = elt_alpha;
					 */
					//-- Cache le form
					//_formEtat("HIDE");
					_formEtat("RESET");
					
					//-- Mise en forme du formulaire
					_initFormStyle();
					_setFormStyle();
					_setTabIndex();
					_setFormListeners();
					
					//-- Récupere les valeurs en base
					//_getFormContent();
					_initListBoxes();
					break;
				case "RESET": 
					//-- Reset le formulaire
					_changeAfficheEtat("RESET");
					break;
				case "HIDE": 
					//-- Cache tous les éléments
					_changeAfficheEtat("HIDE");
					break;
				case "SHOW": 
					//-- Affiche tous les éléments
					_changeAfficheEtat("SHOW");
					break;
				default: 
			}
		}
		
		//-------------------------------------------------------------
		//-- Change l'affichage des champs quand 1ere case cochée
		//-------------------------------------------------------------	
		
		private function _changeAfficheEtat(pEtat:String = "RESET", pElt:Object = null):void
		{
			var eltEnable:Boolean = false;
			var eltReset:Boolean = false;
			
			if (pEtat == "SHOW")
			{
				eltEnable = true;
			}
			else if (pEtat == "HIDE")
			{
				eltEnable = false;
			}
			else
			{
				//-- RESET
				eltReset = true;
			}
			
			var eltAlpha:Number;
			var itemName:String;
			
			if (eltEnable)
			{
				eltAlpha = 1;
			}
			else
			{
				eltAlpha = elt_alpha;
			}
			
			if (pElt == null)
			{
				//-- Champs
				var textf:TextField;
				var textf_titre:TextField;
				var textf_fond:MovieClip;
				for each (itemName in tab_champs_name)
				{
					if (itemName != null)
					{
						//AppUtils.TRACE("ScreenInscription::_formEtat(" + pEtat + ") > " + itemName+" ("+_inscription["chp_" + itemName].name+")");
						textf_titre = _inscription["chp_" + itemName + "_titre"];
						textf = _inscription["chp_" + itemName];
						textf_fond = _inscription["chp_" + itemName + "_fond"];
						textf_titre.alpha = eltAlpha;
						textf.alpha = eltAlpha;
						textf_fond.alpha = eltAlpha;
						textf.selectable = eltEnable;
						if (eltReset)
						{
							textf.text = "";
							textf_fond.gotoAndStop(1);
							textf_titre.setTextFormat(titre_12);
						}
					}
				}
				
				//-- Checkboxs
				var checkb:CheckBox;
				for each (itemName in tab_checkbox_name)
				{
					if (itemName != null)
					{
						//AppUtils.TRACE("ScreenInscription::_formEtat(" + pEtat + ") > " + itemName);
						checkb = (_inscription["chp_" + itemName] as CheckBox);
						if (itemName != "accepte_collecte_info")
						{
							checkb.alpha = eltAlpha;
							checkb.enabled = eltEnable;
							if (eltReset)
							{
								checkb.selected = false;
								//checkb.setStyle("embedFonts", true);
								checkb.setStyle("textFormat", tf_12_bold);
								checkb.setStyle("disabledTextFormat", tf_12_bold);
							}
						}
						else
						{
							if (eltReset)
							{
								checkb.selected = false;
								//checkb.setStyle("embedFonts", true);
								checkb.setStyle("textFormat", tf_11_bold);
								checkb.setStyle("disabledTextFormat", tf_11_bold);
							}
						}
					}
				}
				
				//-- Radio buttons
				var radiob:RadioButton;
				for each (itemName in tab_radio_name)
				{
					if (itemName != null)
					{
						//AppUtils.TRACE("ScreenInscription::_formEtat(" + eltEnable + ") > " + itemName);
						//trace("ScreenInscription::_formEtat(" + eltEnable + ") > " + itemName + " / " + radiob);
						radiob = _inscription["chp_" + itemName];
						radiob.alpha = eltAlpha;
						radiob.enabled = eltEnable
						if (eltReset)
						{
							//radiob.selected = false;
							radiob.setStyle("textFormat", tf_11_bold);
							radiob.setStyle("disabledTextFormat", tf_11_bold);
						}
					}
				}
				if (eltReset)
				{
					//-- reset les selections des radios buttons groups
					FormUtils.radioButtonReset_byName("chp_civilite");
					FormUtils.radioButtonReset_byName("chp_type_logement");
				}
				
				//-- Combos
				var combob:ComboBox;
				for each (var itemTab:Array in tab_combos_name)
				{
					if (itemTab != null)
					{
						//AppUtils.TRACE("ScreenInscription::_formEtat(" + eltEnable + ") > " + itemTab[0]);
						combob = _inscription["chp_" + itemTab[0]];
						combob.alpha = eltAlpha;
						combob.enabled = eltEnable;
						if (eltReset)
						{
							combob.selectedIndex = 0;
								//combob.setStyle("textFormat", tf_12_combos);
						}
					}
				}
				
				if (eltReset)
				{
					//-- Cache les infos du bas
					_inscription.info_bas.visible = false;
					
					//-- Cache les selectbox internet
					_inscription.chp_orange_forfait_internet.visible = false;
					_inscription.chp_livebox.visible = false;
					_inscription.chp_decodeur.visible = false;
					
					//-- Cache les selectbox autres operateurs
					_inscription.chp_autre_operateur_fixe.visible = false;
					_inscription.chp_autre_operateur_internet.visible = false;
					_inscription.chp_autre_operateur_mobile.visible = false;
					
					//-- Btn Effacer
					_inscription.btn_reset.enabled = false;
					_inscription.btn_reset.alpha = elt_alpha;
					
					//-- Highlight erreur eligibilite
					_inscription.chp_eligibilite_fond.gotoAndStop(1);
					_inscription.chp_eligibilite_fond.visible = true;
					
					//-- Message d'erreur
					_inscription.msg_erreur.text = "";
					_inscription.msg_erreur.visible = true;
				}
			}
		
		}
		
		private function _validForm():Boolean
		{
			AppUtils.TRACE("ScreenInscription::_validForm()");
			
			//-- Message d'erreur
			_inscription.msg_erreur.text = "";
			
			//-- Test des champs
			var isValid:Boolean = true;
			var msg_eligibilite:String = "";
			var chp_oblig:Array = new Array();
			var chp_incorrect:Array = new Array();
			
			if (_inscription.chp_accepte_collecte_info.selected)
			{
				//-- Champs de texte
				
				//-- Nom
				if (_inscription.chp_nom.text.length < 1)
				{
					chp_oblig.push("nom");
					isValid = false;
					_inscription.chp_nom_fond.gotoAndStop(4);
				}
				else if (_inscription.chp_nom.text.length < 2)
				{
					chp_incorrect.push("nom");
					isValid = false;
					_inscription.chp_nom_fond.gotoAndStop(4);
				}
				else
				{
					_inscription.chp_nom_fond.gotoAndStop(3);
				}
				
				//-- Téléphone fixe
				if ((_inscription.chp_client_orange_fixe.selected || _inscription.chp_client_orange_internet.selected) && _inscription.chp_telephone_fixe.text.length < 1)
				{
					chp_oblig.push("téléphone fixe");
					isValid = false;
					_inscription.chp_telephone_fixe_fond.gotoAndStop(4);
				}
				else if (_inscription.chp_telephone_fixe.text.length > 0)
				{
					if (!FormUtils.isValidPhone(_inscription.chp_telephone_fixe.text))
					{
						chp_incorrect.push("téléphone fixe");
						isValid = false;
						_inscription.chp_telephone_fixe_fond.gotoAndStop(_inscription.chp_telephone_fixe_fond.currentFrame + 1);
					}
					else if (_inscription.chp_client_orange_fixe.selected || _inscription.chp_client_orange_internet.selected)
					{
						_inscription.chp_telephone_fixe_fond.gotoAndStop(3);
					}
					else
					{
						_inscription.chp_telephone_fixe_fond.gotoAndStop(1);
					}
				}
				else
				{
					_inscription.chp_telephone_fixe_fond.gotoAndStop(1);
				}
				
				//-- Téléphone mobile
				if (_inscription.chp_client_orange_mobile.selected && _inscription.chp_telephone_mobile.text.length < 1)
				{
					chp_oblig.push("téléphone mobile");
					isValid = false;
					_inscription.chp_telephone_mobile_fond.gotoAndStop(4);
				}
				else if (_inscription.chp_telephone_mobile.text.length > 0)
				{
					if (!FormUtils.isValidPhone(_inscription.chp_telephone_mobile.text))
					{
						chp_incorrect.push("téléphone mobile");
						isValid = false;
						_inscription.chp_telephone_mobile_fond.gotoAndStop(_inscription.chp_telephone_mobile_fond.currentFrame + 1);
					}
					else if (_inscription.chp_client_orange_mobile.selected)
					{
						_inscription.chp_telephone_mobile_fond.gotoAndStop(3);
					}
					else
					{
						_inscription.chp_telephone_mobile_fond.gotoAndStop(1);
					}
				}
				else
				{
					_inscription.chp_telephone_mobile_fond.gotoAndStop(1);
				}
				
				//-- Email
				if (_inscription.chp_email.text.length > 0)
				{
					if (!FormUtils.isValidMail(_inscription.chp_email.text))
					{
						chp_incorrect.push("email");
						isValid = false;
						_inscription.chp_email_fond.gotoAndStop(2);
					}
					else
					{
						_inscription.chp_email_fond.gotoAndStop(1);
					}
				}
				
				//-- Eligib
				if (_am.profilevo.eligibility_mandatory)
				{
					if (_inscription.chp_test_eligibilite.selectedIndex == 0)
					{
						msg_eligibilite = AppLabels.getString("form_mandatoryTest");
						isValid = false;
						_inscription.chp_eligibilite_fond.gotoAndStop(2);
					}
					else
					{
						_inscription.chp_eligibilite_fond.gotoAndStop(1);
					}
				}
			}
			
			if (!isValid)
			{
				if (chp_oblig.length > 1)
				{
					_inscription.msg_erreur.appendText(AppLabels.getString("form_fields") + chp_oblig.join(", ") + AppLabels.getString("form_areMandatory"));
				}
				else if (chp_oblig.length > 0)
				{
					_inscription.msg_erreur.appendText(AppLabels.getString("form_field") + chp_oblig.join(", ") + AppLabels.getString("form_isMandatory"));
				}
				if (chp_incorrect.length > 1)
				{
					_inscription.msg_erreur.appendText(AppLabels.getString("form_fields") + chp_incorrect.join(", ") + AppLabels.getString("form_areIncorrect"));
				}
				else if (chp_incorrect.length > 0)
				{
					_inscription.msg_erreur.appendText(AppLabels.getString("form_field") + chp_incorrect.join(", ") + AppLabels.getString("form_isIncorrect"));
				}
				_inscription.msg_erreur.appendText(msg_eligibilite);
			}
			return isValid;
		}
		
		private function _saveClientVOAndGoHome( /*pDest:String*/):void
		{
			AppUtils.TRACE("ScreenInscription::_saveClientVOAndGoHome()");
			
			var cvo:ClientVO = new ClientVO;
			var validFormResult:Boolean;
			
			//-- Si modification d'un client, on reaffecte l'id pour la mise a jour en base
			if (_am.clientvo.id != -1)
			{
				cvo.id = _am.clientvo.id;
			}
			else
			{
				//-- Nouveau client -> affecte l'id vendeur a "id_createur"
				cvo.id_createur = _am.vendeurvo.id;
			}
			//-- Affecte l'id vendeur a "id_dernier_modificateur"
			cvo.id_dernier_modificateur = _am.vendeurvo.id;
			
			if (_inscription.chp_accepte_collecte_info.selected)
			{
				//-- Si accepte de transmettre des données
				cvo.accepte_collecte_infos = 1;
				
				if (validFormResult = _validForm())
				{
					//-- Formulaire validé						
					var rbg_civilite:RadioButtonGroup = RadioButtonGroup.getGroup("chp_civilite");
					if (rbg_civilite.selectedData != null)
					{
						cvo.id_civilite = int(rbg_civilite.selectedData);
					}
					//AppUtils.TRACE("ScreenInscription::_goEditor() > id_civilite=" + cvo.id_civilite);
					
					cvo.nom = _inscription.chp_nom.text;
					cvo.prenom = _inscription.chp_prenom.text;
					cvo.adresse = _inscription.chp_adresse.text;
					cvo.cp = _inscription.chp_cp.text;
					cvo.ville = _inscription.chp_ville.text;
					cvo.telephone_fixe = _inscription.chp_telephone_fixe.text;
					cvo.telephone_mobile = _inscription.chp_telephone_mobile.text;
					cvo.email = _inscription.chp_email.text;
					
					cvo.id_test_eligibilite = _inscription.chp_test_eligibilite.selectedItem.data;
					
					if (_inscription.chp_client_orange_fixe.selected)
					{
						cvo.client_orange_fixe = 1;
					}
					else
					{
						cvo.id_autre_operateur_fixe = _inscription.chp_autre_operateur_fixe.selectedItem.data;
					}
					
					if (_inscription.chp_client_orange_internet.selected)
					{
						cvo.client_orange_internet = 1;
						cvo.id_orange_forfait_internet = _inscription.chp_orange_forfait_internet.selectedItem.data;
						cvo.id_livebox = _inscription.chp_livebox.selectedItem.data;
						cvo.id_decodeur = _inscription.chp_decodeur.selectedItem.data;
					}
					else
					{
						cvo.id_autre_operateur_internet = _inscription.chp_autre_operateur_internet.selectedItem.data;
					}
					
					if (_inscription.chp_client_orange_mobile.selected)
					{
						cvo.client_orange_mobile = 1;
					}
					else
					{
						cvo.id_autre_operateur_mobile = _inscription.chp_autre_operateur_mobile.selectedItem.data;
					}
					
					if (_inscription.chp_client_orange_non.selected)
					{
						cvo.client_orange_non = 1;
						cvo.id_autre_operateur_fixe = _inscription.chp_autre_operateur_fixe.selectedItem.data;
						cvo.id_autre_operateur_internet = _inscription.chp_autre_operateur_internet.selectedItem.data;
						cvo.id_autre_operateur_mobile = _inscription.chp_autre_operateur_mobile.selectedItem.data;
					}
					AppUtils.TRACE("ScreenInscription::_goEditor() > fixe selectedData=" + _inscription.chp_autre_operateur_fixe.selectedItem.data);
					var rbg_type_logement:RadioButtonGroup = RadioButtonGroup.getGroup("chp_type_logement");
					if (rbg_type_logement.selectedData != null)
					{
						cvo.id_type_logement = int(rbg_type_logement.selectedData);
					}
					AppUtils.TRACE("ScreenInscription::_goEditor() > id_type_logement=" + cvo.id_type_logement);
				}
			}
			else
			{
				//-- N'accepte pas de transmettre des données
				cvo.accepte_collecte_infos = 0;
			}
			
			if (!_inscription.chp_accepte_collecte_info.selected || validFormResult)
			{
				cvo.id_agence = _am.vendeurvo.id_agence;
				
				//-- Affecte le client au vo (vide si "!_inscription.chp_accepte_collecte_info.selected"
				_am.clientvo = cvo;
				
				//-- Sauve le client en base
				if (ExternalInterface.available)
				{
					_am.clientvo.saveDb(_saveClientsResult);
				}
				else
				{
					/*if(pDest == "nouveau"){
					   _saveClientsNewProjectResult((new Date()).getTime());
					   } else if(pDest == "editeur") {
					   _saveClientsEditeurResult((new Date()).getTime());
					   } else {
					   _saveClientsResult((new Date()).getTime());
					 }*/
					_saveClientsResult((new Date()).getTime());
				}
			}
			else
			{
				AppUtils.TRACE("ScreenInscription::_goEditor() > ERREUR VALIDE FORM");
			}
		}
		
		private function _saveClientsResult(pResult:Object = null):void
		{
			AppUtils.TRACE("ScreenInscription::_saveClientsResult()");
			
			if (pResult != false)
			{
				//-- Affecte l'id du client dans le vo de l'appmodel
				_am.clientvo.id = int(pResult);
				
				//trace(_am.clientvo);
				AppUtils.TRACE("ScreenInscription::_saveClientsResult() > new id=" + _am.clientvo.id);
				AppUtils.TRACE("ScreenInscription::_saveClientsResult() >" + _am.clientvo);
				trace("ScreenInscription::_saveClientsResult() >" + _am.clientvo);
				model.reset();
				
				//-- Affiche l'écran d'accueil du client
				model.screen = ApplicationModel.SCREEN_HOME;
			}
		}
		
		override protected function cleanup():void
		{
			//-- Checkbox accepte_collecte_info
			_inscription.chp_accepte_collecte_info.removeEventListener(Event.CHANGE, _changeHandlerCheckbox);
			
			//-- Checkbox type client
			_inscription.chp_client_orange_fixe.removeEventListener(Event.CHANGE, _changeHandlerCheckbox);
			_inscription.chp_client_orange_mobile.removeEventListener(Event.CHANGE, _changeHandlerCheckbox);
			_inscription.chp_client_orange_internet.removeEventListener(Event.CHANGE, _changeHandlerCheckbox);
			_inscription.chp_client_orange_non.removeEventListener(Event.CHANGE, _changeHandlerCheckbox);
			
			//-- Btn recherche
			//_inscription.btn_recherche.removeEventListener(MouseEvent.CLICK, _btnPressRecherche);
			
			//-- Btn Nv projet
			//_inscription.btn_nv_projet.removeEventListener(MouseEvent.CLICK, _newProject);
			
			//-- Btn Effacer
			_inscription.btn_reset.removeEventListener(MouseEvent.CLICK, _resetForm);
			
			//-- Btn save
			_inscription.btn_save.removeEventListener(MouseEvent.CLICK, _saveClient);
			//-- Btn save
			//_inscription.btn_retour_projet.removeEventListener(MouseEvent.CLICK, _saveAndBackEditor);
			
			super.cleanup();
		}
	}
}