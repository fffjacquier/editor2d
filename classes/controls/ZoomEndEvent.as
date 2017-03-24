package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe ZoomEndEvent distribue un objet ZoomEndEvent chaque fois que l'action de zoomer dans l'éditeur 
	 * est terminée.
	 * 
	 */
	public class ZoomEndEvent extends Event 
	{
		private static const EVENT_NAME:String = "ZoomEndEvent";
		
		/**
		 * Crée un objet Event sans information spécifique sur l'evenement ZoomEndEvent
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function ZoomEndEvent( bubbles:Boolean = false,
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
			return new ZoomEndEvent(bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("ZoomEndEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}

}