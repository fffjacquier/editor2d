package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe HomeResizeEvent distribue un objet HomeResizeEvent chaque fois que l'utilisateur change 
	 * le scale de l'éditeur
	 */
	public class HomeResizeEvent extends Event 
	{
		private static const EVENT_NAME:String = "HomeResizeEvent";
		/**
		 * Indique le scale en cours
		 */
		public var scale:Number;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement HomeResizeEvent : le changement de scale
		 * 
		 * @param	scale Le nouveau scale de l'éditeur
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function HomeResizeEvent(scale:Number, 										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.scale = scale;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new HomeResizeEvent(scale, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("HomeResizeEvent", "type", "bubbles", "cancelable", "eventPhase", "scale");
		}
		
	}

}