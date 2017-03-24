package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe CurrentScreenUpdateEvent distribue un objet CurrentScreenUpdateEvent chaque fois qu'un changement 
	 * d'écran a lieu
	 * 
	 * @see classes.model.ApplicationModel#screen
	 */
	public class CurrentScreenUpdateEvent extends Event
	{
		private static const EVENT_NAME:String = "CurrentScreenUpdateEvent";
		
		/**
		 * Crée un objet Event sans information spécifique sur l'événement CurrentScreenUpdateEvent
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function CurrentScreenUpdateEvent(bubbles:Boolean = false,
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
			return new CurrentScreenUpdateEvent(bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("CurrentScreenUpdateEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}
}