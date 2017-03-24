package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe PointMoveEndEvent distribue un objet PointMoveEndEvent chaque fois que l'utilisateur a fini de 
	 * déplacer un point
	 */
	public class PointMoveEndEvent extends Event 
	{
		private static const EVENT_NAME:String = "PointMoveEndEvent";
		/**
		 * Indique le tableau de points concernés par ou impliqués dans le déplacement
		 */
		public var points:Array;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement PointMoveEndEvent : les points concernés
		 * 
		 * @param	points Le tableau de points concernés par le déplacement
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function PointMoveEndEvent(points:Array,										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.points = points;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new PointMoveEndEvent(points, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("PointMoveEndEvent", "type", "bubbles", "cancelable", "eventPhase", "points");
		}
		
	}

}