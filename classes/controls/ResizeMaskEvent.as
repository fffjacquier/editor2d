package classes.controls 
{
	import classes.vo.MaskSizeVO;
	import flash.events.Event;
	
	/**
	 * La classe ResizeMaskEvent distribue un objet ResizeMaskEvent chaque fois que la taille du masque de l'éditeur 
	 * est modifiée (par un resize du navigateur)
	 */
	public class ResizeMaskEvent extends Event 
	{
		private static const EVENT_NAME:String = "ResizeMaskEvent";
		/**
		 * Indique la nouvelle largeur et hauteur du masque
		 */
		public var sizevo:MaskSizeVO;
		
		/**
		 * Crée un objet Event contenant des informations sur l'événement ResizeMaskEvent : l'étage <code>floor</code>
		 * 
		 * @param	sizevo La nouvelle taille du mask (<code>MaskSizeVO</code>)
		 * @param	bubbles Détermine si l’objet Event prend part à la phase de propagation vers le haut (bubbling) du flux d’événements. La valeur par défaut est false.
		 * @param	cancelable Détermine si l’objet Event peut être annulé. La valeur par défaut est false. 
		 */
		public function ResizeMaskEvent(sizevo:MaskSizeVO, 										
										bubbles:Boolean = false,
										cancelable:Boolean = false)
		{
			super(getType(), bubbles, cancelable);
			this.sizevo = sizevo;
		}
		
		public static function getType():String
		{
			return EVENT_NAME;
		}
		
		// every custom event class must override clone()
		public override function clone():Event{
			return new ResizeMaskEvent(sizevo, bubbles, cancelable);
		}
		
		// every custom event class must override toString()
		// could be removed from class
		public override function toString():String{
			return formatToString("ResizeMaskEvent", "type", "bubbles", "cancelable", "eventPhase", "sizevo");
		}
		
	}

}