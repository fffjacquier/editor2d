package classes.views 
{
	import classes.commands.SaveCommand;
	import classes.config.Config;
	import classes.controls.CurrentScreenUpdateEvent;
	import classes.controls.CurrentVendeurUpdateEvent;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.StringUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertMemo;
	import classes.views.alert.DemoPopup;
	import classes.views.alert.HelpPopup;
	import classes.views.alert.InscriptionSimplePopup;
	import classes.views.alert.YesAlert;
	import classes.views.alert.YesNoAlert;
	import classes.vo.ClientVO;
	import com.warmforestflash.drawing.DottedLine;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * La classe Header contient la navigation du haut : les textes "plan" et "maison connectée", ainsi que les
	 * différents boutons de navigation de premier niveau (déconnecter, rechercher, nouveau client, démo, aide, nom du vendeur
	 * et numéro du projet en cours plus sauvegarde)
	 * 
	 * <p>Ces différents boutons peuvent être présents ou non selon les écrans et selon le profil <code>profileVO</code> 
	 * du user loggué</p>
	 */
	public class Header extends Sprite
	{
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _btnSearch:Btn;
		private var _btnNewClient:Btn;
		private var _btnDisconnect:Btn;
		private var _btnMyAccount:Btn;
		private var _btnNotes:Btn;
		private var _btnDemo:Btn;
		private var _btnHelp:Btn;
		private var _btnSave:Btn;
		private var _idClient:Btn;
		private var _idProject:CommonTextField;
		private var _dottedLine:DottedLine;
		private var _callback:Function;
		private var titre1:CommonTextField;
		private var titre2:CommonTextField;
		private var _toggleVisibility:Boolean = true;
		private var _bgUser:Sprite;
		private var _bgHelp:Sprite;
		private var _bgSave:Sprite;
		
		public function Header() 
		{
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			titre1 = new CommonTextField("helvet35", Config.COLOR_CONNEXION_FIBRE, 42);
			titre1.width = 80;
			titre1.setText(AppLabels.getString("common_plan"));
			addChild(titre1);
			titre1.x = 5;
			titre1.y = -3;
			
			titre2 = new CommonTextField("helvet45", Config.COLOR_WHITE, 16, "left", 0, -6);
			titre2.setText(AppLabels.getString("common_connectedHome"));
			addChild(titre2);
			titre2.x = 84;
			titre2.y = 7;
			
			_dottedLine = new DottedLine(Config.FLASH_WIDTH -20, 1, Config.COLOR_CONNEXION_FIBRE, 1, 1.3, 2);
			addChild(_dottedLine);
			_dottedLine.x = 16;
			_dottedLine.y = 43;
			
			_appmodel.addProfileUpdateListener(_updateFromProfile);
			
			/*_appmodel.addCurrentVendeurUpdateListener(_onCurrentVendeurUpdate);
			_appmodel.addCurrentScreenUpdateListener(_onCurrentScreenUpdate);
			_onCurrentScreenUpdate();*/
			
			//-- Ecouteur de session terminee
			_appmodel.addSessionOverListener(_deconnexion);
			
			//stage.addEventListener(KeyboardEvent.KEY_UP, _onKeyUp);
		}
		
		private function _updateFromProfile(e:Event=null):void
		{
			if (_appmodel.profilevo == null) return;
			AppUtils.TRACE("Header::_updateFromProfile() "+ _appmodel.profilevo.user_profile)
			
			_appmodel.addCurrentVendeurUpdateListener(_onCurrentVendeurUpdate);
			_onCurrentVendeurUpdate();
			_appmodel.addCurrentScreenUpdateListener(_onCurrentScreenUpdate);
			_onCurrentScreenUpdate();
		}
		
		/*private function _onKeyUp(e:KeyboardEvent):void
		{
			//trace(e.keyCode, e.altKey, e.ctrlKey, e.shiftKey);
			if (e.ctrlKey && e.altKey && e.shiftKey && e.keyCode == 74) {
				trace("Header::_onKeyUp()");
				_toggleVisibility = !_toggleVisibility;
				if (btnRecherche) btnRecherche.visible = _toggleVisibility;
				if (_btnNewClient) _btnNewClient.visible = _toggleVisibility;
				if (btnDeconnexion) btnDeconnexion.visible = _toggleVisibility;
			}
			//_toggleVisibility = !_toggleVisibility;
			
		}*/
		
		private function _onCurrentVendeurUpdate(e:CurrentVendeurUpdateEvent=null):void
		{
			AppUtils.TRACE("Header::_onCurrentVendeurUpdate() "+_appmodel.vendeurvo.id+" "+ApplicationModel.NOT_LOGGED_VENDEUR_ID)
			if (_appmodel.vendeurvo.id == ApplicationModel.NOT_LOGGED_VENDEUR_ID) {
				_removeButtons();
				return;
			}
			
			_displayButtons();
		}
		
		private function _removeButtons():void
		{
			if (_btnSearch != null && _btnSearch.stage != null) {
				_btnMyAccount.removeEventListener(MouseEvent.CLICK, _onClickMyAccount);
				_btnNewClient.removeEventListener(MouseEvent.CLICK, _inscription);
				_btnDisconnect.removeEventListener(MouseEvent.CLICK, _deconnexion);
				_btnSearch.removeEventListener(MouseEvent.CLICK, _search);
				_btnDemo.removeEventListener(MouseEvent.CLICK, _clickDemo);
				_btnHelp.removeEventListener(MouseEvent.CLICK, _clickAide);
				_btnSave.removeEventListener(MouseEvent.CLICK, _saveProject);
				removeChild(_idClient);
				removeChild(_btnSearch);
				removeChild(_btnNewClient);
				removeChild(_btnDisconnect);
				removeChild(_btnMyAccount);
				removeChild(_btnHelp);
				removeChild(_btnDemo);
				removeChild(_btnNotes);
				removeChild(_btnSave);
			}
		}
		
		private function _onCurrentScreenUpdate(e:CurrentScreenUpdateEvent=null):void
		{
			//AppUtils.TRACE("Header::_onCurrentScreenUpdate "+ _appmodel.screen);
			graphics.clear();
			
			if (_appmodel.screen == ApplicationModel.SCREEN_HOME) {
				if (_btnNotes && _btnNotes.stage) {
					_btnNotes.disable();
				}
				if (_btnSave && _btnSave.stage) _appmodel.notifySaveStateUpdate(false);
			} else {
				if (_btnNotes && _btnNotes.stage) {
					_btnNotes.enable();
				}
			}
			if (_appmodel.screen == ApplicationModel.SCREEN_RECAP) {
				if (_btnHelp && _btnHelp.stage) _btnHelp.disable();
			} else {
				if (_btnHelp && _btnHelp.stage) _btnHelp.enable();
			}
			if (_btnDisconnect == null) return;
			
			if (_appmodel.profilevo.acces_recherche) {
				_btnSearch.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			} else {
				_btnSearch.visible = _appmodel.profilevo.acces_recherche;
			}
			_btnNewClient.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			
			_onResize();
		}
		
		private function _displayButtons():void
		{
			// création des fonds des groupes de boutons
			_bgUser = new Sprite();
			addChild(_bgUser);
			_bgHelp = new Sprite();
			addChild(_bgHelp);
			_bgSave = new Sprite();
			addChild(_bgSave);
			
			//trace("displayButtons")
			_btnSearch = new BtnHeader( -1, AppLabels.getString("buttons_search"), PictoLoupe, 65, 0xffffff, 12, 24, null, false);
			addChild(_btnSearch);
			_btnSearch.addEventListener(MouseEvent.CLICK, _onClick);
			
			_btnNewClient = new BtnHeader( -1, AppLabels.getString("buttons_newClient"), PictoClient, 65, 0xffffff, 12, 24, null, false);
			addChild(_btnNewClient);
			_btnNewClient.addEventListener(MouseEvent.CLICK, _onClick);
			
			_btnSearch.visible = _btnNewClient.visible = true;
			//_btnSearch.visible = _btnNewClient.visible = _fromPocd;
			
			// bouton compte présent que sur la version client et doit renvoyer sur la page inscription (sans le bouton recherche)
			_btnMyAccount = new BtnHeader( -1, AppLabels.getString("buttons_myAccount"), PictoCompte, 65, 0xffffff, 12, 24, null, false);
			addChild(_btnMyAccount);
			_btnMyAccount.addEventListener(MouseEvent.CLICK, _onClickMyAccount);
			_btnMyAccount.visible = false;
			
			_btnDisconnect = new BtnHeader(-1, AppLabels.getString("buttons_disconnect"), PictoDeconnecter, 65, 0xffffff, 12, 24, null, false);
			addChild(_btnDisconnect);
			_btnDisconnect.addEventListener(MouseEvent.CLICK, _onClick, false, 0, true);
			
			//var str:String = (_appmodel.projetvo.id != -1) ? "projet n°" + _appmodel.projetvo.id +"   " + _appmodel.vendeurvo.prenom + " " + _appmodel.vendeurvo.nom : _appmodel.vendeurvo.prenom + " " + _appmodel.vendeurvo.nom;
			var bonjourStr:String = "";
			_appmodel.clientvo.prenom = " ";
			/*trace("vendeurvo:", _appmodel.vendeurvo.prenom, _appmodel.vendeurvo.nom);
			trace("clientvo:", _appmodel.clientvo.prenom, _appmodel.clientvo.nom);*/
			if (_appmodel.clientvo.prenom != null && !(new RegExp(/^\S/).test(_appmodel.clientvo.prenom))) {
				bonjourStr += StringUtils.trim(_appmodel.clientvo.prenom, " ");
			}
			if (_appmodel.clientvo.nom != null) {
				bonjourStr += _appmodel.clientvo.nom;
			}
			/*if (_appmodel.vendeurvo.prenom != null && _appmodel.vendeurvo.nom != null) {
				bonjourStr += _appmodel.vendeurvo.prenom +" "+ _appmodel.vendeurvo.nom
			}*/
			
			_idClient = new Btn(-1, bonjourStr, null, 65, 0xffffff, 12, 24, null, false);
			addChild(_idClient);
			AppUtils.TRACE("Header "+bonjourStr+" "+_appmodel.profilevo);
			if (_appmodel.profilevo && _appmodel.profilevo.user_profile == "VENDEUR") {
				_idClient.setText(_appmodel.vendeurvo.prenom + " " + _appmodel.vendeurvo.nom);
			}
			else {
				if (bonjourStr == "") {
					// wait for client info
					_appmodel.addClientDataUpdateListener(_onClientDataUpdate);
				} else {
					_idClient.setText(bonjourStr);
					//_onClientDataUpdate();
				}
			}
			_idClient.buttonMode = false;
			_idClient.enabled = false;
			
			_btnDemo = new BtnHeader(-1, AppLabels.getString("common_demo"), PictoVideo, 65, 0xffffff, 12, 24, null, false);
			addChild(_btnDemo);
			_btnDemo.addEventListener(MouseEvent.CLICK, _clickDemo, false, 0, true);
			_btnDemo.visible = (_appmodel.screen != ApplicationModel.SCREEN_SEARCH && _appmodel.screen != ApplicationModel.SCREEN_INSCRIPTION);
			
			_btnHelp = new BtnHeader(-1, AppLabels.getString("buttons_help"), PictoAide, 65, 0xffffff, 12, 24, null, false);
			addChild(_btnHelp);
			_btnHelp.addEventListener(MouseEvent.CLICK, _clickAide, false, 0, true);
			_btnHelp.visible = (_appmodel.screen != ApplicationModel.SCREEN_SEARCH && _appmodel.screen != ApplicationModel.SCREEN_INSCRIPTION);
			
			_btnNotes = new BtnHeader(-1, AppLabels.getString("buttons_notepad"), PictoTromboneSmall, 65, 0xffffff, 12, 24, null, false);
			addChild(_btnNotes);
			_btnNotes.addEventListener(MouseEvent.CLICK, _onClickMemo, false, 0, true);
			_btnNotes.visible = (_appmodel.screen != ApplicationModel.SCREEN_SEARCH && _appmodel.screen != ApplicationModel.SCREEN_INSCRIPTION);
			
			_btnSave = new BtnHeaderSave( AppLabels.getString("buttons_save") );
			addChild(_btnSave);
			_btnSave.addEventListener(MouseEvent.CLICK, _saveProject);
			_btnSave.visible = (_appmodel.screen != ApplicationModel.SCREEN_SEARCH && _appmodel.screen != ApplicationModel.SCREEN_INSCRIPTION);
			_appmodel.notifySaveStateUpdate(false);
			
			_idProject = new CommonTextField("helvet", 0xeaeaea, 11);
			_idProject.width = _btnSave.width;
			var tf:TextFormat = _idProject.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			//_idProject.autoSize = TextFormatAlign.CENTER;
			//_idProject.background = true;
			_idProject.setText(AppLabels.getString("editor_project"));
			_idProject.setTextFormat(tf);
			addChild(_idProject);			
			if (_appmodel.projetvo.id != -1) {
				_idProject.setText(AppLabels.getString("editor_projectNum") + _appmodel.projetvo.id);
			} 
			
			_btnSave.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME)
			_btnHelp.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_btnDemo.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_btnNotes.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_btnMyAccount.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_idProject.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_idClient.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			
			_onResize();
			stage.addEventListener(Event.RESIZE, _onResize);
			
			_appmodel.addProjectvoIdUpdateListener(_onProjectvoIdUpdate);
		}
		
		private function _onClickMyAccount(e:MouseEvent):void
		{
			var popup:InscriptionSimplePopup = new InscriptionSimplePopup();
			AlertManager.addPopup(popup, Main.instance);
			AppUtils.appCenter(popup);
			popup.x = Background.instance.masq.width / 2 - popup.width / 2;
			popup.y = Background.instance.masq.height/2 - popup.height/2;
		}
		
		private function _onClickMemo(e:MouseEvent):void
		{
			var popup:AlertMemo = new AlertMemo();
			AlertManager.addPopup(popup, Main.instance);
			AppUtils.appCenter(popup);
		}
		
		private function _clickDemo(e:MouseEvent):void
		{
			var popup:DemoPopup = new DemoPopup(null, "aide");
			AlertManager.addPopup(popup, Main.instance);
			popup.x = Background.instance.masq.width/2 - 900/2;
			popup.y = Background.instance.masq.height/2 - 600/2;
		}
		
		private function _clickAide(e:MouseEvent):void
		{
			if (_appmodel.screen == ApplicationModel.SCREEN_RECAP) return;
			
			var popup:HelpPopup = new HelpPopup();
			AlertManager.addPopup(popup, Main.instance);
			popup.x = Background.instance.masq.width/2 - popup.width/2;
			//popup.y = Background.instance.masq.height/2 - popup.height/2;
		}
		
		private function _onProjectvoIdUpdate(e:Event):void
		{
			//_idClient.setText(AppLabels.getString("editor_project") + _appmodel.projetvo.id +"   " + _appmodel.vendeurvo.prenom + " " + _appmodel.vendeurvo.nom);
			_idProject.setText(AppLabels.getString("editor_projectNum") + _appmodel.projetvo.id);
			/*_onResize();
			if (!_idClient.hasEventListener(MouseEvent.CLICK)) {
				_idClient.addEventListener(MouseEvent.CLICK, _goInscription);
				_idClient.buttonMode = true;
				_idClient.enabled = true;
			}*/
		}
		
		private function _onClientDataUpdate(e:Event=null):void
		{
			if (_appmodel.profilevo && _appmodel.profilevo.user_profile == "VENDEUR") return;
			
			var nom:String = _appmodel.clientvo.nom;
			var prenom:String = _appmodel.clientvo.prenom;
			var nomprenom:String;
			if (nom != null && prenom != null) {
				nomprenom = StringUtils.capitalize(prenom) + " " + StringUtils.capitalize(nom);
			} else {
				if (prenom == null && nom == null) nomprenom = "";
				else if (prenom == null) nomprenom = StringUtils.capitalize(nom);
				else if (nom == null) nomprenom = StringUtils.capitalize(prenom);
				else nomprenom = "";
			}
			_idClient.setText(nomprenom);
			var xpos:int;
			if (_appmodel.profilevo.user_profile == "VENDEUR")
			{
				xpos = _btnNewClient.x;
			} else {
				xpos = _btnMyAccount.x;
			}
			_idClient.x = xpos - _idClient.width - 4;
		}
		
		private function _goInscription(e:MouseEvent):void
		{
			_appmodel.screen = ApplicationModel.SCREEN_INSCRIPTION;
		}
		
		private function _onClick(e:MouseEvent):void
		{
			AlertManager.removePopup();
			if (e.target == _btnDisconnect) {
				_callback = _deconnexion;
			} else if (e.target == _btnNewClient) {
				_callback = _inscription;
			} else if (e.target == _btnSearch) {
				_callback = _search;
			} else {
				_callback = null;
			}
			if (_appmodel.screen === ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP) {
				var popup:YesNoAlert = new YesNoAlert(AppLabels.getString("alert_disconnection"), AppLabels.getString("alert_subDisconnection"), _saveProjectAndCallback, function():void{});
				AlertManager.addPopup(popup, Main.instance);
				//AppUtils.appCenter(popup);
			} else {
				_callback();
			}
		}
		
		private function _saveProjectAndCallback(e:MouseEvent=null):void
		{
			AlertManager.removePopup();
			new SaveCommand(false).run(_callback);
		}
		
		private function _saveProject(e:MouseEvent=null):void
		{
			AlertManager.removePopup();
			new SaveCommand(false).run();
		}
		
		private function _deconnexion(pEvt:*=null):void
		{
			AlertManager.removePopup();
			Main.instance._authentificationQuitteEditeur();
		}
		
		private function _search(pResult:Object=null):void
		{
			_appmodel.screen = ApplicationModel.SCREEN_SEARCH;
		}
		
		private function _inscription(pResult:Object=null):void
		{
			_appmodel.clientvo = new ClientVO();
			_appmodel.screen = ApplicationModel.SCREEN_INSCRIPTION;
		}
		
		private function _onResize(e:Event=null):void
		{
			//graphics.clear();
			_bgHelp.graphics.clear();
			_bgUser.graphics.clear();
			_bgSave.graphics.clear();
			
			var posy:int = Background.instance.masq.y + 8;
			var right:int = Background.instance.masq.width;
			//var centre:int = right / 2;
			var theSize:Number;
			var lastx:int;
			
			_idClient.y = posy;
			_btnSave.y = posy +20;
			_btnHelp.y = posy;
			_btnDemo.y = posy;
			_btnNotes.y = posy;
			_btnSearch.y = posy;
			_btnNewClient.y = posy;
			_btnMyAccount.y = posy;
			_btnDisconnect.y = posy;
			
			_btnSave.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME)
			_btnHelp.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_btnDemo.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_btnNotes.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_btnMyAccount.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_idProject.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			_idClient.visible = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR || _appmodel.screen == ApplicationModel.SCREEN_RECAP || _appmodel.screen == ApplicationModel.SCREEN_HOME);
			
			//AppUtils.TRACE("resize " + _appmodel.screen);
			if (_appmodel.screen == ApplicationModel.SCREEN_SEARCH || _appmodel.screen == ApplicationModel.SCREEN_INSCRIPTION || _appmodel.screen == ApplicationModel.SCREEN_LOG)
			{
				//_btnDisconnect.visible = true;
				theSize = Background.instance.masq.width - 20;
				
				_btnDisconnect.x = right - _btnDisconnect.width - 10;
				if (_appmodel.screen == ApplicationModel.SCREEN_INSCRIPTION)
				{
					_btnSearch.visible = true;
					_btnNewClient.visible = false;
					_btnSearch.x = _btnDisconnect.x - _btnSearch.width - 20;
				}
				if (_appmodel.screen == ApplicationModel.SCREEN_SEARCH)
				{
					_btnNewClient.visible = true;
					_btnSearch.visible = false;
					_btnNewClient.x = _btnDisconnect.x - _btnNewClient.width - 20;
				}
				//AppUtils.TRACE("resize AAA");
				// pas de fond sur la bouton save (bouton non présent)
				_bgSave.graphics.clear();
				
				// fond noir alpha .2
				var g:Graphics = _bgHelp.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0, .2);
				g.drawRoundRect(0, 0, _btnDisconnect.width + 15, 38, 8);
				g.endFill();
				
				//dégradé spécial
				g = _bgUser.graphics;
				g.clear();
				g.lineStyle();
				var fillType:String = GradientType.LINEAR;
				var colors:Array = [0xffffff, 0xffffff];
				var alphas:Array = [0, .09];
				var ratios:Array = [0, 32];
				var matr:Matrix = new Matrix();
				matr.createGradientBox(449, 38, 0);
				var spreadMethod:String = SpreadMethod.PAD;
				g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
				g.drawRoundRect(0, 0, 449, 38, 8);
				g.endFill();
				
				_bgHelp.x = right - _bgHelp.width - 5;
				_bgUser.x = _bgHelp.x -_bgUser.width - 2;
				
			} else {
				
				_btnSave.visible = _btnNotes.visible = _btnDemo.visible = _btnHelp.visible = true;
				_btnSave.x = right - _btnSave.width - 10;
				_idProject.x = _btnSave.x;
				_idProject.y = posy -5;
				_btnNotes.x = _btnSave.x - _btnNotes.width - 10;
				_btnDemo.x = _btnNotes.x - _btnDemo.width - 4;
				_btnHelp.x = _btnDemo.x - _btnHelp.width - 4;
				
				if (_appmodel.profilevo.user_profile == "VENDEUR")
				{
					_btnDisconnect.visible = _btnMyAccount.visible = false;
					_btnSearch.visible = _btnNewClient.visible = true;
					_btnSearch.x = _btnHelp.x - _btnSearch.width - 13;
					_btnNewClient.x = _btnSearch.x - _btnNewClient.width - 4;
					lastx = _btnNewClient.x;
				} else {
					_btnSearch.visible = _btnNewClient.visible = false;
					_btnDisconnect.visible = _btnMyAccount.visible = true;
					_btnDisconnect.x = _btnHelp.x - _btnDisconnect.width - 13;
					_btnMyAccount.x = _btnDisconnect.x - _btnMyAccount.width - 4;
					lastx = _btnMyAccount.x;
				}
				_idClient.x = lastx - _idClient.width - 4;
				
				g = _bgSave.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0, .3);
				g.drawRoundRect(0, 0, _btnSave.width + 10, 57, 8);
				g.endFill();
				
				_bgSave.x = right - _bgSave.width - 5;
				
				g = _bgHelp.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0, .2);
				g.drawRoundRect(0, 0, _btnNotes.x + _btnNotes.width + 12 -_btnHelp.x, 38, 8);
				g.endFill();
				
				_bgHelp.x = _bgSave.x - _bgHelp.width -2;
				
				//dégradé spécial
				g = _bgUser.graphics;
				g.clear();
				g.lineStyle();
				fillType = GradientType.LINEAR;
				colors = [0xffffff, 0xffffff];
				alphas = [0, .09];
				ratios = [0, 32];
				matr = new Matrix();
				matr.createGradientBox(449, 38, 0);
				spreadMethod = SpreadMethod.PAD;
				g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
				g.drawRoundRect(0, 0, 449, 38, 8);
				g.endFill();
				
				_bgUser.x = _bgHelp.x -_bgUser.width - 2;
				
				theSize = Background.instance.masq.width - _bgSave.width - 22;
			}			
			
			_dottedLine.update(theSize);
		}
		
		/*private function _addWhiteLine(mc:MovieClip):void
		{
			graphics.clear();
			graphics.lineStyle(1, 0xffffff);
			graphics.moveTo(mc.x, mc.y + mc.height);
			graphics.lineTo(mc.x + mc.width, mc.y + mc.height);
		}*/
		
		/*private function get _fromPocd():Boolean
		{
			return (_appmodel._auth_provenance == Main.AUTH_REFERER_POCD);
		}*/
	}

}