package classes.views.alert 
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.ArrayUtils;
	import classes.utils.NumberUtils;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.equipements.DecodeurView;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.LiveboxView;
	import classes.views.equipements.LiveplugView;
	import classes.views.equipements.WifiExtenderView;
	import classes.views.EquipementsLayer;
	import classes.views.menus.MenuContainer;
	import classes.vo.EquipementVO;
	import classes.vo.IntersectionVO;
	import fl.controls.RadioButton;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	/**
	 * Cette classe affiche les connexions possibles pour l'équipement choisi en mode Ethernet.
	 * 
	 * Affichage des distances et des murs/porteurs/plafonds
	 * Gestion de l'affichage de l'option switch également.
	 */
	public class ConnectionEthernet extends AlertConnection 
	{		
		public function ConnectionEthernet(eq:EquipementView) 
		{
			super(eq);
		}
		
		override protected function _addTitle():void
		{
			super._addTitle();
			if (_eqView.selectedConnexion == null) {
				_title.setText(AppLabels.getString("connections_connectLBEthernet"));
				var icon:MovieClip = new BulleEthernet();
				addChild(icon);
				icon.scaleX = icon.scaleY = 1.45;
				icon.x = 9;
				icon.y = 5;
				var color:Number = Config.COLOR_DARK;
				var gg:Graphics = icon.graphics;
				gg.clear();
				gg.lineStyle();
				gg.beginFill(color);
				gg.drawCircle(9, 9, 9);
				gg.endFill();
				_title.x = icon.width + 12;
			} else {
				var tf:TextFormat = _title.cloneFormat();
				tf.color = Config.COLOR_WHITE;
				_title.setText(AppLabels.getString("connections_modifyConnection"));
				_title.setTextFormat(tf);
				_title.x = 10;
				var s:Shape = new Shape();
				addChildAt(s, 0);
				s.x = 8
				s.y = 4
				var g:Graphics = s.graphics;
				g.lineStyle();
				var fillType:String = GradientType.LINEAR;
				var colors:Array = Btn.GRADIENT_ORANGE;
				var alphas:Array = [1, 1, 1, 1, 1];
				var ratios:Array = [0, 26, 161, 212, 255];
				var matr:Matrix = new Matrix();
				matr.createGradientBox(10, 29, - Math.PI / 2);
				var spreadMethod:String = SpreadMethod.PAD;
				g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
				g.drawRect(0, 0, 506, 29);
				//g.endFill();
			}
			
		}
		
		override protected function _addHeader():void
		{
			_addDistance("lb");
		}
		
		private function _addDistance(str:String, xpos:int = 9, module:EquipementView = null):void
		{
			var t:CommonTextField = new CommonTextField("helvet", 0x333333);
			t.autoSize = "left";
			t.width = WIDTH -30;
			
			var distLB:String = NumberUtils.commonFormat(_eqView.distanceLivebox());
			//var distWF:String = NumberUtils.commonFormat(_eqView.distanceWifi());
			if(module) var distWF:String = NumberUtils.commonFormat(_eqView.getDistance(module));
			//var duoOrExtender:String = ""//(str === "duo") ? "Duo" : "Extender";
			var label:String = (str == "lb") ? AppLabels.getString("connections_distanceLB") : AppLabels.getString("connections_distance");
			t.setText(label);
			t.x = xpos;
			t.y = _nexty;
			_itemsContainer.addChild(t);
			
			var t2:CommonTextField = new CommonTextField("helvetBold", 0x333333);
			t2.autoSize = "left";
			t2.width = 120;
			t2.setText((str == "lb") ? AppUtils.displayDistance(_eqView.distanceLivebox()) : AppUtils.displayDistance(_eqView.getDistance(module)));
			t2.y = _nexty - 1;
			_itemsContainer.addChild(t2);
			t2.x = t.x + t.textWidth;
			
			// s'il y a des obstacles, affichons les
			var nbObstacles:int = nbWalls + nbCeilings + nbBearingWalls;
			if (str == "lb" && nbObstacles > 0) 
			{
				var t3:CommonTextField = new CommonTextField("helvet", 0x333333);
				t3.autoSize = "left";
				t3.width = 80;
				t3.setText((nbObstacles == 1) ? AppLabels.getString("connections_obstacle") : AppLabels.getString("connections_obstacles"));
				t3.y = _nexty;
				_itemsContainer.addChild(t3);
				t3.x = 260;
				
				var murporteurstr:String = (nbBearingWalls.toString() == "0") ? "" : (nbBearingWalls.toString() == "1") ? "1"+ AppLabels.getString("connections_wall") : nbBearingWalls.toString() + AppLabels.getString("connections_walls");
				var murstr:String = (nbWalls.toString() == "0") ? "" : (nbWalls.toString() == "1") ? "1" + AppLabels.getString("connections_divider") : nbWalls.toString() + AppLabels.getString("connections_dividers");
				var plafondstr:String = (nbCeilings.toString() == "0") ? "" : (nbCeilings.toString() == "1") ? "1" + AppLabels.getString("connections_ceiling") : nbCeilings.toString() + AppLabels.getString("connections_ceilings");

				var t4:CommonTextField = new CommonTextField("helvetBold", 0x333333);
				t4.autoSize = "left";
				t4.width = 170;
				t4.setText(murporteurstr+murstr+plafondstr);
				t4.y = _nexty -1;
				_itemsContainer.addChild(t4);
				t4.x = t3.x + t3.textWidth;
			}
			_nexty = t.y + t.height + 10;
		}
		
		override protected function _clickHandler(e:MouseEvent):void
		{
			if (_switchAlert && _switchAlert.stage) {
				_nbSwitchSlots = -1;
				_fullPortEq = null;
				removeChild(_switchAlert);
			}
			
			super._clickHandler(e);
			
			_btnValidate.alpha = 1;
			_btnValidate.addEventListener(MouseEvent.CLICK, _valider, false, 0, true);
			
			var eqToCheck:EquipementView;
			
			switch(_selectedConnexion) {
				case ModesDeConnexion.ETHERNET:
					eqToCheck = EquipementsLayer.getLivebox();
					break;
				
				case ModesDeConnexion.DUO_ETHERNET:
					eqToCheck = EquipementsLayer.getWifiDuo();
					break;
				
				case ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW:
				case ModesDeConnexion.LIVEPLUG_NEW:
					break;
					
				case ModesDeConnexion.LIVEPLUG:
					eqToCheck = _getModuleFromOption("LiveplugHDDetected");
					break;
					
				case ModesDeConnexion.WIFIEXTENDER_ETHERNET:
					eqToCheck = _getModuleFromOption("WifiExtenderDetected");
					break;
					
				default:
					if(ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion) == ModesDeConnexion.ETHERNET) eqToCheck = EquipementsLayer.getLivebox();
			}
			trace("eqToCheck " + eqToCheck);
			if(eqToCheck == null) eqToCheck = EquipementsLayer.getLivebox();
			
			var ypos:int = ((_rbgroup.selection as RadioButton).y - 15 > 200) ? (_rbgroup.selection as RadioButton).y - 80 : (_rbgroup.selection as RadioButton).y - 15;
			if(eqToCheck) _checkIfSwitchNeed(eqToCheck, ypos);
		}
		
		/**
		 * Méthode d'affichage d'une option de connexion.
		 * 
		 */
		override protected function _addRadioButton(label:String, value:String, subtext:String = "", module:EquipementView = null):void
		{
			// ne pas montrer la connexion en cours, sauf si la connexion needsToBeChecked
			//trace("addRAdioBUTon", _eqView.selectedConnexion, value, _eqView.connection.needsToBeChecked)
			if (_eqView.selectedConnexion === value && !_eqView.connection.needsToBeChecked) return;
			
			var rb:RadioButton = new RadioButton();
			rb.value = value;
			rb.setStyle("embedFonts", true);
			rb.setStyle("bold", true);
			rb.setStyle("upIcon", RadioButtonSkinBase);
			rb.setStyle("overIcon", RadioButtonSkinBase);
			rb.setStyle("downIcon", RadioiButtonSkinDown);
			rb.setStyle("disabledIcon", RadioButtonSkinBase);
			rb.setStyle("selectedUpIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedOverIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedDownIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedDisabledIcon", RadioButtonSkinSelected);
            rb.setStyle("focusRectSkin", new Sprite());
			rb.setSize(430, 19);
			rb.label = "";
			rb.setStyle("textFormat", tf);
			rb.drawNow();
			_itemsContainer.addChild(rb);
			rb.y = _nexty + (49 - rb.height)/2;
			rb.x = 9;
			rb.group = _rbgroup;
			AppUtils.setButton(rb);
			
			var xpos:int = 140;
			
			//add image
			var im:Sprite = new Sprite();
			im.graphics.clear();
			im.graphics.lineStyle(1, 0x999999);
			im.graphics.beginFill(0, 0);
			im.graphics.drawRoundRect(0, 0, 96, 49, 15);
			im.graphics.endFill();
			_itemsContainer.addChild(im);
			im.x = 38;
			im.y = _nexty;
			
			var switchInstalled:Boolean = false;
			
			switch(value) {
				case ModesDeConnexion.LIVEPLUG_NEW:
				case ModesDeConnexion.LIVEPLUG:
					var lvp:LiveplugHD = new LiveplugHD();
					im.addChild(lvp);
					lvp.scaleX = lvp.scaleY = .6;
					//if (EquipementsLayer.isThereALiveplugModuleDeBase()) {
					if(/*value == ModesDeConnexion.LIVEPLUG && */_liveplugHDDetectedConditions()) {
						lvp.numero1.visible = false;
						lvp.x -= lvp.numero1.width / 6;
					}
					if (module != null) {
						switchInstalled = (module.switchAsChild != null);
					}
					break;
				case ModesDeConnexion.DUO_ETHERNET:
					var lpwifi:MovieClip;
					if (EquipementsLayer.isLiveboxPlay()) {
						lpwifi = new WifiSolo();
					} else {
						lpwifi = new WifiDuo();
					}
					im.addChild(lpwifi);
					lpwifi.scaleX = lpwifi.scaleY = .6;
					if (module != null) {
						switchInstalled = (module.switchAsChild != null);
					}
					break;
				case ModesDeConnexion.WIFIEXTENDER_ETHERNET:
				case ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW:
					var wfe:MovieClip = new WifiExtenders();
					im.addChild(wfe);
					wfe.scaleX = wfe.scaleY = .5;
					if (EquipementsLayer.isThereALiveplugModuleDeBase()) {
						wfe.numero1.visible = false;
						wfe.x -= wfe.numero1.width / 6;
					}
					if (module != null) {
						switchInstalled = (module.switchAsChild != null);
					}
					break;
				case ModesDeConnexion.ETHERNET:
					var l:Loader = new Loader();
					l.load(new URLRequest("images/cableEthernet.png"));
					im.addChild(l);
					l.y -= 1;
					im.graphics.clear();
					var border:Shape = new Shape();
					border.graphics.clear();
					border.graphics.lineStyle(1, 0x999999);
					border.graphics.beginFill(0, 0);
					border.graphics.drawRoundRect(0, 0, 96, 49, 15);
					border.graphics.endFill();
					im.addChild(border);
					
					var eq:EquipementView = EquipementsLayer.getLivebox();
					if (eq != null) {
						switchInstalled = (eq.switchAsChild != null);
					}
					break;
			}
			im.name = value;
			correspondances[value] = rb;
			im.addEventListener(MouseEvent.CLICK, _clickImage, false, 0, true);
			im.buttonMode = true;
			var label_switch:String = AppLabels.getString("connections_onSwitchInstalled");
			if (switchInstalled) label += label_switch;
			
			//add label 
			var the_label:CommonTextField = new CommonTextField("helvet", Config.COLOR_ORANGE, 14);
			the_label.width = 380;
			the_label.embedFonts = true;
			the_label.setHtmlText(label);
			var boldStartNum:int = (label.split("<b>")[0] as String).length;
			if(boldStartNum != label.length) label.replace("<b>", "");
			var boldEndNum:int = (label.split("</b>")[0] as String).length -3;
			if(boldStartNum != label.length) label.replace("</b>", "");
			if (boldStartNum < boldEndNum) {
				var boldFormat:TextFormat = the_label.cloneFormat();
				boldFormat.font = (new Helvet55Bold() as Font).fontName;
				boldFormat.bold = true;
				the_label.setTextFormat(boldFormat, boldStartNum, boldEndNum);
			}
			_itemsContainer.addChild(the_label);
			the_label.x = xpos
			the_label.y = _nexty;
			
			//add info btn
			var _linkBtnInfo:String = "null";
			var vo:EquipementVO;
			switch(value) {
				case ModesDeConnexion.LIVEPLUG_NEW:
				case ModesDeConnexion.LIVEPLUG:
					_linkBtnInfo =  _appmodel.getVOFromXML("Liveplug").diaporama360;
					break;
				case ModesDeConnexion.DUO_ETHERNET:
					_linkBtnInfo = _appmodel.getVOFromXML("WiFiDuo").diaporama360;
					break;
				case ModesDeConnexion.WIFIEXTENDER_ETHERNET:
				case ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW:
					_linkBtnInfo = _appmodel.getVOFromXML("WiFiExtender").diaporama360;
					break;
				case ModesDeConnexion.ETHERNET:
					_linkBtnInfo = "null"//TODO
					break;
			}
			if(_linkBtnInfo != "null") {
				var btnI:IconInfo = new IconInfo();
				_itemsContainer.addChild(btnI);
				btnI.addEventListener(MouseEvent.CLICK, _info, false, 0, true);
				btnI.buttonMode = true;
				btnI.mouseChildren = false;
				btnI.x = the_label.x + the_label.textWidth + 20;
				btnI.y = _nexty;
				btnI.name = _linkBtnInfo;
			}
			
			_nexty = the_label.y + the_label.textHeight + 3;
			
			//ajoute soustexte
			var alreadyThere:Boolean = (module != null); //label.indexOf("déjà installé") != -1;
			if (subtext != "") {
				var the_subtext:CommonTextField = new CommonTextField("helvet", 0x333333, 12);
				the_subtext.width = 380;
				_itemsContainer.addChild(the_subtext);
				the_subtext.setHtmlText(subtext);
				if(subtext.indexOf("<b>") != -1) the_subtext.boldify(subtext);
				the_subtext.x = xpos
				the_subtext.y = _nexty;
				_nexty = Math.max(the_subtext.y + the_subtext.height + 3, im.y + im.height + 5);
				return;
			} else {
				if (alreadyThere) {
					_addDistance("wifi", xpos, module);
					return;
				}
			}
			
			_nexty = im.y + im.height + 5;
		}
		
		private function _clickImage(e:MouseEvent):void
		{
			var rb:RadioButton = correspondances[e.currentTarget.name];
			rb.selected = true;
			_clickHandler(e);
		}
		
		override protected function _info(e:MouseEvent):void
		{
			trace("_info", e.target.name);
			var diapo:String = e.target.name;
			var popup:Info360 = new Info360(diapo);
			AlertManager.addSecondPopup(popup, Main.instance);
		}
		
		/**
		 * Cette méthode permet de définir le choix des options possibles pour un équipement dans la configuration actuelle du plan.
		 */
		override protected function _addChoiceModeConnection():void
		{
			_optionsArr = [];
			
			var optionEthernetCable:ConnectionsOption = new ConnectionsOption(_eqView);
			optionEthernetCable.type = ModesDeConnexion.ETHERNET;
			optionEthernetCable.display = _actionEthernet;
			optionEthernetCable.funcName = "AddEthernetCable";
			optionEthernetCable.priority = 1;
			//trace("_ethernetCondition()", _ethernetCondition())
			optionEthernetCable.conditions.push(_ethernetCondition());
			
			var optionLiveplugHD:ConnectionsOption = new ConnectionsOption(_eqView);
			optionLiveplugHD.type = ModesDeConnexion.LIVEPLUG_NEW;
			optionLiveplugHD.display = _actionLiveplugHD;
			optionLiveplugHD.funcName = "AddLiveplugHD";
			optionLiveplugHD.priority = 4;
			trace("_liveplugHDConditions", _liveplugHDConditions())
			optionLiveplugHD.conditions.push(_liveplugHDConditions());
			
			var optionLiveplugHDDetected:ConnectionsOption = new ConnectionsOption(_eqView);
			optionLiveplugHDDetected.type = ModesDeConnexion.LIVEPLUG;
			optionLiveplugHDDetected.display = _actionLiveplugDetected;
			optionLiveplugHDDetected.funcName = "LiveplugHDDetected";
			//trace("_liveplugHDDetectedConditions()", _liveplugHDDetectedConditions())
			optionLiveplugHDDetected.priority = 3;
			optionLiveplugHDDetected.conditions.push(_liveplugHDDetectedConditions());
			
			var optionWifiDuo:ConnectionsOption = new ConnectionsOption(_eqView);
			optionWifiDuo.type = ModesDeConnexion.DUO_ETHERNET;
			optionWifiDuo.display = _actionWifiDuo;
			optionWifiDuo.funcName = "AddLiveplugWifiDuo";
			optionWifiDuo.priority = 3;
			trace("_wifiDuoConditions()", _wifiDuoConditions())
			optionWifiDuo.conditions.push(_wifiDuoConditions());
			
			var optionWifiSolo:ConnectionsOption = new ConnectionsOption(_eqView);
			optionWifiSolo.type = ModesDeConnexion.DUO_ETHERNET;
			optionWifiSolo.display = _actionWifiSolo;
			optionWifiSolo.funcName = "AddLiveplugWifiSolo";
			optionWifiSolo.priority = 3;
			trace("_wifiSoloConditions()", _wifiSoloConditions())
			optionWifiSolo.conditions.push(_wifiSoloConditions());
			
			var optionWifiDuoDetected:ConnectionsOption = new ConnectionsOption(_eqView);
			optionWifiDuoDetected.type = ModesDeConnexion.DUO_ETHERNET;
			optionWifiDuoDetected.display = _actionWifiDuoDetected;
			optionWifiDuoDetected.funcName = "WifiDuoDetected";
			optionWifiDuoDetected.priority = 3;
			trace("_wifiDuoDetectedConditions()", _wifiDuoDetectedConditions())
			optionWifiDuoDetected.conditions.push(_wifiDuoDetectedConditions());
			
			var optionWifiExtender:ConnectionsOption = new ConnectionsOption(_eqView);
			optionWifiExtender.type = ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW;
			optionWifiExtender.display = _actionNewWifiExtender;
			optionWifiExtender.funcName = "AddWifiExtender";
			optionWifiExtender.priority = 2;
			optionWifiExtender.conditions.push(_newWifiExtenderConditions());
			
			var optionWifiExtenderDetected:ConnectionsOption = new ConnectionsOption(_eqView);
			optionWifiExtenderDetected.type = ModesDeConnexion.WIFIEXTENDER_ETHERNET;
			optionWifiExtenderDetected.display = _actionWifiExtenderDetected;
			optionWifiExtenderDetected.funcName = "WifiExtenderDetected";
			optionWifiExtenderDetected.priority = 2;
			//trace("_wifiExtenderDetectedConditions()", _wifiExtenderDetectedConditions())
			optionWifiExtenderDetected.conditions.push(_wifiExtenderDetectedConditions());
			
			/* le calcul des priorités dépend de :
				 * - type d'équipement : décodeur ou autre
				 * - distance plus grande 2m ou plus petite que 2m
				 * - présence ou non d'un mur entre l'équipement et la livebox 
				 *   présence d'un mur entre l'équipement et le wfe ou liveplug wifi placé à moins de 2m
			**/
			var distLB:Number = _eqView.distanceLivebox();
			// si décodeur
			if (_eqView.vo.type == "DecodeurItem") 
			{				
				// pas de WFE sur décodeur
				optionWifiExtender.conditions.push(false);
				optionWifiExtenderDetected.conditions.push(false);
				optionLiveplugHDDetected.conditions.push(false);
				
				// si livebox play
				var lbplay:Boolean = EquipementsLayer.isLiveboxPlay();
				
				//trace("décodeur, nbMurs:", nbWalls, "dist:", distLB.toFixed(2))
				//trace("optionEthernetCable", optionEthernetCable);
				if ((nbWalls + nbBearingWalls) > 0 || nbCeilings > 0) {
					optionEthernetCable.priority = 3;
					optionLiveplugHD.priority = 2;
					if (lbplay) {
						optionWifiSolo.priority = 1;
					} else {
						optionWifiDuo.priority = 1;
					}
					optionWifiDuoDetected.priority = 1;
				} else {
					if ( distLB < Config.DISTANCE_PRECO_LIVEPLUG) {
						optionEthernetCable.priority = 1;
						optionLiveplugHD.priority = 2;
						if (lbplay) {
							optionWifiSolo.priority = 3;
						} else {
							optionWifiDuo.priority = 3;
						}
						optionWifiDuoDetected.priority = 3;
					} else {
						optionEthernetCable.priority = 2;
						optionLiveplugHD.priority = 1;
						if (lbplay) {
							optionWifiSolo.priority = 3;
						} else {
							optionWifiDuo.priority = 3;
						}
						optionWifiDuoDetected.priority = 3;
					}
				}
				
			} else {
				
				var mod:EquipementView = _getClosestModuleNoWalls();
				
				//trace("nb murs vers la LB", nbWalls);
				if ((nbWalls + nbBearingWalls) > 0 || nbCeilings > 0) {
					// s'il y a des modules proches (moins de 3.5m) sans murs
					if (mod != null) {
						//trace("module existant", mod.vo.type);
						if (mod.vo.type == "WifiExtenderItem") 
						{
							optionLiveplugHDDetected.conditions.push(false);
							optionWifiDuoDetected.conditions.push(false);
							optionWifiExtender.conditions.push(false);
							
							optionLiveplugHD.priority = 2;
							optionEthernetCable.priority = 4;
							if (lbplay) {
								optionWifiSolo.priority = 5;
							} else {
								optionWifiDuo.priority = 5;
							}
							optionWifiDuoDetected.priority = 5;
							optionWifiExtender.priority = 3;
							optionWifiExtenderDetected.priority = 1;
							optionWifiExtenderDetected.moduleDetected = mod;
						} 
						else if (mod.vo.type == "WifiDuoItem") 
						{
							//remove liveplug HD from options
							//optionLiveplugHD.conditions.push(false);
							optionLiveplugHDDetected.conditions.push(false);
							optionWifiExtenderDetected.conditions.push(false);
						
							optionLiveplugHD.priority = 4;
							optionEthernetCable.priority = 2;
							if (lbplay) {
								optionWifiSolo.priority = 5;
							} else {
								optionWifiDuo.priority = 5;
							}
							optionWifiDuoDetected.priority = 1;
							optionWifiDuoDetected.moduleDetected = mod;
							optionWifiExtender.priority = 4;
							optionWifiExtenderDetected.priority = 5;
						}  
						else if (mod.vo.type == "LivePlugItem") 
						{
							optionWifiExtenderDetected.conditions.push(false);
							optionWifiDuoDetected.conditions.push(false);
							optionWifiDuo.conditions.push(false);
							
							optionLiveplugHDDetected.priority = 1;
							optionLiveplugHDDetected.moduleDetected = mod;
							// vérifier le seuil de distance et proposer ou non
							optionLiveplugHD.priority = 2;
							optionEthernetCable.priority = 4;
							if (lbplay) {
								optionWifiSolo.priority = 5;
							} else {
								optionWifiDuo.priority = 5;
							}
							optionWifiDuoDetected.priority = 5;
							optionWifiExtender.priority = 3;							
							optionWifiExtenderDetected.priority = 5;
						}
					} else {
						optionLiveplugHDDetected.conditions.push(false);
						optionWifiExtenderDetected.conditions.push(false);
						optionWifiDuoDetected.conditions.push(false);
						if (lbplay) {
							optionWifiSolo.conditions.push(false);
						} else {
							optionWifiDuo.conditions.push(false);
						}
							
						optionLiveplugHD.priority = 1;
						optionEthernetCable.priority = 3;
						optionWifiExtender.priority = 2;
					}
				} else {
					
					//trace("pas de murs ni plafonds", distLB, Config.DISTANCE_PRECO_LIVEPLUG.toString())
					
					if ( distLB < Config.DISTANCE_PRECO_LIVEPLUG) {
						optionEthernetCable.priority = 1;
						if (mod == null) {
							optionLiveplugHDDetected.conditions.push(false);
							optionWifiDuoDetected.conditions.push(false);
							//optionWifiDuo.conditions.push(false);
							optionWifiExtenderDetected.conditions.push(false);
						} else if (mod.vo.type == "LivePlugItem") {
							optionWifiDuoDetected.conditions.push(false);
							optionWifiExtenderDetected.conditions.push(false);
							optionLiveplugHDDetected.moduleDetected = mod;
						} else if (mod.vo.type == "WifiDuoItem") {
							optionWifiExtenderDetected.conditions.push(false);
							optionLiveplugHDDetected.conditions.push(false);
							optionWifiDuoDetected.moduleDetected = mod;
						} else if (mod.vo.type == "WifiExtenderItem") {
							optionWifiDuoDetected.conditions.push(false);
							optionLiveplugHDDetected.conditions.push(false);
							optionWifiExtenderDetected.moduleDetected = mod;
						}
						// il faut utiliser la détection du module le plus proche
						// si c liveplug hd on le propose en 2 et un nouveau en 3
						// si c wfe on le propose pas ?
						// si c lpwf duo, on le propose en 2 et un liveplugHD nouveau en 3
						
						optionLiveplugHD.priority = 2;
						if (lbplay) {
							optionWifiSolo.priority = 3;
						} else {
							optionWifiDuo.priority = 3;
						}
						optionWifiDuoDetected.priority = 3;
						optionWifiExtender.priority = 4;
						optionWifiExtenderDetected.priority = 4;
					} else {
						//trace("optionWifiDuoDetected", optionWifiDuoDetected)
						//Préconisation plug dispo dans la même pièce ou nouveau liveplug HD
						//Puis dans l’ordre nouveau liveplug HD, wifi extender, câble
						if (mod == null) {
							optionLiveplugHD.priority = 1;
							optionWifiExtender.priority = 2;
							optionEthernetCable.priority = 3;
							optionWifiDuoDetected.conditions.push(false);
							optionLiveplugHDDetected.conditions.push(false);
							optionWifiExtenderDetected.conditions.push(false);
						} else if (mod.vo.type == "LivePlugItem") {
							optionLiveplugHDDetected.priority = 1;
							optionLiveplugHDDetected.moduleDetected = mod;
							optionWifiExtender.priority = 2;
							optionEthernetCable.priority = 3;
							optionWifiDuoDetected.conditions.push(false);
							optionLiveplugHD.conditions.push(false);
							optionWifiExtenderDetected.conditions.push(false);
						} else if (mod.vo.type == "WifiDuoItem") {
							optionWifiDuoDetected.priority = 1;
							optionWifiDuoDetected.moduleDetected = mod;
							optionLiveplugHD.priority = 2;
							optionWifiExtender.priority = 3;
							optionEthernetCable.priority = 4;
							optionLiveplugHDDetected.conditions.push(false);
							optionWifiExtenderDetected.conditions.push(false);
						} else if (mod.vo.type == "WifiExtenderItem") {
							optionWifiExtenderDetected.priority = 1;
							optionWifiExtenderDetected.moduleDetected = mod;
							optionLiveplugHD.priority = 2;
							optionWifiExtender.priority = 3;
							optionEthernetCable.priority = 4;
							optionWifiDuoDetected.conditions.push(false);
							optionLiveplugHDDetected.conditions.push(false);
						}
					}
				}
			}
			// push conditions
			//trace("optionEthernetCable", optionEthernetCable.condition());
			if (optionEthernetCable.condition())
			{
				_optionsArr.push(optionEthernetCable);
			}
			if(optionLiveplugHD.condition())
			{
				_optionsArr.push(optionLiveplugHD);
			}
			if(optionWifiDuo.condition())
			{
				_optionsArr.push(optionWifiDuo);
			}
			if(optionWifiSolo.condition())
			{
				_optionsArr.push(optionWifiSolo);
			}
			if(optionWifiExtender.condition())
			{
				_optionsArr.push(optionWifiExtender);
			}
			if(optionWifiDuoDetected.condition())
			{
				_optionsArr.push(optionWifiDuoDetected);
			}
			if(optionWifiExtenderDetected.condition())
			{
				_optionsArr.push(optionWifiExtenderDetected);
			}
			if(optionLiveplugHDDetected.condition())
			{
				_optionsArr.push(optionLiveplugHDDetected);
			}
			
			_optionsArr.sortOn("priority");
			
			_bestAdvice();			
			_otherAdvices();
		}
		
		private function _getClosestModuleNoWalls():EquipementView
		{
			// we have to check all modules present which have the following params
			// - no walls between equipement and module
			// - distance should be less than 3.5m
			var selectableEquipts:Array = [];
			var tmpArr:Array;
			var wifiexts:Array = EquipementsLayer.getWifiExtenderArray(_eqView);
			tmpArr = wifiexts;
			var num:int = wifiexts.length;			
			for (var i:int = 0; i < num; i++)
			{
				var module:EquipementView = tmpArr[i] as EquipementView;
				var interVO:IntersectionVO = getIntersections(module);
				var walls:int = interVO.numWalls;
				//trace("WFE murs:", walls);
				if (walls == 0 && module.getDistance(_eqView) < Config.DISTANCE_PRECO_LIVEPLUG) selectableEquipts.push(module); 
			}
			//
			var lpwfduoArr:Array = EquipementsLayer.getClosestWifiDuoArray(_eqView);
			tmpArr = lpwfduoArr;
			num = lpwfduoArr.length;			
			for (i = 0; i < num; i++)
			{
				module = tmpArr[i] as EquipementView;
				interVO = getIntersections(module);
				walls = interVO.numWalls;
				//trace("LPWifiduo murs:", walls);
				if (walls == 0 && module.getDistance(_eqView) < Config.DISTANCE_PRECO_LIVEPLUG) selectableEquipts.push(module); 
			}
			
			var lphds:Array = EquipementsLayer.getLiveplugHDArray(_eqView);
			tmpArr = lphds;
			num = lphds.length;			
			for (i = 0; i < num; i++)
			{
				module = tmpArr[i] as EquipementView;
				interVO = getIntersections(module);
				walls = interVO.numWalls;
				//trace("LP HD+ murs:", walls);
				if (walls == 0 && module.getDistance(_eqView) < Config.DISTANCE_PRECO_LIVEPLUG && !module.isDecoderConnectionSource/* && !LiveplugView(module).isModuleDeBase*/) selectableEquipts.push(module); 
			}
			
			trace("SELECTABLE-EQUIPEMENTS:", selectableEquipts);
			if (selectableEquipts.length == 0) return null;
			
			trace("_getClosestModuleNoWalls():", EquipementsLayer.getClosestEquipement(selectableEquipts, _eqView))
			return EquipementsLayer.getClosestEquipement(selectableEquipts, _eqView);
		}
		
		private function _ethernetCondition():Boolean
		{
			return ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.ETHERNET);
		}
		
		private function _actionEthernet():Boolean
		{
			var sub:String = "";
			if (_eqView.getDistance(EquipementsLayer.getLivebox()) < Config.DISTANCE_ETHERNET) {
				sub = AppLabels.getString("connections_idealWireDistance")
			} else {
				sub = AppLabels.getString("connections_possibleWireDistance")
			}
			_addRadioButton(AppLabels.getString("connections_connectEthernetWire"), ModesDeConnexion.ETHERNET, sub);
		    return true;
		}
		
		/**
		 * utilitaire pour détecter si le type de livebox est liveboxplay
		 * @return Boolean
		 */
		private function _detectLiveboxPlay():Boolean
		{
			if (EquipementsLayer.isLiveboxPlay()) {
				return true;
			}
			return false;
		}
		
		/**
		 * Règles Liveplug WiFi Solo 09/04/2013
		 * - pas proposé sur un projet de type adsl2tv -> NON !
		 * - proposé uniquement si la livebox est de type liveboxplay 
		 * - si l'équipement est un décodeur compatible solo
		 * - si pas de LPWifi Solo déjà posé
		 * @return Boolean
		 */
		private function _wifiSoloConditions():Boolean
		{
			// pas de solo si pas la liveboxplay
			if (!_detectLiveboxPlay()) {
				return false;
			}
			//if (_appmodel.projectType !== "adsl2tv") 
			{
				if (_eqView is DecodeurView && ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.DUO_ETHERNET)) {
					if (!EquipementsLayer.isThereAWifiSolo()) return true;
				}
			}
			return false;
		}
		
		private function _actionWifiSolo():void
		{
			var sub:String = "";
			if (_eqView.getDistance(EquipementsLayer.getLivebox()) < Config.DISTANCE_ETHERNET) {
				sub = AppLabels.getString("connections_wfsoloAdvantage");
			} else {
				sub = AppLabels.getString("connections_wfduoSubtext");
			}
			_addRadioButton(AppLabels.getString("connections_connectEthernetLPWF"), ModesDeConnexion.DUO_ETHERNET, sub);
		}
		
		/**
		 * Règles WiFi Duo
		 * - pas proposé sur un projet de type adsl2tv
		 * - toujours par paire
		 * - v1 21-03-2012 : 
		 * 4 ports ethernets sur l'esclave, aucun géré sur le master
		 * - si Wifi Duo déjà installé, on ne le repropose pas		
		 * - v2 : we'll add 4 ports on master to be handled
		 * - G1R4 : pas de wifi duo si la livebox est de type liveboxplay 09/04/2013 
		 */
		private function _wifiDuoConditions():Boolean
		{
			// pas de wifi duo si la livebox est de type liveboxplay
			if (_detectLiveboxPlay()) {
				return false;
			}
			
			if (_appmodel.projectType !== "adsl2tv") 
			{
				if (_eqView is DecodeurView && ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.DUO_ETHERNET)) {
					if (!EquipementsLayer.isThereAWifiDuo()) return true;
					else { 
						if (_eqView.connection && _eqView.connection.needsToBeChecked) return true;//FJ added 08/06/2012
					}
				}
			}
			return false;
		}
		
		private function _actionWifiDuo():void
		{
			var sub:String = "";
			if (_eqView.getDistance(EquipementsLayer.getLivebox()) < Config.DISTANCE_ETHERNET) {
				sub = AppLabels.getString("connections_wfduoAdvantage");
			} else {
				sub = AppLabels.getString("connections_wfduoSubtext");
			}
			_addRadioButton(AppLabels.getString("connections_connectEthernetLPWF"), ModesDeConnexion.DUO_ETHERNET, sub);
		}
		
		private function _newWifiExtenderConditions():Boolean
		{
			return (ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.WIFIEXTENDER_ETHERNET) /*&& _eqView.selectedConnexion != "wifiextender-ethernet"*//*&& !EquipementsLayer.isThereAWifiDuo()*/)
		}
		
		private function _actionNewWifiExtender():void
		{
			_addRadioButton(AppLabels.getString("connections_connectEthernetWFE"), ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW, AppLabels.getString("connections_connectEthernetWFESubtext"));
		}
		
		private function _wifiExtenderDetectedConditions():Boolean
		{
			// detection of wifi extender / wifi duo close to equipement
			if (EquipementsLayer.WIFI_POINTS.length !== 0 && _eqView.distanceWifi() <= Config.DISTANCE_PRECO_LIVEPLUG) 
			{
				// check for wifi extender proche deja installé
				if ((ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.WIFIEXTENDER_ETHERNET) /*&& _eqView.selectedConnexion != "wifiextender-ethernet"*/) || (ArrayUtils.contains(_vo.modesDeConnexionPossibles, "wifiextender-wifi") /*&& _eqView.selectedConnexion != "wifiextender-wifi"*/)) 
				{
					var closestWFE:Array = EquipementsLayer.getWifiExtenderArray(_eqView);
					if (closestWFE.length > 0) {
						return true;
					}					
				}
			}
			return false;
		}
		
		private function _wifiDuoDetectedConditions():Boolean
		{
			// detection of wifi extender / wifi duo close to equipement
			if (EquipementsLayer.WIFI_POINTS.length !== 0) 
			{
				// check for liveplug wifi duo proche deja installé
				if (ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.DUO_ETHERNET))
					var closestWifiDuo:Array = EquipementsLayer.getClosestWifiDuoArray(_eqView);
					if(closestWifiDuo.length >0 && !(_eqView is DecodeurView) && _eqView.getDistance(closestWifiDuo[0]) <= Config.DISTANCE_PRECO_LIVEPLUG) {/* ok because there is only one Liveplug Wifi Duo */
					{	
						return true;
					} 
				}
			}
			return false;
		}
		
		private function _liveplugHDDetectedConditions():Boolean
		{
			//trace("_liveplugHDDetectedConditions", EquipementsLayer.isThereLiveplugDecodeur(), (EquipementsLayer.isthereLiveplugMasterConnected()));
			if ( EquipementsLayer.getEquipements(LiveplugView) === 0 || 
				(_appmodel.projectType === "adsl2tv" && _eqView is DecodeurView) ||
				((_appmodel.projectType === "adsl2tv") && EquipementsLayer.isThereLiveplugDecodeur() && !EquipementsLayer.isThereLPHDNotDecodeurSource()/*(EquipementsLayer.isthereLiveplugMasterConnected() === false)*/))
			{
				return false;
			} else {
				return true;
			}
			return false;
		}
		
		private function _getModuleFromOption(optionName:String):EquipementView
		{
			for (var i:int = 0; i < _optionsArr.length; i++) {
				var opt:ConnectionsOption = (_optionsArr[i] as ConnectionsOption)
				if (opt.funcName === optionName) {
					//trace("_getModuleFromOption:", opt.moduleDetected)
					return opt.moduleDetected;
				}
			}
			return null;
		}
		
		private function _actionWifiExtenderDetected():void
		{
			var s:String = AppLabels.getString("connections_connectEthernetWFEPresent")
			var module:EquipementView = _getModuleFromOption("WifiExtenderDetected");
			_addRadioButton(s, ModesDeConnexion.WIFIEXTENDER_ETHERNET, "", module);
		}
		
		private function _actionLiveplugDetected():void
		{
			var s:String = AppLabels.getString("connections_connectEthernetLPHDPresent");
			var module:EquipementView = _getModuleFromOption("LiveplugHDDetected");
			_addRadioButton(s, ModesDeConnexion.LIVEPLUG, "", module);
		}
		
		private function _actionWifiDuoDetected():void
		{
			var s:String = AppLabels.getString("connections_connectEthernetLPWFPresent");
			var module:EquipementView = _getModuleFromOption("WifiDuoDetected");
			_addRadioButton(s, ModesDeConnexion.DUO_ETHERNET, "", module);
		}
		
		// cela ne nous dit pas s'il en faut un ou deux Liveplugs
		// ce point est géré dans _addRadioButton
		private function _liveplugHDConditions():Boolean
		{
			/* Règles Liveplug HD+ avec Livebox 2 / Livebox 2 Fibre :
			 * - si fibre et un décodeur posé avec liveplug, pas de choix liveplug sur deuxieme décodeur
			 * - si adsl 2tv et un decodeur avec liveplug, pas d'autres equipement en liveplug
			 *  Regle modifiée le 08/02/2012 : 
				 * si adsl 2 tv et décodeur et liveplug, pas d'autre décodeur en liveplug
				 * ET pour les autres équipements on ajoute une paire qui va prendre un nouveau port
			 * - 21/03/2012 : s'il y a déjà un wifiduo, on ne propose pas de liveplugHD+
			 * - 06/2012 : adslSat peut avoir 2 décodeurs aussi
			 */
			/* Règles Liveplug HD+ avec LiveboxPlay :
			 * - si liveboxplay les règles de la fibre s'appliquent
			 * - si Liveplug Wi-Fi Solo déjà présent, pas de choix LPHD+
			 */
			if (_appmodel.projectType === "fibre" || (_appmodel.projectType === "adsl2tv" && EquipementsLayer.isLiveboxPlay()) || _appmodel.projectType === "adslSat") 
			{
				if (EquipementsLayer.isLiveboxPlay() && EquipementsLayer.isThereAWifiSolo()) {
					return false;
				}
				if (_eqView is DecodeurView && EquipementsLayer.isThereLiveplugDecodeur()) {
					// si on est deja avec un liveplug et que l'équipement a été déplacé et qu'on doit checker sa connection
					if (_eqView.connection && _eqView.connection.needsToBeChecked) return true;//FJ added 08/06/2012 14:37
					return false;
				} else {
					if (ArrayUtils.contains(_vo.modesDeConnexionPossibles, "liveplug") /*&& _eqView.selectedConnexion != "ethernet-liveplug"*//* && !EquipementsLayer.isThereAWifiDuo()*/) {
						return true;
					}
				}
			} 
			else if (_appmodel.projectType === "adsl2tv" /*|| _appmodel.projectType === "adslSat"*/) 
			{
				if (EquipementsLayer.isThereLiveplugDecodeur() && _eqView is DecodeurView) {
					// no other decodeur with liveplug
					return false;
				} else {
					if (ArrayUtils.contains(_vo.modesDeConnexionPossibles, "liveplug") /*&& _eqView.selectedConnexion != "ethernet-liveplug"*/) {
						return true;
					}
				}
			} 
			else 
			{
				if (ArrayUtils.contains(_vo.modesDeConnexionPossibles, "liveplug") /*&& _eqView.selectedConnexion != "ethernet-liveplug"*/ /*&& !EquipementsLayer.isThereAWifiDuo()*/) {
					return true;
				}
			}
			return false;
		}
		
		private function _actionLiveplugHD():void
		{
			_addRadioButton(AppLabels.getString("connections_connectEthernetLPHD"), ModesDeConnexion.LIVEPLUG_NEW, AppLabels.getString("connections_connectEthernetLPHDSubtext"));
		}
		
		override protected function _addButtons():void
		{
			_btnValidate = new Btn(0, AppLabels.getString("buttons_validateAndConnect"), IconBtnConnect, 158, 0xffffff, 12, 30, Btn.GRADIENT_ORANGE);
			_itemsContainer.addChild(_btnValidate);
			_btnValidate.y = _itemsContainer.height +17;
			_btnValidate.x = (WIDTH - 158 - 20);
			_btnValidate.alpha = .3;
			super._addButtons();
		}
		
		override protected function _cancel(e:MouseEvent):void
		{
			var isEthernetPossible:Boolean = ArrayUtils.contains(_eqView.vo.modesDeConnexionPossibles, ModesDeConnexion.ETHERNET);
			var isWifiPossible:Boolean = ArrayUtils.contains(_eqView.vo.modesDeConnexionPossibles, ModesDeConnexion.WIFI);
			var poup:AlertConnection;
			if (isEthernetPossible && isWifiPossible && _eqView.selectedConnexion == null)
			{
				poup = new ConnectionFilter(_eqView);
				AlertManager.addPopup(poup, Main.instance);
				poup.x = MenuContainer.instance.x - 560;
				poup.y = 109;
			} else {
				super._cancel(e);
			}
		}
		/*override protected function _remove(e:Event):void 
		{
			im.removeEventListener(MouseEvent.CLICK, _clickImage);
			super._remove(e);
		}*/
	}

}