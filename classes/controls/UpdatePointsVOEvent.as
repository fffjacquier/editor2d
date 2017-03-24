package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe UpdatePointsVOEvent distribue un objet UpdatePointsVOEvent chaque fois que les coordonnées d'un 
	 * point (<code>PointVO</code>) sont modifiées
	 */
	public class UpdatePointsVOEvent extends Event 
	{
		private static const EVENT_NAME:String = "UpdatePointsVOEvent";
	
		/**
		 * Crée un objet Event sans information spécifique sur l'evenement UpdatePointsVOEvent
		 * 
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function UpdatePointsVOEvent(bubbles:Boolean = false,
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
			return new UpdatePointsVOEvent(bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("UpdatePointsVOEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}

}