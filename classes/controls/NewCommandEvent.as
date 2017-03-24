package classes.controls 
{
	import classes.commands.Command;
	import flash.events.Event;
	
	/**
	 * La classe NewCommandEvent distribue un objet NewCommandEvent .
	 * 
	 * <p>Pour certaines commandes, quand on annule l'action (deplacement de points avec points liés sur segments) 
	 * ... à finir</p>
	 * 
	 */
	public class NewCommandEvent extends Event 
	{
		private static const EVENT_NAME:String = "NewCommandEvent";
		/**
		 * Indique la commande <code>Command</code> utilisée
		 */
		public var command:Command;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement NewCommandEvent : la commande
		 * 
		 * @param	command La commande concernée
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function NewCommandEvent(command:Command, 										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.command = command;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new NewCommandEvent(command, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("NewCommandEvent", "type", "bubbles", "cancelable", "eventPhase", "command");
		}
		
	}

}