package classes.views 
{
	import classes.commands.CreatePDF;
	import classes.commands.SaveCommand;
	import classes.components.ScrollBarH;
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.ArrayUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSauvegarde;
	import classes.views.alert.EnvoiMailPopup;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.Liste;
	import classes.views.items.EquipmentInstalled;
	import classes.views.items.ItemListeCourse;
	import classes.views.plan.EditorNav;
	import classes.views.synthese.TabBtn;
	import classes.vo.EquipementVO;
	import classes.vo.MaskSizeVO;
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	import fl.controls.TextArea;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/* Optimisation de code
	 * 
	 * Scinder le code en quatre si possible dans le package synthese afin de ne gérer que l'affichage dans cet écran. 
	 * Les détails de l'implémentation ne devraient pas être là.
	 * 
	 */
	
	/**
	 * La classe ScreenRecap affiche les 4 onglets : méos, installation, équipements et plan-étages
	 * 
	 * <p><strong>Remarque</strong> Les boutons imprimer le pdf et envoyer par mail sont gérés dans la classe <code>EditorNav</code></p>
	 * 
	 * @see classes.views.plan.EditorNav
	 */
	public class ScreenRecap extends Screen 
	{
		private var editorNav:EditorNav;
		private var recapEtages:Sprite;
		private var recapNotes:Sprite;
		private var recapListeEquipements:Sprite;
		private var recapListeCourses:Sprite;
		private var recapEnd:Sprite;
		private var recapContainer:Sprite;// pour centrer l'écran
		private var _ta:TextArea;
		private var _tb:TextArea;		
		public var listeDeCourses:Liste;
		
		private var _bg:Sprite;
		
		private var _btnMaison:TabBtn;
		private var _btnInstall:TabBtn
		private var _btnEquipts:TabBtn
		private var _btnMemos:TabBtn;
		private var _btnEnd:TabBtn;
		
		private var _tabMemo:Sprite;
		private var _tabMaison:Sprite;
		private var _tabInstall:Sprite;
		private var _tabCourses:Sprite;
		
		private var btnEnvoiMail:Btn;
		private var btnImprimer:Btn;
		private var btnSave:Btn;
		
		private var _masqPlan:Sprite;
		private var _masqInstall:Sprite;
		private var _masqCourses:Sprite;
		
		private var _scrollPlan:Sprite;
		private var _scrollInstall:Sprite;
		private var _scrollCourses:Sprite;
		private var _listeCoursesSprite:Sprite;
		
		private var _previousTexte:String;
		
		private var _scrollpane:ScrollPane;
		private var _tweensArr:Array = new Array();
		private var _tweenCompleteCount:int;
		private var _am:ApplicationModel = ApplicationModel.instance;
		
		public function ScreenRecap() 
		{
			screen = ApplicationModel.SCREEN_RECAP;
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
			trace("ScreenRecap::_init()");
			editorNav = new EditorNav();
			addChild(editorNav);
			
			//le fond gris, blanc et noir
			_bg = new Sprite();
			addChild(_bg);
			_bg.x = 15;
			_bg.y = 175;
			
			// on a 4 onglets
			//-votre maison, (vos plans, murs porteurs)
			//-votre installation
			//-vos équipements et le type de projet (liste)
			//-vos mémos
			
			// 4 boutons
			_btnMemos = new TabBtn(AppLabels.getString("check_yourMemos"));
			_btnMemos.name = "memo"
			addChild(_btnMemos);
			_btnMemos.addEventListener(MouseEvent.CLICK, _onclicktab);
			_btnMaison = new TabBtn(AppLabels.getString("check_yourHome2"));
			_btnMaison.name = "maison"
			addChild(_btnMaison)
			_btnMaison.addEventListener(MouseEvent.CLICK, _onclicktab);
			_btnInstall = new TabBtn(AppLabels.getString("check_yourInstall"));
			_btnInstall.name = "install"
			addChild(_btnInstall)
			_btnInstall.addEventListener(MouseEvent.CLICK, _onclicktab);
			_btnEquipts = new TabBtn(AppLabels.getString("check_shoppingList"))
			_btnEquipts.name = "courses";
			addChild(_btnEquipts);
			_btnEquipts.addEventListener(MouseEvent.CLICK, _onclicktab);
			
			_btnEnd = new TabBtn(AppLabels.getString("check_endYourProject"));
			_btnEnd.name = "end";
			addChild(_btnEnd);
			_btnEnd.addEventListener(MouseEvent.CLICK, _onclicktab);
			
			_btnMaison.selected();
			
			recapContainer = new Sprite();
			addChild(recapContainer);
			
			_positionTabs();			
			
			//selon la valeur de l'onglet courant, afficher le bon contenu
			var titre:CommonTextField;
			var texte:CommonTextField;
			var currentSprite:Sprite;
			var shape:Shape;
			
			//-------------------
			// TAB end
			//-------------------
			recapEnd = new Sprite();
			recapContainer.addChild(recapEnd);
			currentSprite = recapEnd;
			recapEnd.x = 32;
			recapEnd.y = 175;
			
			var breadcumbs:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_DARK, 14);
			breadcumbs.width = 900;
			currentSprite.addChild(breadcumbs);
			breadcumbs.setText(AppLabels.getString("editor_projectNum") + _am.projetvo.id);
			breadcumbs.y = 12;
			
			//--- partie gauche, cadre noir
			var icon:MovieClip = new PictoOeil();
			currentSprite.addChild(icon);
			icon.x = (183) / 2;
			icon.scaleX = icon.scaleY = 2.1
			icon.y = 80 + icon.height/2;
			icon.alpha = .4;

			titre = new CommonTextField("helvet35", Config.COLOR_WHITE, 23);
			currentSprite.addChild(titre);
			titre.width = 183;
			titre.y = 120;
			titre.setText(AppLabels.getString("check_endYourProject"));
			var tf:TextFormat = titre.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			titre.setTextFormat(tf); 
			
			//--- partie centrale
			shape = new Shape();
			currentSprite.addChild(shape);
			shape.x = 240;
			shape.y = 62;
			var g:Graphics = shape.graphics;
			g.clear();
			g.lineStyle(1, Config.COLOR_LIGHT_GREY);
			g.beginFill(0xffffff);
			g.drawRoundRect(0, 0, 651, 295, 15);
			g.endFill();
			
			texte = new CommonTextField("helvet", 0, 18);
			texte.width = 625;
			currentSprite.addChild(texte);
			texte.setText(AppLabels.getString("check_end1"));
			var nextx:int = shape.x + 10;
			texte.x = nextx;
			texte.y = shape.y + 10;
			var nexty:int = texte.y + texte.height + 20;
			
			texte = new CommonTextField("helvet", 0, 14);
			texte.width = 625;
			currentSprite.addChild(texte);
			texte.setText(AppLabels.getString("check_end2"));
			texte.x = nextx;
			texte.y = nexty;
			nexty = texte.y + texte.textHeight + 10;
			
			// projet
			breadcumbs = new CommonTextField("helvetBold", Config.COLOR_DARK, 14);
			breadcumbs.width = 140;
			currentSprite.addChild(breadcumbs);
			breadcumbs.setText(AppLabels.getString("editor_projectNum") + _am.projetvo.id);
			breadcumbs.x = nextx;
			breadcumbs.y = nexty;
			
			var projectName:NomDuProjet = new NomDuProjet();
			currentSprite.addChild(projectName);
			if (model.projectLabel == null) {
				model.projectLabel = AppLabels.getString("editor_nameTheProject");
			}
			projectName.projectName.htmlText = "<b>" + model.projectLabel;
			projectName.projectName.textColor = Config.COLOR_WHITE;
			var s:Shape = (projectName.getChildAt(0) as Shape);
			g = s.graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0x999999);
			g.drawRoundRect(0, 0, 171, 24, 12);
			projectName.projectName.addEventListener(FocusEvent.FOCUS_IN, _onFocusInProject, false, 0, true);
			projectName.projectName.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOutProject, false, 0, true);
			projectName.projectName.addEventListener(Event.CHANGE, _onChangeProject, false, 0, true);
			projectName.x = breadcumbs.x + breadcumbs.textWidth + 12;
			projectName.y = nexty;
			nexty = breadcumbs.y + breadcumbs.height + 25;
			
			texte = new CommonTextField("helvet", 0, 14);
			texte.width = 625;
			currentSprite.addChild(texte);
			texte.setText(AppLabels.getString("check_end3"));
			texte.x = nextx;
			texte.y = nexty;
			nexty = texte.y + texte.textHeight + 10;
			
			btnSave = new Btn(0, AppLabels.getString("buttons_save"), PictoMain, 135, 0xffffff, 16, 30, Btn.GRADIENT_ORANGE);
			currentSprite.addChild(btnSave);
			btnSave.x = nextx;
			btnSave.y = nexty;
			btnSave.addEventListener(MouseEvent.CLICK, _saveProject);
			
			btnImprimer = new Btn(0, AppLabels.getString("buttons_print"), PictoImprim, 155, 0xffffff, 16, 30, Btn.GRADIENT_ORANGE);
			currentSprite.addChild(btnImprimer);
			btnImprimer.x = nextx + 200;
			btnImprimer.y = nexty;
			btnImprimer.addEventListener(MouseEvent.CLICK, _saveLocalPDF);
			btnImprimer.visible = _am.profilevo.acces_btnprint;

			btnEnvoiMail = new Btn(0, AppLabels.getString("buttons_send"), PictoMail, 155, 0xffffff, 16, 30, Btn.GRADIENT_ORANGE);
			currentSprite.addChild(btnEnvoiMail);
			btnEnvoiMail.x = nextx + 415;
			btnEnvoiMail.y = nexty;
			btnEnvoiMail.addEventListener(MouseEvent.CLICK, _sendMail);
			btnEnvoiMail.visible = _am.profilevo.acces_btnmail;
			nexty = btnSave.y + btnSave.height + 20;
			
			texte = new CommonTextField("helvet", 0, 14);
			texte.width = 415;
			currentSprite.addChild(texte);
			texte.x = nextx;
			texte.y = nexty;
			nexty = texte.y + texte.textHeight + 15;
			if (_am.profilevo.user_profile == "VENDEUR") texte.setText(AppLabels.getString("check_end4"));
			else texte.setText(AppLabels.getString("pdf_signature2b"));
			
			//-------------------
			// TAB notes et mémos
			//-------------------
			recapNotes = new Sprite();
			recapContainer.addChild(recapNotes);
			currentSprite = recapNotes;
			recapNotes.x = 32;
			recapNotes.y = 175;

			breadcumbs = new CommonTextField("helvetBold", Config.COLOR_DARK, 14);
			breadcumbs.width = 900;
			currentSprite.addChild(breadcumbs);
			breadcumbs.setText(AppLabels.getString("check_subTextMemo"));
			breadcumbs.y = 12;
			//breadcumbs.x = 0;
			
			icon = new PictoTrombone();
			currentSprite.addChild(icon);
			icon.x = (183) / 2;
			icon.y = 80 + icon.height/2;
			icon.alpha = .4;

			titre = new CommonTextField("helvet35", Config.COLOR_WHITE, 23);
			currentSprite.addChild(titre);
			titre.width = 183;
			titre.y = 120;
			titre.setText(AppLabels.getString("check_yourMemosAndNotes"));
			tf = titre.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			titre.setTextFormat(tf); 
			
			// add the title
			titre = new CommonTextField("helvet35", Config.COLOR_DARK, 30, "left", 0.5);
			currentSprite.addChild(titre);
			titre.width = 283;
			titre.x = 240;
			titre.y = 53;
			titre.setText(AppLabels.getString("check_yourMemos"));
			
			// ajout d'un sous texte
			var sub:CommonTextField = new CommonTextField();
			currentSprite.addChild(sub);
			sub.width = 160;
			sub.setText(AppLabels.getString("check_memoExamples"));
			tf = sub.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			sub.setTextFormat(tf);
			sub.x = 9;
			sub.y = 220;
			
			// add the text and background and scroll
			shape = new Shape();
			currentSprite.addChild(shape);
			shape.x = 240;
			shape.y = 94;
			g = shape.graphics;
			g.clear();
			g.lineStyle(1, Config.COLOR_LIGHT_GREY);
			g.beginFill(0xffffff);
			g.drawRoundRect(0, 0, 323, 267, 15);
			g.endFill();
			_tb = new TextArea();
			_tb.setSize(334, 267);
			_tb.move(shape.x + 6, shape.y);
			_tb.editable = true;
			_tb.enabled = true; 
			_tb.wordWrap = true;
			_tb.horizontalScrollPolicy = ScrollPolicy.OFF;
			_tb.verticalScrollPolicy = ScrollPolicy.ON;
			_tb.textField.antiAliasType = AntiAliasType.ADVANCED;
			
			var ft:TextFormat = new TextFormat();
			ft.font = (new Helvet55Reg() as Font).fontName;
			ft.size = 12;
			_tb.setStyle("embedFonts", true);
			_tb.setStyle("textFormat", ft);
			_tb.drawNow();
			currentSprite.addChild(_tb);
			
			var str:String = (model.memos == " " || model.memos == "") ? AppLabels.getString("check_noMemo") : model.memos;
			_tb.text = str;
			model.addMemoUpdateListener(_updateMemo);
			_updateMemo();
			_tb.addEventListener(Event.CHANGE, _onChangeMemo, false, 0, true); 
			_tb.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, _prevent, false, 0, true); 
			_tb.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _prevent, false, 0, true);
			
			//add the notes title
			if (model.profilevo.acces_notesvendeur) 
			{
				titre = new CommonTextField("helvet35", Config.COLOR_DARK, 30, "left", 0.5);
				currentSprite.addChild(titre);
				titre.width = 280;
				titre.x = 610;
				titre.y = 53;
				titre.setText(AppLabels.getString("check_notes"));
				//add the background
				shape = new Shape();
				currentSprite.addChild(shape);
				shape.x = 610;
				shape.y = 94;
				g = shape.graphics;
				g.clear();
				g.lineStyle(1, Config.COLOR_LIGHT_GREY);
				g.beginFill(0xffffff);
				g.drawRoundRect(0, 0, 323, 267, 15);
				g.endFill();
				//add the input text
				_ta = new TextArea();
				_ta.setSize(334, 267);
				_ta.move(shape.x + 6, shape.y);
				_ta.editable = true;
				_ta.enabled = true; 
				_ta.text = model.projetvo.note_vendeur || AppLabels.getString("popups_typeYourText"); 
				_ta.wordWrap = true;
				_ta.horizontalScrollPolicy = ScrollPolicy.OFF;
				_ta.verticalScrollPolicy = ScrollPolicy.ON;
				_ta.textField.antiAliasType = AntiAliasType.ADVANCED;
				_ta.setStyle("embedFonts", true);
				_ta.setStyle("textFormat", ft);
				_ta.drawNow();
				currentSprite.addChild(_ta);
				_ta.addEventListener(FocusEvent.FOCUS_IN, _onFocusIn, false, 0, true);
				_ta.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut, false, 0, true);
				_ta.addEventListener(Event.CHANGE, _onChange, false, 0, true); 
				_ta.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, _prevent, false, 0, true); 
				_ta.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _prevent, false, 0, true);
			}
			
			//-------------------
			// TAB vos plans
			//-------------------
			recapEtages = new Sprite();
			recapContainer.addChild(recapEtages);
			currentSprite = recapEtages;
			recapEtages.x = 32;
			recapEtages.y = 175;
			
			breadcumbs = new CommonTextField("helvetBold", Config.COLOR_DARK, 14);
			breadcumbs.width = 900;
			currentSprite.addChild(breadcumbs);
			breadcumbs.setText("Chez vous : ");
			breadcumbs.y = 12;
			
			projectName = new NomDuProjet();
			currentSprite.addChild(projectName);
			if (model.projectLabel == null) {
				model.projectLabel = AppLabels.getString("editor_nameTheProject");
			}
			projectName.projectName.htmlText = "<b>" + model.projectLabel;
			//projectName.projectName.textColor = Config.COLOR_DARK;
			s = (projectName.getChildAt(0) as Shape);
			g = s.graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(Config.COLOR_LIGHT_GREY);
			g.drawRoundRect(0, 0, 171, 24, 12);
			projectName.projectName.addEventListener(FocusEvent.FOCUS_IN, _onFocusInProject, false, 0, true);
			projectName.projectName.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOutProject, false, 0, true);
			projectName.projectName.addEventListener(Event.CHANGE, _onChangeProject, false, 0, true);
			projectName.x = breadcumbs.x + breadcumbs.textWidth + 12;
			projectName.y = 12;

			icon = new PictoVosPlans();
			currentSprite.addChild(icon);
			icon.x = (183) / 2;
			icon.y = 80 + icon.height/2;
			icon.alpha = .4;

			titre = new CommonTextField("helvet35", Config.COLOR_WHITE, 23);
			currentSprite.addChild(titre);
			titre.width = 183;
			titre.y = 120;
			titre.setText(AppLabels.getString("check_yourPlans"));
			tf = titre.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			titre.setTextFormat(tf);

			var blal:CommonTextField = new CommonTextField();
			blal.width = 160;
			currentSprite.addChild(blal);
			blal.setText(AppLabels.getString("check_remindBearWalls"));
			tf = blal.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			blal.setTextFormat(tf);
			blal.x = 10;
			blal.y = 220;

			// btn Modifier
			var btnModif:Btn = new Btn(0, AppLabels.getString("buttons_modify"), null, 66, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			currentSprite.addChild(btnModif);
			btnModif.addEventListener(MouseEvent.CLICK, _gotoEditorFloor, false, 0, true);
			btnModif.x = 60;
			btnModif.y = 160;
			
			var captures:Sprite = new Sprite();
			currentSprite.addChild(captures);
			captures.x = 240;
			captures.y = 64//titre.y + titre.height + 10;
			if (model.capturesArr.length > 0) {
				for (var i:int = 0; i < model.capturesArr.length; i++)
				{
					s = new Shape();
					g = s.graphics
					g.clear();
					g.lineStyle(1, 0xcccccc);
					g.beginFill(Config.COLOR_WHITE);
					g.drawRoundRect(0,0,543,296,12);
					g.endFill();
					captures.addChild(s);
					s.x = i * ( 543 + 5);
					
					var bitm:Bitmap = new Bitmap(model.capturesArr[i]);
					//trace("bitm.width " + bitm.width);
					bitm.smoothing = true;
					
					captures.addChild(bitm);
					
					bitm.x = s.x + 10;
					bitm.y = 30;
					//bitm.y = i * (bitm.height + 16);
					
					var t:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_ORANGE, 14);
					t.width = 540;					
					// combien de murs porteurs par étage calculé depuis le xml
					var nbMP:int = 0;
					var mursPorteursList:XMLList = XMLList(model.projetvo.xml_plan.floors.floor.(@index == i).blocs.bloc.@mursPorteurs);
					//trace("mursPorteursList", mursPorteursList+"$");
					if (mursPorteursList.toXMLString() != "") {
						var arr:Array = mursPorteursList.(toString() != "").toXMLString().split("\n");
						//trace(i, "arr", arr+"$", arr.length)
						var tmp:String = arr.join(",");
						//trace(tmp+"$")
						if (tmp != " " && tmp != "") {
							arr = tmp.split(",");
							nbMP = arr.length;
						}
					}
					mursPorteursList = XMLList(model.projetvo.xml_plan.floors.floor.(@index == i).blocs.bloc.cloisons.cloison.@mursPorteurs);
					//trace("mursPorteursList", mursPorteursList+"$");
					if (mursPorteursList.toXMLString() != "") {
						arr = mursPorteursList.(toString() != "").toXMLString().split("\n");
						//trace(i, "arr:", arr+"$", arr.length)
						tmp = arr.join(",");
						//trace(tmp+"$")
						if (tmp != " " && tmp != "") {
							arr = tmp.split(",");
							nbMP += arr.length;
						}
					}
					
					t.setText(model.etages[i] + " : " + nbMP + AppLabels.getString("check_bearingWallsFloor"));
					var rangeForNewColor:int = t.text.indexOf(" : ") +3;
					tf = t.cloneFormat();
					tf.color = Config.COLOR_DARK;
					t.setTextFormat(tf, rangeForNewColor, t.text.length);
					captures.addChild(t);
					t.x = s.x + 5;
					t.y = s.y + 5;
					
					var legendContainer:Sprite = _addWallsLegend();
					captures.addChild(legendContainer);
					legendContainer.x = bitm.x + bitm.width + 15;
					legendContainer.y = (296 - 10 - legendContainer.height);
				}
				//_testAndAddScroll(captures);
				
				_scrollPlan = new ScrollBarH(captures);
				currentSprite.addChild(_scrollPlan);
				_scrollPlan.x = 212
				_scrollPlan.y = 212
				
				_masqPlan = new Sprite();
				currentSprite.addChild(_masqPlan);
				g = _masqPlan.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0);
				g.drawRect(212, 64, 695, 300);
				g.endFill();
				captures.mask = _masqPlan;
			}
			
			//-------------------
			// =TAB votre installation, vos équipements
			//-------------------
			recapListeEquipements = new Sprite();
			recapContainer.addChild(recapListeEquipements);
			currentSprite = recapListeEquipements;
			recapListeEquipements.x = 32;
			recapListeEquipements.y = 175;
			
			breadcumbs = new CommonTextField("helvetBold", Config.COLOR_DARK, 14);
			breadcumbs.width = 900;
			currentSprite.addChild(breadcumbs);
			str = AppLabels.getString("check_installTypeLabel");
			if (model.projectType == null) {
				str += AppLabels.getString("check_noEquipements");
			} else {
				str += Config.getProjectTypes()[model.projectType]
			}
			breadcumbs.setText(str);
			breadcumbs.y = 12;
			
			icon = new PictoEquipements();
			currentSprite.addChild(icon);
			icon.x = (183) / 2;
			icon.y = 80 + icon.height/2;
			icon.alpha = .4;

			titre = new CommonTextField("helvet35", Config.COLOR_WHITE, 23);
			currentSprite.addChild(titre);
			titre.width = 183;
			titre.y = 120;
			titre.setText(AppLabels.getString("check_yourEquipements"));
			tf = titre.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			titre.setTextFormat(tf);

			var numEq:int = model.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.length();
			var numEqNotConnected:int = model.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.(@mdc.toString() == "null" && @type.toString() != "PriseItem" && @type.toString() != "LiveboxItem" && @type.toString() != "LivePlugItem" && @type.toString() != "WifiExtenderItem" && @type.toString() != "WifiDuoItem" && @type.toString() != "TelephoneItem" && @type.toString() != "LivephoneItem" && @type.toString() != "MainDoorItem").length();
			var numEqWifiConnected:int = model.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.@mdc.(toString() == ModesDeConnexion.WIFI || toString() == ModesDeConnexion.WIFIEXTENDER_WIFI).length();
			//trace("nb equipements:", numEq);
			trace("nb equipements non connectés:", numEqNotConnected);
			trace("nb equipements connectés wifi:", numEqWifiConnected);
			if (numEqNotConnected > 0) {
				
				blal = new CommonTextField("helvetBold", Config.COLOR_YELLOW);
				blal.width = 183;
				currentSprite.addChild(blal);
				blal.setText(AppLabels.getString("messages_warning"));
				tf = blal.cloneFormat();
				tf.align = TextFormatAlign.CENTER;
				blal.setTextFormat(tf);
				blal.y = 200;
				
				blal = new CommonTextField();
				blal.width = 165;
				currentSprite.addChild(blal);
				if (numEqNotConnected == 1) str = numEqNotConnected.toString() + AppLabels.getString("check_singleEqNotConnected");
				else str = numEqNotConnected.toString() + AppLabels.getString("check_multipleEqNotConnected");
				blal.setText(str);
				blal.width = 170;
				tf = blal.cloneFormat();
				tf.align = TextFormatAlign.CENTER;
				blal.setTextFormat(tf);
				blal.x = 6;
				blal.y = 220;
			}
			
			if(numEqWifiConnected > 5) {
				blal = new CommonTextField();
				blal.width = 165;
				currentSprite.addChild(blal);
				blal.setText(AppLabels.getString("editor_warningTooManyWifiEquipements"));
				tf = blal.cloneFormat();
				tf.align = TextFormatAlign.CENTER;
				blal.setTextFormat(tf);
				blal.x = 6;
				blal.y = 255;
			}

			// btn Modifier
			btnModif = new Btn(0, AppLabels.getString("buttons_modify"), null, 66, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			currentSprite.addChild(btnModif);
			btnModif.addEventListener(MouseEvent.CLICK, _gotoEditorEquipts, false, 0, true);
			btnModif.x = 60;
			btnModif.y = 160;
			
			// display liste des équipements et le scroll
			if (numEq == 0) {
			} else {
				captures = new Sprite();
				currentSprite.addChild(captures);
				captures.x = 240;
				captures.y = 64;
				if (model.capturesArr.length > 0) {
					// on ne tient pas compte des modules et prises et portes dans cet écran
					var eqA:Array = XMLList(model.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.(@type.toString() != "PriseItem" && @type.toString() != "LivePlugItem" && @type.toString() != "WifiDuoItem" && @type.toString() != "WifiExtenderItem" && @type.toString() != "MainDoorItem" && @type.toString() != "SwitchItem")).toXMLString().split("\n");
					// on réordonne la liste - LB en 1, décodeurs ensuite, etc...
					var liveboxArr:Array = [];
					var decodeursArr:Array = [];
					var liveplugArr:Array = [];
					var wifiextArr:Array = [];
					var wifiduoArr:Array = [];
					var tmpArr:Array = [];
					for (i = 0; i < eqA.length; i++)
					{
						//trace("^"+eqA[i]+"$", (eqA[i] != ""))
						var eqRawXml:XML = XML(eqA[i]);
						//trace(eqRawXml.@type, (eqRawXml.@type == "PriseItem"))
						if (eqRawXml.@type == "LiveboxItem") {
							liveboxArr.push(eqA[i]);
						} else if (eqRawXml.@type == "DecodeurItem") {
							decodeursArr.push(eqA[i]);
						} else if (eqRawXml.@type == "LivePlugItem") {
							liveplugArr.push(eqA[i]);
						} else if (eqRawXml.@type == "WifiExtenderItem") {
							wifiextArr.push(eqA[i]);
						} else if (eqRawXml.@type == "WifiDuoItem") {
							wifiduoArr.push(eqA[i]);
						} else {
							if (eqA[i] != "") tmpArr.push(eqA[i]);
						}
					}
					var eqArr:Array = [];/*le tableau des équipements ordonnés*/
					eqArr = liveboxArr.concat(decodeursArr, wifiduoArr, liveplugArr, wifiextArr, tmpArr);
					//trace("eqArr", eqArr.length);
					for (i = 0; i < eqArr.length; i++)
					{
						eqRawXml = XML(eqArr[i]);
						var vo:EquipementVO = model.getVOFromXML(eqRawXml.@vo);
						var eq:EquipmentInstalled = new EquipmentInstalled();
						eq.uniqueId = eqRawXml.@uniqueId;
						eq.image = vo.imagePath;
						eq.label = vo.screenLabel;
						eq.linkInfo = vo.diaporama360;
						eq.connection = eqRawXml.@mdc;
						eq.connectionAcceptable = "true"
						eq.connectionAcceptable = XMLList(model.projetvo.xml_plan.connections.connection.(@eq2.toString() == eq.uniqueId)).@needsCheck.toXMLString().split("\n");
						//trace(i, "connectionAcceptable", eq.label, eq.connectionAcceptable);
						eq.isOwned = eqRawXml.@isOwned;
						eq.videosArr = vo.videosArr;
						eq.type = vo.type;
						
						captures.addChild(eq);
						eq.x = i * ( 183 + 7);
						eq.render();
					}
					//_testAndAddScroll(captures);
					
					_scrollInstall = new ScrollBarH(captures);
					currentSprite.addChild(_scrollInstall);
					_scrollInstall.x = 212;
					_scrollInstall.y = 212;
					
					_masqInstall = new Sprite();
					currentSprite.addChild(_masqInstall);
					g = _masqInstall.graphics;
					g.clear();
					g.lineStyle();
					g.beginFill(0);
					g.drawRect(212, 64, 695, 300);
					g.endFill();
					captures.mask = _masqInstall;
				}
			}
			
			//-------------------
			// TAB liste de courses
			//-------------------
			recapListeCourses = new Sprite();
			recapContainer.addChild(recapListeCourses);
			currentSprite = recapListeCourses;
			recapListeCourses.x = 32;
			recapListeCourses.y = 175;
			
			breadcumbs = new CommonTextField("helvetBold", Config.COLOR_DARK, 14);
			breadcumbs.width = 900;
			currentSprite.addChild(breadcumbs);
			breadcumbs.setText(AppLabels.getString("check_subEquipements"));
			breadcumbs.y = 12;
			
			icon = new PictoCaddie();
			currentSprite.addChild(icon);
			icon.x = (183) / 2;
			icon.y = 80 + icon.height/2;
			icon.alpha = .4;

			titre = new CommonTextField("helvet35", Config.COLOR_WHITE, 23);
			currentSprite.addChild(titre);
			titre.width = 183;
			titre.y = 120;
			titre.setText(AppLabels.getString("check_shoppingList2"));
			tf = titre.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			titre.setTextFormat(tf);
			
			blal = new CommonTextField();
			blal.width = 165;
			currentSprite.addChild(blal);
			blal.setText(AppLabels.getString("check_howList"));
			blal.width = 170;
			tf = blal.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			blal.setTextFormat(tf);
			blal.x = 6;
			blal.y = 220;
			
			_buildListeCourses();
			/*if (numEq == 0) {
			} else {
				_listeCoursesSprite = new Sprite();
				currentSprite.addChild(_listeCoursesSprite);
				_listeCoursesSprite.x = 240;
				_listeCoursesSprite.y = 64;
				
				_updateListeCourses(_listeCoursesSprite);
				
				_scrollCourses = new ScrollBarH(_listeCoursesSprite);
				currentSprite.addChild(_scrollCourses);
				_scrollCourses.x = 212
				_scrollCourses.y = 212
				
				_masqCourses = new Sprite();
				currentSprite.addChild(_masqCourses);
				g = _masqCourses.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0);
				g.drawRect(212, 64, 695, 300);
				g.endFill();
				_listeCoursesSprite.mask = _masqCourses;
			}*/
			
			// on presuppose que btn print desactivé == aussi btn envoimail desactivé
			if (!model.profilevo.acces_btnprint) {
				var spriteT:Sprite = new Sprite();
				addChild(spriteT);
				spriteT.alpha = 0;
				spriteT.y = 50;
				spriteT.x = 950;
				t = new CommonTextField("helvetBold");
				t.width = 230;
				t.setText(AppLabels.getString("check_getVendor") + model.projetvo.id +"");
				spriteT.addChild(t);
				
				_tweensArr.push(new Tween(spriteT, "alpha", Regular.easeOut, 0, 1, 5, true));
				(_tweensArr[_tweensArr.length - 1] as Tween).addEventListener(TweenEvent.MOTION_FINISH, _tweenComplete, false, 0, true);
				_tweensArr.push(new Tween(spriteT, "x", Regular.easeOut, spriteT.x, 780, 5, true));
				(_tweensArr[_tweensArr.length - 1] as Tween).addEventListener(TweenEvent.MOTION_FINISH, _tweenComplete, false, 0, true);
			}
			
			_loadTab();
			
			stage.addEventListener(Event.RESIZE, _onResize);
			_onResize();
			
			AlertManager.removePopup();
		}
		
		private function _saveProject(e:MouseEvent=null):void
		{
			AlertManager.removePopup();
			new SaveCommand(false).run(_afterSaving);
		}
		
		private function _afterSaving(pResult:Object = null):void
		{
			_am.notifySaveStateUpdate(false);
		}
		
		private function _pdfReady(e:Event):void
		{
			AlertManager.removePopup();
		}
		
		private function _saveLocalPDF(e:MouseEvent):void
		{
			new CreatePDF("savePDF");
			_am.addPDFReadyListener(_pdfReady);
			var popup:AlertSauvegarde = new AlertSauvegarde(AppLabels.getString("messages_pdfGeneratedProcess"));
			AlertManager.addPopup(popup, Main.instance);
			AppUtils.appCenter(popup);
		}
		
		private function _sendMail(e:MouseEvent):void
		{
			var popup:EnvoiMailPopup = new EnvoiMailPopup();
			AlertManager.addPopup(popup, Main.instance);
			AppUtils.appCenter(popup);
		}
		
		private function _tweenComplete(e:TweenEvent):void
		{
			_tweenCompleteCount++;
			if (_tweenCompleteCount == 2) {
				_tweensArr = [];
			}
		}
		
		private function _testAndAddScroll(captures:*, larg:int=700 ):void
		{
			//trace(captures.height);
			if (captures.width < larg) return; 
			
			_scrollpane = new ScrollPane();
			_scrollpane.x = captures.x;
			_scrollpane.y = captures.y;
			captures.parent.addChild(_scrollpane);
			_scrollpane.setSize(larg, 312);
			_scrollpane.verticalScrollPolicy = ScrollPolicy.OFF;
			_scrollpane.source = captures;
		}
		
		private function _addWallsLegend():Sprite
		{
			var legendContainer:Sprite = new Sprite();
			
			var leg:Sprite = new Sprite();
			leg.graphics.clear();
			leg.graphics.lineStyle();
			leg.graphics.beginFill(0);
			leg.graphics.drawRect(0, 1, 22, 6);
			var t:CommonTextField = new CommonTextField("helvet", 0);
			t.width = 85;
			t.setText(AppLabels.getString("check_legendBearingWall3"));
			leg.addChild(t);
			t.x = 30;
			t.y = - 5;
			legendContainer.addChild(leg);
			var ypos:int = leg.height + 2;
			
			leg = new Sprite();
			leg.graphics.clear();
			leg.graphics.lineStyle();
			leg.graphics.beginFill(0);
			leg.graphics.drawRect(0, 5, 22, 3);
			t = new CommonTextField("helvet", 0);
			t.width = 85;
			t.setText(AppLabels.getString("check_legendBearingWall2"));
			leg.addChild(t);
			t.x = 30;
			t.y = - 5;
			legendContainer.addChild(leg);
			leg.y = ypos;
			ypos = leg.y + leg.height + 2;
			
			leg = new Sprite();
			leg.graphics.clear();
			leg.graphics.lineStyle();
			leg.graphics.beginFill(Config.COLOR_ORANGE);
			leg.graphics.drawRect(0, 5, 22, 3);
			t = new CommonTextField("helvet", 0);
			t.width = 85;
			t.setText(AppLabels.getString("check_legendBearingWall1"));
			leg.addChild(t);
			t.x = 30;
			t.y = - 5;
			legendContainer.addChild(leg);
			leg.y = ypos;
			return legendContainer;
		}
		
		private function _loadTab(tab:String = "maison"):void
		{
			/*var memo:TabMemo = new TabMemo();
			memo.x = 32
			memo.y = 188
			addChild(memo);*/
			recapNotes.visible = false;
			recapEtages.visible = false;
			recapListeCourses.visible = false;
			recapListeEquipements.visible = false;
			recapEnd.visible = false;
			
			if (tab == "memo") {
				recapNotes.visible = true;
			} else if (tab == "maison") {
				recapEtages.visible = true;
			} else if (tab == "courses") {
				var numEq:int = model.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.length();
				if (numEq == 0) {
				} else {
					if (_listeCoursesSprite && _listeCoursesSprite.stage) recapListeCourses.removeChild(_listeCoursesSprite);
					
					_listeCoursesSprite = new Sprite();
					recapListeCourses.addChild(_listeCoursesSprite);
					_listeCoursesSprite.x = 240;
					_listeCoursesSprite.y = 64;
					
					_updateListeCourses(_listeCoursesSprite);
					if (_scrollCourses && _scrollCourses.stage) recapListeCourses.removeChild(_scrollCourses);
					_scrollCourses = new ScrollBarH(_listeCoursesSprite, 508);
					recapListeCourses.addChild(_scrollCourses);
					_scrollCourses.x = 212
					_scrollCourses.y = 212
					
					if (_masqCourses && _masqCourses.stage) recapListeCourses.removeChild(_masqCourses);
					_masqCourses = new Sprite();
					recapListeCourses.addChild(_masqCourses);
					var g:Graphics = _masqCourses.graphics;
					g.clear();
					g.lineStyle();
					g.beginFill(0);
					g.drawRect(212, 64, 695, 300);
					g.endFill();
					_listeCoursesSprite.mask = _masqCourses;
					
					_onResize();
				}
				recapListeCourses.visible = true;
			} else if (tab == "install") {
				recapListeEquipements.visible = true;
			} else {
				recapEnd.visible = true;
			}
		}
		
		private function _onclicktab(e:MouseEvent):void
		{
			//--- on déselect tous les onglets
			_btnEquipts.deselected();
			_btnInstall.deselected();
			_btnMaison.deselected();
			_btnMemos.deselected();
			_btnEnd.deselected();
			
			//--- on select l'onglet cliqué
			TabBtn(e.target).selected();
			if (e.target == _btnMemos) {
				_loadTab("memo");
			} else if (e.target == _btnMaison) {
				_loadTab();
			} else if (e.target == _btnEquipts) {
				_loadTab("courses");
			} else if (e.target == _btnInstall) {
				_loadTab("install");
			} else {
				_loadTab("end");
			}
			
			_positionTabs();
		}
			
		private function _buildListeCourses():void
		{
			// recup les equipements, sauf prises et portes
			var eqA:Array = XMLList(model.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.(@type.toString() != "MainDoorItem" && @type.toString() != "PriseItem")).toXMLString().split("\n");
			// on réordonne la liste - LB en 1, décodeurs ensuite, etc...
			var liveboxArr:Array = [];
			var decodeursArr:Array = [];
			var liveplugArr:Array = [];
			var wifiextArr:Array = [];
			var wifiduoArr:Array = [];
			var tmpArr:Array = [];
			
			for (var i:int = 0; i < eqA.length; i++)
			{
				var eqRawXml:XML = XML(eqA[i]);
				//trace(eqRawXml.@type, (eqRawXml.@type == "LiveboxItem"))
				if (eqRawXml.@type == "LiveboxItem") {
					liveboxArr.push(eqA[i]);
				} else if (eqRawXml.@type == "DecodeurItem") {
					decodeursArr.push(eqA[i]);
				} else if (eqRawXml.@type == "LivePlugItem") {
					liveplugArr.push(eqA[i]);
				} else if (eqRawXml.@type == "WifiExtenderItem") {
					wifiextArr.push(eqA[i]);
				} else if (eqRawXml.@type == "WifiDuoItem") {
					wifiduoArr.push(eqA[i]);
				} else {
					tmpArr.push(eqA[i]);
				}
			}
				
			var eqArr:Array = [];/*le tableau des équipements ordonnés*/
			eqArr = eqArr.concat(liveboxArr, decodeursArr, wifiduoArr, liveplugArr, wifiextArr, tmpArr);
			liveboxArr = [];
			decodeursArr = [];
			liveplugArr = [];
			wifiextArr = [];
			wifiduoArr = [];
			tmpArr = [];
			// on a ensuite besoin des vo
				for (i = 0; i < eqArr.length; i++)
				{	
					eqRawXml = XML(eqArr[i]);
					var vo:EquipementVO = model.getVOFromXML(eqRawXml.@vo);
					var equipement:EquipementView = new EquipementView(vo);
					equipement.isOwned = eqRawXml.@isOwned;
					if ( vo.isOrange == "true" && eqRawXml.@isOwned == "false" )
					{
						if (vo.type == "LiveboxItem") {
							if(model.clientvo.id_livebox != vo.id) liveboxArr.push(equipement);
						} else if (vo.type == "DecodeurItem") {
							if (model.clientvo.id_decodeur != vo.id) {
								decodeursArr.push(equipement);
							} else {
								// special case for decodeur 86 (not in the xml list anymore)
								if (model.clientvo.id_decodeur == 3 && vo.id == 4) {
									decodeursArr.push(equipement);
								}
							}
						} else if (vo.type == "LivePlugItem") {
							liveplugArr.push(equipement);
						} else if (vo.type == "WifiExtenderItem") {
							wifiextArr.push(equipement);
						} else if (vo.type == "WifiDuoItem") {
							wifiduoArr.push(equipement);
						} else {
							tmpArr.push(equipement);
						}
					}
				}
				
				// on ajoute les câbles ethernet dans le cas où il y a une connexion ethernet dans le xml
				var itemWiresNeeded:Boolean = (model.projetvo.xml_plan != null && model.projetvo.xml_plan.connections.connection.(@type == "ethernet").length() > 0);
				if (itemWiresNeeded) {
					var wireVO:EquipementVO = new EquipementVO();
					wireVO.imagePath = "images/cableEthernet.png";
					wireVO.type = "WireItem";
					wireVO.diaporama360 = "null";
					wireVO.linkArticleShop = AppLabels.getString("check_ethernetWireLinkShop");
					wireVO.screenLabel = AppLabels.getString("check_ethernetWire");// managed in 
					var wiresEq:EquipementView = new EquipementView(wireVO);
					tmpArr.push(wiresEq);
				}
			model.listeDeCourses = [];
			model.listeDeCourses = model.listeDeCourses.concat(liveboxArr, decodeursArr, wifiduoArr, liveplugArr, wifiextArr, tmpArr);
			//trace("_buildListeCourses", model.listeDeCourses)
			
			// cette condition permet d'éviter le bug de la liste de courses qui n'apparait pas dans le pdf quand on n'a pas 
			// encore cliqué sur l'onglet liste de courses FJ 11/09/12
			if (model.listeDeCourses != null) {
				model.listeDeCoursesSynthese = new Liste();
				listeDeCourses = new Liste();
				for (var iii:int = 0; iii < model.listeDeCourses.length; iii++)
				{
					var eqV:EquipementView = (model.listeDeCourses[iii] as EquipementView);
					var eqvo:EquipementVO = eqV.vo;
					var key:String = eqV.vo.screenLabel;
					//trace("liste de course recap:", key, eqV);
					if (listeDeCourses.containsKey(key)) {
						listeDeCourses.updateValue(key, +1);
					} else {
						listeDeCourses.put(key,  new ItemListeCourse(eqvo, iii));
					}
				}
				if (listeDeCourses.containsKey(AppLabels.getString("check_wfe"))) {
					listeDeCourses.updateValue(AppLabels.getString("check_liveplugHD"), -1);
				}
				model.listeDeCoursesSynthese = listeDeCourses;
				//trace("listeDeCourses.toString()",listeDeCourses.toString());
			
				//var keys:Array = listeDeCourses.getValues();
				//keys.sortOn("ordre");
				//trace("listeDeCourses.toString()",listeDeCourses.toString());
			}
		}
		
		private function _updateListeCourses(captures:Sprite):void
		{
			while (captures.numChildren > 0) {
				captures.removeChild(captures.getChildAt(0))
			}
			//trace(captures.numChildren);
			
			_buildListeCourses();
			
			if (model.listeDeCourses != null) {
				listeDeCourses = new Liste();
				var listeCoursesArr:Array = new Array();
				for (var i:int = 0; i < model.listeDeCourses.length; i++)
				{
					var eqV:EquipementView = (model.listeDeCourses[i] as EquipementView);
					var eqvo:EquipementVO = eqV.vo;
					var key:String = eqV.vo.screenLabel;
					//trace("liste de course recap:", key, eqV);
					var item:ItemListeCourse = new ItemListeCourse(eqvo, i);
					var index:int = ArrayUtils.indexOf(listeCoursesArr, item);
					if (index != -1) {
						var it:ItemListeCourse = listeCoursesArr[index] as ItemListeCourse;
						it.nombre += 1;
					} else {
						listeCoursesArr.push(item);
					}
					if (listeDeCourses.containsKey(key)) {
						listeDeCourses.updateValue(key, +1);
					} else {
						listeDeCourses.put(key,  new ItemListeCourse(eqvo, i));
					}
				}
				// si la liste des courses contient un Wi-Fi Extender, on enlève un LiveplugHD+
				// puisque le premier WI-Fi Extender va fonctionner en Kit (avec LiveplugHD+)
				if (listeDeCourses.containsKey(AppLabels.getString("check_wfe"))) {
					listeDeCourses.updateValue(AppLabels.getString("check_liveplugHD"), -1);
					/*var listeHasWFE:Boolean;
					for  (i = 0; i< listeCoursesArr.length; i++)
					{
						var ite:ItemListeCourse = listeCoursesArr[i] as ItemListeCourse;
						if (ite.label == "Wi-Fi Ext") {
							listeHasWFE = true;
						}
					}
					if (listeHasWFE) {
						for  (i = 0; i< listeCoursesArr.length; i++)
						{
							var ite:ItemListeCourse = listeCoursesArr[i] as ItemListeCourse;
							if (ite.label == AppLabels.getString("check_liveplugHD")) {
								ite.nombre -= 1;
							}
						}
					
					}*/
				}
				/*for  (i = 0; i< listeCoursesArr.length; i++)
				{
					ite = listeCoursesArr[i] as ItemListeCourse;
					trace(ite.label, ite.nombre);
				}*/
				model.listeDeCoursesSynthese = new Liste();
				model.listeDeCoursesSynthese = listeDeCourses;
				//AppUtils.TRACE("_updateListeCourses() " + listeDeCourses.toString());				
				var keys:Array = listeDeCourses.getValues();
				keys.sortOn("ordre");
				AppUtils.TRACE("_updateListeCourses() " + listeDeCourses.toString());
				var listeLength:int = keys.length;
				//var listeLength:int = listeCoursesArr.length;
				for (var ii:int = 0; ii < listeLength; ii++) {
					item = keys[ii] as ItemListeCourse;
					//var item:ItemListeCourse = listeCoursesArr[ii] as ItemListeCourse;
					captures.addChild(item);
					item.x = Math.floor(ii / 2) * (183 + 6);
					item.y = Math.floor(ii % 2) * (144 + 6);
					//trace(item.getLabel());
				}
				
				//_testAndAddScroll(captures);
				
			}
		}
		
		private function _updateMemo(e:Event=null):void
		{
			_tb.text = model.memos;
		}
		
		private function _gotoEditorEquipts(e:MouseEvent):void
		{
			EditorModelLocator.instance.isDrawStep = false;
			model.floorIdToGo = 0//e.target["floorId"];
			model.projetvo.nom = model.projectLabel//editorNav.projectName.projectName.text;
			model.projetvo.durationBetween2Savings = getTimer();
			model.screen = ApplicationModel.SCREEN_EDITOR;
		}
		
		private function _gotoEditorFloor(e:MouseEvent):void
		{
			/*AppUtils.TRACE("goto to floor :"+e.target["floorId"]);
			trace("goto to floor :"+e.target["floorId"]);*/
			EditorModelLocator.instance.isDrawStep = true;
			model.floorIdToGo = 0//e.target["floorId"];
			//model.projectLabel = editorNav.projectName.projectName.text;
			model.projetvo.nom = model.projectLabel//editorNav.projectName.projectName.text;
			model.projetvo.durationBetween2Savings = getTimer();
			model.screen = ApplicationModel.SCREEN_EDITOR;
		}
		
		private function _onFocusInProject(e:FocusEvent):void
		{
			_previousTexte = e.currentTarget.text;
			//e.currentTarget.text = "";
			//e.currentTarget.setSelection(0, e.currentTarget.text.length);
			setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
		}
		
		private function _onFocusOutProject(e:FocusEvent):void
		{
			if (e.currentTarget.text == "") {
				e.currentTarget.text = _previousTexte;
			}
			model.projectLabel = e.currentTarget.text;
		}
		
		private function _onChangeProject(e:Event):void
		{
			//trace("Projectname::_onChange", e.currentTarget.text)
			model.projectLabel = e.currentTarget.text;
			model.notifySaveStateUpdate(true);
		}	
		
		private function _onFocusIn(e:FocusEvent):void
		{
			setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
		}
		
		private function _onFocusOut(e:FocusEvent):void
		{
			//setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
			model.notes = _ta.text;
			model.memos = _tb.text;
		}
		
		private function _onChange(e:Event):void
		{
			//setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
			model.notes = _ta.text;
			model.notifySaveStateUpdate(true);
		}
		
		private function _onChangeMemo(e:Event):void
		{
			//setTimeout(e.currentTarget.setSelection, 100, 0, e.currentTarget.text.length);
			model.memos = _tb.text;
			model.notifySaveStateUpdate(true);
		}
		
		private function _prevent(kmf_event:FocusEvent):void 
		{ 
			kmf_event.preventDefault(); 
		}
		
		private function _positionTabs():void
		{
			var xpos:int = 30
			var ypos:int = 141.5//129.5
			var esp:int = 3
			
			_btnMaison.x = xpos;
			_btnMaison.y = ypos;
			_btnInstall.x = _btnMaison.x + _btnMaison.width + esp;
			_btnInstall.y = ypos;
			_btnEquipts.x = _btnInstall.x + _btnInstall.width + esp;
			_btnEquipts.y = ypos;
			_btnMemos.x = _btnEquipts.x + _btnEquipts.width + esp;
			_btnMemos.y = ypos;
			_btnEnd.x = _btnMemos.x + _btnMemos.width + esp;
			_btnEnd.y = ypos;
		}
		
		private function _onResize(e:Event=null):void
		{
			var maskSize:MaskSizeVO = model.maskSize;
			
			var g:Graphics = _bg.graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0xe5e5e5);
			var larg:int = maskSize.width -32;
			g.drawRoundRect(0, 0, larg, 389, 10);
			g.beginFill(Config.COLOR_WHITE);
			g.drawRoundRect(9, 42, larg - 19, 337, 10);
			g.beginFill(0);
			g.drawRoundRect(16, 42 + 20, 184, 300, 10);
			g.endFill();
			
			g = _masqPlan.graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0);
			g.drawRect(212, 64, larg - 273, 300);
			g.endFill();
			
			if (_masqInstall && _masqInstall.stage) {
				g = _masqInstall.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0);
				g.drawRect(212, 64, larg - 273, 300);
				g.endFill();
			}
			
			if (_masqCourses && _masqCourses.stage) {
				g = _masqCourses.graphics;
				g.clear();
				g.lineStyle();
				g.beginFill(0);
				g.drawRect(212, 64, larg - 273, 300);
				g.endFill();
			}
		}
		
		override protected function cleanup():void
		{
			super.cleanup();
			listeDeCourses = null;
			
			if (model.profilevo && model.profilevo.acces_notesvendeur) 
			{
				if (_ta) {
					_ta.removeEventListener(FocusEvent.FOCUS_IN, _onFocusIn);
					_ta.removeEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);
					_ta.removeEventListener(Event.CHANGE, _onChange); 
					_ta.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, _prevent); 
					_ta.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _prevent);
				}
			}
			if (_tb) {
				_tb.removeEventListener(Event.CHANGE, _onChangeMemo); 
				_tb.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, _prevent); 
				_tb.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, _prevent);
			}
			stage.removeEventListener(Event.RESIZE, _onResize);
			if (_scrollpane && _scrollpane.stage)
			{
				_scrollpane.parent.removeChild(_scrollpane);
				_scrollpane = null;
			}
		}
	}	
}