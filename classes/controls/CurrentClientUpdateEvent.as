package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe CurrentClientUpdateEvent distribue un objet CurrentClientUpdateEvent chaque fois que le client du vendeur 
	 * en boutique change
	 */
	public class CurrentClientUpdateEvent extends Event 
	{
		private static var EVENT_NAME:String = "CurrentClientUpdateEvent";
		
		/**
		 * Crée un objet Event sans information spécifique
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function CurrentClientUpdateEvent(bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(getType(), bubbles, cancelable);
		} 
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		public override function clone():Event 
		{ 
			return new CurrentClientUpdateEvent(bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CurrentClientUpdateEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
}