package classes.views.alert 
{
	import classes.commands.AddEquipementCommand;
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.ArrayUtils;
	import classes.utils.GeomUtils;
	import classes.utils.WifiUtils;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.equipements.DecodeurView;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.LiveplugView;
	import classes.views.equipements.SwitchView;
	import classes.views.equipements.WifiDuoView;
	import classes.views.equipements.WifiExtenderView;
	import classes.views.EquipementsLayer;
	import classes.views.menus.MenuContainer;
	import classes.views.menus.MenuFactory;
	import classes.views.plan.EditorContainer;
	import classes.views.plan.IntersectionPoint;
	import classes.vo.BestWifiChoice;
	import classes.vo.ConnectionsCollection;
	import classes.vo.EquipementVO;
	import classes.vo.IntersectionVO;
	import com.warmforestflash.drawing.DottedLine;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextFormat;
	
	/**
	 * Classe de base pour le popup de connexion
	 */
	public class AlertConnection extends Sprite 
	{
		/**
		 * Le nombre de murs à traverser en ligne droite pour aller de l'équipement à la source (Livebox)
		 */
		public var nbWalls:int;
		/**
		 * Le nombre de murs porteurs à traverser en ligne droite pour aller de l'équipement à la source (Livebox)
		 */
		public var nbBearingWalls:int;
		/**
		 * Le nombre de plafonds à traverser en ligne droite pour aller de l'équipement à la source (Livebox)
		 */
		public var nbCeilings:int;
		/**
		 * Résultat du calcul de perte wifi entre l'équipement et la Livebox
		 */
		public var pertes:int;		
		/**
		 * La largeur de la fenêtre
		 */
		protected var WIDTH:int = 600;
		protected var _eqView:EquipementView;
		protected var _vo:EquipementVO;
		protected var _itemsContainer:Sprite;
		protected var _rbgroup:RadioButtonGroup;
		protected var myFont:Font; 
 		protected var tf:TextFormat;
		protected var _g:Graphics;
		protected var _appmodel:ApplicationModel = ApplicationModel.instance;
		protected var _model:EditorModelLocator = EditorModelLocator.instance;
		protected var _nexty:int;
		protected var _xpos:int;
		protected var _selectedConnexion:String;
		protected var _btnValidate:Btn;
		protected var _btnCancel:Btn;
		protected var _hasEquipement:Boolean = false;
		protected var _title:CommonTextField;
		protected var _nbSwitchSlots:int = -1;
		protected var _switchAlert:SwitchAlert;
		protected var _fullPortEq:EquipementView;
		protected var _optionsArr:Array;
		protected var _collection:ConnectionsCollection = ApplicationModel.instance.connectionsCollection;
		/** 
		 * Tableau de correspondance entre les images et les radio bouton 
		 */
		protected var correspondances:Array = new Array();
		
		/**
		 * Constructeur : gère l'ensemble de l'affichage du popup
		 * 
		 * <p>Les choix possibles en fonction du contexte</p>
		 * 
		 * @param equipementview L'équipement concerné par la connexion
		 */
		public function AlertConnection(equipementview:EquipementView) 
		{
			super();
			_eqView = equipementview;
			_vo = _eqView.vo;
			
			myFont = new Helvet55Reg(); 
 			tf = new TextFormat();
			tf.font = myFont.fontName; 
			//tf.bold = true;
			tf.color = Config.COLOR_ORANGE; 
			tf.size = 20; 
			
			_g = graphics;
			var color:int = Config.COLOR_GREY;
			_g.lineStyle(2, color);
			_g.beginFill(0xffffff);
			
			_itemsContainer = new Sprite();
			addChild(_itemsContainer);
			
			_rbgroup = new RadioButtonGroup("generic");
			
			_addTitle();
			_drawDotsLine(9, 36);
			
			var intervo:IntersectionVO = getIntersections();
			nbWalls = intervo.numWalls;
			nbBearingWalls = intervo.numBearingWalls;
			nbCeilings = intervo.numCeilings;
			pertes = intervo.pertes;
			
			_draw();
			
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _remove);
			
			_onResize();
			stage.addEventListener(Event.RESIZE, _onResize, false, 0, true);
			
			// envoi notification aux sprites qui ont besoin de passer par dessus le popup
			_appmodel.notifyConnectPopupOpen();
		}
		
		protected function _addTitle():void
		{
			_title = new CommonTextField("helvet", 0, 20);
			_title.autoSize = "left";
			_title.width = WIDTH - 30;
			_title.height = 18.5;
			//_title.setText(_vo.screenLabel || _vo.name);/* cas des anciens fichiers xml sans screenlabel */
			_title.x = 10;
			_title.y = 5;
			_nexty = _title.y + _title.height + 10;
			
			_itemsContainer.addChild(_title);
		}
		
		protected function _drawDotsLine(xpos:int, ypos:int):void
		{
			var s:Shape = new DottedLine(WIDTH -22, 1, 0x333333, 1, 1.3, 2);
			_itemsContainer.addChild(s);
			s.x = xpos;
			s.y = ypos;
			_nexty = s.y + 9;
		}
		
		protected function _addHeader():void
		{
			_addText(AppLabels.getString("connections_what"), "helvet45", 20, Config.COLOR_ORANGE);
			_addText(AppLabels.getString("connections_whatSubtext"), "helvetBold", 12, Config.COLOR_ORANGE);
			_nexty += 14;
		}
		
		protected function _info(e:MouseEvent):void
		{
			if (_eqView.vo.diaporama360 != "null") {
				var popup:Info360 = new Info360(_eqView.vo.diaporama360);
				AlertManager.addSecondPopup(popup, Main.instance);
			}
		}
		
		private function _draw():void
		{
			_addHeader();
			
			_addChoiceModeConnection();
			_rbgroup.addEventListener(MouseEvent.CLICK, _clickHandler);
			
			_addButtons();
			_drawDotsLine(9, _nexty - 12);
		}
		
		private function _drawBG():void
		{
			var esp:int = 55;
			_g.lineStyle();
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xe5e5e5, Config.COLOR_WHITE];
			var alphas:Array = [1, 1];
			var ratios:Array = [210, 255];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(WIDTH, _itemsContainer.height + esp, - Math.PI / 2);
			var spreadMethod:String = SpreadMethod.PAD;
			_g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			_g.drawRoundRect(0, 0, WIDTH, _itemsContainer.height + esp, 10, 10);
			_g.endFill();
		}
		
		protected function _addText(str:String, font:String, size:int, color:Number, xpos:int = 9, wdth:int = 500, ypos:int=0):void
		{
			var t:CommonTextField = new CommonTextField(font, color, size);
			t.autoSize = "left";
			t.width = wdth;
			if(str.indexOf("<b>") != -1) {
				t.embedFonts = true;
				t.setHtmlText(str);
			}
			var boldStartNum:int = (str.split("<b>")[0] as String).length;
			if(boldStartNum != str.length) str.replace("<b>", "");
			var boldEndNum:int = (str.split("</b>")[0] as String).length -3;
			if(boldStartNum != str.length) str.replace("</b>", "");
			if (boldStartNum < boldEndNum) {
				var boldFormat:TextFormat = t.cloneFormat();
				boldFormat.font = (new Helvet55Bold() as Font).fontName;
				boldFormat.bold = true;
				t.setTextFormat(boldFormat, boldStartNum, boldEndNum);
			} 
			if( str.indexOf("<b>") == -1) {
				t.setText(str);
			}
			t.x = xpos;
			t.y = (ypos == 0) ? _nexty : ypos;
			_nexty = t.y + t.textHeight + 2;
			_xpos = t.x + t.textWidth + 8;
			
			_itemsContainer.addChild(t);
		}
		
		/**
		 * Doit être overriden par les classes étendantes
		 */
		protected function _addChoiceModeConnection():void
		{
			if (ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.ETHERNET) ) {
				_addRadioButton("Ethernet", ModesDeConnexion.ETHERNET);
			}
		}
		
		/**
		 * Utilisé par ConnectionFilter en l'état mais doit être overriden par les classes étendantes si les fonctionnalités diffèrent.
		 * 
		 * <p>Propose un <code>RadioButton</code> et un texte label sans image, comportement par défaut du <code>RadioButton</code></p>
		 */
		protected function _addRadioButton(label:String, value:String, subtext:String = "", module:EquipementView = null):void
		{
			// ne pas montrer la connexion en cours
			if (_eqView.selectedConnexion === value) return;
			
			// code radiobutton normal
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
			rb.label = label;
			rb.setStyle("textFormat", tf);
			rb.drawNow();
			_itemsContainer.addChild(rb);
			rb.y = _nexty;
			rb.x = 9;
			_nexty = rb.y + rb.height + 3;
			rb.group = _rbgroup;
			AppUtils.setButton(rb);
			
			// avec images et textes dans le radiobutton (comme dans ConnectionEthernet)
			/*var rb:RadioButton = new RadioButton();
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
			var the_label:CommonTextField = new CommonTextField("helvet", Config.COLOR_ORANGE, 20);
			the_label.width = 360;
			the_label.embedFonts = true;
			the_label.setText(label);
			_itemsContainer.addChild(the_label);
			the_label.x = xpos + 5;
			the_label.y = _nexty + 8;
			
			_nexty = rb.y + rb.height + 3;*/
		}
		
		/*private function _clickImage(e:MouseEvent):void
		{
			var rb:RadioButton = correspondances[e.currentTarget.name];
			rb.selected = true;
			_clickHandler(e);
		}*/
		
		/**
		 * Vérifie si l'ajout d'un switch est nécessaire; la règle étant que l'ajout d'un switch est nécessaire si tous les ports 
		 * ethernet d'un équipement sont pris. Par contre, on ne gère que le premier niveau, on ne gère pas l'ajout d'un switch sur 
		 * un switch.
		 * 
		 * @param eq EquipementView concerné
		 * @param ypos La position y de l'aerte Switch
		 */
		protected function _checkIfSwitchNeed(eq:EquipementView, ypos:int):void
		{
			// un switch est nécessaire si tous les ports ethernet d'un équipement sont pris 
			if (eq == null) return;
			
			// si deja un switch présent on n'affiche pas l'alerte switch
			trace("_checkForSwitch:eq::", eq+"::", eq.switchAsChild );
			if (eq.switchAsChild) {
				_fullPortEq = eq;
				return;
			}
			
			// s'il y a un master et qu'on veut ajouter un autre LPHD ou WFE, on n'a pas l'alerte switch
			if (_selectedConnexion == ModesDeConnexion.LIVEPLUG_NEW || _selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW) {
				if (EquipementsLayer.isThereALiveplugModuleDeBase()) return;
			}

			var nbPortsEthernet:int = eq.vo.nbPortsEthernet;
			//3 ports max pour la livebox / fibre si livebox 2 Fibre
			if (_appmodel.projectType === "fibre" && eq.vo.type == "LiveboxItem" && eq.vo.name === "Livebox2 Fibre") {
				nbPortsEthernet = eq.vo.nbPortsEthernet-1;
			}
			trace("_checkForSwitch:", nbPortsEthernet, _collection.getReceivingConnections(eq, ModesDeConnexion.ETHERNET).length );
			if (nbPortsEthernet - _collection.getReceivingConnections(eq, ModesDeConnexion.ETHERNET).length <= 0) {
				//cas de modif d'une connection, on va virer _eqview donc il va libérer sa place
				if(_eqView.connection && _eqView.connection.provider == eq) return;
				_switchAlert = new SwitchAlert(eq);
				_switchAlert.y = ypos;
				addChild(_switchAlert);
				_switchAlert.x = 140;
				_nbSwitchSlots = 4;
				_fullPortEq = eq;
			}
		}
		
		protected function _addButtons():void
		{			
			_btnCancel = new Btn(0x999999, AppLabels.getString("buttons_cancel"), null, 116, 0xffffff, 12, 26, Btn.GRADIENT_DARK);
			_itemsContainer.addChild(_btnCancel);
			_btnCancel.x = _btnValidate.x - 116 - 10;
			_btnCancel.y = _btnValidate.y + (30 - 24) / 2;
			_btnCancel.addEventListener(MouseEvent.CLICK, _cancel, false, 0, true);
			
			_nexty = _btnCancel.y + _btnCancel.height +7;
			
			_drawBG()
		}
		
		/**
		 * Affiche le meilleur choix de connexion pour l'équipement sélectionné
		 */
		protected function _bestAdvice():void
		{
			_addText(AppLabels.getString("connections_adviceText"), "helvet", 20, Config.COLOR_ORANGE);
			_nexty += 5
			//trace(_optionsArr);
			var option:ConnectionsOption = (_optionsArr[0] as ConnectionsOption)
			option.display();
		}
		
		/**
		 * Needs to be overriden
		 */
		protected function _noBetterChoice():void
		{
		}
		
		/**
		 * Les autres conseils de connexion possibles pour cet équipement dans la config actuelle
		 */
		protected function _otherAdvices():void
		{
			var i:int = 1;
			//trace(i, _optionsArr.length);
			if (i >= _optionsArr.length) return;
			
			_addText(AppLabels.getString("connections_advice2Text"), "helvet", 20, Config.COLOR_ORANGE);
			_nexty += 7;
			
			while (i < _optionsArr.length) {
				var option:ConnectionsOption = (_optionsArr[i] as ConnectionsOption)
				option.display();
				i++;
			}
		}
		
		/**
		 * Renvoie le meilleur choix Wi-Fi parmi les Wifi Extender présents (avec ou sans la Livebox, voir paramètre addLBInCalc) 
		 * parmi ceux présents au même étage que l'équipement et à distance acceptable
		 * 
		 * @param	_eqView L'équipement concerné 
		 * @param	addLBInCalc ajoute la Livebox dans les calculs
		 * @return Un objet BestWifiChoice
		 */
		public function getBestWifiChoice(_eqView:EquipementView, addLBInCalc:Boolean = true):BestWifiChoice
		{
			// on calcule la puissance sur chaque source wifi de l'étage à distance acceptable
			var wifiArrs:Array = EquipementsLayer.getClosestWifiObjectsArray(_eqView);
			if (addLBInCalc) {
				wifiArrs.push(EquipementsLayer.getLivebox());
			}
			//trace(wifiArrs);
			var nbWifiSrcs:int = wifiArrs.length;
			var values:Array = [];
			var wifiChoice:BestWifiChoice = new BestWifiChoice();
			wifiChoice.distance = -1;
			wifiChoice.equipement = null;
			wifiChoice.pertes = -1;
			wifiChoice.puissance = 0;
			for (var i:int = 0; i < nbWifiSrcs; i++) {
				var module:EquipementView = wifiArrs[i];
				//trace("calcul puissance Wifi-Objets ", i, module.uniqueId);
				var d:Number = _eqView.getDistance(module);
				var inter:IntersectionVO = getIntersections(module);
				var p2:int = WifiUtils.puissance(inter.pertes, d);
				wifiChoice.distance = d;
				wifiChoice.equipement = module;
				wifiChoice.pertes = inter.pertes;
				wifiChoice.puissance = p2;
				values.push( wifiChoice );
			}
			if (nbWifiSrcs != 0) {
				values.sortOn("puissance", Array.NUMERIC | Array.DESCENDING);
				/*for (i = 0; i < nbWifiSrcs; i++) {
					trace(values[i].puissance, values[i].equipement.vo.name);
				}*/
				return values[0];// i-1 si Array.DESCENDING seul comme second param de sortOn
			} 
			return wifiChoice;
		}
		
		/**
		 * Récupère les intersections de murs et plafonds entre la Livebox et l'équipement sélectionné
		 * 
		 * @param equipement L'équipement avec lequel il faut vérifier les intersections
		 */
		public function getIntersections(equipement:EquipementView=null):IntersectionVO
		{
			if (equipement == null) equipement = EquipementsLayer.getLivebox();
			
			var p1:Point = new Point(_eqView.x, _eqView.y)
			var p2:Point = new Point(equipement.x, equipement.y)
			var intersectionPoints:Array = GeomUtils.getHittingPoints(p1, p2, _model.currentBlocMaison);
			var mursPorteursCount:int = 0;
			var pertes:int;
			for(var i:int = 0; i< intersectionPoints.length; i++)
			{
				var intersection:IntersectionPoint = intersectionPoints[i];
				var p:int// pertes par mur
				if (intersection.mur.murPorteur) {
					mursPorteursCount++;
					p = intersection.mur.coeff;
				} else {
					p = WifiUtils.coeffCloison("def");
				}
				//trace("\t", p);
				pertes += p;
			}
			trace("Nombre de murs " , intersectionPoints.length - mursPorteursCount);
			//trace("Nombre de murs porteurs " + mursPorteursCount);
			//trace("nombre de plafonds traversés " + Math.abs(_eqView.floorId - EquipementsLayer.getLivebox().floorId));
			var intersectionVO:IntersectionVO = new IntersectionVO()
			intersectionVO.numBearingWalls = mursPorteursCount;
			intersectionVO.numWalls = intersectionPoints.length - mursPorteursCount;
			intersectionVO.numCeilings = Math.abs(_eqView.floorId - equipement.floorId);
			//ici temporary stuff, 12/06/2012 FJ, valeur moyenne plaquée ici mais on devrait avoir chaque étage*son coeff (fonction beton/bois 12/7)
			pertes += intersectionVO.numCeilings * 10;
			intersectionVO.pertes = pertes;
			trace("pertes:", pertes);
			
			return intersectionVO;
		}
		
		protected function _clickHandler(e:MouseEvent):void
		{
			_selectedConnexion = _rbgroup.selection.value.toString()//;e.target.selection.value;
		}
		
		protected function _cancel(e:MouseEvent):void
		{
			_closeActions();
		}
		
		protected function _closeActions():void
		{
			//trace("_closeActions");
			AlertManager.removePopup();
			
			//update menu after validation
			MenuContainer.instance.closeMenu();
			//MenuFactory.createMenu(_eqView, EditorContainer.instance);
		}
		
		/**
		 * Méthode d'ajout du ou des Liveplug HD+ lors de l'établissement d'une connexion.
		 * 
		 * <p>il faut ajouter un master et son module esclave</p>
		 * <ul>
		 * 	<li>CAS GENERIQUE : si pas de liveplug HD présent</li>
		 *  <li>CAS PARTICULIER 1 : si adsl2tv et l'équipement est un décodeur et le mode de connexion est Liveplug 
		 *    (ce choix n'est proposé que s'il est possible, traité en amont dans ConnectionEthernet, donc 
		 *     fonctionne si on a déjà un LP HD présent sur autre equipement que décodeur)</li>
		 *  <li>CAS PARTICULIER 2 : ou si adsl2tv et présence d'un LP décodeur et pas présence d'un deuxieme LiveplugHD maitre</li>
		 * </ul>
		 */
		protected function _addLiveplugs():void
		{
			var liveplug2:LiveplugView;
			//trace("addLiveplugs", _selectedConnexion, _appmodel.projectType, _eqView, EquipementsLayer.isThereLiveplugDecodeur(), EquipementsLayer.isThereALiveplugModuleDeBase(), EquipementsLayer.isthereLiveplugMasterConnected(), EquipementsLayer.isThereLPHDNotDecodeurSource())
			if (_selectedConnexion === ModesDeConnexion.LIVEPLUG) 
			{
				// on utilise une connexion existante - devrait etre déjà traité en amont 
				trace("_addLiveplugs premier return")
				return;
			}
			if ( EquipementsLayer.getEquipements(LiveplugView) === 0 || 
				(_appmodel.projectType === "adsl2tv" && _eqView is DecodeurView) ||
				((_appmodel.projectType === "adsl2tv") && (EquipementsLayer.isThereLiveplugDecodeur()) && !EquipementsLayer.isThereLPHDNotDecodeurSource()/*(EquipementsLayer.isthereLiveplugMasterConnected() === false)*/))
			{
				var vo:EquipementVO = _appmodel.getVOFromXML("Liveplug");		
				var liveplug1:LiveplugView = new LiveplugView(vo);
				liveplug1.id = LiveplugView.count;
				liveplug1.isModuleDeBase = true;
				liveplug1.draw();
				
				var provider:EquipementView = EquipementsLayer.getLivebox();
				trace("ajout liveplug", _fullPortEq, _eqView);
				if ( _fullPortEq && !_eqView.isDecodeur ) {
					var switchView:SwitchView = _fullPortEq.switchAsChild as SwitchView;
					if (switchView) provider = switchView;
				}
				//lb.parentBloc.equipements.addEquipement(liveplug1);
				
				liveplug2 = new LiveplugView(vo);
				//liveplug2.id = LiveplugView.count;
				liveplug2.draw();
				new AddEquipementCommand(provider.parentBloc, liveplug1, _eqView.parentBloc, liveplug2, false).run();
				
				liveplug1.x = provider.x + 30 + Math.random()*10;
				if ((_appmodel.projectType === "adsl2tv") && EquipementsLayer.isThereLiveplugDecodeur()) liveplug1.y = provider.y + 10 + Math.random()*15;
				else liveplug1.y = provider.y;
				liveplug1.addSlave(liveplug2);
				//_eqView.connexionViewsAssociated.push(liveplug1);
				provider.connexionViewsAssociated.push(liveplug1);
				
				liveplug2.x = _eqView.x + 30 + Math.random()*10;
				liveplug2.y = _eqView.y;
				liveplug2.master = liveplug1;
				_eqView.connexionViewsAssociated.push(liveplug2);
				if (_eqView.selectedConnexion == ModesDeConnexion.LIVEPLUG_NEW) {
					_eqView.setConnexion(ModesDeConnexion.LIVEPLUG);
				}
				_collection.createConnection(provider, liveplug1, ModesDeConnexion.ETHERNET, provider.provider);
				_collection.createConnection(liveplug1, liveplug2, ModesDeConnexion.CPL, provider);
				_collection.createConnection(liveplug2, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), liveplug1);
				_eqView.linkedEquipment = liveplug2;
				liveplug2.linkedEquipment = _eqView;
				//associate the pair of object for a deletion purpose
				//liveplug1.connexionViewsAssociated.push(liveplug2);
				//liveplug2.connexionViewsAssociated.push(liveplug1);
				
				// register the equipement associated to this pair of connexion mode
				liveplug1.equipement = _eqView;
				liveplug2.equipement = _eqView;
				
				//_askForPossession(2, "Liveplug HD+", _updateOwnership, liveplug1, liveplug2);
				
			} 
			else { // là on gère le cas où on ne doit ajouter que le module esclave car le master est déjà là
				
				var master:LiveplugView;
				//vo = new EquipementVO();
				vo = _appmodel.getVOFromXML("Liveplug");				
				liveplug2 = new LiveplugView(vo);
				//liveplug2.id = LiveplugView.count;
				liveplug2.draw();
				new AddEquipementCommand(_eqView.parentBloc, liveplug2, null, null, false).run();
				
				liveplug2.x = _eqView.x + 30 + Math.random()*10;
				liveplug2.y = _eqView.y;// + Math.random() * 50;
				_eqView.connexionViewsAssociated.push(liveplug2);
				//FJ ajout 22/08
				if (_eqView.selectedConnexion == ModesDeConnexion.LIVEPLUG_NEW) {
					_eqView.setConnexion(ModesDeConnexion.LIVEPLUG);
				}
				liveplug2.equipement = _eqView;
				master = EquipementsLayer.getLiveplugMaster();
				if(!master) 
				{
					trace("addliveplug master should be here,  but master = ", master);
					return;
				}
				
				liveplug2.master = master;
				master.addSlave(liveplug2);
	            _collection.createConnection(master, liveplug2, ModesDeConnexion.CPL, master.provider);
				_collection.createConnection(liveplug2, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), master);
				_eqView.linkedEquipment = liveplug2;
				liveplug2.linkedEquipment = _eqView;
				
				//_askForPossession(1, vo.screenLabel, _updateOwnership, liveplug2);
				
			}
		}
		
		/**
		 * Méthode d'ajout d'un Liveplug Wi-Fi Solo lors de l'établissement d'une connexion.
		 */ 
		protected function _addSolo():void
		{
			var wifisolo:WifiDuoView;
			if (!EquipementsLayer.isThereAWifiSolo()) {
				var vo:EquipementVO = _appmodel.getVOFromXML("WiFiSolo");
				
				wifisolo = new WifiDuoView(vo);
				wifisolo.isModuleDeBase = false;
				wifisolo.draw();
				
				var lb:EquipementView = EquipementsLayer.getLivebox();
				trace("ajout solo", _fullPortEq, _eqView);
				if ( _fullPortEq && !_eqView.isDecodeur ) {
					var switchView:SwitchView = _fullPortEq.switchAsChild as SwitchView;
					if (switchView) lb = switchView;
				}
				new AddEquipementCommand(_eqView.parentBloc, wifisolo, null, null, false).run();
				
				wifisolo.x = _eqView.x + 20 + Math.random()*20;
				wifisolo.y = _eqView.y + Math.random() * 20;
				_eqView.connexionViewsAssociated.push(wifisolo);
				
				wifisolo.connectedEthernetEquipements.push(_eqView);
				
				_collection.createConnection(lb, wifisolo, ModesDeConnexion.WIFI);
				_collection.createConnection(wifisolo, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), lb);
				_eqView.linkedEquipment = wifisolo;
				wifisolo.linkedEquipment = _eqView;
				
			} else {
				// utilise le solo déjà présent
				// connecte l'équipement au solo déjà présent
				wifisolo = EquipementsLayer.getWifiDuo();// works because only 2 wifiduo possible on plan for now
				if (wifisolo != null) {
					// connecte sauf s'il y a un switch, cas déjà traité avant d'arriver ici
					if (_fullPortEq != null && (_fullPortEq.switchAsChild as SwitchView)) {
						trace("port plein et switch présent, on arrete là");
						return;
					}
					_eqView.connexionViewsAssociated.push(wifisolo);
					wifisolo.connectedEthernetEquipements.push(_eqView);
					
					_collection.createConnection(wifisolo, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), wifisolo.provider);
				}
			}
		}
		
		/**
		 * Méthode d'ajout du ou des Liveplug Wi-Fi Duo lors de l'établissement d'une connexion.
		 */ 
		protected function _addDuos():void
		{
			//trace("duo added");
			var wifiduo2:WifiDuoView;
			if(!EquipementsLayer.isThereAWifiDuo()) {
				var vo:EquipementVO = _appmodel.getVOFromXML("WiFiDuo");
				var wifiduo1:WifiDuoView = new WifiDuoView(vo);
				wifiduo1.isModuleDeBase = true;
				wifiduo1.draw();
				
				wifiduo2 = new WifiDuoView(vo);
				wifiduo2.isModuleDeBase = false;
				wifiduo2.draw();
				
				var lb:EquipementView = EquipementsLayer.getLivebox();
				trace("ajout duo", _fullPortEq, _eqView);
				if ( _fullPortEq && !_eqView.isDecodeur ) {
					var switchView:SwitchView = _fullPortEq.switchAsChild as SwitchView;
					if (switchView) lb = switchView;
				}
				new AddEquipementCommand(lb.parentBloc, wifiduo1, _eqView.parentBloc, wifiduo2, false).run();
				wifiduo1.x = lb.x + 20 + Math.random() * 30;
				wifiduo1.y = lb.y + Math.random() * 30;
				wifiduo1.connexionViewsAssociated.push(wifiduo2);
				lb.connexionViewsAssociated.push(wifiduo1);
				
				wifiduo2.x = _eqView.x + 20 + Math.random()*20;
				wifiduo2.y = _eqView.y + Math.random() * 20;
				_eqView.connexionViewsAssociated.push(wifiduo2);
				wifiduo2.connexionViewsAssociated.push(wifiduo1);
				wifiduo1.equipement = EquipementsLayer.getLivebox();
				wifiduo1.addSlave(wifiduo2);
				wifiduo2.master = wifiduo1;
				
				if (_eqView.selectedConnexion == ModesDeConnexion.DUO_ETHERNET) {
					wifiduo2.connectedEthernetEquipements.push(_eqView);
				}
				_collection.createConnection(lb, wifiduo1, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion));
				_collection.createConnection(wifiduo1, wifiduo2, ModesDeConnexion.WIFI, lb);
				_collection.createConnection(wifiduo2, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), wifiduo1);
				_eqView.linkedEquipment = wifiduo2;
				wifiduo2.linkedEquipment = _eqView;
				
				//_askForPossession(1, vo.screenLabel, _updateOwnership, wifiduo1, wifiduo2);
				
			} else {
				trace("wifi duo deja installé");
				// connect equipment to the already-there wifiduo
				wifiduo2 = EquipementsLayer.getWifiDuo();// works because only 2 wifiduo possible on plan for now
				if (wifiduo2 != null) {
					// connect to it, except if there is a switch
					if (_fullPortEq != null && (_fullPortEq.switchAsChild as SwitchView)) {
						trace("port plein et switch présent, on arrete là");
						return;
					}
					_eqView.connexionViewsAssociated.push(wifiduo2);
					if (_eqView.selectedConnexion == ModesDeConnexion.DUO_ETHERNET) {
						wifiduo2.connectedEthernetEquipements.push(_eqView);
					}
					var master:WifiDuoView = EquipementsLayer.getDuoMaster();
					if(master != null) wifiduo2.master = master;
					
					_collection.createConnection(wifiduo2, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), wifiduo2.provider);
				}
				
			}
		}
		
		/**
		 * Ajout des modules Wi-Fi extenders
		 * 
		 * S'il n'y pas de Liveplug maître (hors décodeur) on ajoute un kit LP Maitre + Wifi Extender
		 * Dans le cas adsl 2tv avec liveplug maitre connecté sur décodeur, on doit ajouter un second Liveplug HD+ maître
		 * 
		 * Sinon on ajoute le Wifi Extender seul
		 * 
		 * Si on utilise un WIfi Extender déjà présent (installé), on vérifie la présence ou non d'un switch avant de
		 * connecter l'équipement 
		 */
		protected function _addWifis():void
		{
			trace("addWifis()", EquipementsLayer.WIFI_POINTS.length, "etage:", _eqView.floorId, "connexion:", _eqView.selectedConnexion);
		
			if (EquipementsLayer.WIFI_POINTS.length === 0 || _eqView.selectedConnexion === ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW || _eqView.selectedConnexion === ModesDeConnexion.WIFIEXTENDER_WIFI_NEW) 
			{
				// on ajoute le module de base liveplug si
				// pas de liveplug maitre deja présent
				// ou dans le cas adsl 2tv si liveplug maitre connecté sur décodeur 
				// on doit ajouter un second maitre
				
				if (!EquipementsLayer.isthereLiveplugMasterConnectedAndUsable()) {
				//if(!EquipementsLayer.isThereLPHDNotDecodeurSource() && (_appmodel.projectType === "adsl2tv" /*|| _appmodel.projectType == "adslSat"*/)) {
					trace("_addWifis, cas1, pas de master")
					var vo:EquipementVO = _appmodel.getVOFromXML("Liveplug");
					var liveplug:LiveplugView;
					liveplug = new LiveplugView(vo);
					liveplug.id = LiveplugView.count;
					liveplug.isModuleDeBase = true;
					liveplug.draw();
					
					vo = _appmodel.getVOFromXML("WiFiExtender");
					var wifi2:WifiExtenderView = new WifiExtenderView(vo);
					wifi2.id = WifiExtenderView.count;
					wifi2.draw();
					
					var lb:EquipementView = EquipementsLayer.getLivebox();
					trace("ajout wifiextender", _fullPortEq, _eqView);
					if ( _fullPortEq && !_eqView.isDecodeur ) {
						var switchView:SwitchView = _fullPortEq.switchAsChild as SwitchView;
						if (switchView) lb = switchView;
					}
					new AddEquipementCommand(lb.parentBloc, liveplug, _eqView.parentBloc, wifi2, false).run();
					liveplug.x = lb.x + 25 + Math.random() * 25;
					liveplug.y = lb.y + Math.random() * 30;
					liveplug.connexionViewsAssociated.push(wifi2);
					//_eqView.connexionViewsAssociated.push(liveplug);
					lb.connexionViewsAssociated.push(liveplug);
					
					wifi2.x = _eqView.x + 25 + Math.random()*20;
					wifi2.y = _eqView.y + Math.random() * 20;
					_eqView.connexionViewsAssociated.push(wifi2);
					wifi2.connexionViewsAssociated.push(liveplug);
					liveplug.equipement = EquipementsLayer.getLivebox();
					liveplug.addSlave(wifi2);
					wifi2.master = liveplug;
					
					//trace("AAApas de wifi ext posés", _eqView, _eqView.selectedConnexion, wifi1)
					if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_WIFI_NEW) {
						_eqView.setConnexion(ModesDeConnexion.WIFIEXTENDER_WIFI);
					}
					if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW) {
						_eqView.setConnexion(ModesDeConnexion.WIFIEXTENDER_ETHERNET);
					}
					if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_WIFI) {
						//trace("AAAwifi cas 1")
						wifi2.connectedWifiEquipements.push(_eqView);
					}
					else if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET) {
						//trace("AAAwifi cas 2")
						wifi2.connectedEthernetEquipements.push(_eqView);
					}
					
					_collection.createConnection(lb, liveplug, ModesDeConnexion.ETHERNET);
					_collection.createConnection(liveplug, wifi2, ModesDeConnexion.CPL, lb);
					_collection.createConnection(wifi2, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), liveplug);
					_eqView.linkedEquipment = wifi2;
					wifi2.linkedEquipment = _eqView;				
					
					//_askForPossession(2, "Wi-Fi Extender", _updateOwnership, liveplug, wifi2);
					
				} else {
					trace("_addWifis, cas2, master présent")
					vo = _appmodel.getVOFromXML("WiFiExtender");
					wifi2 = new WifiExtenderView(vo);
					wifi2.id = WifiExtenderView.count;
					wifi2.draw();
					new AddEquipementCommand(_eqView.parentBloc, wifi2, null, null, false).run();
					wifi2.x = _eqView.x + 20 + Math.random()*20;
					wifi2.y = _eqView.y + Math.random() * 20;
					_eqView.connexionViewsAssociated.push(wifi2);
					var master:LiveplugView = EquipementsLayer.getLiveplugMaster();
					if (!master) 
					{
						trace("add wifiextender master should be here,  but master = ", master);
						return;
					}
					trace("liveplug master", master, master.uniqueId);
					wifi2.master = master;
					master.addSlave(wifi2);
					//trace("AAAwifi ext posés mais pas assez proches", _eqView, _eqView.selectedConnexion, wifi2)
					if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_WIFI_NEW) {
						_eqView.setConnexion(ModesDeConnexion.WIFIEXTENDER_WIFI);
					}
					if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW) {
						_eqView.setConnexion(ModesDeConnexion.WIFIEXTENDER_ETHERNET);
					}
					
					if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_WIFI) {
						//trace("AAAwifi cas 1")
						wifi2.connectedWifiEquipements.push(_eqView);
					}
					else if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET) {
						//trace("AAAwifi cas 2");
						wifi2.connectedEthernetEquipements.push(_eqView);
					}
					
					_collection.createConnection(master, wifi2, ModesDeConnexion.CPL, master.provider);
					_collection.createConnection(wifi2, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), master);
					_eqView.linkedEquipment = wifi2;
					wifi2.linkedEquipment = _eqView;
					//_askForPossession(1, "Wi-Fi Extender", _updateOwnership, wifi2);
				}
			
			} else {
				
				if (_fullPortEq != null) {
					switchView = _fullPortEq.switchAsChild as SwitchView;
					if(switchView)
					{
						return;
					}
				}
				trace("_addWifis, cas3, wifiextender deja present, pas de switch")
				
				var arr:Array = EquipementsLayer.getClosestWifiObjectsArray(_eqView);
				var bestWifiChoice:WifiExtenderView = getClosestEquipement(arr) as WifiExtenderView;
				// connect to it
				_eqView.connexionViewsAssociated.push(bestWifiChoice);
				//trace("AAAwifi ext posés proche", _eqView, _eqView.selectedConnexion, bestWifiChoice)
				if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_WIFI) {
					//trace("AAAwifi cas 1")
					bestWifiChoice.connectedWifiEquipements.push(_eqView);
				}
				else if (_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET) {
					//trace("AAAwifi cas 2");
					bestWifiChoice.connectedEthernetEquipements.push(_eqView);
				}
				master = EquipementsLayer.getLiveplugMaster();
				bestWifiChoice.master = master;
				_collection.createConnection(master, bestWifiChoice, ModesDeConnexion.CPL, master.provider);
				_collection.createConnection(bestWifiChoice, _eqView, ModesDeConnexion.GET_MODE_TYPE(_selectedConnexion), master);
			
			}
		}
		
		/**
		 * Connexion à un switch. 
		 * 
		 * S'il s'agit d'un décodeur, il faut débrancher un autre objet et le mettre sur le switch éventuellement 
		 * déjà présent ou ajouter un switch avec et brancher le décodeur directement sur la Livebox en Ethernet
		 * ou sur un module cohérent avec ses modes de connexion.
		 * 
		 * @param	switchView
		 * @param	equipment
		 */
		protected function _connectToSwitch(switchView:SwitchView, equipment:EquipementView=null):void
		{
			// il faut vérifier le type d'equipement
			// si decodeur il faut débrancher un autre objet et le mettre sur le switch eventuellement présent 
			//				ou ajouter un switch avec
			// et brancher le décodeur directement sur LB sur ethernet ou sur un module cohérent 
			
			trace("_connectToSwitch", switchView, equipment)
			
			if (equipment == null)  equipment = _eqView;
			
			// FJ: la ligne commentée ci-dessous pose pb dans le cas d'une connexion ethernet-liveplug (deja existant) car ca implique la pose
			// d'un switch et la connexion doit devenir "ethernet"
			//equipment.selectedConnexion = _selectedConnexion;
			
			// FJ: patch here: si on est dans le cas d'une connexion liveplug existante, la connexion change et devient ethernet (sur le switch)
			if (_selectedConnexion == ModesDeConnexion.LIVEPLUG || _selectedConnexion == ModesDeConnexion.DUO_WIFI || _selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET) {
				equipment.selectedConnexion = ModesDeConnexion.ETHERNET;
			} else {
				equipment.selectedConnexion = _selectedConnexion;
			}
			equipment.draw();
			
			_collection.createConnection(switchView, equipment, ModesDeConnexion.ETHERNET);
			
			if(equipment == _eqView) equipment.showConnections();
		}
		
		/**
		 * Ajoute le switch à l'équipement cible si tous les ports sont pris
		 * 
		 * @param connectEqView Savoir si on doit brancher l'équipement directement au switch ou pas; il peut s'agir d'un décodeur qu'on branche 
		 * en direct ou via liveplug ou wifiduo; comme _fullPortEq est a nouveau plein puisqu'on lui a mis un switch, on doit virer un autre 
		 * equipement qui n'est pas un decodeur et le brancher au switch .
		 */
		protected function _addSwitchToFullPortEq(connectEqView:Boolean=true):SwitchView
		{
			trace("_addSwitchToFullPortEq", connectEqView, _fullPortEq);
			if (!_fullPortEq) return null;
			
			//le provider _fullPortEq a tous ses ports pleins, on ajoute un switch
			//mais pour cela on doit debrancher un élément de _fullPortEq qu'on rebranchera au switch
			var equipment:EquipementView = _collection.getRemovableEquipment(_fullPortEq);
			trace("_addSwitchToFullPortEq() getRemovableEquipment:", equipment);
			if (!equipment) return null;
			
			equipment.connection.remove(false, false);
			
			// ajout du switch et on connecte le switch à _fullPortEq
			var switchWiew:SwitchView = _addSwitchView();
			
			//on connecte l'équipement débranché au switch 
			_connectToSwitch(switchWiew, equipment);
			
			if(connectEqView)
			{
				//le parametre connectEqView est true, on branche direct l'équipement _eqView au switch
			//	if(_selectedConnexion  == ModesDeConnexion.ETHERNET) _connectToSwitch(switchWiew, _eqView);
				_connectToSwitch(switchWiew, _eqView);
			}
			else
			{
				//le parametre connectEqView est false, il peut s'agir  d'un décodeur qu'on branche en direct ou via liveplug ou wifiduo
				//comme _fullPortEq est a nouveau plein puisqu'on lui a mis un switch
				//on doit virer un autre equipement qui n'est pas un decodeur 
				//et le brancher au switch 
				if(_eqView.isDecodeur)
				{
					/*var anotherEquipement:EquipementView = _collection.getRemovableEquipment(_fullPortEq);
					if (!anotherEquipement)
					{
						trace("ATTENTION ne devrait pas avoir lieu  on devrait avoir encore un port avec un terminal débranchable");
						return switchWiew;
					}
					anotherEquipement.connection.remove(false);
					_connectToSwitch(switchWiew, anotherEquipement);*/
				}
				else
				{
					//autre cas par ex on connecte eqview à un liveplug sur un switch
					// on ne veut juste ne pas connecter eqview au switch
					
					// FJ: EN FAIT Si dans un cas, on veut connecter une connexion "ethernet-liveplug"(-existant) ce qui veut dire switch, ce
					// qui veut dire que la connexion sera en ethernet sur switch et non pas ethernet-liveplug sur switch
					//trace("pas de l'ethernet ni du wifi, et pas un decodeur", _eqView.selectedConnexion);
					//_eqView.selectedConnexion = ModesDeConnexion.ETHERNET;
					if(_eqView.selectedConnexion == ModesDeConnexion.LIVEPLUG) _connectToSwitch(switchWiew, _eqView);
					if(_eqView.selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET) _connectToSwitch(switchWiew, _eqView);
					if(_eqView.selectedConnexion == ModesDeConnexion.DUO_ETHERNET) _connectToSwitch(switchWiew, _eqView);
				}
				//maintenant _fullPortEq a un port vide le decodeur va se brancher dessus, en direct ou via liveplug ou wifiduo
			}
			return switchWiew;
		}
		
		/**
		 * Méthode qui ajoute la vue du Switch
		 * 
		 * @return Renvoie le SwitchView nouvellement créé
		 */
		protected function _addSwitchView():SwitchView
		{
			if(!_fullPortEq) return null;
			var vo:EquipementVO = _appmodel.getVOFromXML("Switch");
			var switchWiew:SwitchView = new SwitchView(vo);
			switchWiew.draw();
			new AddEquipementCommand(_fullPortEq.parentBloc, switchWiew, null, null, false).run();
			switchWiew.x = _fullPortEq.x - 20 - Math.random()*20;
			switchWiew.y = _fullPortEq.y - Math.random() * 20;
			_collection.createConnection(_fullPortEq, switchWiew, ModesDeConnexion.ETHERNET, _fullPortEq.provider);
			return switchWiew;			
		}
		
		/**
		 * Méthode qui génère le process de connexion des équipements et la mise à jour du menu de l'équipement
		 * 
		 * @param e Le clic sur le bouton valider la connexion
		 */
		protected function _valider(e:MouseEvent):void 
		{
			trace("_valider", _selectedConnexion,  _nbSwitchSlots, _fullPortEq);
			
			if (_selectedConnexion == null) return;
			if(_eqView.selectedConnexion == _selectedConnexion && !_eqView.connection.needsToBeChecked) return;
			
			if(_eqView.connection) _eqView.connection.remove();
			_eqView.setConnexion(_selectedConnexion);
			
			_closeActions();
			
			trace("\t_fullPortEq", _fullPortEq);
			if(_fullPortEq != null)
			{
				//l'équipement sur lequel on connecte l'objet 
				var switchView:SwitchView = _fullPortEq.switchAsChild as SwitchView;
				
				if(switchView)
				{
					var equipement:EquipementView;
					trace("\tswitch déja présent")
					trace("\t_eqView " + _eqView);
					if(_eqView.isDecodeur) // + les 2 liveplug qui connectent un decodeur 
					{
						//si l'équipement à brancher est un decodeur on libère un port de _fullPortEq (livebox ou libeplug) 
						//d'un équipement qu'on peut retirer (qui ne fournit pas de connexion à un autre decodeur)
						//on branche cet équipement au switch
						//on a un port libre, on peut continuer, le décodeur va se brancher 
						equipement = _collection.getRemovableEquipment(_fullPortEq);
						if(equipement) 
						{
							equipement.connection.remove(false);
							_connectToSwitch(switchView, equipement);
						}
						else
						{
							trace("\tpas d'eq // impossible tant que 2 decodeurs uniquement") 
						}
						//on continue ...  ça devrait brancher le decodeur 
					}
					else
					{
						// s'il y a un master et qu'on veut ajouter un autre LPHD ou WFE, on n'a pas l'alerte switch
						/*if (_selectedConnexion == ModesDeConnexion.LIVEPLUG_NEW || _selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW) {
							if (EquipementsLayer.isThereALiveplugModuleDeBase()) return;
						}*/
									
						// FJ patch : on doit connecter l'equipement au switch
						// si le switch est sur module existant on doit connecter au switch en ethernet 
						// si le switch est sur la Livebox on doit connecter le module au switch
						
						// si c'est un module sur switch on doit connecter le module au switch, heu... est-ce clair ?
						// FJ comment: 21/06
						// if (_selectedConnexion == ModesDeConnexion.ETHERNET) 
						// FJ comment: 05/09/12 cette condition empeche l'ajout des équipements sur le switch (ca se connecte sur la LB pleine)
						// if(_fullPortEq.vo.type !== "LiveboxItem") 
						// on ne connecte au switch que si la connexion n'est (pas de type WIFIEXTENDER_WIFI_NEW ou WIFIEXTENDER_ETHERNET_NEW ou LIVEPLUG_NEW) et (avec LP master déjà présent)
						if (_selectedConnexion == ModesDeConnexion.ETHERNET)
						{
							_connectToSwitch(switchView, _eqView);
							return;
						} 
					}
				}
				else //pas de switch
				{
					trace("\tpas de switch présent")
					// nous devons déconnecter un des équipements déjà connectés de la livebox
					// 3 actions:
					// 1- débrancher un équipement qui ne soit pas (un décodeur ou qui mene à un décodeur)
					// 2- brancher le décodeur à la place
					// 3- rebrancher l'équipement déconnecté en 1 sur le switch
					if(_eqView.isDecodeur) 
					{
						trace("c'est un décodeur");
						//on libere un port pour y poser le switch 
						equipement = _collection.getRemovableEquipment(_fullPortEq);
						trace("\tgetRemovableEquipement", equipement);
						if(equipement) 
						{
							equipement.connection.remove(false);
						}
						else
						{
							trace("\tpas d'eq // impossible tant que 2 decodeurs uniquement") 
						}
						
						//le parametre est a false, on a libéré un port de plus dans _fullPortEq
						switchView = _addSwitchToFullPortEq(false);//_addSwitchView();
						_connectToSwitch(switchView, equipement);
						//on continue ...  ça devrait brancher le decodeur 
						
					}
					else
					{
						trace("\tce n'est pas un décodeur " +_selectedConnexion + " " +  ModesDeConnexion.ETHERNET);
						//on ne connecte l'equipement que s'il est branche direct
						//
						var connectEqView:Boolean = (_selectedConnexion == ModesDeConnexion.ETHERNET);
						_addSwitchToFullPortEq(connectEqView);
						//le return  et le paramètre  connectEqView = true pour les cas ou on branche l'ordi en direct sur le switch
						//mais aussi les cas ou on branche un second equipement sur un liveplug existant? 
						//dans ce cas on aurait déjà créé la connexion d'un equipement au liveplug existant et on veut juste brancher cet equipement au switch créé sur le liveplug
						//le trick de mettre _selectedConnexion = ModesDeConnexion.ETHERNET ligne 835 et 836 dans connectToSwitch servirai bien à cela
						if(_selectedConnexion == ModesDeConnexion.ETHERNET) return;
					}
					
					// vérifier si tous les ports sont pris et débrancher 2 equipements
					// puis poser le switch, 
					// connecter le décodeur
					// connecter les 2 equipements débranchés
					
				}
			}
			
			if (_selectedConnexion == ModesDeConnexion.LIVEPLUG_NEW || _selectedConnexion == ModesDeConnexion.LIVEPLUG) {
				_addLiveplugs();
			} else if (_selectedConnexion == ModesDeConnexion.WIFIEXTENDER_WIFI || _selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET || _selectedConnexion == ModesDeConnexion.WIFIEXTENDER_WIFI_NEW || _selectedConnexion == ModesDeConnexion.WIFIEXTENDER_ETHERNET_NEW) {
				_addWifis();
			} else if (_selectedConnexion == ModesDeConnexion.DUO_ETHERNET || _selectedConnexion == ModesDeConnexion.DUO_WIFI) {
				if (EquipementsLayer.isLiveboxPlay()) {
					_addSolo();
				} else {
					_addDuos();
				}
			} else {
				//var bestWifiChoice:BestWifiChoice = getBestWifiChoice(_eqView);
				_collection.createConnection(EquipementsLayer.getLivebox()/*bestWifiChoice.equipement*/, _eqView, _selectedConnexion);
			}
			_eqView.showConnections();
			
			MenuFactory.createMenu(_eqView, EditorContainer.instance);
			_appmodel.notifySaveStateUpdate(true);
		}
		
		/** 
		 * Méthode qui renvoie l'équipement d'un tableau d'équipements qui est le plus proche de la Livebox.
		 * 
		 * @param arr Un tableau d'équipements 
		 * 
		 * @return renvoie l'équipementView le plus proche de la Livebox parmi la liste fournie en paramètre
		 */
		protected function getClosestEquipement(arr:Array):EquipementView
		{
			var values:Array = [];
			for (var i:int = 0; i < arr.length; i++)
			{
				var eq:EquipementView = arr[i] as EquipementView;
				values.push({"distance":_eqView.getDistance(eq), "equipement":eq});
			}
			values.sortOn("distance");
			return (values.length > 0) ? values[0].equipement : null;
		}
		
		protected function _onResize(e:Event = null):void
		{
			x = MenuContainer.instance.x - WIDTH//Background.instance.masq.width / 2 - width / 2;
			y = 109;
		}
		
		protected function _remove(e:Event):void
		{
			//trace("AlertConnection::_remove");
			_appmodel.notifyConnectPopupClose();
			if(stage) stage.removeEventListener(Event.RESIZE, _onResize);
			_btnCancel.removeEventListener(MouseEvent.CLICK, _cancel);
			removeEventListener(Event.REMOVED_FROM_STAGE, _remove);
		}
	}

}