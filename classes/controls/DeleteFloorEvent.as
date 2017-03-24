package classes.controls 
{
	import classes.views.plan.Floor;
	import flash.events.Event;
	
	/**
	 * La classe DeleteFloorEvent distribue un objet DeleteFloorEvent chaque fois que l'utilisateur supprime 
	 *  un étage
	 */
	public class DeleteFloorEvent extends Event 
	{
		private static const EVENT_NAME:String = "DeleteFloorEvent";
		/**
		 * Indique l'étage affiché
		 */
		public var floor:Floor;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement DeleteFloorEvent : l'étage <code>floor</code>
		 * 
		 * @param	floor L'étage supprimé (<code>Floor</code>)
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function DeleteFloorEvent(floor:Floor, 										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.floor = floor;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new ChangeFloorEvent(floor, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("DeleteFloorEvent", "type", "bubbles", "cancelable", "eventPhase", "floor");
		}
		
	}

}