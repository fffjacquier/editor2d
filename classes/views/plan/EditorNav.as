package classes.views.plan 
{
	import classes.commands.CreatePDF;
	import classes.commands.SaveCommand;
	import classes.controls.CurrentScreenUpdateEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertMemo;
	import classes.views.alert.AlertSauvegarde;
	import classes.views.alert.EnvoiMailPopup;
	import classes.views.alert.YesAlert;
	import classes.views.Background;
	import classes.views.Btn;
	import classes.views.EquipementsLayer;
	import classes.views.menus.MenuContainer;
	import classes.views.Toolbar;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * La classe EditorNav affiche les boutons de navigation dans l'éditeur : accueil, dessinez le plan,
	 * installez les équipements et voir la synthèse du projet.
	 * 
	 * <p>Il contient aussi deux boutons supplémentaires disponibles uniquement sur l'écran Synthèse récap du projet :
	 * <ul>
	 * 		<li>le bouton imprimer le PDF</li>
	 * 		<li>le bouton Envoyer le PDF par mail</li>
	 * </ul>
	 * </p>
	 */
	public class EditorNav extends Sprite 
	{
		//public var projectName:NomDuProjet;
		//private var btnRecap:Btn;
		//private var btnSave:Btn;// BtnSauvegarder;
		//private var btnEnvoiMail:Btn;// BtnEnvoyerParMail;
		//private var btnImprimer:Btn;//BtnImprimer;
		private var _btnHome:EditorNavButton;
		private var _btnDraw:EditorNavButton;
		private var _btnInstall:EditorNavButton;
		private var _btnCheck:EditorNavButton;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var isEditorScreen:Boolean;
		private var _previousTexte:String;
		private var _fileRef:FileReference;
		private static var _instance:EditorNav;
		public static function get instance():EditorNav
		{
			return _instance;
		}
		
		/**
		 * EditorNav est un singleton, un getter public statique réfère à son instance.
		 */
		public function EditorNav() 
		{
			if (_instance == null) _instance = this;
		
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{	
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			addEventListener(Event.REMOVED_FROM_STAGE, _cleanup);
			
			_btnHome = new EditorNavButton(AppLabels.getString("buttons_home"), PictoMaison);
			addChild(_btnHome);
			_btnHome.changeScaleIcon(.5925);
			_btnHome.alpha = .5;
			_btnHome.addEventListener(MouseEvent.CLICK, _goHome);
			
			_btnDraw = new EditorNavButton(AppLabels.getString("buttons_draw"), IconCrayon);
			addChild(_btnDraw);
			_btnDraw.alpha = .5;
			_btnDraw.addEventListener(MouseEvent.CLICK, _gotoDraw);
			
			_btnInstall = new EditorNavButton(AppLabels.getString("buttons_install"), IconEquipement);
			addChild(_btnInstall);
			_btnInstall.alpha = .5;
			_btnInstall.addEventListener(MouseEvent.CLICK, _gotoInstall);
			
			_btnCheck = new EditorNavButton(AppLabels.getString("buttons_check"), PictoOeil);
			addChild(_btnCheck);
			_btnCheck.alpha = .5;
			_btnCheck.addEventListener(MouseEvent.CLICK, _onClickRecap);
			
			/*projectName = new NomDuProjet();
			addChild(projectName);
			if (_appmodel.projectLabel == null) {
				_appmodel.projectLabel = "Nommez le projet";
			}
			projectName.projectName.htmlText = "<b>" + _appmodel.projectLabel;
			projectName.projectName.addEventListener(FocusEvent.FOCUS_IN, _onFocusIn, false, 0, true);
			projectName.projectName.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut, false, 0, true);*/
			
			isEditorScreen = (_appmodel.screen == ApplicationModel.SCREEN_EDITOR);
			
			if (!isEditorScreen) 
			{
				/*btnImprimer = new Btn(0, AppLabels.getString("buttons_print"), PictoImprim, 175, 0xffffff, 16, 30, Btn.GRADIENT_ORANGE);
				addChild(btnImprimer);
				btnImprimer.addEventListener(MouseEvent.CLICK, _saveLocalPDF);
				btnImprimer.visible = _appmodel.profilevo.acces_btnprint;

				btnEnvoiMail = new Btn(0, AppLabels.getString("buttons_send"), PictoMail, 175, 0xffffff, 16, 30, Btn.GRADIENT_ORANGE);
				addChild(btnEnvoiMail);
				btnEnvoiMail.addEventListener(MouseEvent.CLICK, _sendMail);
				//trace("btnmail=",_appmodel.profilevo.acces_btnmail);
				btnEnvoiMail.visible = _appmodel.profilevo.acces_btnmail;
				*/
				_btnCheck.alpha = 1;
				_btnCheck.changeScaleIcon(1.35);
			} else {
				manageAlphaBtnsEditor();
			}
			
			/*btnSave = new Btn(0xff6600, "sauvegarder", PictoMain);
			addChild(btnSave);
			btnSave.addEventListener(MouseEvent.CLICK, _save);*/
			
			stage.addEventListener(Event.RESIZE, _onResize, false, 0, true);
			_onResize();
			
			//_appmodel.addCurrentScreenUpdateListener(_onScreenUpdate);
		}
		
		public function manageAlphaBtnsEditor():void
		{
			if(_model.isDrawStep) {
				_btnInstall.alpha = .5;
				_btnDraw.alpha = 1;
				_btnDraw.changeScaleIcon(1.35);
			}
			else {
				_btnDraw.alpha = .5;
				_btnDraw.changeScaleIcon(1);
				_btnInstall.alpha = 1;
				_btnInstall.changeScaleIcon(1.35);
			}
		}
		
		private function _onFocusIn(e:FocusEvent):void
		{
			_previousTexte = e.currentTarget.text;
			//e.currentTarget.text = "";
			//e.currentTarget.setSelection(0, e.currentTarget.text.length);
			setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
		}
		
		private function _onFocusOut(e:FocusEvent):void
		{
			if (e.currentTarget.text == "") {
				e.currentTarget.text = _previousTexte;
			}
			_appmodel.projectLabel = e.currentTarget.text;
		}
		
		/*private function _pdfReady(e:Event):void
		{
			AlertManager.removePopup();
		}
		
		private function _saveLocalPDF(e:MouseEvent):void
		{
			new CreatePDF("savePDF");
			_appmodel.addPDFReadyListener(_pdfReady);
			var popup:AlertSauvegarde = new AlertSauvegarde(AppLabels.getString("messages_pdfGeneratedProcess"));
			AlertManager.addPopup(popup, Main.instance);
			AppUtils.appCenter(popup);
		}
		
		private function _sendMail(e:MouseEvent):void
		{
			var popup:EnvoiMailPopup = new EnvoiMailPopup();
			AlertManager.addPopup(popup, Main.instance);
			AppUtils.appCenter(popup);
		}*/
		
		private function _onClickRecap(e:MouseEvent):void
		{
			if (_appmodel.screen == ApplicationModel.SCREEN_RECAP) return;

			MenuContainer.instance.closeMenu();
			_appmodel.projetvo.durationBetween2Savings = (getTimer() - _appmodel.projetvo.durationBetween2Savings) / 1000;
			AppUtils.TRACE("EditorNav::durationBetween2Savings:"+ _appmodel.projetvo.durationBetween2Savings);
			EquipementsLayer.updateListeCourses();
			new SaveCommand().run(_gotoRecapScreen);
		}
		
		private function _gotoRecapScreen(pResult:Object = null):void
		{
			EquipementsLayer.updateListeCourses();
			//if (EditorModelLocator.instance.currentBlocMaison == null) return;
			/*var ground0:Floor = _model.getFloorById(0) as Floor;
			if(!ground0.blocMaison)
			{
				var popupa:YesAlert = new YesAlert("Veuillez ajouter une surface au rez-de-chaussée afin de pouvoir accéder à la synthèse", true, true);
				AlertManager.addPopup(popupa, Main.instance);
				AppUtils.appCenter(popupa);
				return;
			}*/
			
			var popup:AlertSauvegarde = new AlertSauvegarde();
			AlertManager.addPopup(popup, Main.instance);
			AppUtils.appCenter(popup);
			
			//_appmodel.projectLabel = projectName.projectName.text;
			_appmodel.screen = ApplicationModel.SCREEN_RECAP;
			_appmodel.projetvo.durationBetween2Savings = 0;
		}
		
		private function _goHome(e:MouseEvent):void
		{
			MenuContainer.instance.closeMenu();
			new SaveCommand().run( function():void {_appmodel.screen = ApplicationModel.SCREEN_HOME;} );
		}
		
		private function _gotoDraw(e:MouseEvent):void
		{
			MenuContainer.instance.closeMenu();
			new SaveCommand(false).run( function():void {
				_appmodel.screen = ApplicationModel.SCREEN_EDITOR;
				_model.isDrawStep = true;
				_model.notifyModeUpdate();
				manageAlphaBtnsEditor(); } );
		}
		
		private function _gotoInstall(e:MouseEvent):void
		{
			MenuContainer.instance.closeMenu();
			new SaveCommand(false).run( function():void {
				_appmodel.screen = ApplicationModel.SCREEN_EDITOR;
				_model.isDrawStep = false;
				_model.notifyModeUpdate();
				manageAlphaBtnsEditor(); } );
		}
		
		private function _onResize(e:Event=null):void
		{
			var b:Background = Background.instance;
			var posy:int = 48//b.masq.y;
			
			_btnHome.x = 15;
			_btnHome.y = posy;
			
			_btnDraw.x = _btnHome.x + _btnHome.width + 10;
			_btnDraw.y = posy;
			
			_btnInstall.x = _btnDraw.x + _btnDraw.width + 10;
			_btnInstall.y = posy;
			
			_btnCheck.x = _btnInstall.x + _btnInstall.width + 10;
			_btnCheck.y = posy;
			
			/*btnSave.x = 500//b.masq.width - btnSave.width -7;
			btnSave.y = posy;*/
			if (!isEditorScreen) 
			{
				/*btnImprimer.x = b.masq.width - 25 - btnImprimer.width;
				btnImprimer.y = posy;
				
				btnEnvoiMail.x = b.masq.width - 25 - btnEnvoiMail.width;
				btnEnvoiMail.y = posy + btnImprimer.height + 10;*/
			}
		}
		
		/*private function _save(e:MouseEvent):void
		{
			var dontshootetage:Boolean = false;
			//var projectNameStr:String = (projectName != null && projectName.projectName.text != null) ? projectName.projectName.text : "";
			new SaveCommand(dontshootetage).run();
		}*/
		
		private function _cleanup(e:Event):void
		{
			//trace("EditorNav::_cleanup");
			_instance = null;
			//btnSave.removeEventListener(MouseEvent.CLICK, _save);
			_btnCheck.removeEventListener(MouseEvent.CLICK, _onClickRecap);
			_btnHome.removeEventListener(MouseEvent.CLICK, _goHome);
			_btnDraw.removeEventListener(MouseEvent.CLICK, _gotoDraw);
			_btnInstall.removeEventListener(MouseEvent.CLICK, _gotoInstall);
			stage.removeEventListener(Event.RESIZE, _onResize);
			/*projectName.projectName.removeEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
			projectName.projectName.removeEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);*/
			removeEventListener(Event.REMOVED_FROM_STAGE, _cleanup);
			if (!isEditorScreen) {
				/*btnImprimer.removeEventListener(MouseEvent.CLICK, _saveLocalPDF);
				btnEnvoiMail.removeEventListener(MouseEvent.CLICK, _sendMail);*/
			}
		}
	}

}