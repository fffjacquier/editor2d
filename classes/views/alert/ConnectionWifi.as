package classes.views.alert 
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.ArrayUtils;
	import classes.utils.NumberUtils;
	import classes.utils.WifiUtils;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.equipements.EquipementView;
	import classes.views.EquipementsLayer;
	import classes.views.menus.MenuContainer;
	import classes.vo.BestWifiChoice;
	import fl.controls.RadioButton;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	/**
	 * Cette classe affiche le popup de Connexion Wi-Fi selon ce qui est possible pour cet équipement (ses modes de connexions définis
	 * dans le fichier all.xml)
	 */
	public class ConnectionWifi extends AlertConnection 
	{		
		/**
		 * Cette classe affiche le popup de Connexion Wi-Fi selon ce qui est possible pour cet équipement (ses modes de connexions définis
		 * dans le fichier all.xml)
		 * 
		 * <p>Affiche la distance de la Livebox et l'état du Wi-Fi.</p>
		 * 
		 * <p>Les choix possibles sont triés par ordre de priorité.</p>
		 */
		public function ConnectionWifi(eq:EquipementView) 
		{			
			super(eq);			
		}
		
		override protected function _addTitle():void
		{
			super._addTitle();
			if (_eqView.selectedConnexion == null) {
				_title.setText(AppLabels.getString("connections_connectToLBWifi"));
				var icon:MovieClip = new BulleWifi();
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
				_title.setText(AppLabels.getString("connections_modifyWifiConnection"));
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
			//var label:String = "distance de la Livebox : " + distLB + " m";
			/*if (str == "lb" && _eqView.distanceLivebox() plus petit que Config.DISTANCE_ETHERNET) {
				label = "distance de la Livebox plus petit  que "+Config.DISTANCE_ETHERNET+" m";
			}*/
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
			_nexty = t.y + t.height /*+ 10*/;
		}
		
		private function _addIconWifi(dist:Number, xpos:int = 100):void
		{
			var iconWifi:MovieClip = new Wifi();
			iconWifi.x = xpos;
			iconWifi.y = _nexty -15;
			_itemsContainer.addChild(iconWifi);
			
			trace("_addIconWifi calcul puissance");
			var puissance:int = WifiUtils.puissance(pertes, /*nbWalls, nbCeilings, nbBearingWalls, */dist);
			
			var the_color:Number;
			var the_label:String;
			switch(WifiUtils.getColor(puissance)) {
				case WifiUtils.RED:
					the_color = Config.COLOR_WIFI_RED;
					the_label = AppLabels.getString("connections_warningWifiRed");
					break;
				case WifiUtils.ORANGE:
					the_color = Config.COLOR_WIFI_ORANGE;
					the_label = AppLabels.getString("connections_warningWifiOrange");
					break;
				case WifiUtils.YELLOW:
					the_color = Config.COLOR_WIFI_YELLOW;
					the_label = AppLabels.getString("connections_warningWifiYellow");
					break;
				case WifiUtils.GREEN:
					the_color = Config.COLOR_WIFI_GREEN;
					the_label = AppLabels.getString("connections_warningWifiGreen");
					break;
			}
			/*if (dist < Config.DISTANCE_WIFI -5) the_color = Config.COLOR_WIFI_GREEN
			else if ( (Config.DISTANCE_WIFI -5) <= dist && dist > Config.DISTANCE_WIFI) the_color = Config.COLOR_WIFI_ORANGE
			else the_color = Config.COLOR_WIFI_RED;*/
			AppUtils.changeColor(the_color, iconWifi);
			
			var t:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_DARK);
			t.width = 200;
			var tf:TextFormat = t.cloneFormat();
			tf.color = the_color;
			t.setText(the_label);
			t.setTextFormat(tf);
			addChild(t);
			t.x = iconWifi.x + iconWifi.width + 5;
			t.y = _nexty - 16;
		
			// icon info
			var btnI:IconInfo = new IconInfo();
			addChild(btnI);
			btnI.x = t.x + t.textWidth + 12;
			btnI.y = _nexty - 16;
			btnI.addEventListener(MouseEvent.CLICK, _showInfoWifi, false, 0, true);
			btnI.buttonMode = true;
		}
		
		private function _addIconWifiExtender(dist:Number, pertes:int, xpos:int = 100):void
		{
			var iconWifi:MovieClip = new Wifi();
			iconWifi.x = xpos;
			iconWifi.y = _nexty -15;
			_itemsContainer.addChild(iconWifi);
			
			trace("_addIconWifiExtender calcul puissance");
			var puissance:int = WifiUtils.puissance(pertes, /*nbWalls, nbCeilings, nbBearingWalls, */dist);
			
			var the_color:Number;
			var the_label:String;
			switch(WifiUtils.getColor(puissance)) {
				case WifiUtils.RED:
					the_color = Config.COLOR_WIFI_RED;
					the_label = AppLabels.getString("connections_warningWifiRed");
					break;
				case WifiUtils.ORANGE:
					the_color = Config.COLOR_WIFI_ORANGE;
					the_label = AppLabels.getString("connections_warningWifiOrange");
					break;
				case WifiUtils.YELLOW:
					the_color = Config.COLOR_WIFI_YELLOW;
					the_label = AppLabels.getString("connections_warningWifiYellow");
					break;
				case WifiUtils.GREEN:
					the_color = Config.COLOR_WIFI_GREEN;
					the_label = AppLabels.getString("connections_warningWifiGreen");
					break;
			}
			/*if (dist < Config.DISTANCE_WIFI -5) the_color = Config.COLOR_WIFI_GREEN
			else if ( (Config.DISTANCE_WIFI -5) <= dist && dist > Config.DISTANCE_WIFI) the_color = Config.COLOR_WIFI_ORANGE
			else the_color = Config.COLOR_WIFI_RED;*/
			AppUtils.changeColor(the_color, iconWifi);
			
			var t:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_DARK);
			t.width = 200;
			var tf:TextFormat = t.cloneFormat();
			tf.color = the_color;
			t.setText(the_label);
			t.setTextFormat(tf);
			addChild(t);
			t.x = iconWifi.x + iconWifi.width + 5;
			t.y = _nexty - 16;
		
			// icon info
			var btnI:IconInfo = new IconInfo();
			addChild(btnI);
			btnI.x = t.x + t.textWidth + 12;
			btnI.y = _nexty - 16;
			btnI.addEventListener(MouseEvent.CLICK, _showInfoWifi, false, 0, true);
			btnI.buttonMode = true;
		}
		
		private function _showInfoWifi(e:MouseEvent):void
		{
			var s:Sprite = new Sprite();
			var t:CommonTextField = new CommonTextField("helvet", Config.COLOR_DARK, 12);
			t.autoSize = "left";
			t.width = 480
			s.addChild(t);
			var str:String = AppLabels.getString("connections_wifiExplainedLine1");
			str += AppLabels.getString("connections_wifiExplainedLine2");
			str += AppLabels.getString("connections_wifiExplainedLine3");
			str += AppLabels.getString("connections_wifiExplainedLine4");
			str += AppLabels.getString("connections_wifiExplainedLine5");
			str += AppLabels.getString("connections_wifiExplainedLine6");
			str += AppLabels.getString("connections_wifiExplainedLine7");
			str += AppLabels.getString("connections_wifiExplainedLine8");
			str += AppLabels.getString("connections_wifiExplainedLine9");
			str += AppLabels.getString("connections_wifiExplainedLine10");
			t.setHtmlText(str);
			t.autoSize = "left";
			addChild(s);
			t.x = 20
			t.y = 12
			
			var b:Btn = new Btn(0, AppLabels.getString("buttons_close"), null, 80, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			s.addChild(b);
			b.x = 480 - 80;
			b.y = t.height + 12
			b.addEventListener(MouseEvent.CLICK, _removeInfoWifi, false, 0, true);
			
			var g:Graphics = s.graphics;
			g.lineStyle();
			g.beginFill(0xdedede);
			g.drawRoundRect(0, 0, 500, t.textHeight + 12 +24 +12, 10);
			g.endFill();
		}
		
		private function _removeInfoWifi(e:MouseEvent): void
		{
			var s:Sprite = e.currentTarget.parent;
			removeChild(s);
		}
		
		override protected function _clickHandler(e:MouseEvent):void
		{
			super._clickHandler(e);
			
			_btnValidate.alpha = 1;
			_btnValidate.addEventListener(MouseEvent.CLICK, _valider, false, 0, true);
		}
		
		override protected function _addRadioButton(label:String, value:String, subtext:String = "", module:EquipementView = null):void
		{
			//super._addRadioButton("", value);
			
			// ne pas montrer la connexion en cours
			if (_eqView.selectedConnexion === value) return;
			
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
			switch(value) {
				case ModesDeConnexion.DUO_WIFI:
					var duo:MovieClip = new WifiDuo();
					im.addChild(duo);
					duo.scaleX = duo.scaleY = .6;
					break;
				case ModesDeConnexion.WIFIEXTENDER_WIFI:
				case ModesDeConnexion.WIFIEXTENDER_WIFI_NEW:
					var wfe:MovieClip = new WifiExtenders();
					im.addChild(wfe);
					wfe.scaleX = wfe.scaleY = .5;
					if (EquipementsLayer.isThereALiveplugModuleDeBase()) {
						wfe.numero1.visible = false;
						wfe.x -= wfe.numero1.width / 6;
					}
					break;
				case ModesDeConnexion.WIFI:
					var w:Wifi = new Wifi();
					im.addChild(w);
					w.scaleX = w.scaleY = 2.5;
					w.y = (49 - w.height) / 2;
					w.x = (96 - w.width) / 2;
					AppUtils.changeColor(0xffffff, w);
					break;
			}
			im.name = value;
			correspondances[value] = rb;
			im.addEventListener(MouseEvent.CLICK, _clickImage, false, 0, true);
			im.buttonMode = true;
			
			//add label 
			var the_label:CommonTextField = new CommonTextField("helvet", Config.COLOR_ORANGE, 14);
			the_label.width = 300;
			the_label.embedFonts = true;
			the_label.setHtmlText(label);
			var boldStartNum:int = (label.split("<b>")[0] as String).length;
			if(boldStartNum != label.length) label.replace("<b>", "");
			var boldEndNum:int = (label.split("</b>")[0] as String).length -3;
			//trace(boldEndNum, boldStartNum);
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
			var btnI:IconInfo = new IconInfo();
			_itemsContainer.addChild(btnI);
			btnI.addEventListener(MouseEvent.CLICK, _info, false, 0, true);
			btnI.x = the_label.x + the_label.textWidth + 20;
			btnI.y = _nexty;
			
			_nexty = the_label.y + the_label.textHeight + 3;
			
			//ajoute soustexte
			var alreadyThere:Boolean = (module != null);//label.indexOf("déjà installé") != -1;
			if (subtext != "") {
				var the_subtext:CommonTextField = new CommonTextField("helvet", 0x333333, 12);
				the_subtext.width = 330;
				_itemsContainer.addChild(the_subtext);
				the_subtext.setText(subtext);
				the_subtext.x = xpos
				the_subtext.y = _nexty;
				_nexty = Math.max(the_subtext.y + the_subtext.height + 3, im.y + im.height + 5);
			} else {
				if (alreadyThere) {
					// obtenir la distance
					var arr:Array = EquipementsLayer.getClosestWifiObjectsArray(_eqView);
					var values:Array = [];
					for (var i:int = 0; i < arr.length; i++)
					{
						values.push({"distance":_eqView.getDistance(arr[i]), "equipement":arr[i]});
					}
					values.sortOn("distance");
					var dist:int = _eqView.getDistance(values[0].equipement);
					
					_addText(AppLabels.getString("connections_wifiState"), "helvetBold", 12, Config.COLOR_DARK, 140);
					_addIconWifi(dist, 235);
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
		
		/**
		 * Cette méthode crée un tableau d'options de connexion pour l'équipement dans la configuration actuelle avec une priorité
		 * 
		 * Les options sont ensuite triées et affichées.
		 */
		override protected function _addChoiceModeConnection():void
		{
			//trace(_eqView.selectedConnexion);
			/* on crée un tableau d'options avec une priorité */
			_optionsArr = [];
			var optionWifi:ConnectionsOption = new ConnectionsOption(_eqView);
			optionWifi.type = ModesDeConnexion.WIFI;
			optionWifi.display = _addWifiOption;
			optionWifi.funcName = "_addWifiOption";
			optionWifi.priority = 1;
			optionWifi.conditions.push(_condition1());
			
			var optionWifi2:ConnectionsOption = new ConnectionsOption(_eqView);
			optionWifi2.type = ModesDeConnexion.WIFIEXTENDER_WIFI_NEW;
			optionWifi2.display = _addWifiExtenderNewOption;
			optionWifi2.funcName = "_addWifiExtenderNewOption";
			optionWifi2.priority = 2;
			optionWifi2.conditions.push(_condition2());
			
			var optionWifi3:ConnectionsOption = new ConnectionsOption(_eqView);
			optionWifi3.type = ModesDeConnexion.WIFIEXTENDER_WIFI;
			optionWifi3.display = _addExistingWifiExtenderOption;
			optionWifi3.funcName = "_addExistingWifiExtenderOption";
			optionWifi3.priority = 1;
			/*optionWifi3.conditions.push(_condition3());
			optionWifi3.conditions.push(_condition2());*/
			optionWifi3.conditions.push(_condition4());
			
			// nouvelle regle du 22/11/2012
			// on ne propose plus l'option WifiExtender détecté, mais on doit savoir s'il y en a un proche.
			// je garde quand meme l'ensemble du code sous la main
			//optionWifi3.conditions.push(false);
			
			trace("calcul puissance Livebox");
			var puissance:int = WifiUtils.puissance(pertes, _eqView.distanceLivebox());
			//trace("puissance", puissance);
			/*if (WifiUtils.getColor(puissance) !== WifiUtils.GREEN) {
				
				// FJ comment : on propose toujours le wifi LB -- Modif régle demandée le 03/07/2012
				//optionWifi.conditions.push(false);
				
				// check distance wifi
				var eq:EquipementView = EquipementsLayer.getClosestWifiObjectsArray(_eqView)[0];
				if (eq != null) {
					var inter:IntersectionVO = getIntersections(eq);
					var p2:int = WifiUtils.puissance(inter.pertes, _eqView.getDistance(eq));
					//trace("p2 avec eq:", p2, "dist", _eqView.getDistance(eq));
				} else {
					p2 = WifiUtils.puissance(pertes,_eqView.distanceWifi());
					//trace("p2 sans eq:", p2);
				}
				
				if (WifiUtils.getColor(p2) === WifiUtils.RED) {
					optionWifi3.conditions.push(false);
				}
			} else {
				optionWifi3.conditions.push(false);
				// on ne propose l'option nouveau wifi extender que si murs ou étage, soit:
				// on ne propose pas l'option nouveau WFE si 0 mur et 0 étage
				if (nbWalls == 0 && nbBearingWalls == 0 && nbCeilings == 0) {
					optionWifi2.conditions.push(false);
				} 
				optionWifi.priority = 1;
			}*/
			
			/* Nouvelles règles 26/11/2012 */
			/*var distWF:Number = _eqView.distanceLivebox();
			trace(distWF, " est la dist de la LB, puissance ", WifiUtils.getColor(puissance), "vert=2");
			var label:String = AppLabels.getString("connections_wifiLBState");
			var nbObstacles:int = nbWalls + nbCeilings + nbBearingWalls;
			//trace("couleur ", WifiUtils.getColor(puissance));
			// si couleur verte ou orange
			if (WifiUtils.getColor(puissance) == WifiUtils.GREEN || WifiUtils.getColor(puissance) == WifiUtils.ORANGE) {
				// on ne propose l'option 2 Wi FI Extender nouveau que si murs ou étages
				// et l'option wifi LB passe en priorité 1
				if (nbObstacles == 0) {
					optionWifi2.conditions.push(false);
					optionWifi.priority = 1;
				}
				//var mod:EquipementView = EquipementsLayer.getClosestWifiObjectsArray(_eqView)[0];
				//if (mod != null) {
					//distWF = _eqView.getDistance(mod);
					//trace(distWF, " est la distance du WFE le plus proche");
					//var inter:IntersectionVO = getIntersections(module);
					//var p2:int = WifiUtils.puissance(inter.pertes, distWF);
					//trace("couleur2", WifiUtils.getColor(p2));
				//}
			} 
			else if (WifiUtils.getColor(puissance) == WifiUtils.RED) 
			{				
				// si couleur rouge et Wifi Extender détecté, recalcul puissance wifi du WFE et affichage avant les choix de connexion
				var module:EquipementView = EquipementsLayer.getClosestWifiObjectsArray(_eqView)[0];
				if (module != null) 
				{
					var inter:IntersectionVO = getIntersections(module);
					distWF = _eqView.getDistance(module);
					label = AppLabels.getString("connections_wifiState");
					var p2:int = WifiUtils.puissance(inter.pertes, distWF);
					//trace("couelur2", WifiUtils.getColor(p2));
					// si nouvelle puissance verte, l'option WiFi LB passe en priorité 1
					// si nouvelle puissance rouge, l'option Wi Fi Extender nouveau passe en priorité 1
					if (WifiUtils.getColor(p2) === WifiUtils.RED) {
						optionWifi2.priority = 1;
						optionWifi.priority = 2;
					} else if (WifiUtils.getColor(p2) === WifiUtils.GREEN) {
						optionWifi2.priority = 2;
						optionWifi.priority = 1;
					}
				} 
				else {
					// si couleur rouge et pas de WiFi extender détecté
					optionWifi.priority = 2;
					optionWifi2.priority = 1;
				}
			}*/
			
			/*Nouvelles règles 01/04/2013 */
			/* Pour chacune des sources détectées de Wi-Fi, on calcule la puissance
			 * */
			var distWF:Number = _eqView.distanceLivebox();
			//trace(distWF, " est la dist de la LB", WifiUtils.getColor(puissance), " (vert=2)");
			var label:String = AppLabels.getString("connections_wifiLBState");
			var nbObstacles:int = nbWalls + nbCeilings + nbBearingWalls;
			
			var b:BestWifiChoice = getBestWifiChoice(_eqView, false);
			trace(b.equipement, b.puissance, puissance);
			
			// si un wifi extender est un meilleur choix que la Livebox
			if (b.equipement != null && b.puissance > puissance) {
				optionWifi.conditions.push(false);
			} else {
				optionWifi3.conditions.push(false);
			}
			
			// si couleur verte
			if (WifiUtils.getColor(puissance) == WifiUtils.GREEN || WifiUtils.getColor(b.puissance) == WifiUtils.GREEN) {
				// on ne propose l'option 2 Wi FI Extender nouveau que si murs ou étages
				// et l'option wifi LB passe en priorité 1
				if (nbObstacles == 0) {
					optionWifi2.conditions.push(false);
					optionWifi.priority = 1;
				}
			} 
			/*else
			{	
				// optionWifi passe en priorité 1 et optionNouveauWiFiExtender en priorité 2
				// ce sont les données par défaut, donc on se passe de cette condition
			}*/
			
			if(optionWifi.condition())
			{
				_optionsArr.push(optionWifi);
			}
			if(optionWifi2.condition())
			{
				_optionsArr.push(optionWifi2);
			}
			if(optionWifi3.condition())
			{
				_optionsArr.push(optionWifi3);
			}
			
			_optionsArr.sortOn("priority");
			
			_addText(label, "helvetBold", 12, Config.COLOR_DARK);
			//trace("distWF = ", distWF);
			_addIconWifi(distWF, _xpos);
			
			//_addText("Pour connecter cet équipement à la Livebox, compte-tenu des informations récoltées,", "helvet", 12, Config.COLOR_ORANGE);
			//_addText("(murs à traverser : "+nbWalls.toString()+", mursPorteurs : "+nbBearingWalls.toString()+", plafonds à percer : "+nbCeilings.toString()+")", "helvetBold", 12, Config.COLOR_DARK);
			_nexty += 5; 
			if (b.equipement != null) {
				_addText(AppLabels.getString('connections_wifiExtenderState'), "helvetBold", 12, Config.COLOR_DARK);
				_addIconWifiExtender(b.distance, b.pertes, _xpos);
			}
			
			if (_isNoBetterChoice()) {
				_noBetterChoice();
				return;
			}
			
			_bestAdvice();
			_otherAdvices();
		}
		
		/**
		 * Méthode appelée s'il n'y a pas de meilleur choix possible de connexion que la connexion actuelle.
		 */
		override protected function _noBetterChoice():void
		{
			_addText(AppLabels.getString("connections_noBetterWifiChoice"), "helvet", 20, Config.COLOR_ORANGE);
			_nexty += 5;
			
			_addText(AppLabels.getString("connections_alsoConnectWithEthernet"), "helvet", 12, Config.COLOR_DARK);
			_nexty += 30
			
			var b:Btn = new Btn(0, AppLabels.getString("buttons_connectWithEthernet"), null, 150, 0xffffff, 12, 24, Btn.GRADIENT_ORANGE);
			// si l'équipement peut se connecter en ethernet on ajoute le bouton
			if(ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.ETHERNET)) {addChild(b);}
			b.addEventListener(MouseEvent.CLICK, _askEthernet, false, 0, true);
			b.x = 250;
			b.y = _nexty -50;
			
			_nexty = b.x + b.height + 10
		}
		
		private function _askEthernet(e:MouseEvent):void
		{
			var op:ConnectionEthernet = new ConnectionEthernet(_eqView);
			AlertManager.addPopup(op, Main.instance);
			op.x = MenuContainer.instance.x - 560;
			op.y = 109;
		}
		
		private function _isNoBetterChoice():Boolean
		{
			return (_optionsArr.length == 0 || (_optionsArr.length == 1 && _eqView.selectedConnexion == _optionsArr[0].type))
		}
		
		private function _addWifiOption():void
		{
			var subtext:String = (_condition4()) ? AppLabels.getString("connections_installWifiSubtextB") : AppLabels.getString("connections_installWifiSubtext");
			_addRadioButton(AppLabels.getString("connections_installWifi"), ModesDeConnexion.WIFI, subtext);
		}
		
		private function _addWifiExtenderNewOption():void
		{
			//if (_condition2()) {
				_addRadioButton(AppLabels.getString("connections_installWifiWFE"), ModesDeConnexion.WIFIEXTENDER_WIFI_NEW, AppLabels.getString("connections_installWifiWFESubtext"));
			//}
		}
		
		private function _addExistingWifiExtenderOption():void
		{
			var subtext:String = (_condition4()) ? AppLabels.getString("connections_installWifiSubtextB") : AppLabels.getString("connections_installWifiSubtext");
			_addRadioButton(AppLabels.getString("connections_installWifi"), ModesDeConnexion.WIFIEXTENDER_WIFI, subtext);
			return;
			
			var closestWFE:Array = EquipementsLayer.getWifiExtenderArray(_eqView);
			var module:EquipementView;
			if (closestWFE.length > 0) module = closestWFE[0] as EquipementView;
			
			/*if (_condition3()) 
			{
				// check for wifi extender proche deja installé
				if (_condition2()) 
				{
					//var closestWFE:Array = EquipementsLayer.getClosestWifiExtenderArray(_eqView);
					if (_condition4()) {*/
						//_addRadioButton(AppLabels.getString("connections_installWifiWFEPresent"), ModesDeConnexion.WIFIEXTENDER_WIFI, "", module);
					/*}					
				}
			}*/
		}
		// check for liveplug wifi duo proche deja installé
		// à intégrer plus tard
		/*if (ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.DUO_WIFI))
			var closestWifiDuo:Array = EquipementsLayer.getClosestWifiDuoArray(_eqView);
			if(closestWifiDuo.length >0 && !(_eqView is DecodeurView)) {
			{	
				_addRadioButton("installer en Wi-Fi <b>avec Liveplug Wi-Fi déjà installé</b>", ModesDeConnexion.DUO_WIFI);
			} 
		}*/
		
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
		
		private function _condition1():Boolean
		{
			return ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.WIFI);
		}
		
		private function _condition2():Boolean
		{
			return ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.WIFIEXTENDER_WIFI);
		}
		
		private function _condition3():Boolean
		{
			return (EquipementsLayer.WIFI_POINTS.length !== 0 && _eqView.distanceWifi() <= Config.DISTANCE_WIFI) ;
		}
		
		private function _condition4():Boolean
		{
			var closestWFE:Array = EquipementsLayer.getClosestWifiObjectsArray(_eqView);
			return (closestWFE.length > 0);
		}
		
		override protected function _addButtons():void
		{
			_btnValidate = new Btn(0, AppLabels.getString("buttons_validateAndConnect"), IconBtnConnect, 158, 0xffffff, 12, 30, Btn.GRADIENT_ORANGE);
			_itemsContainer.addChild(_btnValidate);
			_btnValidate.y = _itemsContainer.height +16;
			_btnValidate.x = (WIDTH - 158 - 20);
			_btnValidate.alpha = .3;
			if (_isNoBetterChoice()) _btnValidate.mouseEnabled = false;
			
			super._addButtons();
		}
	}

}