package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe UndoEvent distribue un objet UndoEvent chaque fois qu'on annule un déplacement de point. 
	 * Déplacer un point équivaut presque toujours à en déplacer plusieurs puisque les segments suivent.
	 * 
	 */
	public class UndoEvent extends Event 
	{
		private static const EVENT_NAME:String = "UndoEvent";
		
		/**
		 * Crée un objet Event sans information spécifique sur l'evenement UndoEvent
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function UndoEvent(	bubbles:Boolean = false,
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
			return new UndoEvent(bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("UndoEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}

}