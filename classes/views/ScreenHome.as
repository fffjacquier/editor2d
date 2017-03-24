package classes.views 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.services.php.ListeClientProjects;
	import classes.utils.AppUtils;
	import classes.utils.ObjectUtils;
	import classes.utils.StringUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.DemoPopup;
	import classes.views.alert.HelpPopup;
	import classes.views.alert.YesNoAlert;
	import classes.vo.ClientVO;
	import classes.vo.ProjetVO;
	import com.warmforestflash.drawing.DottedLine;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import fl.video.FLVPlayback;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	/**
	 * La classe ScreenHome affiche les données de la page d'accueil
	 */
	public class ScreenHome extends Screen 
	{
		private var _mainBlockWidth:int = 448;
		private var _nexty:int = 136;
		private var _xpos:int = 521+14//50+14;
		//private var _btnStart:Btn;
		private var _listeProjets:Object = null;
		private var _lastSavedPlan:String;
		private var _lastSavedProjectId:String;
		private var _edmodel:EditorModelLocator = EditorModelLocator.instance;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _f:FLVPlayback;
		
		public function ScreenHome() 
		{
			screen = ApplicationModel.SCREEN_HOME;
			super();
		}
		
		override protected function _added(e:Event):void
		{
			super._added(e);
			_edmodel.isDrawStep = true;
			_init();
		}
		
		private function _init():void
		{
			// reset plan type
			_appmodel.reset();
			//_appmodel.plantype = null;
			_appmodel.projetvo = null;
			_addTitles();
			
			// disable btn save
			_appmodel.notifySaveStateUpdate(false);
			
			try {
				new ListeClientProjects(_handleResult).call();
			} catch (e:Error) {
				_addMainBlock()
			}
			_addLeftBlock();
		}
		
		private function _addTitles():void
		{
			var ypos:int = 66;
			
			var icon:MovieClip = new PictoMaison()
			addChild(icon);
			icon.x = 45
			icon.y = ypos;
			
			var title1:CommonTextField = new CommonTextField("helvet35", Config.COLOR_WHITE, 26);
			title1.width = Config.FLASH_WIDTH - 110;
			addChild(title1);
			title1.setText(AppLabels.getString("common_welcome"));
			title1.x = icon.x + icon.width -5;
			title1.y = ypos -12;
			
			var sub1:CommonTextField = new CommonTextField("helvet", Config.COLOR_WHITE, 14);
			sub1.width = Config.FLASH_WIDTH - 110;
			addChild(sub1);
			sub1.setText(AppLabels.getString("common_subWelcome"));
			sub1.x = icon.x + icon.width -5;
			sub1.y = title1.y + title1.textHeight + 2;
		}
		
		private function _addMainBlock():void
		{
			var g:Graphics = graphics;
			g.clear()
			g.lineStyle();
			g.beginFill(0, .69);
			// fond du bloc de droite
			g.drawRoundRect(521, 130, _mainBlockWidth, 418, 12);
			// fond du bloc de gauche
			g.drawRoundRect(64, 130, 429, 418, 20);
			
			// Quatre parties
			// 1. Nouveau
			// 2. Nouveau depuis plan déjà installé (s'il y en a)
			// 3. Plan type
			// 4. Ouvrir un plan sauvegardé (s'il y en a)
			
			// Règles
			// Dans le cas d’un vendeur avec un nouveau client ou d’un client qui n’a pas de projet sauvé il doit avoir les menus :
			// Nouveau projet
			// Partir d’un plan type
			
			// Dans le cas d’un vendeur et un client existant qui a déjà un projet sauvé
			// Nouveau projet
			// Repartir d’un plan sauvé
			// Partir d’un projet sauvé
			
			// Dans le cas d'un client à domicile
			
			// 1.Nouveau
			if (_listeProjets) {
				if(_appmodel.clientvo.id != -1) {
					if (model.clientvo.liste_id_projet != "") {
						
						// tri des projets
						//AppUtils.TRACE("_listeProjets: élement 0:"+ _listeProjets[0].id_projet );
						//AppUtils.TRACE("_listeProjets: élément lenght-1:"+ _listeProjets[_listeProjets.length-1].id_projet);
						var tmp:Array = _listeProjets.concat();
						tmp.sortOn("timestamp_derniere_modif", Array.DESCENDING);
						//AppUtils.TRACE("timestamp_derniere_modif 0:"+ tmp[0].id_projet);
						//AppUtils.TRACE("timestamp_derniere_modif length-1:"+ tmp[tmp.length-1].id_projet);
						_lastSavedPlan = tmp[0].xml_plan;
						_lastSavedProjectId = tmp[0].id_projet;
						
						// titre projets enregistrés
						var t:CommonTextField = new CommonTextField("helvet35", Config.COLOR_CONNEXION_FIBRE, 50);
						t.width = _mainBlockWidth;
						t.autoSize = TextFieldAutoSize.LEFT;
						addChild(t);
						t.setText(AppLabels.getString("common_savedProjects"));
						t.x = _xpos +2;
						t.y = _nexty;
						_nexty = t.y + t.textHeight;
						
						//sous texte 
						t = new CommonTextField("helvet", Config.COLOR_WHITE, 15, "left", 0, 2);
						t.width = _mainBlockWidth;
						t.autoSize = TextFieldAutoSize.LEFT;
						addChild(t);
						t.setText(AppLabels.getString("common_openSavedPlan"));
						t.x = _xpos +2;
						t.y = _nexty;
						_nexty = t.y + t.textHeight +10;
						
						// 4 boutons projets
						//var nbResultCombo:int = _listeProjets.length;
						//if (nbResultCombo > 0)
						//{
							//var dp:DataProvider = new DataProvider();
							for (var j:int = 0; j < 4; j++)
							{
								var btnProjet1:BtnPlanType = new BtnPlanType();
								if (tmp[j]) btnProjet1.name = tmp[j].id_projet;
								addChild(btnProjet1);
								btnProjet1.txt.mouseEnabled = false;
								if (tmp[j] && tmp[j] != undefined) 
								{
									// equivalent ref_type_projet
									var projectTypeStr:String = "";
									if (tmp[j].ref_type_projet == "fibre") projectTypeStr = AppLabels.getString("common_fiber");
									else if (tmp[j].ref_type_projet == "adsl") projectTypeStr = AppLabels.getString("common_adsl");
									else if (tmp[j].ref_type_projet == "adslSat") projectTypeStr = AppLabels.getString("common_adslSatHome");
									else if (tmp[j].ref_type_projet == "adsl2tv") projectTypeStr = AppLabels.getString("common_adsl2DecHome");
									
									// si nom du projet trop long, 3 petits points
									var projectNameStr:String = tmp[j].nom;
									if (String(tmp[j].nom).length > 22) projectNameStr = String(tmp[j].nom).substr(0, 19) + "...";
									
									btnProjet1.txt.htmlText = "<b>" + projectNameStr + " " + AppLabels.getString("common_num") + tmp[j].id_projet + "</b>  |  " + projectTypeStr;
									
								} else {
									btnProjet1.txt.htmlText = "";
								}
								if (tmp[j] != undefined) {
									btnProjet1.addEventListener(MouseEvent.CLICK, _openProject, false, 0, true);
									btnProjet1.addEventListener(MouseEvent.MOUSE_OVER, _overPlan, false, 0, true);
									btnProjet1.addEventListener(MouseEvent.MOUSE_OUT, _outPlan, false, 0, true);
								} else {
									btnProjet1.btn.alpha = .5;
									btnProjet1.btn.enabled = false;
								}
								btnProjet1.x = _xpos + 2;
								btnProjet1.y = _nexty;
								_nexty = btnProjet1.y + btnProjet1.height +2;
							}
						//}
						
						//ligne
						_addDotLine(Config.COLOR_ORANGE);
						
						//titre nouveau projet
						t = new CommonTextField("helvet35", Config.COLOR_CONNEXION_FIBRE, 50);
						t.width = _mainBlockWidth;
						t.autoSize = TextFieldAutoSize.LEFT;
						t.setText(AppLabels.getString("common_new"));
						addChild(t);
						t.x = _xpos;
						t.y = _nexty -6;
						_nexty = t.y + t.textHeight;
						
						//sous titre
						t = new CommonTextField("helvetBold", Config.COLOR_WHITE, 15, "left", 0, 2);
						t.width = _mainBlockWidth;
						t.autoSize = TextFieldAutoSize.LEFT;
						addChild(t);
						t.setText(AppLabels.getString("common_newFromSaved"));
						t.x = _xpos +2;
						t.y = _nexty;
						_nexty = t.y + t.textHeight;
						
						//bouton dernier plan sauvegardé
						var btnPlan:BtnPlanType = new BtnPlanType();
						btnPlan.name = "p";
						addChild(btnPlan);
						btnPlan.txt.mouseEnabled = false;
						btnPlan.txt.htmlText = "<b>" + AppLabels.getString("buttons_openLastSavedPlan") + "</b>";
						btnPlan.addEventListener(MouseEvent.CLICK, _selectBasePlan, false, 0, true);
						btnPlan.addEventListener(MouseEvent.MOUSE_OVER, _overPlan, false, 0, true);
						btnPlan.addEventListener(MouseEvent.MOUSE_OUT, _outPlan, false, 0, true);
						btnPlan.x = _xpos + 2;
						btnPlan.y = _nexty + 10;
					}
				}
				
			} else {
				//titre
				t = new CommonTextField("helvet35", Config.COLOR_CONNEXION_FIBRE, 50);
				t.width = _mainBlockWidth;
				t.autoSize = TextFieldAutoSize.LEFT;
				t.setText(AppLabels.getString("common_new"));
				addChild(t);
				t.x = _xpos;
				t.y = _nexty;
				_nexty = t.y + t.textHeight;
				
				//sous texte
				t = new CommonTextField("helvet", Config.COLOR_WHITE, 15, "left", 0, 2);
				t.width = _mainBlockWidth;
				t.autoSize = TextFieldAutoSize.LEFT;
				addChild(t);
				t.setText(AppLabels.getString("common_subNew"));
				t.x = _xpos +2;
				t.y = _nexty;
				_nexty = t.y + t.textHeight + 37;
				
				//boutons de formes -- 5 formes
				// forme rectangle
				var btn0:ShapesHome = new ShapesHome();
				btn0.name = "b0";
				btn0.gotoAndStop(1);
				addChild(btn0);
				btn0.addEventListener(MouseEvent.CLICK, _clickShapes);
				btn0.addEventListener(MouseEvent.ROLL_OVER, _overShapes, false, 0, true);
				btn0.addEventListener(MouseEvent.ROLL_OUT, _outShapes, false, 0, true);
				btn0.y = _nexty + 10;
				btn0.x = _xpos + btn0.width/2 + 2;
				// formes en L
				var btn1:ShapesHome = new ShapesHome();
				btn1.name = "b1";
				btn1.gotoAndStop(2);
				addChild(btn1);
				btn1.addEventListener(MouseEvent.CLICK, _clickShapes, false, 0, true);
				btn1.addEventListener(MouseEvent.ROLL_OVER, _overShapes, false, 0, true);
				btn1.addEventListener(MouseEvent.ROLL_OUT, _outShapes, false, 0, true);
				btn1.y = _nexty + 10;
				btn1.x = btn0.x + btn0.width + 18;
				var btn2:ShapesHome = new ShapesHome();
				btn2.name = "b2";
				btn2.gotoAndStop(3);
				addChild(btn2);
				btn2.addEventListener(MouseEvent.CLICK, _clickShapes, false, 0, true);
				btn2.addEventListener(MouseEvent.ROLL_OVER, _overShapes, false, 0, true);
				btn2.addEventListener(MouseEvent.ROLL_OUT, _outShapes, false, 0, true);
				btn2.y = _nexty + 10;
				btn2.x = btn1.x + btn1.width + 18;
				var btn3:ShapesHome = new ShapesHome();
				btn3.name = "b3";
				btn3.gotoAndStop(4);
				addChild(btn3);
				btn3.addEventListener(MouseEvent.CLICK, _clickShapes, false, 0, true);
				btn3.addEventListener(MouseEvent.ROLL_OVER, _overShapes, false, 0, true);
				btn3.addEventListener(MouseEvent.ROLL_OUT, _outShapes, false, 0, true);
				btn3.y = _nexty + 10;
				btn3.x = btn2.x + btn2.width + 18;
				var btn4:ShapesHome = new ShapesHome();
				btn4.name = "b4";
				btn4.gotoAndStop(5);
				addChild(btn4);
				btn4.addEventListener(MouseEvent.CLICK, _clickShapes, false, 0, true);
				btn4.addEventListener(MouseEvent.ROLL_OVER, _overShapes, false, 0, true);
				btn4.addEventListener(MouseEvent.ROLL_OUT, _outShapes, false, 0, true);
				btn4.y = _nexty + 10;
				btn4.x = btn3.x + btn3.width + 18;
				_nexty = btn0.y +110 - btn0.height/2;
				
				//ligne
				_addDotLine(Config.COLOR_ORANGE);
				
				// texte plan préconçu
				t = new CommonTextField("helvet", Config.COLOR_WHITE, 15, "left", 0, 2);
				t.width = _mainBlockWidth;
				t.autoSize = TextFieldAutoSize.LEFT;
				addChild(t);
				t.setText(AppLabels.getString("common_newFromModel"));
				t.x = _xpos +2;
				t.y = _nexty;
				_nexty = t.y + t.textHeight + 10;
				
				// boutons pour les plans
				var btnPlan1:BtnPlanType = new BtnPlanType();
				btnPlan1.name = "f2";
				addChild(btnPlan1);
				btnPlan1.txt.mouseEnabled = false;
				btnPlan1.txt.htmlText = AppLabels.getString("common_studio");
				btnPlan1.addEventListener(MouseEvent.CLICK, _clickPlan, false, 0, true);
				btnPlan1.addEventListener(MouseEvent.MOUSE_OVER, _overPlan, false, 0, true);
				btnPlan1.addEventListener(MouseEvent.MOUSE_OUT, _outPlan, false, 0, true);
				btnPlan1.x = _xpos + 2;
				btnPlan1.y = _nexty;
				_nexty = btnPlan1.y + btnPlan1.height +2;
				
				var btnPlan2:BtnPlanType = new BtnPlanType();
				btnPlan2.name = "f3";
				addChild(btnPlan2);
				btnPlan2.txt.mouseEnabled = false;
				btnPlan2.txt.htmlText = AppLabels.getString("common_flatF4");
				btnPlan2.addEventListener(MouseEvent.CLICK, _clickPlan, false, 0, true);
				btnPlan2.addEventListener(MouseEvent.MOUSE_OVER, _overPlan, false, 0, true);
				btnPlan2.addEventListener(MouseEvent.MOUSE_OUT, _outPlan, false, 0, true);
				btnPlan2.x = _xpos + 2;
				btnPlan2.y = _nexty;
				_nexty = btnPlan2.y + btnPlan2.height +2;
				
				var btnPlan3:BtnPlanType = new BtnPlanType();
				btnPlan3.name = "f4";
				addChild(btnPlan3);
				btnPlan3.txt.mouseEnabled = false;
				btnPlan3.txt.htmlText = AppLabels.getString("common_houseF4");
				btnPlan3.addEventListener(MouseEvent.CLICK, _clickPlan, false, 0, true);
				btnPlan3.addEventListener(MouseEvent.MOUSE_OVER, _overPlan, false, 0, true);
				btnPlan3.addEventListener(MouseEvent.MOUSE_OUT, _outPlan, false, 0, true);
				btnPlan3.x = _xpos + 2;
				btnPlan3.y = _nexty;
				//_nexty = btnPlan2.y + btnPlan2.height +2;
				
				_displayHelp();
			}
			
			
			//_nexty = t.y + t.textHeight;
			
			/*_btnStart = new Btn(Config.COLOR_ORANGE, AppLabels.getString("buttons_start"), null, 66, Config.COLOR_WHITE, 18, 31, Btn.GRADIENT_ORANGE);
			addChild(_btnStart);
			_btnStart.x = 521 + _mainBlockWidth - 30 -_btnStart.width;
			_btnStart.y = 188;
			_nexty = _btnStart.y + _btnStart.height / 2 +20;
			_btnStart.addEventListener(MouseEvent.CLICK, _start);
			
			_addDotLine(Config.COLOR_WHITE);*/
			
			// 2. get the projects list
			/*if(_listeProjets) {
				if(_appmodel.clientvo.id != -1) {
					if (model.clientvo.liste_id_projet != "") {
						t = new CommonTextField("helvetBold", Config.COLOR_WHITE);
						t.width = 270;
						addChild(t);
						t.setText(AppLabels.getString("common_newFromSaved"));
						t.x = _xpos +2;
						t.y = _nexty;
						_nexty = t.y + t.textHeight;

						var tmp:Array = _listeProjets.concat();
						tmp.sortOn("timestamp_derniere_modif", Array.DESCENDING);
						//AppUtils.TRACE(tmp[0].id_projet +" " + tmp[0].id_projet);
						_lastSavedPlan = tmp[0].xml_plan;
						_lastSavedProjectId = tmp[0].id_projet;
						//AppUtils.TRACE("dernier plan:"+_lastSavedPlan);
						var btnPlan:Btn = new Btn(0, AppLabels.getString("buttons_openLastSavedPlan"), null, 116, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
						addChild(btnPlan);
						btnPlan.addEventListener(MouseEvent.CLICK, _selectBasePlan, false, 0, true);
						btnPlan.x = _xpos;
						btnPlan.y = _nexty + 10;
						_nexty = btnPlan.y + 24//btnPlan.height;
						
						_addDotLine(Config.COLOR_WHITE);
					}
				}
			}*/
			
			// 3. plan type
			//AppUtils.TRACE("_listeProjets="+_listeProjets);
			/*if (!_listeProjets) {
				t = new CommonTextField("helvetBold", Config.COLOR_WHITE);
				t.width = 300;
				t.autoSize = TextFieldAutoSize.LEFT;
				addChild(t);
				t.setText(AppLabels.getString("common_newFromModel"));
				t.x = _xpos+2;
				t.y = _nexty;
				_nexty = t.y + t.textHeight;
				
				var combo3:ComboBox = new ComboBox();
				combo3.setSize(200, 24);
				addChild(combo3);
				combo3.x = _xpos+2;
				combo3.y = _nexty +10;
				var dp:DataProvider = new DataProvider();
				dp.addItem({label: AppLabels.getString("common_choose"), data: null});
				dp.addItem({label: AppLabels.getString("common_studio"), data: "f2"});
				dp.addItem({label: AppLabels.getString("common_flatF4"), data: "f3"});
				dp.addItem({label: AppLabels.getString("common_houseF4"), data: "f4"});
				combo3.dataProvider = dp;
				combo3.addEventListener(Event.CHANGE, _selectPlanType, false, 0, true );
				_nexty += combo3.height +10;
				
				_addDotLine(Config.COLOR_ORANGE);
			}*/
			
			// 4. ouvrir 
			//AppUtils.TRACE("liste_id_projet:"+model.clientvo.liste_id_projet)
			/*if(_listeProjets) {
				if (_appmodel.clientvo.id != -1) _addOpenProjectCombo();
			}*/
		}
		
		private function _displayHelp():void
		{
			var popup:HelpPopup = new HelpPopup();
			AlertManager.addPopup(popup, Main.instance);
			popup.x = Background.instance.masq.width/2 - popup.width/2;
			/*popup.y = Background.instance.masq.height/2 - popup.height/2;*/
			//AppUtils.appCenter(popup);
		}
		
		/**
		 * Fait à l'arrache, bouton démarrer en dur dans le clip BtnPlanType dans le fla
		 */
		private function _overPlan(e:MouseEvent):void
		{			
			var shp:BtnPlanType = e.currentTarget as BtnPlanType;
			shp.gotoAndStop(2);
		}
		
		private function _overShapes(e:MouseEvent):void
		{
			var shp:ShapesHome = e.currentTarget as ShapesHome;
			var btnStart:Btn = new Btn( -1, AppLabels.getString("buttons_start"), null, 50, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			btnStart.mouseChildren = false;
			btnStart.buttonMode = false;
			btnStart.enabled = false;
			shp.addChildAt(btnStart, 0);
			btnStart.y = 55;			
			btnStart.alterAfter(function ():void {
				//trace("moveX", btnLink, btnLink.width);
				btnStart.x = -btnStart.width /2// - (shp.width - btnStart.width) / 2;
			});
		}
		
		private function _outShapes(e:MouseEvent):void
		{
			var shp:ShapesHome = e.currentTarget as ShapesHome;
			shp.removeChildAt(0);
		}
		
		private function _outPlan(e:MouseEvent):void
		{
			var shp:BtnPlanType = e.currentTarget as BtnPlanType;
			shp.gotoAndStop(1);
		}
		
		private function _clickPlan(e:MouseEvent):void
		{
			_closeFLVPlayback();
			// AppUtils.TRACE("_selectPlanType:"+ plantype);
			if (model.plantype == null) {//TODO best
				if(e.currentTarget.name == "f2") model.plantype = Config.f2();
				if(e.currentTarget.name == "f3") model.plantype = Config.f4();
				if (e.currentTarget.name == "f4") model.plantype = Config.mf4();
				model.projetvo.xml_plan = model.plantype;
				model.screen = ApplicationModel.SCREEN_EDITOR;
				model.projetvo.durationBetween2Savings = getTimer();
			}
		}
		
		private function _clickShapes(e:MouseEvent):void
		{
			if (e.currentTarget.name == "b0") {
				_appmodel.shape = 0;
			} else if (e.currentTarget.name == "b1") {
				_appmodel.shape = 1;
			} else if (e.currentTarget.name == "b2") {
				_appmodel.shape = 2;
			} else if (e.currentTarget.name == "b3") {
				_appmodel.shape = 3;
			} else if (e.currentTarget.name == "b4") {
				_appmodel.shape = 4;
			}
			_start();
		}
		
		/*private function _getUniquesPlans():Array
		{
			// fresh copie de la liste des projets
			var tmp:Array = (_listeProjets as Array).concat();
			var len:int = tmp.length;
			
			// utilise un dictionary pour comparer et filtrer les plans
			var dict:Dictionary = new Dictionary();
			for (var i:int = 0; i<len; ++i)
			{
				var str:String = tmp[i].xml_plan as String;
				if (!dict[str])
				{
					dict[str] = true;
				}
				else
				{
					tmp.splice(i,1);
					i--; len--;
				}
			}
			dict = null;
			return tmp;
		}*/
		
		private function _selectBasePlan(e:Event):void
		{
			_closeFLVPlayback()
			var xx:XML = new XML(_lastSavedPlan);// as XML does not work
			
			// on enleve les connexions, equipements et fibre présents
			delete xx.connections;
			delete xx.floors.floor.blocs.bloc.equipements;
			delete xx.floors.floor.blocs.bloc.fiberLine;
			
//			AppUtils.TRACE("_selectBasePlan() "+model.projetvo);
			model.projetvo.xml_plan = xx;
			model.screen = ApplicationModel.SCREEN_EDITOR;
			model.projetvo.durationBetween2Savings = getTimer();
		}
		
		private function _selectPlanType(e:Event):void
		{
			_closeFLVPlayback()
			var plantype:String = ComboBox(e.target).selectedItem.data;
	//		AppUtils.TRACE("_selectPlanType:"+ plantype);
			if (model.plantype == null) {//TODO best
				if(plantype == "f2") model.plantype = Config.f2();
				if(plantype == "f3") model.plantype = Config.f4();
				if (plantype == "f4") model.plantype = Config.mf4();
				model.projetvo.xml_plan = model.plantype;
				model.screen = ApplicationModel.SCREEN_EDITOR;
				model.projetvo.durationBetween2Savings = getTimer();
			}
		}
		
		private function _start(e:MouseEvent = null):void
		{
			//-- Crée un projet vide
			var testXML:XML /*= <maison>
  <title><![CDATA[Nommez le projet]]></title>
  <floors>
    <floor id="0" index="0" plancher="béton">
      <name><![CDATA[rez-de-chaussée]]></name>
      <blocs>
        <bloc type="blocMaison" classz="[class MainEntity]" positionx="104.95" positiony="52.45" mursPorteurs="" coeffMurs="10,10,10,10" surfaceType="free">
          <points>
            <point x="-10.5" y="26.25" id="0"/>
            <point x="524.95" y="26.25" id="1"/>
            <point x="524.95" y="288.75" id="2"/>
            <point x="-10.5" y="288.75" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="-10.5" y="31.5" id="0"/>
            <point x="94.5" y="31.5" id="1"/>
            <point x="94.5" y="136.5" id="2"/>
            <point x="-10.5" y="136.5" id="3"/>
          </points>
          <cloisons/>
          <equipements>
            <equipement uniqueId="670F3B8B-3E17-1B55-4D46-123B59ABEC5F" vo="Ordinateur" type="OrdinateurItem" x="61" y="111" isOwned="false" mdc="wifiextender-wifi" asso="44041B65-48EA-0874-5820-123C5E784F29" linked="44041B65-48EA-0874-5820-123C5E784F29"/>
            <equipement uniqueId="44041B65-48EA-0874-5820-123C5E784F29" vo="WiFiExtender" type="WifiExtenderItem" x="92.95" y="118.75" isOwned="false" mdc="null" asso="" isModuleDeBase="false" linked="670F3B8B-3E17-1B55-4D46-123B59ABEC5F"/>
          </equipements>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="141.75" y="42" id="0"/>
            <point x="246.75" y="42" id="1"/>
            <point x="246.75" y="147" id="2"/>
            <point x="141.75" y="147" id="3"/>
          </points>
          <cloisons/>
          <equipements>
            <equipement uniqueId="1EDD19B5-A14D-889B-EC4F-123B42592418" vo="OrdinateurFixe" type="OrdinateurItem" x="215" y="98" isOwned="false" mdc="wifiextender-wifi" asso="33E8E6D1-06D2-1C6B-9BC6-123C32A0C081" linked="33E8E6D1-06D2-1C6B-9BC6-123C32A0C081"/>
            <equipement uniqueId="33E8E6D1-06D2-1C6B-9BC6-123C32A0C081" vo="WiFiExtender" type="WifiExtenderItem" x="235.8" y="98.15" isOwned="false" mdc="null" asso="" isModuleDeBase="false" linked="1EDD19B5-A14D-889B-EC4F-123B42592418"/>
          </equipements>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="283.5" y="47.25" id="0"/>
            <point x="503.95" y="47.25" id="1"/>
            <point x="503.95" y="273" id="2"/>
            <point x="283.5" y="273" id="3"/>
          </points>
          <cloisons/>
          <equipements>
            <equipement uniqueId="A9A767B3-08A2-C432-C42D-123B4776F9D6" vo="OrdinateurFixe" type="OrdinateurItem" x="354" y="146" isOwned="false" mdc="wifiextender-wifi" asso="C294973D-49A4-1456-A317-123C1D9E276D" linked="C294973D-49A4-1456-A317-123C1D9E276D"/>
            <equipement uniqueId="C294973D-49A4-1456-A317-123C1D9E276D" vo="WiFiExtender" type="WifiExtenderItem" x="377.05" y="163.35" isOwned="false" mdc="null" asso="" isModuleDeBase="false" linked="A9A767B3-08A2-C432-C42D-123B4776F9D6"/>
            <equipement uniqueId="C00AACD5-94AA-2885-C9E0-123B4D10DEB9" vo="Ordinateur" type="OrdinateurItem" x="448" y="224" isOwned="false" mdc="null" asso=""/>
          </equipements>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="120.75" y="157.5" id="0"/>
            <point x="225.75" y="157.5" id="1"/>
            <point x="225.75" y="262.5" id="2"/>
            <point x="120.75" y="262.5" id="3"/>
          </points>
          <cloisons/>
          <equipements>
            <equipement uniqueId="529480E6-FFCF-C971-3A22-123B54400900" vo="Ordinateur" type="OrdinateurItem" x="171" y="228" isOwned="false" mdc="wifiextender-wifi" asso="2F4D3F1B-74A2-2CCD-2C0C-123C465BB596" linked="2F4D3F1B-74A2-2CCD-2C0C-123C465BB596"/>
            <equipement uniqueId="2F4D3F1B-74A2-2CCD-2C0C-123C465BB596" vo="WiFiExtender" type="WifiExtenderItem" x="194.1" y="245.65" isOwned="false" mdc="null" asso="" isModuleDeBase="false" linked="529480E6-FFCF-C971-3A22-123B54400900"/>
          </equipements>
        </bloc>
      </blocs>
    </floor>
    <floor id="1" index="1" plancher="béton">
      <name><![CDATA[1er étage]]></name>
      <blocs>
        <bloc type="blocMaison" classz="[class MainEntity]" positionx="104.95" positiony="52.45" mursPorteurs="" coeffMurs="10,10,10,10" surfaceType="free">
          <points>
            <point x="-10.5" y="26.25" id="0"/>
            <point x="524.95" y="26.25" id="1"/>
            <point x="524.95" y="288.75" id="2"/>
            <point x="-10.5" y="288.75" id="3"/>
          </points>
          <cloisons>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="299.2" y="36.75" id="0"/>
              <point x="299.2" y="141.75" id="1"/>
            </cloison>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="372.7" y="84" id="0"/>
              <point x="477.7" y="84" id="1"/>
            </cloison>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="157.5" y="225.75" id="0"/>
              <point x="262.5" y="225.75" id="1"/>
            </cloison>
          </cloisons>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="0" y="36.75" id="0"/>
            <point x="105" y="36.75" id="1"/>
            <point x="105" y="141.75" id="2"/>
            <point x="0" y="141.75" id="3"/>
          </points>
          <cloisons/>
          <equipements>
            <equipement uniqueId="25C994BB-DB9D-194F-5138-123B124D2B5F" vo="LiveboxPlay" type="LiveboxItem" x="35" y="72" isOwned="false" mdc="null" asso="60403A3F-1396-7CEC-B181-123BEE2FFEFE"/>
            <equipement uniqueId="60403A3F-1396-7CEC-B181-123BEE2FFEFE" vo="Liveplug" type="LivePlugItem" x="71.85" y="97.6" isOwned="false" mdc="null" asso="F3746111-B15C-BDDF-1B45-123BEE2F88CC" isModuleDeBase="true"/>
          </equipements>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="131.25" y="84" id="0"/>
            <point x="236.25" y="84" id="1"/>
            <point x="236.25" y="189" id="2"/>
            <point x="131.25" y="189" id="3"/>
          </points>
          <cloisons/>
          <equipements>
            <equipement uniqueId="3D1AA800-6B5F-9DEE-9A2C-123B31C9F72C" vo="OrdinateurFixe" type="OrdinateurItem" x="170" y="129" isOwned="false" mdc="wifiextender-wifi" asso="F3746111-B15C-BDDF-1B45-123BEE2F88CC" linked="F3746111-B15C-BDDF-1B45-123BEE2F88CC"/>
            <equipement uniqueId="F3746111-B15C-BDDF-1B45-123BEE2F88CC" vo="WiFiExtender" type="WifiExtenderItem" x="201.5" y="136.25" isOwned="false" mdc="null" asso="60403A3F-1396-7CEC-B181-123BEE2FFEFE" isModuleDeBase="false" linked="3D1AA800-6B5F-9DEE-9A2C-123B31C9F72C"/>
          </equipements>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="5.25" y="157.5" id="0"/>
            <point x="110.25" y="157.5" id="1"/>
            <point x="110.25" y="262.5" id="2"/>
            <point x="5.25" y="262.5" id="3"/>
          </points>
          <cloisons/>
          <equipements>
            <equipement uniqueId="B5E10AE8-6422-3CC2-10B4-123B198C5AC4" vo="DecodeurTVPlay" type="DecodeurItem" x="45" y="219" isOwned="false" mdc="duo-ethernet" asso="87E7103C-021A-AB88-5485-123B24C1501C" linked="87E7103C-021A-AB88-5485-123B24C1501C"/>
            <equipement uniqueId="87E7103C-021A-AB88-5485-123B24C1501C" vo="WiFiSolo" type="WifiDuoItem" x="76.6" y="224.05" isOwned="false" mdc="null" asso="" isModuleDeBase="false" linked="B5E10AE8-6422-3CC2-10B4-123B198C5AC4"/>
          </equipements>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="314.95" y="157.5" id="0"/>
            <point x="430.45" y="157.5" id="1"/>
            <point x="430.45" y="262.5" id="2"/>
            <point x="314.95" y="262.5" id="3"/>
          </points>
          <cloisons/>
          <equipements>
            <equipement uniqueId="65395F43-C906-2DA2-FD7A-123B37EF0F6C" vo="OrdinateurFixe" type="OrdinateurItem" x="370" y="205" isOwned="false" mdc="wifiextender-wifi" asso="8FBB8ABB-FDFF-FB35-537E-123C02F21EAA" linked="8FBB8ABB-FDFF-FB35-537E-123C02F21EAA"/>
            <equipement uniqueId="8FBB8ABB-FDFF-FB35-537E-123C02F21EAA" vo="WiFiExtender" type="WifiExtenderItem" x="401.8" y="206.5" isOwned="false" mdc="null" asso="" isModuleDeBase="false" linked="65395F43-C906-2DA2-FD7A-123B37EF0F6C"/>
          </equipements>
        </bloc>
      </blocs>
    </floor>
  </floors>
  <connections>
    <connection eq1="25C994BB-DB9D-194F-5138-123B124D2B5F" eq2="87E7103C-021A-AB88-5485-123B24C1501C" type="wifi" needsCheck="false"/>
    <connection eq1="87E7103C-021A-AB88-5485-123B24C1501C" eq2="B5E10AE8-6422-3CC2-10B4-123B198C5AC4" type="ethernet" needsCheck="false" parent="25C994BB-DB9D-194F-5138-123B124D2B5F"/>
    <connection eq1="25C994BB-DB9D-194F-5138-123B124D2B5F" eq2="60403A3F-1396-7CEC-B181-123BEE2FFEFE" type="ethernet" needsCheck="false"/>
    <connection eq1="60403A3F-1396-7CEC-B181-123BEE2FFEFE" eq2="F3746111-B15C-BDDF-1B45-123BEE2F88CC" type="cpl" needsCheck="false" parent="25C994BB-DB9D-194F-5138-123B124D2B5F"/>
    <connection eq1="F3746111-B15C-BDDF-1B45-123BEE2F88CC" eq2="3D1AA800-6B5F-9DEE-9A2C-123B31C9F72C" type="wifi" needsCheck="false" parent="60403A3F-1396-7CEC-B181-123BEE2FFEFE"/>
    <connection eq1="60403A3F-1396-7CEC-B181-123BEE2FFEFE" eq2="8FBB8ABB-FDFF-FB35-537E-123C02F21EAA" type="cpl" needsCheck="false" parent="25C994BB-DB9D-194F-5138-123B124D2B5F"/>
    <connection eq1="8FBB8ABB-FDFF-FB35-537E-123C02F21EAA" eq2="65395F43-C906-2DA2-FD7A-123B37EF0F6C" type="wifi" needsCheck="false" parent="60403A3F-1396-7CEC-B181-123BEE2FFEFE"/>
    <connection eq1="60403A3F-1396-7CEC-B181-123BEE2FFEFE" eq2="C294973D-49A4-1456-A317-123C1D9E276D" type="cpl" needsCheck="false" parent="25C994BB-DB9D-194F-5138-123B124D2B5F"/>
    <connection eq1="C294973D-49A4-1456-A317-123C1D9E276D" eq2="A9A767B3-08A2-C432-C42D-123B4776F9D6" type="wifi" needsCheck="false" parent="60403A3F-1396-7CEC-B181-123BEE2FFEFE"/>
    <connection eq1="60403A3F-1396-7CEC-B181-123BEE2FFEFE" eq2="33E8E6D1-06D2-1C6B-9BC6-123C32A0C081" type="cpl" needsCheck="false" parent="25C994BB-DB9D-194F-5138-123B124D2B5F"/>
    <connection eq1="33E8E6D1-06D2-1C6B-9BC6-123C32A0C081" eq2="1EDD19B5-A14D-889B-EC4F-123B42592418" type="wifi" needsCheck="false" parent="60403A3F-1396-7CEC-B181-123BEE2FFEFE"/>
    <connection eq1="60403A3F-1396-7CEC-B181-123BEE2FFEFE" eq2="2F4D3F1B-74A2-2CCD-2C0C-123C465BB596" type="cpl" needsCheck="false" parent="25C994BB-DB9D-194F-5138-123B124D2B5F"/>
    <connection eq1="2F4D3F1B-74A2-2CCD-2C0C-123C465BB596" eq2="529480E6-FFCF-C971-3A22-123B54400900" type="wifi" needsCheck="false" parent="60403A3F-1396-7CEC-B181-123BEE2FFEFE"/>
    <connection eq1="60403A3F-1396-7CEC-B181-123BEE2FFEFE" eq2="44041B65-48EA-0874-5820-123C5E784F29" type="cpl" needsCheck="false" parent="25C994BB-DB9D-194F-5138-123B124D2B5F"/>
    <connection eq1="44041B65-48EA-0874-5820-123C5E784F29" eq2="670F3B8B-3E17-1B55-4D46-123B59ABEC5F" type="wifi" needsCheck="false" parent="60403A3F-1396-7CEC-B181-123BEE2FFEFE"/>
  </connections>
</maison>*/;
			if(testXML)
			{
				model.projetvo = new ProjetVO();
				model.projetvo.id = 250331;
				model.projetvo.duree_utilisation = 248904;
				model.projetvo.duree_creation = 0;
				model.projetvo.nom = "Mon projet étage unique";
				model.projetvo.id_type_logement = 0;
				model.projetvo.ref_type_projet = "fibre";//"adslSat";//
				model.projetvo.note_memo = "";
				model.projetvo.note_vendeur = "";
				model.projetvo.liste_courses = "";//"#livebox_4#decodeur_4#"
				model.projetvo.xml_plan = testXML;
				//trace("lb xml " + testXML.@lb + "$");
				// si pas renseigné, forcément 'Livebox2'
				// on vérifie quand même que pas de LiveboxPlay dans les vo des équipements présents
				if (String(testXML.@lb) === "") {
					if (String(testXML.floors.floor.blocs.bloc.equipements.equipement.@vo).indexOf("LiveboxPlay") != -1) {
						model.selectedLivebox = "LiveboxPlay";
					} else {
						model.selectedLivebox = "Livebox2";
					}
				} else {
					model.selectedLivebox = testXML.@lb;
				}
			} else {
				model.projetvo = null;
			}
			_closeFLVPlayback();
			model.reset();
			model.screen = ApplicationModel.SCREEN_EDITOR;
			model.projetvo.durationBetween2Savings = getTimer();
		}
		
		private function _addLeftBlock():void
		{			
			// si on a des données client et qu'on a un profil vendeur 
			// (attention profil vendeur basé sur le critere de ProfileVO acces_recherche
			// si gestion des profils change, cette supposition peut devenir fausse)
			if (_appmodel.profilevo.acces_recherche && _appmodel.clientvo != null) {
				// on affiche les données du client
				_displayClientVO();
			} else {
				// on affiche le player video d'aide
				_addDemo();
			}
		}
		
		private function _addDemo():void
		{
			var xpos:int = 64 + 14;
			var ypos:int = 130;
			
			var b:HomeVideo = new HomeVideo();
			b.x = xpos -14;
			b.y = ypos;
			addChild(b);
			b.addEventListener(MouseEvent.CLICK, _openVideoAide, false, 0, true);
			// texte bonjour
			/*var t:CommonTextField = new CommonTextField("helvet35", Config.COLOR_CONNEXION_FIBRE, 50);
			t.width = 300;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.setText(AppLabels.getString("common_demo"));
			addChild(t);
			t.x = xpos;
			t.y = ypos;
			ypos += t.height + 35;
			
			_f = new FLVPlayback();
			_f.source = "Anim_PlanMaisonConnectee_dedans.flv";
			_f.autoPlay = true;
			_f.scaleMode = "maintainAspectRatio";
			_f.skin = "SkinUnderPlaySeekFullscreen.swf";
			_f.skinBackgroundAlpha = .85;
			_f.skinBackgroundColor = 0x666666;
			_f.width = 409;
			addChild(_f);
			_f.x = 74;
			_f.y = ypos;*/
		}
		
		private function _openVideoAide(e:MouseEvent=null):void
		{
			var popup:DemoPopup = new DemoPopup(null, "home");
			AlertManager.addPopup(popup, Main.instance);
			popup.x = Background.instance.masq.width/2 - 900/2;
			popup.y = Background.instance.masq.height / 2 - 600 / 2;
		}
		
		private function _closeFLVPlayback():void
		{
			//SoundMixer.stopAll();
			//if(_f && _f.stage) _f.stop();
		}
		
		private function _displayClientVO():void
		{
			var xpos:int = 64 + 14;
			var ypos:int = 136;
			// texte bonjour
			var t:CommonTextField = new CommonTextField("helvet35", Config.COLOR_CONNEXION_FIBRE, 50);
			t.width = 300;
			t.autoSize = TextFieldAutoSize.LEFT;
			if (_appmodel.profilevo.user_profile == "VENDEUR") t.setText(AppLabels.getString("common_hello2"));
			else t.setText(AppLabels.getString("common_hello"));
			addChild(t);
			t.x = xpos;
			t.y = ypos;
			ypos += t.height + 35;
			
			t = new CommonTextField("helvet", 0xffffff, 14, "left", .2);
			t.width = 390
			addChild(t);
			var c:ClientVO = _appmodel.clientvo;
			var str:String = "";
			var civ:String;
			if (c.id_civilite == 1) civ = AppLabels.getString("common_miss") + " ";
			else if(c.id_civilite == 2) civ = AppLabels.getString("common_madam") + " ";
			else if (c.id_civilite == 3) civ = AppLabels.getString("common_mister") + " ";
			else civ = "";
			if (c.nom != null && c.nom != "") str = civ + ((c.prenom == null || c.prenom == "") ? "" : StringUtils.capitalize(c.prenom) + " ") + StringUtils.capitalize(c.nom) + "\n";
			else str = AppLabels.getString("form_lastname") + " " + AppLabels.getString("common_emptyField") + "\n";
			if (c.adresse != null && c.adresse != "") str += c.adresse + "\n";
			else str += AppLabels.getString("form_address") + " " + AppLabels.getString("common_emptyField") + "\n";
			if (c.cp != null && c.ville != null && c.ville != "") str += ((c.cp == null) ? "" : c.cp + " ") + StringUtils.capitalize(c.ville) + "\n";
			else str += AppLabels.getString("form_city") + " " + AppLabels.getString("common_emptyField") + "\n";
			if (c.email != null && c.email != "") str += c.email;
			else str += AppLabels.getString("form_email") + " " + AppLabels.getString("common_emptyField") + "\n";
			t.setText(str);
			t.x = xpos;
			t.y = ypos;
			ypos += t.height +20;
			
			// données
			t = new CommonTextField("helvet", 0xffffff, 14, "left", .2);
			t.width = 390;
			addChild(t);
			str = "";
			
			//TODO vérifier les comparaisons et les valeurs à récupérer
			
			var defaultStyleObj:Object = new Object();
			defaultStyleObj.fontFamily = (new Helvet55Reg() as Font).fontName;
			defaultStyleObj.fontSize = '14';
			defaultStyleObj.color = '#ffffff';
			
			var myStyleSheet:StyleSheet = new StyleSheet();
			myStyleSheet.setStyle(".defaultStyle", defaultStyleObj);
			// à noter
			// le em, balise inline en html, provoque un retour à la ligne dans flash une fois mis en setStyle ...
			myStyleSheet.setStyle("em", {color:'#ffcc00'});
			
			if (c.client_orange_fixe != 1) {
				if(c.id_autre_operateur_fixe == 0) 
					str = "<span class='defaultStyle'>" + AppLabels.getString("common_phoneClient") + "<em>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_AUTRE_OP_FIXE, c.id_autre_operateur_fixe) +"</em>";
				else 
					str = "<span class='defaultStyle'>" + AppLabels.getString("common_phoneClient") + "<em>" + AppLabels.getString("common_emptyField") + "</em>";
			}
			else str = "<span class='defaultStyle'>" + AppLabels.getString("common_phoneClient") + "<em>" + AppLabels.getString("common_orangeMark") + "</em>";
			
			if (c.client_orange_internet != 1) {
				if (c.id_autre_operateur_internet == 0) 
					str += AppLabels.getString("common_internetClient") + "<em>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_AUTRE_OP_INTERNET, c.id_autre_operateur_internet) +"</em>";
				else
					str += AppLabels.getString("common_internetClient") + "<em>" + AppLabels.getString("common_emptyField") + "</em>";
			}
			else {
				str += AppLabels.getString("common_internetClient") + "<em>" + AppLabels.getString("common_orangeMark") + "</em>";
				if (c.id_orange_forfait_internet != -1) str += AppLabels.getString("common_access") + "<em>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_ORANGE_FORFAIT_INTERNET, c.id_orange_forfait_internet) +"</em>";
				if (c.id_livebox != -1 && c.id_decodeur != -1) {
					str += AppLabels.getString("common_livebox") + "<font color='#ffcc00'>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_LIVEBOX, c.id_livebox) +"</font>, "+ AppLabels.getString("common_decoder") + "<em>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_DECODEUR, c.id_decodeur) +"</em>";
				} else {
					if (c.id_livebox != -1 && c.id_decodeur == -1) {
						str += AppLabels.getString("common_livebox") + "<em>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_LIVEBOX, c.id_livebox) +"</em>";
					} else {
						str += AppLabels.getString("common_decoder") + "<em>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_DECODEUR, c.id_decodeur) +"</em>";
					}
				}
			}
			
			if (c.client_orange_mobile != 1) {
				if (c.id_autre_operateur_mobile == 0)
					str += AppLabels.getString("common_mobileClient") + "<em>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_AUTRE_OP_MOBILE, c.id_autre_operateur_mobile) +"</em>";
				else
					str += AppLabels.getString("common_mobileClient") + "<em>" + AppLabels.getString("common_emptyField") + "</em>";
			}
			else {
				str += AppLabels.getString("common_mobileClient") + "<em>" + AppLabels.getString("common_orangeMark") + "</em>"
			}
			
			if (c.id_type_logement != 0) str += AppLabels.getString("common_housingType") + "<em>" + (c.id_type_logement == 1) ? "appartement" : "maison" +"</em>";
			else str += AppLabels.getString("common_housingType") + "<em>" + AppLabels.getString("common_emptyField") + "</em>";
			
			if (c.id_test_eligibilite != 0) str += AppLabels.getString("common_eligibility") + "<em>" + _appmodel._liste_combos.getListeBoxLabel(ApplicationModel.CBNAME_TEST_ELIGIBILITE, c.id_test_eligibilite) +"</em></span>";
			else str += AppLabels.getString("common_eligibility") + "<em>" + AppLabels.getString("common_emptyField") + "</em></span>";
			
			var myTextField:TextField = new TextField();
			myTextField.width = 390;
			myTextField.autoSize = TextFieldAutoSize.LEFT;
			myTextField.wordWrap = true;
			myTextField.multiline = true;
			myTextField.embedFonts = true;
			myTextField.styleSheet = myStyleSheet;
			myTextField.htmlText = str;
			addChild(myTextField);
			myTextField.x = xpos;
			myTextField.y = ypos;
			
			ypos += myTextField.height +20;
			
			// btn modifier -- lien vers données inscription
			var btnMod:Btn = new Btn(0, AppLabels.getString("buttons_modify"), null, 80, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			addChild(btnMod);
			btnMod.x = xpos;
			btnMod.y = ypos;
			btnMod.addEventListener(MouseEvent.CLICK, _goInscription, false, 0, true);
		}
		
		private function _goInscription(e:MouseEvent):void
		{
			_appmodel.screen = ApplicationModel.SCREEN_INSCRIPTION;
		}
		
		private function _addDotLine(color:Number):void
		{
			var s:Shape = new DottedLine(_mainBlockWidth - 30, 1, color, 1, 1.3, 2);
			addChild(s);
			s.x = _xpos;
			s.y = _nexty +20;
			_nexty = s.y + 10;			
		}
		
		private function _handleResult(pResult:Object=null):void
		{
			_listeProjets = pResult;
			
			if (_listeProjets) _appmodel.listProjectsCopy = _listeProjets.length;
			else _appmodel.listProjectsCopy = 0;
			
			_addMainBlock();
		}
		
		/*private function _addOpenProjectCombo():void
		{
			//trace("_addOpenProjectCombo !");
			//AppUtils.TRACE("ScreenHome::_addOpenProjectCombo > " + _listeProjets);
			if (_listeProjets) {
				//AppUtils.TRACE(model.clientvo.liste_id_projet)
				var t:CommonTextField = new CommonTextField("helvet35", Config.COLOR_CONNEXION_FIBRE, 50);
				t.width = 300;
				t.autoSize = TextFieldAutoSize.LEFT;
				t.setText(AppLabels.getString("buttons_open"));
				addChild(t);
				t.x = _xpos;
				t.y = _nexty -5;
				_nexty = t.y + t.textHeight;
			
				t = new CommonTextField("helvetBold", Config.COLOR_WHITE);
				t.width = 300;
				t.autoSize = TextFieldAutoSize.LEFT;
				addChild(t);
				t.setText(AppLabels.getString("common_openSavedPlan"));
				t.x = _xpos +2;
				t.y = _nexty;
				_nexty = t.y + t.textHeight;	
				
				var combo4:ComboBox = new ComboBox();
				combo4.setSize(200, 24);
				addChild(combo4);
				combo4.x = _xpos;
				combo4.y = _nexty + 10;
				_nexty = combo4.y + combo4.height;
				var nbResultCombo:int = _listeProjets.length;
				if (nbResultCombo > 0)
				{
					var dp:DataProvider = new DataProvider();
					dp.addItem( { label: AppLabels.getString("common_choose"), data: null } );
					for (var j:int = 0; j < nbResultCombo; j++)
					{
						dp.addItem( { label: _listeProjets[j].id_projet + " : " + _listeProjets[j].nom, data: _listeProjets[j].id_projet } );
					}
				}
				combo4.dataProvider = dp;
				combo4.addEventListener(Event.CHANGE, _openProject);
			}
		}*/
		
		private function _openProject(e:Event):void
		{
			// set project as project
			//var idProject:int = ComboBox(e.target).selectedItem.data;
			var idProject:int = parseInt(e.currentTarget.name);
			AppUtils.TRACE("num projet" + idProject);
			_appmodel.projetvo.loadDb(idProject, _checkLastPlan);
		}
		
		private function _checkLastPlan():void
		{
			AppUtils.TRACE("_checkLastPlan "+_lastSavedProjectId + " " + _appmodel.projetvo.id);
			// Règle:
			// si ce n'est pas le dernier projet enregistré et que le plan du projet différe du plan du dernier projet enregistré
			// popup
			if ( _appmodel.projetvo.id != parseInt(_lastSavedProjectId) ) {
				
				var xx:XML = new XML(_appmodel.projetvo.xml_plan);
				// on enleve les connexions, equipements et fibre présents
				delete xx.connections;
				delete xx.floors.floor.blocs.bloc.equipements;
				delete xx.floors.floor.blocs.bloc.fiberLine;
				
				var yy:XML = new XML(_lastSavedPlan);
				// on enleve les connexions, equipements et fibre présents
				delete yy.connections;
				delete yy.floors.floor.blocs.bloc.equipements;
				delete yy.floors.floor.blocs.bloc.fiberLine;
				
				// on compare les deux versions écrémées
				var str:String = xx.toString();
				if (str == yy.toString()) {
					AppUtils.TRACE("_checkLastPlan plans identiques");
					_goEditor();
					return;
				} else {
					AppUtils.TRACE("str:"+str);
					AppUtils.TRACE("_lastSavedPlan:"+yy.toString());
				}
			} else {
				_goEditor();
				return;
			}
			var p:YesNoAlert = new YesNoAlert(AppLabels.getString("messages_warning"), AppLabels.getString("messages_notLastSavedPlan"), _goEditor, null);
			AlertManager.addPopup(p, Main.instance);
			AppUtils.appCenter(p);
		}
		
		private function _goEditor():void
		{
			// go to editor
			model.screen = ApplicationModel.SCREEN_EDITOR;
			model.projetvo.duree_utilisation = getTimer();
		}
		
		override protected function cleanup():void
		{			
			//_btnStart.removeEventListener(MouseEvent.CLICK, _start);
			super.cleanup();
		}
	}
}