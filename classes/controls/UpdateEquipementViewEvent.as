package classes.controls 
{
	import classes.views.equipements.EquipementView;
	import flash.events.Event;
	
	/**
	 * La classe UpdateEquipementViewEvent distribue un objet UpdateEquipementViewEvent chaque fois qu'une 
	 * modification est apportée à un équipement (ajout, suppression, connexion ou déconnexion)
	 */
	public class UpdateEquipementViewEvent extends Event 
	{
		private static const EVENT_NAME:String = "UpdateEquipementViewEvent";
		private static const EVENT_ADD:String = "AddEquipementViewEvent";
		private static const EVENT_DELETE:String = "DeleteEquipementViewEvent";
		/**
		 * Indique une action de type suppression
		 */
		public static var ACTION_DELETE:String = "delete";
		/**
		 * Indique une action de type ajout
		 */
		public static var ACTION_ADD:String = "add";
		/**
		 * Indique l'équipement concerné par la mise à jour ou modification
		 */
		public var item:EquipementView;
		/**
		 * Indique le type d'action qui a eu lieu
		 */
		public var action:String;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement UpdateEquipementViewEvent
		 * 
		 * @param	item L'équipement concerné par la mise à jour
		 * @param	action L'action qui a eu lieu sur l'équipement en question (item)
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function UpdateEquipementViewEvent(item:EquipementView, 	action:String,									
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.item = item;
			this.action = action;
		}
		
		public static function getType():String
		{
			//return (action === "delete") ? EVENT_DELETE : EVENT_ADD;
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new UpdateEquipementViewEvent(item, action, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("UpdateEquipementViewEvent", "type", "bubbles", "cancelable", "eventPhase", "item", "action");
		}
		
	}

}