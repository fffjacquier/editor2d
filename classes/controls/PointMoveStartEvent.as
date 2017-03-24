package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe PointMoveStartEvent distribue un objet PointMoveStartEvent quand on déplace les segements ou points 
	 * de la fibre, pour ne pas recalculer les intersections pendant les mouvements
	 */
	public class PointMoveStartEvent extends Event 
	{
		private static const EVENT_NAME:String = "PointMoveStartEvent";
		/**
		 * Indique le tableau de points déplacés
		 */
		public var points:Array;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement PointMoveStartEvent : le tableau de points déplacés
		 * 
		 * @param	points
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false.
		 */
		public function PointMoveStartEvent(points:Array,										
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
			return new PointMoveStartEvent(points, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("PointMoveStartEvent", "type", "bubbles", "cancelable", "eventPhase", "points");
		}
		
	}

}