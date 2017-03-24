package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe CurrentProjetUpdateEvent distribue un objet CurrentProjetUpdateEvent chaque fois que le projet en cours 
	 * (<code>ProjetVO</code>) est modifié ou mis à jour
	 * 
	 */
	public class CurrentProjetUpdateEvent extends Event 
	{
		private static var EVENT_NAME:String = "CurrentProjetUpdateEvent";
		
		/**
		 * Crée un objet Event sans information spécifique sur l'événement CurrentProjetUpdateEvent
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function CurrentProjetUpdateEvent(bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(getType(), bubbles, cancelable);
		} 
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		public override function clone():Event 
		{ 
			return new CurrentProjetUpdateEvent(bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CurrentProjetUpdateEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
}