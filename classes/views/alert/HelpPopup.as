package classes.views.alert
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.Background;
	import classes.views.Btn;
	import fl.transitions.easing.Regular;
	import fl.transitions.easing.Strong;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	
	/**
	 * La classe HelpPopup ouvre le popup d'aide.
	 * 
	 * <p>3 aides sont possibles pour le FUT :
		 * <ul>
		 * 	<li>Aide sur l'accueil</li>
		 * 	<li>Aide sur la page de dessin</li>
		 * 	<li>Aide sur la page d'install</li>
		 * </ul>
		 * </p>
	 * 
	 */
	public class HelpPopup extends Sprite
	{
		private var _btnFermer:SimpleButton;
		private var _help:Aide;
		private var _tween:Tween;
		private var _am:ApplicationModel = ApplicationModel.instance;
		
		/**
		 * Permet d'instancier l'aide
		 * 
		 * @param	src La ou les sources videos à jouer
		 * @param	pWidth La largeur du player FLVPlayback
		 * @param	pHeight La hauteur du player FLVPlayback
		 */
		public function HelpPopup()
		{
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			_help = new Aide();
			if (_am.screen == ApplicationModel.SCREEN_HOME) {
				_help.gotoAndStop(ApplicationModel.SCREEN_HOME);
			} else if (_am.screen == ApplicationModel.SCREEN_EDITOR) {
				if (EditorModelLocator.instance.isDrawStep) _help.gotoAndStop("dessin");
				else _help.gotoAndStop("install");
			} else {
				_doClose();
			}
			addChild(_help);
			
			var targety:int = (Background.instance.masq.height == 0) ? 34 : (Background.instance.masq.height - height) / 2;
			_tween = new Tween(_help, "y", Regular.easeOut, _help.y, targety, 1, true);
			_tween.addEventListener(TweenEvent.MOTION_FINISH, function ():void { /*trace(y, _help.y, Background.instance.masq.height, height, _help.height);*/ }, false, 0, true);
			_addBtnFermer();
			
			stage.addEventListener(Event.RESIZE, _onResize);
			//_onResize();
		}
		
		protected function _addBtnFermer(e:VideoEvent=null):void
		{
			_btnFermer = _help.btn;
			_btnFermer.addEventListener(MouseEvent.CLICK, _close);
		}
		
		private function _removed(e:Event):void
		{
			_btnFermer.removeEventListener(MouseEvent.CLICK, _close);
			stage.removeEventListener(Event.RESIZE, _onResize);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		private function _onResize(e:Event = null):void
		{
			x = (Background.instance.masq.width - _help.width) / 2;
			y = (Background.instance.masq.height - height) / 2 -34;
		}
		
		private function _close(e:MouseEvent):void
		{
			_tween = new Tween(_help, "y", Regular.easeOut, _help.y, -_help.height, .6, true);
			_tween.addEventListener(TweenEvent.MOTION_FINISH, _doClose);
		}
		
		private function _doClose(e:TweenEvent = null):void
		{
			stage.removeEventListener(Event.RESIZE, _onResize);
			if(_tween) _tween.removeEventListener(TweenEvent.MOTION_FINISH, _doClose);
			_tween = null;
			AlertManager.removePopup();
		}
	
	}

}