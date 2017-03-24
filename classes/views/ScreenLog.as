package classes.views 
{
	/*import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	import classes.vo.ProfileVO;
	import classes.vo.VendeurVO;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.ui.Keyboard;*/
	
	 /**
	 * Deprecated
	 * 
	 * Cet écran n'est plus appelé depuis que l'appli passe par le poc-D
	 * 
	 */
	public class ScreenLog extends Screen 
	{
		private var _identification:AccueilIdentification;
		//private var _version:CommonTextField;
		
		public function ScreenLog() 
		{
		/*	screen = ApplicationModel.SCREEN_LOG;
			super();
		}
		
		override protected function _added(e:Event):void
		{
			super._added(e);
			//model.hasSeenStartPopup = false;
			_init();
		}
		
		private function _init():void
		{
			_identification = new AccueilIdentification();
			addChild(_identification);
			
			_identification.x = 55;
			_identification.y = 75;
			
			_identification.btnConnecter.addEventListener(MouseEvent.CLICK, _btnPressSeConnecter);
			_identification.btnConnecter.buttonMode = true;
			_identification.btnConnecter.mouseChildren = false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _keyPressSeConnecter);
		}
		
		private function _btnPressSeConnecter(pEvt:MouseEvent):void
		{
			//AppUtils.TRACE("ScreenLog::_btnPressSeConnecter()")
			_validLogin();
		}
		
		private function _keyPressSeConnecter(pEvt:KeyboardEvent):void
		{
			//AppUtils.TRACE("ScreenLog::_keyPressSeConnecter() > "+pEvt.keyCode)
			if (pEvt.keyCode == Keyboard.ENTER)
			{
				_validLogin();
			}
		}
		
		private function _validLogin():void
		{
			//_identification.identifiant.text = "vince";
			//_identification.motdepasse.text = "vincent";
			if (_identification.identifiant.text.length > 0 && _identification.motdepasse.text.length > 0) {
				// if in a browser, save with php			
				if (ExternalInterface.available) {
					//new LogVendeur(vendeurLoginResult).call(_identification.identifiant.text, _identification.motdepasse.text);
					ApplicationModel.instance.vendeurvo.loginDb(_identification.identifiant.text, _identification.motdepasse.text, vendeurLoginResult);
				}
				else {
					//-- TEMPORAIRE for swf tests (not in html)
					var vo:VendeurVO = new VendeurVO();
					vo.id = (new Date()).getTime();
					vo.id_orange = "12345678";
					vo.id_agence = 1;
					vo.nom = "Caudron";
					vo.prenom = "Vincent";
					vo.str_profil = "#identification_acces:1#recherche_acces:1#inscription_acces:1#inscription_creer:1#";
					vo.str_profil += "inscription_modifier:1#inscription_eligibilite_obligatoire:1#plan_acces:1#plan_creer:1#";
					vo.str_profil += "plan_sols_modifier:1#plan_install_modifier:1#synthese_acces:1#";
					vo.str_profil += "synthese_note_afficher:1#synthese_btn_imprimer:1#synthese_btn_email:1";
					
					model.profilevo = new ProfileVO();
					model.profilevo.setProfile(vo.str_profil);
					
					model.vendeurvo = vo;
					if (model.profilevo.acces_recherche) {
						model.screen = ApplicationModel.SCREEN_SEARCH;
					} else {
						model.screen = ApplicationModel.SCREEN_INSCRIPTION;
					}
				}
			}else {
				//-- Erreur de saisie
				_MessageErreur("ERREUR : veuillez saisir un identifiant et un mot de passe correct !");
			}
		}

		private function vendeurLoginResult(pResult:Object):void {
			//trace("Vendeur LOGGED");
			AppUtils.TRACE("ScreenLog::vendeurLoginResult(" + pResult + ")");
			
			if (pResult)
			{
				AppUtils.TRACE(model.vendeurvo);
				
				//-- Pour signaler a l'appmodel la mise a jour du vo
				model.vendeurvo =  model.vendeurvo;
				//model.notifyCurrentClientUpdate();
				
				//-- Affiche l'écran de recherche
				if (model.profilevo.acces_recherche) {
					model.screen = ApplicationModel.SCREEN_SEARCH;
				} else {
					model.screen = ApplicationModel.SCREEN_INSCRIPTION;
				}
			}
			else
			{
				//--Erreur d'identification
				_MessageErreur("ERREUR : identifiant et/ou\n mot de passe incorrect  !");
			}
		}
		
		private function _MessageErreur(pMsg:String):void
		{
			_identification.msg.alpha = 0;
			_identification.msg.text = pMsg;
			//TweenLite.to(_identification.msg, 1, { alpha:1 } );
			new Tween(_identification.msg, "alpha", Regular.easeOut, 0, 1, 1, true);
		}
		
		override protected function cleanup():void
		{
			_identification.btnConnecter.removeEventListener(MouseEvent.CLICK, _btnPressSeConnecter);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _keyPressSeConnecter);
			removeChild(_identification);
			
			super.cleanup();*/
		}
	}
}