package classes.views.alert 
{
	import classes.views.Background;
	import classes.views.sequencesPlayer.Sequences;
	import fl.video.VideoEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * Videos Popup affiche une séquence d'animations de branchement pour un équipement donné dans un type d'installation donné
	 * Ces animations sont des fichiers .swf
	 * 
	 * @author FJ 
	 */
	public class VideosPopup extends DemoPopup 
	{
		private var _seq:Sequences;
		
		/**
		 * Le constructeur instancie Sequences et ajoute un bouton fermer.
		 * 
		 * @param	videosArr Un tableau contenant les liens vers les fichiers d'animation
		 */
		public function VideosPopup(videosArr:Array, label:String, connection:String) 
		{
			super(videosArr, "", 640, 405);
			_seq = new Sequences(videosArr, label, connection);
			addChild(_seq);
			
			_addBtnFermer();
		}
		
		override protected function _addBtnFermer(e:VideoEvent=null):void
		{
			super._addBtnFermer(e);
			_btnFermer.x = 905 - _btnFermer.width;
			_btnFermer.y = - _btnFermer.height / 2;
		}
		
		override protected function _onResize(e:Event = null):void
		{
			x = Background.instance.masq.width / 2 - 905 / 2;
			y = (Background.instance.masq.height / 2) - 460 / 2 /*-39*/;
			//trace("aidepopup onresize", y, _flvpb.height, Background.instance.masq.height);
			if (_btnFermer && _btnFermer.stage) {
				_btnFermer.x = _seq.width - _btnFermer.width;
				_btnFermer.y = - _btnFermer.height / 2;
			}
			//trace("_onResize", y, _btnFermer.y, _flvpb.y);
		}
	}

}