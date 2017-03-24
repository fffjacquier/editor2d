package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe CurrentStepUpdateEvent distribue un objet CurrentStepUpdateEvent chaque fois que l'utilisateur change 
	 * de rubrique (step) dans l'accordion 
	 */
	public class CurrentStepUpdateEvent extends Event 
	{
		private static const EVENT_NAME:String = "CurrentStepUpdateEvent";
		/**
		 * Indique la valeur du choix courant de la liste déroulante (accordion)
		 */
		public var step:int;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement CurrentStepUpdateEvent : l'étape <code>step</code>
		 * 
		 * @param	step Le nombre entier de la nouvelle étape appellée par l'utilisateur
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function CurrentStepUpdateEvent(step:int, 										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.step = step;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new CurrentStepUpdateEvent(step, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("CurrentStepUpdateEvent", "type", "bubbles", "cancelable", "eventPhase", "step");
		}
		
	}

}