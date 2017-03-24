package classes.views.items 
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.Info360;
	import classes.views.alert.VideosPopup;
	import classes.views.Background;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.vo.VideoVO;
	import com.warmforestflash.drawing.DottedLine;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * La classe EquipementInstalled affiche dans la synthèse les données d'un équipement installé dans le plan.
	 */
	public class EquipmentInstalled extends Sprite 
	{
		public var uniqueId:String;
		public var image:String;
		public var type:String;
		public var label:String;
		public var linkInfo:String;
		public var connection:String;
		public var videosArr:Array;/*array of videoVO*/
		private var _filteredVideosArr:Array;
		public var connectionAcceptable:String;
		public var isOwned:String;/*String "true" ou "false"*/
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		/**
		 * La création d'un EquipmentInstalled se fait par un new EquipementInstalled() suivi de la récupération de ses données 
		 * EquipementVO réaffectées suivi d'un render() qui permet l'affichage de l'élément.
		 */
		public function EquipmentInstalled() 
		{
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
		}
		
		/**
		 * Permet de dessiner et d'afficher l'équipement installé.
		 */
		public function render():void
		{
			draw();
			addLabel();
			loadImage();
			addDots(100);
			addConnection();
			addDots(175);
			addPossession();
			addDots(258);
			_addVideoBtn();
		}
		
		/**
		 * dessine la forme du fond du bloc, le fond est transparent, le contour est gris.
		 * 
		 * @param	color la couleur de fond, 0 par défaut et transparent
		 */
		public function draw(color:int = 0):void
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, 0xcccccc);
			g.beginFill(0xffffff, 0);
			g.drawRoundRect(0, 0, 183, 295, 10);
			g.endFill();
		}
		
		private function addDots(posy:int):void
		{
			var s:DottedLine = new DottedLine(180, 1, Config.COLOR_DARK, 1, 1.3, 2);
			addChild(s);
			s.x = 2;
			s.y = posy;
		}
		
		private function addLabel():void
		{
			var _t:CommonTextField = new CommonTextField("helvet", 0, 14 );
			_t.autoSize = "left";
			_t.width = 180;
			addChild(_t);
			_t.y = 74;
			_t.setText(label);
			var tf:TextFormat = _t.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			_t.setTextFormat(tf);
			
			if(linkInfo != "null") {
				var btnI:IconInfo = new IconInfo();
				addChild(btnI);
				btnI.addEventListener(MouseEvent.CLICK, _info, false, 0, true);
				btnI.buttonMode = true;
				btnI.mouseChildren = false;
				btnI.x = 173;
				btnI.y = 76;
				btnI.name = linkInfo;
				AppUtils.changeColor(Config.COLOR_YELLOW, btnI.getChildAt(0));
			}
		}
		
		private function _info(e:MouseEvent):void
		{
			//trace("_info", e.target.name);
			var diapo:String = e.target.name;
			var popup:Info360 = new Info360(diapo);
			AlertManager.addSecondPopup(popup, Main.instance);
		}
		
		private function addConnection():void
		{
			if (type == "LiveboxItem") return;
			
			var t:CommonTextField;
			var col:Number;
			if (connection == "null") {
				col = Config.COLOR_ORANGE;
			} else {
				col = Config.COLOR_DARK;
			}
			t = new CommonTextField("helvetBold", col);
			t.width = 181;
			//trace("connection,", connection);
			if (connection == "null") {
				t.setText(AppLabels.getString("connections_notConnected"));
			} else {
				if(type === "LivephoneItem" || type === "TelephoneItem")  t.setText(AppLabels.getString("editor_plugged"));
				else t.setText(AppLabels.getString("connections_connected"));
				
				// connecté en quoi ?
				if(ModesDeConnexion.getConnexionLabel(connection) != null) {
					//trace(label, connection);
					var tConn:CommonTextField = new CommonTextField("helvet", 0);
					addChild(tConn);
					tConn.width = 180;
					tConn.setText(AppLabels.getString("connections_as") + ModesDeConnexion.getConnexionLabel(connection));
					var tf:TextFormat = tConn.cloneFormat();
					tf.align = "center";
					tConn.setTextFormat(tf);
					tConn.y = 136;
					
					// btn info
					//TODO
				}
			}
			tf = t.cloneFormat();
			tf.align = "center";
			t.setTextFormat(tf);
			addChild(t);
			t.y = 111;
			
			if (connection == "null") return;
			
			// ajouter la pastille icon de connexion verte ou orange
			var _connexionIcon:MovieClip;
			if(connection == ModesDeConnexion.WIFI || connection == ModesDeConnexion.WIFIEXTENDER_WIFI) {
				_connexionIcon = new BulleWifi();
				addChild(_connexionIcon);
			} else /*if(connection == ModesDeConnexion.ETHERNET)*/ {
				_connexionIcon = new BulleEthernet();
				addChild(_connexionIcon);
			}
			if (_connexionIcon && _connexionIcon.stage) {
				_connexionIcon.y = 112;
				_connexionIcon.x = 130;
				var g:Graphics = _connexionIcon.graphics;
				g.clear();
				g.lineStyle();
				if(connectionAcceptable !== "true")
					g.beginFill(Config.COLOR_GREEN_CONNECT_LINE);
				else 
					g.beginFill(Config.COLOR_ORANGE_CONNECT_LINE);
				g.drawCircle(9, 9, 9);
			}
		}
		
		private function _addVideoBtn():void
		{
			// si equipement pas connecté on ne propose pas de video de branchement (sauf pour la Livebox)
			if (connection == "null" && type != "LiveboxItem") return;
			
			//si pas de videos
			if (videosArr.length == 0) return;
			
			// on vérifie la Livebox à part car elle n'a pas de filtre de connection pour ses videos (b)
			// On considère dans le code qu'elle n'a pas de connexion: 
			// les autres se branchent sur elle, mais elle ne se branche sur rien
			if (type != "LiveboxItem") 
			{
				_filteredVideosArr = videosArr.filter(_filterVideos);
			} else {
				_filteredVideosArr = videosArr.filter(_filterVideosByInstallType);
			}
			
			// si pas de videos correspondant à l'install et à la connexion, on n'affiche pas le bouton video
			if (_filteredVideosArr.length == 0) return;
			
			//
			var b:Btn = new Btn(0, AppLabels.getString("buttons_videoConnection"), null, 1, 0xffffff, 12, 24, Btn.GRADIENT_DARK);
			addChild(b);
			b.addEventListener(MouseEvent.CLICK, _showVideo, false, 0, true);
			b.x = 5
			b.y = 265
		}
		
		/**
		 * Vérifie que la video de branchement est compatible avec le type de projet et la connexion choisie
		 * 
		 * @param	element Chaque élément VideoVO du tableau
		 * @param	index L'index de l'élément en question
		 * @param	arr Le tableau de videos dont on souhaite vérifier la compatibilité
		 * @return Renvoie true si l'élément est comptaible, false autrement.
		 */
		private function _filterVideos(element:VideoVO, index:int, arr:Array):Boolean 
		{
			trace("_filterVideos", element.install, element.b, _appmodel.projectType, connection, String(element.install).indexOf(_appmodel.projectType + ",") , String(element.b).indexOf(connection + ",") )
			var tmp:Array = element.b.split(",");
			var compatConnection:Array = tmp.filter(_filterConnection);
			trace("compatConnection", compatConnection.length);
			return compatConnection.length != 0;
			//return (String(element.install).indexOf(_appmodel.projectType + ",") != -1 && String(element.b).indexOf(connection + ",") != -1);// (element.install == _appmodel.projectType);
		}
		
		private function _filterConnection(element:String, index:int, arr:Array):Boolean 
		{
			return (element === connection);
		}
		
		/**
		 * Vérifie que la video de branchement est compatible avec le type de projet et la connexion choisie
		 * 
		 * @param	element Chaque élément VideoVO du tableau
		 * @param	index L'index de l'élément en question
		 * @param	arr Le tableau de videos dont on souhaite vérifier la compatibilité
		 * @return Renvoie true si l'élément est comptaible, false autrement.
		 */
		private function _filterVideosByInstallType(element:VideoVO, index:int, arr:Array):Boolean 
		{
			trace("_filterVideosByInstallType ", element.install, _appmodel.projectType, connection, String(element.install).indexOf(_appmodel.projectType + ",") )
			return (String(element.install).indexOf(_appmodel.projectType + ",") != -1);
		}
		
		private function _showVideo(e:MouseEvent):void
		{
			var popup:VideosPopup = new VideosPopup(_filteredVideosArr, label, connection);
			AlertManager.addPopup(popup, Main.instance);
			popup.x = Background.instance.masq.width/2 - 905/2;
			popup.y = Background.instance.masq.height/2 - 460/2;
		}
		
		private function addPossession():void
		{
			//trace(label, isOwned)
			var t:CommonTextField = new CommonTextField("helvet", 0);
			t.width = 181;
			t.setText(AppLabels.getString("alert_askOwnership"));
			var tf:TextFormat = t.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			t.setTextFormat(tf);
			tf.font = (new Helvet55Bold() as Font).fontName;
			tf.bold = true;
			t.setTextFormat(tf, 0, 13);
			t.y = 185
			addChild(t);
			
			// boutons radio
			var group:RadioButtonGroup = new RadioButtonGroup("possess");
			group.addEventListener(MouseEvent.CLICK, _clickHandler);
			
			var ypos:int = t.y + t.textHeight + 15;
			var xpos:int = 30;
			
			var rb1:RadioButton = new RadioButton();
			rb1.label = AppLabels.getString("buttons_yes");
			rb1.value = "true";
			rb1.setStyle("embedFonts", true);
			rb1.setStyle("bold", true);
			rb1.setStyle("textFormat", tf);
			rb1.setSize(60,19);
			addChild(rb1);
			rb1.x = xpos;
			rb1.y = ypos;
			rb1.group = group;
			_setAsButton(rb1);
			
			var rb2:RadioButton = new RadioButton();
			rb2.label = AppLabels.getString("buttons_no");
			rb2.value = "false";
			rb2.setStyle("embedFonts", true);
			rb2.setStyle("bold", true);
			rb2.setStyle("textFormat", tf);
			rb2.setSize(60,19);
			addChild(rb2);
			rb2.x = xpos + rb1.width + 5;
			rb2.y = ypos;
			rb2.group = group;
			_setAsButton(rb2);
			
			if (isOwned == "true") {
				rb1.selected = true;
				rb2.selected = false;
				return;
			}
			rb1.selected = false;
			rb2.selected = true;
		}
		
		private function _setAsButton(rb:RadioButton):void
		{
			//skin
			rb.setStyle("upIcon", RadioButtonSkinBase);
			rb.setStyle("overIcon", RadioButtonSkinBase);
			rb.setStyle("downIcon", RadioiButtonSkinDown);
			rb.setStyle("disabledIcon", RadioButtonSkinBase);
			rb.setStyle("selectedUpIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedOverIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedDownIcon", RadioButtonSkinSelected);
			rb.setStyle("selectedDisabledIcon", RadioButtonSkinSelected);
			rb.setStyle("focusRectSkin", new Sprite());
			
			//button stuff
			rb.buttonMode = true;
			rb.useHandCursor = true;
			rb.mouseChildren = false;
		}
		
		private function _clickHandler(e:MouseEvent):void
		{
			isOwned = (e.target.selection.value == "true") ? "true" : "false";
			//trace("isOwned ?", isOwned);_
			//trace(XMLList(appmodel.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.(@uniqueId.toString() === uniqueId)).toXMLString());
			XMLList(_appmodel.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.(@uniqueId.toString() === uniqueId)).@isOwned = isOwned;
			_appmodel.notifySaveStateUpdate(true);
			//trace(XMLList(^_appmodel.projetvo.xml_plan.floors.floor.blocs.bloc.equipements.equipement.(@uniqueId.toString() === uniqueId)).toXMLString());
		}
		
		private function loadImage():void
		{
			var loadr:Loader = new Loader();
			loadr.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImageComplete);
			loadr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onIOError);
			loadr.load(new URLRequest(image));
		}
		
		private function _onIOError(e:IOErrorEvent):void
		{
			//trace("IOError", e.text);
			var lodr:LoaderInfo = e.target as LoaderInfo;
			lodr.removeEventListener(Event.COMPLETE, _onImageComplete);
			lodr.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError);
		}
		
		private function _onImageComplete(e:Event):void
		{
			var lodr:LoaderInfo = e.target as LoaderInfo;
			lodr.removeEventListener(Event.COMPLETE, _onImageComplete);
			lodr.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError);
			
			var bitmap:Bitmap = lodr.content as Bitmap;
			bitmap.smoothing = true;
			var xscale:Number = 85/bitmap.width;
			var yscale:Number = 85/bitmap.height;
			if (type === "OrdinateurItem") {
				xscale = 85/bitmap.width;
				yscale = 70/bitmap.height;
			}
			bitmap.scaleX = xscale;
			bitmap.scaleY = yscale;
			addChild(bitmap);
			bitmap.x = 183/2 - bitmap.width/2;
			bitmap.y = 85 / 2 - bitmap.height / 2;
			if (type == "LiveboxItem") {
				bitmap.y += 8
			}
		}
	}

}