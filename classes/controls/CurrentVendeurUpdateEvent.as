package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe CurrentVendeurUpdateEvent distribue un objet CurrentVendeurUpdateEvent chaque fois que le vendeur 
	 * loggué change
	 * 
	 */
	public class CurrentVendeurUpdateEvent extends Event 
	{
		private static var EVENT_NAME:String = "CurrentVendeurUpdateEvent";
		
		/**
		 * Crée un objet Event sans information spécifique sur l'événement CurrentVendeurUpdateEvent
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function CurrentVendeurUpdateEvent(bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(getType(), bubbles, cancelable);
		} 
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		public override function clone():Event 
		{ 
			return new CurrentVendeurUpdateEvent(bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CurrentVendeurUpdateEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
}