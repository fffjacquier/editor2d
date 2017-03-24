package classes.controls 
{
	import classes.views.plan.PieceEntity;
	import flash.events.Event;
	
	/**
	 * La classe EndMovingPieceEvent distribue un objet EndMovingPieceEvent chaque fois que l'utilisateur 
	 * a fini de déplacer une pièce
	 */
	public class EndMovingPieceEvent extends Event 
	{
		private static const EVENT_NAME:String = "EndMovingPieceEvent";
		/**
		 * Indique la pièce concernée par le déplacement 
		 */
		public var piece:PieceEntity;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement EndMovingPieceEvent : la pièce en cours de déplacement <code>PieceEntity</code>
		 * 
		 * @param	piece La pièce déplacée
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function EndMovingPieceEvent(piece:PieceEntity,										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.piece = piece;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new EndMovingPieceEvent(piece, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("EndMovingPieceEvent", "type", "bubbles", "cancelable", "eventPhase", "piece");
		}
		
	}

}