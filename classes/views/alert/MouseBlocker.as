package classes.views.alert
{
	import classes.model.ApplicationModel;
	import classes.views.Background;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * La classe MouseBlocker permet de créer un fond foncé et de bloquer ou non le clic sur cet espace (hors du popup)
	 */
	public class MouseBlocker extends Sprite
	{
		private var _isContainerEditor:Boolean = false;
		private var popupContainer:DisplayObjectContainer;
		private var _alpha:Number;
		
		/**
		 * Crée le fond global au popup et bloque ou non le clic dessus
		 * 
		 * @param	popupContainer Le popup concerné
		 * @param	mouseBlockerClickable True signifie que l'on permet de cliquer sur le fond pour fermer la fenetre. False veut dire qu'on ne le permet pas.
		 * @param	alpha Le niveau de transparence du fond
		 */
		public function MouseBlocker(popupContainer:DisplayObjectContainer, mouseBlockerClickable:Boolean, alpha:Number=.6)
		{
			_alpha = alpha;
			_isContainerEditor = mouseBlockerClickable;// (popupContainer == EditorContainer.instance);
			//trace("MouseBlocker::", _isContainerEditor);
			this.popupContainer = popupContainer;
			
			if (stage) _added();
			else addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			if(_isContainerEditor) addEventListener(MouseEvent.CLICK, _onClick, false, 0, true);
			
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			stage.addEventListener(Event.RESIZE, _onResize);
			_onResize();
		}
		
		private function _onClick(e:MouseEvent):void
		{
			//trace("MouseBlocker::_onClick");
			AlertManager.removeUpperPopup();
		}
		
		private function _onResize(e:Event=null):void
		{
			//trace("MouseBlocker", popupContainer, ApplicationModel.instance.maskSize.width, ApplicationModel.instance.maskSize.height);
			graphics.clear();
			graphics.beginFill(0x333333, _alpha);
			var large:int;
			var haute:int;
			var xpos:int;
			var ypos:int;
			
			large = Background.instance.masq.width//ApplicationModel.instance.maskSize.width
			haute = ApplicationModel.instance.maskSize.height
			xpos = Background.instance.masq.x// + 5;
			ypos = Background.instance.masq.y// + 39;
			
			graphics.drawRoundRect(xpos, ypos, large, haute, 15, 15);	
		}
		
		private function _removed(e:Event):void
		{
			if(_isContainerEditor) removeEventListener(MouseEvent.CLICK, _onClick);
			stage.removeEventListener(Event.RESIZE, _onResize);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed)
		}
	}
}