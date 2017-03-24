package classes.controls 
{
	import classes.vo.ConnectionVO;
	import flash.events.Event;
	
	/**
	 * La classe DeleteConnectionEvent distribue un objet DeleteConnectionEvent chaque fois que l'utilisateur 
	 * supprime une connexion <code>ConnectionVO</code> entre deux équipements.
	 */
	public class DeleteConnectionEvent extends Event 
	{
		private static const EVENT_NAME:String = "DeleteConnectionEvent";
		/**
		 * Indique la connexion supprimée
		 */
		public var connection:ConnectionVO;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement DeleteConnectionEvent : la connexion <code>ConnectionVO</code>
		 * 
		 * @param	connection La connexion supprimée (<code>ConnectionVO</code>)
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function DeleteConnectionEvent(connection:ConnectionVO,								
											  bubbles:Boolean = false,
											  cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.connection = connection;
		}
		
		public static function getType():String
		{
			//return (action === "delete") ? EVENT_DELETE : EVENT_ADD;
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new DeleteConnectionEvent(connection, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("DeleteConnectionEvent", "type", "bubbles", "cancelable", "eventPhase", "connection");
		}
		
	}

}