package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe SessionOverEvent distribue un objet SessionOverEvent lorsque, lors des échanges php avec le serveur, 
	 * la récupération des résultats d'une requête signifie que la session est terminée.
	 * 
	 */
	public class SessionOverEvent extends Event 
	{
		private static var EVENT_NAME:String = "SessionOverEvent";
		
		/**
		 * Crée un objet Event sans information spécifique sur l'evenement SessionOverEvent
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function SessionOverEvent(bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(getType(), bubbles, cancelable);
		} 
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		public override function clone():Event 
		{ 
			return new SessionOverEvent(bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SessionOverEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
}