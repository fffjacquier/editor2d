package classes.controls 
{
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * La classe PointMoveEvent distribue un objet PointMoveEvent chaque fois que l'utilisateur commence 
	 * à déplacer un point.
	 */
	public class PointMoveEvent extends Event 
	{
		private static const EVENT_NAME:String = "PointMoveEvent";
		/**
		 * Indique le tableau de points concernés par le déplacement
		 */
		public var points:Array;
		/**
		 * Indique les coordonnées du point de départ avant le déplacement
		 */
		public var dep:Point;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement PointMoveEvent : 
		 * les coordonnées du point avant le déplacement
		 * et le tableau des points concernés par ce déplacement
		 * 
		 * @param	points Le tableau de points
		 * @param	dep Les coordonnées du point de départ du <code>PointVO</code>
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function PointMoveEvent(points:Array, dep:Point=null,										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.points = points;
			this.dep = dep;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new PointMoveEvent(points, dep, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("PointMoveEvent", "type", "bubbles", "cancelable", "eventPhase", "points", "dep");
		}
		
	}

}