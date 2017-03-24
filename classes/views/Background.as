package classes.views 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	import classes.vo.MaskSizeVO;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	/**
	 * Responsable du chargement et de l'affichage de l'image de fond
	 * Cette classe écoute le resize de la page
	 * 
	 */
	public class Background extends Sprite 
	{
		/**
		 * Le masque d'image de fond avec bords arrondis
		 */
		public var masq:Sprite;
		/**
		 * le container de l'image de fond loadé
		 */
		private var imageContainer:Sprite;
		private var imageWidth:int;
		private var imageHeight:int;
		private var model:ApplicationModel = ApplicationModel.instance;
		
		private static var _self:Background;
		public static function get instance():Background
		{
			return _self;
		}
		
		public function Background() 
		{
			if (_self) return
			_self = this;
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			masq = new Sprite();
			imageContainer = new Sprite();
			addChild(imageContainer);
			addChild(masq);
			_loadImage();
		}
		
		private function _loadImage():void
		{
			var url:Loader = new Loader();
			url.contentLoaderInfo.addEventListener(Event.COMPLETE, _onComplete);
			url.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onError);
			url.load(new URLRequest("images/fond2.jpg?rev="+Main.VERSION));
		}
		
		private function _onError(e:IOErrorEvent):void
		{
			//trace("Background error");
			AppUtils.TRACE("Background error");
		}
		
		private function _onComplete(e:Event):void
		{
			var url:LoaderInfo = LoaderInfo(e.currentTarget);
			url.removeEventListener(Event.COMPLETE, _onComplete);
			
			imageContainer.addChild(e.target.content);
			imageWidth = e.target.content.width;
			imageHeight = e.target.content.height;
			//center image
			imageContainer.x = (Config.FLASH_WIDTH - imageWidth) / 2;
			imageContainer.y = (Config.FLASH_HEIGHT - imageHeight) / 2;
			imageContainer.alpha = 0;
			
			//TweenLite.to(imageContainer, .1, { alpha:1 } );
			new Tween(imageContainer, "alpha", Regular.easeOut, 0, 1, .1, true);
			
			//_update(Config.MASK_BG_WIDTH_MIN, Config.MASK_BG_HEIGHT_MIN);
			
			Main.instance.addHeader();
			stage.dispatchEvent(new Event(Event.RESIZE));
		}
		
		public function update(w:int, h:int):void
		{
			_update(w , h);
		}
		
		private function _update(pwidth:int = NaN, pheight:int= NaN):void
		{
			// update mask size and pos
			imageContainer.mask = null;
			
			var g:Graphics = masq.graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0);
			
			var maskSizevo:MaskSizeVO = new MaskSizeVO();
			maskSizevo.width = pwidth;
			maskSizevo.height = pheight;
			model.maskSize = maskSizevo;
			
			//g.drawRoundRect(5, 39, model.maskSize.width, model.maskSize.height, 15, 15);
			g.drawRoundRect(0, 0, model.maskSize.width, model.maskSize.height, 15, 15);
			//trace("Background::_update " + pwidth +" "+ pheight+" "+model.maskSize.width+" " +model.maskSize.height);
			g.endFill();
			
			imageContainer.mask = masq;
			
			// update image pos
			imageContainer.x = -(imageContainer.width - model.maskSize.width) / 2;
			imageContainer.y = -(imageContainer.height - model.maskSize.height) / 2;
		}
	}
}