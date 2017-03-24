package classes.controls 
{
	import classes.views.plan.Floor;
	import flash.events.Event;
	
	/**
	 * La classe SaveStateEvent distribue un objet SaveStateEvent chaque fois qu'une sauvegarde est finie
	 * ou qu'une suvegarde est possible.
	 */
	public class SaveStateEvent extends Event 
	{
		private static const EVENT_NAME:String = "SaveStateEvent";
		/**
		 * Indique l'étage affiché
		 */
		public var state:Boolean;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement SaveStateEvent : l'état Sauvagarde possible ou pas.
		 * 
		 * @param	state Le nouvel état de sauvegarde
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function SaveStateEvent(state:Boolean, 										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.state = state;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new SaveStateEvent(state, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("SaveStateEvent", "type", "bubbles", "cancelable", "eventPhase", "state");
		}
		
	}

}