package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe HomeResizeEndEvent distribue un objet HomeResizeEndEvent chaque fois que se termine 
	 * une action de Resize de l'éditeur
	 * 
	 */
	public class HomeResizeEndEvent extends Event 
	{
		private static const EVENT_NAME:String = "HomeResizeEndEvent";
		
		/**
		 * Crée un objet Event sans information spécifique sur l'événement HomeResizeEndEvent
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function HomeResizeEndEvent( bubbles:Boolean = false,
									  cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new HomeResizeEndEvent(bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("HomeResizeEndEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}

}