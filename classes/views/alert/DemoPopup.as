package classes.views.alert
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.Background;
	import classes.views.Btn;
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	
	/**
	 * La classe DemoPopup ouvre un player video en popup avec une ou plusieurs videos en lien sur le côté gauche
	 * 
	 */
	public class DemoPopup extends Sprite
	{
		protected var _btnFermer:BoutonFermerMenus;
		protected var _videosArray:Array;
		
		private var _flvpb:FLVPlayback;
		private var _current:int;
		
		/**
		 * Permet d'instancier un plyer video de type FLVPlayback
		 * 
		 * @param	src La ou les sources videos à jouer
		 * @param	pWidth La largeur du player FLVPlayback
		 * @param	pHeight La hauteur du player FLVPlayback
		 */
		public function DemoPopup(src:Array = null, from:String="",  pWidth:int = 900, pHeight:int = 600)
		{
			//trace("DemoPopup")
			if(src == null) {
				_flvpb = new FLVPlayback();
				_current = 0;
				if (from == "home") _videosArray = new Array( { src:AppLabels.getString("common_videoHome"), label:"" } ) 
				else if (from == "aide") _videosArray = new Array( { src:AppLabels.getString("common_videoHelp"), label:"" } );
				//_videosArray = (src == null) ? new Array({src:AppLabels.getString("common_videoAide"), label:""}) : src;
				_flvpb.source = _videosArray[_current].src;
				//trace(_flvpb.source)
				_flvpb.autoPlay = true;
				_flvpb.scaleMode = "maintainAspectRatio";
				_flvpb.skin = "SkinUnderPlaySeekFullscreen.swf";
				_flvpb.skinBackgroundAlpha = 0.85//1;
				_flvpb.skinBackgroundColor = 0x666666//Config.COLOR_LIGHT_GREY;
				_flvpb.width = pWidth;
				_flvpb.height = pHeight;
				addChild(_flvpb);
				_flvpb.addEventListener(VideoEvent.READY, _addBtnFermer);
				if (_flvpb.source != AppLabels.getString("common_videoHelp") && _flvpb.source != AppLabels.getString("common_videoHome")) {
					_flvpb.addEventListener(VideoEvent.COMPLETE, _donePlaying);
				}
				addEventListener(Event.ADDED_TO_STAGE, _added);
			}
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			stage.addEventListener(Event.RESIZE, _onResize);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, _onFullscreen);
			
			if (_videosArray[_current].label != "") {
				_addLabels();
			}
			//_onResize();
		}
		
		protected function _addLabels():void
		{
			for (var k:int = 0; k < _videosArray.length; k++) {
				//trace(_videosArray[k].label);
				var cColor:int = (k == _current) ? -1 : 0;
				var b:Btn = new Btn( cColor, _videosArray[k].label, null, 110, 0xffffff, 12, 24);
				addChild(b);
				b.x = _flvpb.width + 15
				b.y = 20 + k * (24  + 12);
				b.name = k.toString();
				b.addEventListener(MouseEvent.CLICK, _playVideo, false, 0, true);
			}
		}
		
		protected function _playVideo(e:MouseEvent):void
		{
			Btn(getChildAt(_current + 1)).changeColor( 0 );
			_current = parseInt(e.target.name);
			_flvpb.source = _videosArray[_current].src;
			_flvpb.seek(0);
			Btn(getChildAt(_current + 1)).changeColor( -1 );
		}
		
		private function _donePlaying(e:VideoEvent):void
		{
			Btn(getChildAt(_current + 1)).changeColor( 0 );
			if (_current + 1 > _videosArray.length -1) {
				_flvpb.removeEventListener(VideoEvent.COMPLETE, _donePlaying);
				_current = 0
			} else {
				_current++;
			}
			_flvpb.source = _getNextVideo();
			_flvpb.seek(0);
			Btn(getChildAt(_current + 1)).changeColor( -1 );
		}
		
		private function _getNextVideo():String
		{
			return _videosArray[_current].src;
		}
		
		protected function _addBtnFermer(e:VideoEvent=null):void
		{
			_btnFermer = new BoutonFermerMenus();
			addChild(_btnFermer);
			_btnFermer.buttonMode = true;
			_btnFermer.addEventListener(MouseEvent.CLICK, _fermer);
			//_btnFermer.x = _flvpb.width - _btnFermer.width / 2;
			//_btnFermer.y = _flvpb.y - _btnFermer.height / 2;
			_onResize();
		}
		
		private function _removed(e:Event):void
		{
			SoundMixer.stopAll();
			_flvpb.stop();
			_flvpb.removeEventListener(VideoEvent.COMPLETE, _donePlaying);
			_btnFermer.removeEventListener(MouseEvent.CLICK, _fermer);
			stage.removeEventListener(Event.RESIZE, _onResize);
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, _onFullscreen);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		private function _onFullscreen(e:FullScreenEvent):void
		{
			if (e.fullScreen) {
				AppUtils.TRACE("enter fullScreen"+_flvpb.height+" "+_flvpb.width)
			} else {
				AppUtils.TRACE("leave fullScreen"+_flvpb.height+" "+_flvpb.width)
				_onResize();
			}
		}
		
		protected function _onResize(e:Event = null):void
		{
			x = Background.instance.masq.width / 2 - 900/*_flvpb.width*/ / 2;
			y = (Background.instance.masq.height / 2) - 506/*_flvpb.height*/ / 2 -39;
			AppUtils.TRACE("DemoPopup::_onResize() "+ y+" "+ _flvpb.height+ " "+ Background.instance.masq.height);
			if (_btnFermer && _btnFermer.stage) {
				_btnFermer.x = /*_flvpb.width*/900 - _btnFermer.width / 2;
				_btnFermer.y = 42//_flvpb.y - _btnFermer.height / 2;
				AppUtils.TRACE("_onResize "+ y +" "+ _btnFermer.y +" "+ _flvpb.y);
			}
		}
		
		protected function _fermer(e:MouseEvent):void
		{
			if (_flvpb) {
				_flvpb.stop();
				_flvpb.removeEventListener(VideoEvent.READY, _addBtnFermer);
				_flvpb.removeEventListener(VideoEvent.COMPLETE, _donePlaying);
			}
			_btnFermer.removeEventListener(MouseEvent.CLICK, _fermer);
			stage.removeEventListener(Event.RESIZE, _onResize);
			stage.removeEventListener(FullScreenEvent.FULL_SCREEN, _onFullscreen);
			
			AlertManager.removePopup();
		}
	
	}

}