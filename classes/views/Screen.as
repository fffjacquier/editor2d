package classes.views 
{
	import classes.controls.CurrentScreenUpdateEvent;
	import classes.model.ApplicationModel;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * La classe Screen constitue la classe de base des différents écrans de l'application.
	 * C'est une classe abstraite qui ne doit pas être appelé directement par new Screen().
	 * 
	 * <p>Le paramètre <code>screen</code> doit être défini dans le constructeur des classes enfants. Les différentes valeurs 
	 * de screen sont dans ApplicationModel</p>
	 * 
	 * @see classes.model.ApplicationModel
	 */
	public class Screen extends Sprite 
	{
		protected var model:ApplicationModel = ApplicationModel.instance;
		protected var screen:String;
		
		public function Screen() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		protected function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			model.addCurrentScreenUpdateListener(_onScreenUpdate);
		}
		
		protected function _onScreenUpdate(e:CurrentScreenUpdateEvent):void
		{
			//trace("Screen::_onScreenUpdate() ", model.screen, screen);
			if (model.screen != screen) {
				remove();
			}
		}
		
		public function remove():void
		{
			cleanup();
			parent.removeChild(this);
		}
		
		protected function cleanup():void
		{			
			model.removeCurrentScreenUpdateListener(_onScreenUpdate);
		}
	}

}