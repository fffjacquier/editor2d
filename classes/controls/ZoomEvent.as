package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe ZoomEvent distribue un objet ZoomEvent chaque fois que l'utilisateur zoome ou dézoome
	 * dans l'éditeur
	 */
	public class ZoomEvent extends Event 
	{
		private static const EVENT_NAME:String = "ZoomEvent";
		/**
		 * Indique le scale du zoom en cours
		 */
		public var scale:Number;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement ZoomEvent
		 * 
		 * @param	scale Le scale en cours de l'éditeur
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function ZoomEvent(scale:Number, 										
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
			return new ZoomEvent(scale, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("ZoomEvent", "type", "bubbles", "cancelable", "eventPhase", "scale");
		}
		
	}

}