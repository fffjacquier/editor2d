package classes.controls 
{
	import classes.views.items.ItemListePDF;
	import flash.events.Event;
	
	/**
	 * La classe LegendeLoadedEvent distribue un objet LegendeLoadedEvent lors de la création du PDF :
	 * les légendes des équipements qui apparaissent dans le PDF doivent être chargées avant de 
	 * pouvoir s'ajouter dans le PDF.
	 * 
	 */
	public class LegendeLoadedEvent extends Event 
	{
		private static const EVENT_NAME:String = "LegendeLoadedEvent";
		/**
		 * Indique le numéro de l'item en cours d'affichage (en rapport à la liste totale de légendes à afficher)
		 */
		public var num:int;
		/**
		 * Indique l'item en cours d'affichage
		 */
		public var item:ItemListePDF;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement LegendeLoadedEvent : le numéro d'item de la liste d'items 
		 * en cours d'affichage et l'item <code>ItemListePDF</code> correspondant
		 * 
		 * @param	num Le numéro de l'item ItemListePDF
		 * @param	item L'item ItemListePDF qui est en train de s'afficher en légende dans le PDF
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function LegendeLoadedEvent(num:int, item:/*BitmapData*/ItemListePDF,									
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.num = num;
			this.item = item;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new LegendeLoadedEvent(num, item, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("LegendeLoadedEvent", "type", "bubbles", "cancelable", "eventPhase", "num", "item");
		}
		
	}

}