package classes.views 
{
	import classes.controls.SaveStateEvent;
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	/**
	 * Extension de la classe Btn afin de pouvoir gérer un état on et un état off
	 * 
	 * <p>L'état on étant l'état bouton actif, l'état off - bouton inactif - va modifier la couleur du fond, la transparence de l'icône
	 * et la transparence de la couleur du texte.</p>
	 * 
	 * <p>Cette classe va écouter s'il y a eu des changements effectués dans l'application depuis la dernière sauvegarde
	 * afin de pouvoir se mettre à on ou off automatiquement. Dès qu'une sauvagarde a eu lieu, l'état devient off. Dès qu'une
	 * modification est apportée dans le plan, l'état passe à on.</p>
	 */
	public class BtnHeaderSave extends Btn 
	{
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function BtnHeaderSave(texte:String) 
		{
			super(0, texte, PictoMain, 116, 0xffffff, 12, 24, GRADIENT_ORANGE, false, false);
			_appmodel.addSaveStateUpdateListener(_updateState);
		}
			
		private function _updateState(e:SaveStateEvent):void
		{
			//AppUtils.TRACE("BtnHeaderSave "+e.state);
			if (e.state) {
				_tf.alpha = 1;
				_icon.alpha = 1;
				_gradient = GRADIENT_ORANGE;
				_draw();
				buttonMode = true;
			} else {
				//change gradient
				_gradient = GRADIENT_DARK;
				_draw();
				// set alpha text to .5
				_tf.alpha = .5;
				// set icon alpha to .5
				_icon.alpha = .5
				// inactive 
				buttonMode = false;
			}
		}
		
		override protected function _removeListeners():void
		{
			_appmodel.removeSaveStateUpdateListener(_updateState);
			super._removeListeners();
		}
		
	}

}