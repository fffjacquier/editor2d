package classes.controls 
{
	import flash.events.Event;
	
	/**
	 * La classe SegmentMoveEvent distribue un objet SegmentMoveEvent chaque fois que l'utilisateur déplace 
	 * un segment 
	 */
	public class SegmentMoveEvent extends Event 
	{
		private static const EVENT_NAME:String = "SegmentMoveEvent";
		/**
		 * Indique le tableau des id des points déplacés
		 */
		public var pointsids:Array;
		public var diffx:int;
		public var diffy:int;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement SegmentMoveEvent
		 * 
		 * @param	ids Le tableau des id des points déplacés
		 * @param	diffx La différence de coordonnées en x
		 * @param	diffy La différence de coordonnées en y
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function SegmentMoveEvent(ids:Array,	diffx:int, diffy:int,								
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.pointsids = ids;
			this.diffx = diffx;
			this.diffy = diffy;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new SegmentMoveEvent(pointsids, diffx, diffy, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("SegmentMoveEvent", "type", "bubbles", "cancelable", "eventPhase", "pointsids", "diffx", "diffy");
		}
		
	}

}