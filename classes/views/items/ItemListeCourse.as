package classes.views.items 
{
	import classes.config.Config;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.Info360;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.EquipementsLayer;
	import classes.views.tooltip.Tooltip;
	import classes.vo.EquipementVO;
	import com.warmforestflash.drawing.DottedLine;
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * La classe ItemListeCourse affiche les articles qui sont dans la liste de courses du projet.
	 */
	public class ItemListeCourse extends Sprite 
	{
		public var vo:EquipementVO;
		public var nombre:int = 1;
		public var ordre:int;
		public var label:String;
		private var _t:CommonTextField;
		private var _t2:CommonTextField;
		private var _tooltip:Tooltip;
		
		/**
		 * Crée un article d'un équipement présent dans la liste de course.
		 * 
		 * <p>Un article est dans la liste de course s'il est éligible à l'achat (info correspondant au paramètre 
		 * <code>isOrange</code> dans all.xml et si l'utilisateur a déclaré ne pas le posséder.</p>
		 * 
		 * @param	vo L'équipementVO de l'article
		 * @param	order L'ordre d'affichage de cet article dans la liste
		 */
		public function ItemListeCourse(vo:EquipementVO, order:int) 
		{
			ordre = order;
			this.vo = vo;
			_render();
		}
		
		override public function toString():String
		{
			return label +" / "+nombre
		}
		
		private function _render():void
		{
			// draw circle
			// load image
			draw();
			loadImage();
			
			// add text
			_t = new CommonTextField("helvet", 0x333333, 14 );
			_t.autoSize = "left";
			_t.width = 180;
			addChild(_t);
			
			_renderHowMany();
			renderText();
			addDots(100);
			_addLink();
		}	
		
		public function renderText():void
		{
			//TODO: histoire de Kits, de cables et de switchs
			if (vo.type == "LivePlugItem") {
				label = AppLabels.getString("check_liveplugHD")//(" + String(nombre) + ")";
			} else if (vo.type === "WifiExtenderItem") {
				/*label = "Wi-Fi Extender solo (" + nombre + ")";*/
				if(nombre > 1) label = AppLabels.getString("check_kitWFE")+" +"+ String(nombre-1) + AppLabels.getString("check_wfe");
				else label = AppLabels.getString("check_kitWFE")// (1)";
				/*}*/
			} else if (vo.type == "WifiDuoItem") {
				if (EquipementsLayer.isLiveboxPlay()) {
					label = AppLabels.getString("check_LPWFSolo")// (1)";
				} else {
					label = AppLabels.getString("check_kitLPWF");
				}
				nombre = 1; 
			} else if (vo.type == "WireItem") {
				label = AppLabels.getString("check_ethernetWire")// (1)";
				nombre = 0;
			} else {
				label = vo.screenLabel //+" (" + nombre + ")";
			}
			_t.setText(label);
			_t.y = 74;
			var tf:TextFormat = _t.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			_t.setTextFormat(tf);
			
			if (nombre <= 0 || vo.type == "WireItem") return;
			
			var str:String = nombre + " " +AppLabels.getString("accordion_ex");
			if (nombre > 1) {
				str = nombre + " " +AppLabels.getString("accordion_exs");
			}
			_t2.setText( str );
			tf = _t2.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			_t2.setTextFormat(tf);
		}
		
		private function _renderHowMany():void
		{
			if (nombre <= 0 || vo.type == "WireItem") return;
			
			// nombre d'exemplaires
			_t2 = new CommonTextField("helvet", 0);
			_t2.width = 180
			var str:String = nombre + " " +AppLabels.getString("accordion_ex");
			if (nombre > 1) {
				str = nombre + " " +AppLabels.getString("accordion_exs");
			}
			_t2.setText( str );
			var tf:TextFormat = _t2.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			_t2.setTextFormat(tf);
			addChild(_t2);
			_t2.y = 104;
		}
		
		private function _addLink():void
		{
			//AppUtils.TRACE(vo.name + " " + vo.linkArticleShop.toString());
			if (vo.linkArticleShop != "null") {
				var btnLink:Btn = new Btn(-1, AppLabels.getString("buttons_buyOnLine"), PictoCaddie, 116, Config.COLOR_ORANGE, 11, 20);
				btnLink.icon.scaleX = .31;
				btnLink.icon.scaleY = .31;
				AppUtils.changeColor(Config.COLOR_ORANGE, btnLink.icon);
				addChild(btnLink);
				btnLink.y = 122;
				//btnLink.x = (183 - btnLink.width) / 2
				function moveX(e:Event):void {
					//trace("moveX", btnLink, btnLink.width);
					btnLink.x = (183 - btnLink.width) / 2
					btnLink.icon.x += 3;
					btnLink.icon.y += 1;
				}
				btnLink.alterAfter(moveX);
				//btnLink.addEventListener(MouseEvent.ROLL_OVER, _soon, false, 0, true);
				//btnLink.addEventListener(MouseEvent.ROLL_OUT, _out, false, 0, true);
				btnLink.addEventListener(MouseEvent.CLICK, _openLink, false, 0, true);
			}
			
			//trace(vo.diaporama360);
			if(vo.diaporama360 != null && vo.diaporama360 != "null") {
				var btnI:IconInfo = new IconInfo();
				addChild(btnI);
				btnI.addEventListener(MouseEvent.CLICK, _info, false, 0, true);
				btnI.buttonMode = true;
				btnI.mouseChildren = false;
				btnI.x = 173;
				btnI.y = 76;
				btnI.name = vo.diaporama360;
				AppUtils.changeColor(Config.COLOR_YELLOW, btnI.getChildAt(0));
			} else if (vo.type == "WireItem") {
				btnI = new IconInfo();
				addChild(btnI);
				btnI.addEventListener(MouseEvent.ROLL_OVER, _rollWire, false, 0, true);
				btnI.addEventListener(MouseEvent.ROLL_OUT, _out, false, 0, true);
				btnI.buttonMode = true;
				btnI.mouseChildren = false;
				btnI.x = 173;
				btnI.y = 76;
				AppUtils.changeColor(Config.COLOR_YELLOW, btnI.getChildAt(0));
			}
		}
		
		private function _rollWire(e:MouseEvent):void
		{
			_tooltip = new Tooltip(Main.instance, AppLabels.getString("check_alertWireLength"));
			Main.instance.addChild(_tooltip);
		}
		
		private function _info(e:MouseEvent):void
		{
			//trace("_info", e.target.name);
			var diapo:String = e.target.name;
			var popup:Info360 = new Info360(diapo);
			AlertManager.addSecondPopup(popup, Main.instance);
		}
		
		private function _soon(e:MouseEvent):void
		{
			_tooltip = new Tooltip(Main.instance, AppLabels.getString("accordion_soon"));
			Main.instance.addChild(_tooltip);
		}
		
		private function _out(e:MouseEvent):void
		{
			if (_tooltip && _tooltip.stage) _tooltip.remove();
		}
		
		private function _openLink(e:MouseEvent):void
		{
			//AppUtils.TRACE("_openLink() "+vo.linkArticleShop);
			navigateToURL(new URLRequest(vo.linkArticleShop), "_blank");
		}
		
		private function addDots(posy:int):void
		{
			var s:DottedLine = new DottedLine(180, 1, Config.COLOR_DARK, 1, 1.3, 2);
			addChild(s);
			s.x = 2;
			s.y = posy;
		}
		
		public function getLabel():String
		{
			return label;
		}
		
		public function draw(color:int = 0):void
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, 0xcccccc);
			g.beginFill(0xffffff);
			g.drawRoundRect(0, 0, 183, 144, 10);
		}
		
		private function loadImage():void
		{
			var loadr:Loader = new Loader();
			loadr.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImageComplete);
			if (vo.type === "WifiExtenderItem") {
				loadr.load(new URLRequest("images/kitWiFiExt.png"));
			} else if (vo.type === "WifiDuoItem") {
				var duo:MovieClip;
				if (EquipementsLayer.isLiveboxPlay()) {
					duo =  new WifiSolo();
				} else {
					duo =  new WifiDuo();
				}
				addChild(duo);
				duo.scaleX = duo.scaleY = .65;
				duo.x = 30
				duo.y = 10
				if (EquipementsLayer.isLiveboxPlay()) {
					duo.x = 50;
				}
			} else {
				loadr.load(new URLRequest(vo.imagePath));
			}
		}
		
		private function _onImageComplete(e:Event):void
		{
			var lodr:LoaderInfo = e.target as LoaderInfo;
			lodr.removeEventListener(Event.COMPLETE, _onImageComplete);
			
			var bitmap:Bitmap = lodr.content as Bitmap;
			bitmap.smoothing = true;
			var xscale:Number = 80/bitmap.width;
			var yscale:Number = 80/bitmap.height;
			if (vo.type === "LivePlugItem") {
				xscale = 40/bitmap.width;
				yscale = 55/bitmap.height;
			} else if (vo.type === "OrdinateurItem") {
				xscale = 85/bitmap.width;
				yscale = 70/bitmap.height;
			} else if (vo.type === "WireItem") {
				xscale = 95/bitmap.width;
				yscale = 50/bitmap.height;
			}
			bitmap.scaleX = xscale;
			bitmap.scaleY = yscale;
			addChild(bitmap);
			bitmap.x = 183 / 2 - bitmap.width / 2;
			bitmap.y = 85 / 2 - bitmap.height / 2;
			
		}
	}

}