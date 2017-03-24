package classes.views.alert
{
	import classes.commands.CreatePDF;
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.FormUtils;
	import classes.views.Background;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	/**
	 * La classe EnvoiMailPopup permet d'afficher le popup d'envoi du PDF par mail.
	 * 
	 */
	public class EnvoiMailPopup extends Sprite
	{
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _btn:Btn;//BtnEnvoyerParMail;
		private var _btnA:Btn;//BtnAllerInscription;
		private var _btnAnnuler:Btn;//BtnAnnuler;
		private var _btnFermer:Btn;//BtnFermer;
		private var _emailTF:TextField;
		private var _msgTF:CommonTextField;
		
		/**
		 * <p>Si l'email de l'utilisateur n'est pas saisi on ne permet pas l'envoi, on affiche un bouton qui redirige 
		 * vers l'écran d'inscription pour forcer l'utilisateur à saisir son email.</p>
		 * 
		 * <p>Ensuite on ne revient pas directement à la synthèse mais à l'éditeur.</p>
		 */
		public function EnvoiMailPopup()
		{
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			_drawBG();
			_addTextfield();
			
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		private function _drawBG():void
		{
			var g:Graphics = graphics;
			g.lineStyle();
			g.beginFill(0xffffff);
			g.drawRoundRect(0, 0, 580, 240, 8);
			
			dropShadow();
		}
		
		public function dropShadow(distance:int = 0, angle:int = 45, alpha:Number = 1, blur:int = 20, strength:Number = .5):void
		{
			var d:DropShadowFilter = new DropShadowFilter(distance, angle, 0, alpha, blur, blur, strength);
			filters = [d];
		}
		
		private function _addTextfield():void
		{
			
			var ft:TextFormat = new TextFormat();
			ft.font = (new Verdana() as Font).fontName;
			ft.color = Config.COLOR_MURS;
			ft.size = 12;

			if (_appmodel.clientvo.email == null || _appmodel.clientvo.email == "")
			{
				var t:CommonTextField = new CommonTextField("helvet", Config.COLOR_GREY);
				t.width = 500;
				t.x = 20;
				t.y = 60;
				t.setText(AppLabels.getString("popups_emailNotTyped"));
				addChild(t);
				//_emailTF.text = "votre adresse email";
				
				_btnA = new Btn(0xff9900, AppLabels.getString("popups_typeEmail"), null, 116, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
				_btnA.addEventListener(MouseEvent.CLICK, _gotoInscription, false, 0, true);
				addChild(_btnA);
				
				_btnA.x = 580 / 2 + 30;
				_btnA.y = 200;
				
				//_btnAnnuler = new BtnAnnuler();
				_btnAnnuler = new Btn(0, AppLabels.getString("buttons_cancel"), null, 116, 0xffffff, 12, 24, Btn.GRADIENT_DARK);
				addChild(_btnAnnuler);
				_btnAnnuler.x = 580 / 2 - _btnAnnuler.width - 20;
				_btnAnnuler.y = 200;
				_btnAnnuler.addEventListener(MouseEvent.CLICK, _annuler, false, 0, true);
				
			}
			else
			{
				_emailTF = new TextField();
				_emailTF.selectable = true;
				_emailTF.embedFonts = true;
				_emailTF.type = TextFieldType.INPUT;
				//_emailTF.restrict = "a-z A-ZO-9.@";
				_emailTF.border = true;
				_emailTF.borderColor = Config.COLOR_LIGHT_GREY;
				_emailTF.width = 440;
				_emailTF.height = 20;
				_emailTF.x = 120;
				_emailTF.y = 30;
				_emailTF.text = (_appmodel.clientvo.email);
				_emailTF.setTextFormat(ft);
				
				addChild(_emailTF);
				_emailTF.addEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
				_emailTF.addEventListener(Event.CHANGE, _onChange);
				
				t = new CommonTextField("helvetBold", 0x333333);
				t.width = 120;
				t.x = 20;
				t.y = 30;
				t.setText(AppLabels.getString("popups_yourEmail"));
				addChild(t);
				
				t = new CommonTextField("helvet", Config.COLOR_GREY);
				t.width = 500;
				t.x = 20;
				t.y = 60;
				t.setText(AppLabels.getString("popups_sendPdfMailInfo"));
				addChild(t);
				
				_msgTF = new CommonTextField("helvetBold", 0x333333);
				_msgTF.wordWrap = true;
				_msgTF.autoSize = TextFieldAutoSize.LEFT;
				_msgTF.width = 545;
				_msgTF.x = 20;
				_msgTF.y = 150;
				_msgTF.setText(AppLabels.getString("messages_sendingPdf"));
				addChild(_msgTF);
				_msgTF.visible = false;
				
				_addBtn();
			}
		}
		
		// hack to give focus properly
		private function _onChange(e:Event):void
		{
			setTimeout(function():void
				{
					stage.focus = _emailTF;
				}, 50);
		}
		
		private function _onFocusIn(e:FocusEvent):void
		{
			//trace("focus");
			setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
		}
		
		private function _addBtn():void
		{
			//_btn = new BtnEnvoyerParMail();
			_btn = new Btn(0xff9900, AppLabels.getString("buttons_send"), PictoMail, 116, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			_btn.addEventListener(MouseEvent.CLICK, _sendMail, false, 0, true);
			addChild(_btn);
			
			_btn.x = 580 / 2 + 30;
			_btn.y = 200;
			
			_btnAnnuler = new Btn(Config.COLOR_GREY, AppLabels.getString("buttons_cancel"), null, 116, 0xffffff, 12, 24, Btn.GRADIENT_DARK);
			addChild(_btnAnnuler);
			_btnAnnuler.x = 580 / 2 - _btnAnnuler.width - 20;
			_btnAnnuler.y = 200;
			_btnAnnuler.addEventListener(MouseEvent.CLICK, _annuler, false, 0, true);
			
			_btnFermer = new Btn(Config.COLOR_GREY, AppLabels.getString("buttons_close"), null, 116, 0xffffff, 12, 24, Btn.GRADIENT_DARK);
			_btnFermer.x = 580 / 2;
			_btnFermer.y = 200;
			_btnFermer.visible = false;
			addChild(_btnFermer);
			_btnFermer.addEventListener(MouseEvent.CLICK, _annuler, false, 0, true);
		}
		
		private function _annuler(e:MouseEvent):void
		{
			AlertManager.removePopup();
		}
		
		private function _gotoInscription(e:MouseEvent):void
		{
			//AlertManager.removePopup();
			trace("go inscription")
			var popup:InscriptionSimplePopup = new InscriptionSimplePopup(true);
			AlertManager.addSecondPopup(popup, Main.instance);
			AppUtils.appCenter(popup);
			popup.x = Background.instance.masq.width / 2 - popup.width / 2;
			popup.y = Background.instance.masq.height/2 - popup.height/2;
			//_appmodel.screen = ApplicationModel.SCREEN_INSCRIPTION;
		}
		
		private function _sendMail(e:MouseEvent):void
		{
			//trace("envoi de mail à ", StringUtils.trim(_emailTF.text, " "), _emailTF.text.replace(/^\s+|\s+$/g, ''));
			//if (StringUtils.trim(_emailTF.text, " ") == "" || _emailTF.text.indexOf("@") == -1) return;
			// effacer messages précédents s'ils existent
			//_msgTF.setText("");
			
			//trace("mail envoyable");
			if (_emailTF.text.length > 0 && FormUtils.isValidMail(_emailTF.text))
			{				
				//-- Message d'envoi
				_msgTF.visible = true;
				
				//-- Bloque les boutons
				_btn.enabled = _btnAnnuler.enabled = false;
				_btn.alpha = _btnAnnuler.alpha = 0.3;
				
				//-- Mail du pdf
				AppUtils.TRACE("EnvoiMailPopup::_sendMail() > OK, CreatePDF('mailPDF')");
				new CreatePDF("mailPDF", _emailTF.text, _resultMail);
			}
			else
			{
				AppUtils.TRACE("EnvoiMailPopup::_sendMail() > ERREUR !");
			}
		}
		
		private function _resultMail(evt:Event):void
		{
			var retour:String = evt.target.data;
			if (retour.lastIndexOf("SUCCESS") > 0)
			{
				retour = retour.substr(retour.lastIndexOf("SUCCESS"));
			}
			else if (retour.lastIndexOf("ERROR") > 0)
			{
				retour = retour.substr(retour.lastIndexOf("ERROR"));
			}
			switch (retour)
			{
				case "SUCCESS_MAIL": 
					_msgTF.setText(AppLabels.getString("messages_successMail"));
					_btn.visible = _btnAnnuler.visible = false;
					_btnFermer.visible = true;
					break;
				case "ERROR_MAIL": 
					_msgTF.setText(AppLabels.getString("messages_errorMail"));
					_btn.enabled = _btnAnnuler.enabled = true;
					_btn.alpha = _btnAnnuler.alpha = 1;
					break;
				default: 
					_msgTF.setText(AppLabels.getString("messages_errorOccurred"));
					_btn.visible = _btnAnnuler.visible = false;
					_btnFermer.visible = true;
			}
			AppUtils.TRACE("EnvoiMailPopup::_resultMail() > evt=_" + evt.target.data + "_");
			AppUtils.TRACE("EnvoiMailPopup::_resultMail() > retour=_" + retour + "_");
		}
		
		private function _removed(e:Event):void
		{
			if (_appmodel.clientvo.email == null || _appmodel.clientvo.email == "")
			{
				_btnA.removeEventListener(MouseEvent.CLICK, _gotoInscription);
				_btnAnnuler.removeEventListener(MouseEvent.CLICK, _annuler);
			}
			else
			{
				if(_btn && _btn.stage) _btn.removeEventListener(MouseEvent.CLICK, _sendMail);
				if(_btnAnnuler && _btnAnnuler.stage) _btnAnnuler.removeEventListener(MouseEvent.CLICK, _annuler);
				if(_emailTF && _emailTF.stage) _emailTF.removeEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
			}
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}

}