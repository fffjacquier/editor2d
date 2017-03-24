package classes.views.menus 
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.ArrayUtils;
	import classes.utils.GeomUtils;
	import classes.views.alert.AlertConnection;
	import classes.views.alert.AlertManager;
	import classes.views.alert.ConnectionEthernet;
	import classes.views.alert.ConnectionFilter;
	import classes.views.alert.ConnectionWifi;
	import classes.views.alert.Info360;
	import classes.views.alert.YesAlert;
	import classes.views.alert.YesNoAlert;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.LiveboxView;
	import classes.views.equipements.LiveplugView;
	import classes.views.equipements.MainDoorView;
	import classes.views.equipements.PriseView;
	import classes.views.equipements.SwitchView;
	import classes.views.equipements.WifiDuoView;
	import classes.views.equipements.WifiExtenderView;
	import classes.views.EquipementsLayer;
	import classes.views.plan.Editor2D;
	import classes.views.plan.EditorContainer;
	import classes.views.plan.Floor;
	import classes.views.plan.Surface;
	import classes.vo.EquipementVO;
	import com.warmforestflash.drawing.DottedLine;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	/**
	 * La classe MenuHeaderRenderer contient le header du MenuContainer: données propres à l'objet 
	 * sur lequel l'utilisateur a cliqué.
	 */
	public class MenuHeaderRenderer extends Sprite 
	{
		private var ypos:int;
		private var icon:MovieClip;
		private var t:CommonTextField;
		private var line:DottedLine;
		private var _obj:DisplayObject;
		private var _type:String;
		private var specials:Sprite;
		private var projectName:NomDuProjet;
		private var _previousTexte:String;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		private static var _instance:MenuHeaderRenderer;
		public static function get instance():MenuHeaderRenderer
		{
			return _instance;
		}
		
		/**
		 * Permet de créer le header du MenuContainer. Fonctionne comme un Singleton. Se met à jour avec 
		 * la fonction <code>update</code>
		 * 
		 * <p>Le menu doit aussi pouvoir passer par-dessus certains pop-ups. 
		 * Les events pour cela sont : <code>Event</code></p>
		 */
		public function MenuHeaderRenderer() 
		{
			if (_instance) return;
			
			_instance = this;
			t = new CommonTextField("helvet65", 0xffffff, 18);
			t.width = 200-15;
			t.wordWrap = false;
			t.multiline = false;
			addChild(t);
			line = new DottedLine(200 - 15, 1, Config.COLOR_LIGHT_GREY, 1, 1.3, 2);
			addChild(line);
			specials = new Sprite();
			addChild(specials);
			_appmodel.addConnectPopupOpenListener(_onConnectPopupOpening);
			_appmodel.addConnectPopupCloseListener(_onConnectPopupClosing);
			//addEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		/**
		 * Permet de mettre à jour l'affichage des données de l'objet
		 * 
		 * @param	type Un chaîne String qui nous indique le type de menu à afficher. 
		 * Les valeurs possibles sont "surface", "piece", "balcon", "cloison", "point", "equipement", "floor", 
		 * "pieceLabel"
		 * @param	obj Le type d'objet - classe correspondant à la vue du <code>type</code>
		 */
		public function update(type:String, obj:DisplayObject=null):void
		{
			//clean specials content
			_removeSpecialsChild();
			if (icon && icon.stage) removeChild(icon);
			
			ypos = 0;
			if (obj) _obj = obj;
			if (type) _type = type;
			//AppUtils.TRACE("MenuHeaderRenderer "+ _type+" "+ type);
			switch(_type) {
				case "surface":
					icon = new MenuHeaderSurface();
					addChild(icon);
					icon.x = 10;
					icon.y = 20;
					t.setText(AppLabels.getString("alert_surfaceReplaceTitle"));
					break;
				case "piece":	
					var surface:Surface = obj as Surface;
					if(surface.obj2D.isSquare)
					{
						icon = new MenuHeaderPieceRectangle();
					} else {
						icon = new MenuHeaderPiece();
					}
					addChild(icon);
					icon.x = 10;
					icon.y = 20;
					if(surface.obj2D.isSquare)
					{
						t.setText(AppLabels.getString("editor_roomRectShape"));
					} else {
						t.setText(AppLabels.getString("editor_roomFreeShape"))
					}
					break;
				case "balcon":	
					surface = obj as Surface;
					if(surface.obj2D.isSquare)
					{
						icon = new MenuHeaderPieceRectangle();
					} else {
						icon = new MenuHeaderPiece();
					}
					addChild(icon);
					icon.x = 10;
					icon.y = 20;
					surface = obj as Surface;
					if(surface.obj2D.isSquare)
					{
						t.setText(AppLabels.getString("editor_balconyFreeShape"));
					} else {
						t.setText(AppLabels.getString("editor_balconyRectShape"))
					}
					break;
				case "cloison":	
					icon = new MenuHeaderMur();
					addChild(icon);
					icon.x = 10;
					icon.y = 20;
					t.setText(AppLabels.getString("editor_segment"));
					break;
				case "point":
					icon = new MenuHeaderPoint();
					addChild(icon);
					icon.x = 10;
					icon.y = 20;
					t.setText(AppLabels.getString("editor_point"));
					break;
				/*case "home"://usable ?
					break;*/
					
				case "equipement":
					//load image for icon
					var vo:EquipementVO = EquipementView(_obj).vo;
					var img:String = vo.imagePath;
					
					var loadr:Loader = new Loader();
					loadr.load(new URLRequest(vo.imagePath));
					loadr.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImageComplete);
					icon = new MovieClip()
					addChild(icon);
					//
					var label:String = (vo.type == "LiveboxItem") ? vo.name : vo.screenLabel;
					t.setText(label);
					ypos = t.y + t.textHeight + 6;
					//
					if (vo.diaporama360 != "null") {
						var infoT:CommonTextField = new CommonTextField("helvet", 0xffffff, 10);
						infoT.width = 170;
						infoT.height = 18;
						var tf:TextFormat = infoT.cloneFormat();
						tf.align = TextFieldAutoSize.RIGHT;
						infoT.setText(AppLabels.getString("editor_whatIsIt"));
						infoT.setTextFormat(tf);
						icon.addChild(infoT);
						infoT.y = t.y + t.textHeight;
						//
						var i:IconInfo = new IconInfo();
						AppUtils.changeColor(Config.COLOR_YELLOW, i);
						icon.addChild(i);
						i.x = 180
						i.y = infoT.y
						i.buttonMode = true;
						i.addEventListener(MouseEvent.CLICK, _clickInfo, false, 0, true);
						ypos = i.y + i.height + 6;
					}
					//
					var e:EquipementView = _obj as EquipementView;
					//trace("MenuHeaderRenderer::update()", e, e.selectedConnexion);
					if ((e is LiveboxView) || (e is PriseView) || (e is SwitchView) || (e is MainDoorView)) {
						break;
					} else {
						//trace("MenuHeaderRenderer", e.selectedConnexion, e.connection)
						
						if (isConnectable && !isConnected) {
							var b:Btn = new Btn(Config.COLOR_ORANGE, AppLabels.getString("buttons_connect"), IconBtnConnect, 188, Config.COLOR_WHITE, 18, 31, Btn.GRADIENT_ORANGE);
							specials.addChild(b);
							b.x = 6
							b.y = ypos + 5
							ypos = b.y + b.height + 6
							// SI PAS DE livebox
							if (e.vo.type !== "PriseItem" && e.vo.type !== "LiveboxItem" && EquipementsLayer.getLivebox() == null) {
								b.alpha = .5;
								var alertLbTxt:CommonTextField = new CommonTextField("helvetBold", 0xffffff, 11);
								alertLbTxt.width = 180;
								tf = alertLbTxt.cloneFormat();
								alertLbTxt.setText(AppLabels.getString("editor_warningNoLivebox"));
								alertLbTxt.setTextFormat(tf);
								specials.addChild(alertLbTxt);
								alertLbTxt.y = ypos
								alertLbTxt.x = 6;
								ypos = alertLbTxt.y + alertLbTxt.height + 6;
								b.buttonMode = false;
								_appmodel.currentStep = ApplicationModel.STEP_EQUIPEMENTS;
							} else {								
								b.addEventListener(MouseEvent.CLICK, _openConnectPopup, false, 0, true);
							}
						} 
						else /*if (isConnected || !isConnectable) */
						{
							var connectedInfo:ConnexionInfo = new ConnexionInfo(e);
							specials.addChild(connectedInfo);
							
							connectedInfo.x = 6//(200 - 189) / 2;
							connectedInfo.y = ypos +5;
							ypos = connectedInfo.y + connectedInfo.height + 5;
						} 
					}
					break;
					
				case "floor":
					ypos = 24;
					var floor:Floor = _obj as Floor;
					var str:String;
					var rdc:Boolean = (floor.id == 0);
					if (rdc) {
						icon = new IconCrayon2();
						str = (AppLabels.getString("editor_welcomeHome"));
					} else {
						icon = new IconFloor();
						(icon as IconFloor).num.text = String(floor.id);
						str = floor.floorName;
					}
					//AppUtils.TRACE("MenuHeaderRenderer::update() floor.id="+floor.id+" "+floor.isFirstTime)
					icon.x = 10;
					if (icon.stage) removeChild(icon)
					addChild(icon);
					icon.y = ypos;
					t.setText(str);
					ypos = t.y + t.textHeight + 10;
					
					if (rdc) {
						projectName = new NomDuProjet();
						specials.addChild(projectName);
						if (_appmodel.projectLabel == null) {
							_appmodel.projectLabel = AppLabels.getString("editor_nameTheProject");
						}
						projectName.projectName.htmlText = "<b>" + _appmodel.projectLabel;
						projectName.projectName.addEventListener(FocusEvent.FOCUS_IN, _onFocusIn, false, 0, true);
						projectName.projectName.addEventListener(FocusEvent.FOCUS_OUT, _onFocusOut, false, 0, true);
						projectName.projectName.addEventListener(Event.CHANGE, _onChange, false, 0, true);
						projectName.x = 10;
						projectName.y = ypos;
						ypos = projectName.y + projectName.height + 10;
					}
					_addDottedLine(ypos);
					if (rdc) {
						var ot:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_ORANGE);
						ot.autoSize = "left";
						ot.width = 185;
						ot.setText(AppLabels.getString("editor_youAreLevel") + AppLabels.getString("editor_level0"));
						specials.addChild(ot);
						ot.x = 10;
						ot.y = ypos +2;
						ypos = ot.y + ot.textHeight + 8;
						
						// si nouveau plan
						var subtext:String;
						if (floor.isFirstTime && _appmodel.projectLabel == AppLabels.getString("editor_nameTheProject")) {
							subtext = AppLabels.getString("editor_surfaceInstalled");
							var tt:CommonTextField = new CommonTextField("helvet", Config.COLOR_LIGHT_GREY);
							tt.autoSize = "left";
							tt.width = 180;
							tt.setText(subtext);
							tt.x = 10;
							tt.y = ypos;
							specials.addChild(tt);
							ypos += tt.textHeight + 8;
						}
						// si plan type
						if (_appmodel.plantype != null) {
							subtext = AppLabels.getString("editor_planTypeInstalled");
							tt = new CommonTextField("helvet", Config.COLOR_WHITE);
							tt.autoSize = "left";
							tt.width = 180;
							tt.setText(subtext);
							tt.x = 10;
							tt.y = ypos;
							specials.addChild(tt);
							ypos += tt.textHeight + 8;
						}
						
						_addDottedLine(ypos);
						/*if(_model.isDrawStep) {
							// menu changer superficie 
							// menu changer forme
							if (_appmodel.plantype == null) 
							{
								// superficie
								var ms:MenuSurfaceRenderer = new MenuSurfaceRenderer(new MenuItem("test"), false);
								specials.addChild(ms);
								ms.y = ypos;
								ypos = ms.y + ms.getHeight();
								
								// forme
								var mf:MenuSurfaceRenderer = new MenuSurfaceRenderer(new MenuItem("test"), true);
								specials.addChild(mf);
								mf.y = ypos;
								ypos = mf.y + mf.getHeight();
							}
						}*/
						
					} else { // autres étages que rdc
						
						if(floor.isFirstTime) {
						
							ot = new CommonTextField("helvetBold", Config.COLOR_ORANGE);
							ot.autoSize = "left";
							ot.width = 120;
							ot.setText(AppLabels.getString("editor_justCreatedThe") + floor.floorName);
							specials.addChild(ot);
							ot.x = 10;
							ot.y = ypos +2;
							ypos = ot.y + ot.textHeight + 10;
							
							subtext = AppLabels.getString("editor_surfaceFloorInstalled");
							tt = new CommonTextField("helvet", Config.COLOR_LIGHT_GREY);
							tt.autoSize = "left";
							tt.width = 180;
							//
							tt.setText(subtext);
							tt.x = 10;
							tt.y = ypos;
							specials.addChild(tt);
							ypos += tt.textHeight + 8;

							_addDottedLine(ypos);
						}
						
						// on ajoute deux menus
						// menu nature plancher
						var p:MenuPlancherRenderer = new MenuPlancherRenderer(new MenuItem(AppLabels.getString("editor_floorMaterial")), floor);
						specials.addChild(p);
						p.y = ypos;
						ypos = p.y + p.getHeight();

						// menu supprimer
						var menu:MenuIconRenderer = new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_deleteFloor"), new IconDelete(), "deleteFloor", function():void { } ), false);
						specials.addChild(menu);
						menu.y = ypos;
						ypos = menu.y + 30;
						menu.addEventListener(MouseEvent.CLICK, _onDeleteFloor, false, 0, true);
					}
					break;
				case "piecelabel":
					t.setText(AppLabels.getString("editor_label"));
					break;
			}
			t.y = 70;
			t.x = 10;
			
			line.y = (ypos == 0) ? t.y + t.height +3 : ypos;
			line.x = 15 / 2;
		}
		
		private function get isConnected():Boolean
		{
			//trace("isConnected", EquipementView(_obj).selectedConnexion);
			return (EquipementView(_obj).selectedConnexion != null);
			//return (EquipementView(_obj).connection != null);
		}
		private function get isConnectable():Boolean
		{
			var e:EquipementView = EquipementView(_obj);
			if ((e is LiveplugView || e is WifiExtenderView || e is WifiDuoView || e is MainDoorView)) {
				return false;
			}
			return true;
		}
		
		private function _onDeleteFloor(e:MouseEvent):void
		{
			//trace(_model.currentFloorId, Editor2D.instance.floors.length - 1, Editor2D.instance.floors.getFloorIndex(_model.currentFloor))
			// y a-t-il un étage au dessus de celui-ci (si 1er ou 2eme) ou bien est-ce le dernier ?
			//trace(_model.getFloorById(_model.currentFloorId))
			if(_model.currentFloorId == -1 || Editor2D.instance.floors.length - 1 == Editor2D.instance.floors.getFloorIndex(_model.currentFloor)) {
				var popup:YesNoAlert = new YesNoAlert(AppLabels.getString("alert_deleteFloor"), AppLabels.getString("alert_deleteFloorQuestion"), _deleteFloor, function():void{});
				AlertManager.addPopup(popup, Main.instance);
			} else {
				var pop:YesAlert = new YesAlert(AppLabels.getString("alert_deleteFloor"), AppLabels.getString("alert_deleteFloorWarning"));
				AlertManager.addPopup(pop, Main.instance);
			}
		}
		
		private function _deleteFloor():void
		{
			//trace("_deleteFloor", _model.currentFloor.id)
			var floor:Floor = _model.currentFloor;
			Editor2D.instance.floors.removeFloor(floor);
			_model.currentFloor = _model.getFloorById(0);
		}
		
		private function _removeSpecialsChild():void
		{
			/*var max:int = 0;
			if (EquipementView(_obj).selectedConnexion == null) {
				max = 0;
			}*/
			while (specials.numChildren > 0) {
				specials.removeChildAt(0);
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
		
		private function _onChange(e:Event):void
		{
			//trace("Projectname::_onChange", e.currentTarget.text)
			_appmodel.projectLabel = e.currentTarget.text;
			_appmodel.notifySaveStateUpdate(true);
		}	
		
		private function _openConnectPopup(e:MouseEvent):void
		{
			//trace("_openConnectPopup", _obj)
			if (_obj is EquipementView) {
				var eq:EquipementView = _obj as EquipementView;
				// determiner quel type de fenetre parmi
				// Fenetre Filtre 1: WIfi ou filaire
				// Fenetre Ethernet (filaire)
				// Fenetre Wifi
				// chaque fenetre fonctionne selon le meme principe: des cases à cocher et boutons validation / annulation
				var isEthernetPossible:Boolean = ArrayUtils.contains(eq.vo.modesDeConnexionPossibles, ModesDeConnexion.ETHERNET);
				var isWifiPossible:Boolean = ArrayUtils.contains(eq.vo.modesDeConnexionPossibles, ModesDeConnexion.WIFI);
				var poup:AlertConnection;
				if (isEthernetPossible && isWifiPossible)
				{
					poup = new ConnectionFilter(eq);
				}
				else if (!isWifiPossible && isEthernetPossible) 
				{
					poup = new ConnectionEthernet(eq);
				} 
				else if (isWifiPossible && !isEthernetPossible) 
				{
					poup = new ConnectionWifi(eq);
				}
				
				//var poup:AlertConnection = new AlertConnection(eq);
				AlertManager.addPopup(poup, Main.instance);
				poup.x = MenuContainer.instance.x - 560;
				poup.y = 109;
			}
		}
		
		private function _onConnectPopupOpening(e:Event=null):void
		{
			trace("_onConnectPopupOpening", MenuContainer.instance.parent, EquipementView(_obj).selectedConnexion);
			
			// update line position
			var p:Point = new Point(MenuContainer.instance.x, MenuContainer.instance.y);
			
			// pass the container above the popups
			Main.instance.addChild(MenuContainer.instance);
			
			// change coords
			if (MenuContainer.instance.parent is Main) {
				MenuContainer.instance.x = GeomUtils.localToLocal(p, EditorContainer.instance, Main.instance).x;
				MenuContainer.instance.y = GeomUtils.localToLocal(p, EditorContainer.instance, Main.instance).y;
			}
			
			if (EquipementView(_obj).selectedConnexion == null) {
				_removeSpecialsChild();
			} else {
				ConnexionInfo.instance.update();
			}
			//line.y -= 40;
			line.y = ypos;
		}
		private function _onConnectPopupClosing(e:Event):void
		{
			//trace("_onConnectPopupClosing");
			// update line position
			var p:Point = new Point(MenuContainer.instance.x, MenuContainer.instance.y);
			
			// pass the container above the popups
			EditorContainer.instance.addChild(MenuContainer.instance);
			
			// change coords
			MenuContainer.instance.x = GeomUtils.localToLocal(p, Main.instance, EditorContainer.instance).x;
			MenuContainer.instance.y = GeomUtils.localToLocal(p, Main.instance, EditorContainer.instance).y;
			
			//addChild(specials);
			//specials.visible = true;
			line.y += 40;
		}
		
		private function _onImageComplete(e:Event):void
		{
			var lodr:LoaderInfo = e.target as LoaderInfo;
			lodr.removeEventListener(Event.COMPLETE, _onImageComplete);
			
			var bitmap:Bitmap = lodr.content as Bitmap;
			bitmap.smoothing = true;
			var xs:int = 98;
			var ys:int = 98;
			if (EquipementView(_obj).isLPHD) {
				xs = 52
				ys = 72
			}
			if (EquipementView(_obj).vo.type == "OrdinateurItem") {
				ys = 81
			}
			if (EquipementView(_obj).vo.type == "MainDoorItem") {
				ys = 75
				xs = 75
			}
			if (EquipementView(_obj).vo.type == "PriseItem") {
				ys = 75
				xs = 75
			}
			var xscale:Number = xs / bitmap.width;
			var yscale:Number = ys / bitmap.height;
			//trace(xscale, yscale);
			bitmap.scaleX = xscale;
			bitmap.scaleY = yscale;
			icon.addChild(bitmap);
		}
		
		private function _clickInfo(e:MouseEvent):void
		{
			//trace("click info", (_obj as EquipementView).vo.diaporama360);
			var diapo:String = (_obj as EquipementView).vo.diaporama360
			var popup:Info360 = new Info360(diapo);
			AlertManager.addPopup(popup, Main.instance);
		}
		
		private function _addDottedLine(posy:int):void
		{
			var s:DottedLine = new DottedLine(182, 1, Config.COLOR_LIGHT_GREY, 1, 1.3, 2);
			specials.addChild(s);
			s.x = 10;
			s.y = posy;
		}
		
		/**
		 * Permet d'obtenir la hauteur du header.
		 * 
		 * @return renvoie un nombre entier qui nous donne l'équivalent de la hauteur du header
		 */
		public function getHeight():int
		{
			return line.y + 1;
		}
		
		/*private function _removed(e:Event):void
		{
			_appmodel.removeConnectPopupOpenListener(_onConnectPopupOpening);
			_appmodel.removeConnectPopupCloseListener(_onConnectPopupClosing);
			_instance = null;
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}*/
	}

}