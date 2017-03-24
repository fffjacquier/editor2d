package classes.controls
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * GlobalEventDispatcher est un dispatcher global d'événements.
	 * 
	 * Utilisé en singleton par les ModelLocator ApplicationModel et EditorModelLocator
	 */
	public class GlobalEventDispatcher implements IEventDispatcher
	{
		private static var _instance:GlobalEventDispatcher;
		private var _ed:IEventDispatcher;
		
		// single instance ----------------------
		public static function get instance():GlobalEventDispatcher
		{
			if (_instance == null) _instance = new GlobalEventDispatcher();
			
			return _instance;
		}
		
		/**
		 * Créé l'object global de dispatch d'evenements
		 * 
		 * @param	target L'interface IEventDispatcher
		 */
		public function GlobalEventDispatcher( target:IEventDispatcher = null ) 
		{
			_ed = new EventDispatcher(target);
		}
		
		/**
		 * Ajoute un écouteur d'événement.
		 * 
		 * @param	type Le type d'evenement
		 * @param	listener La function appelée lors de la notification de l'evenement. Cette fonction doit accepter
		 * un objet de type Event ou une sous-classe comme unique paramètre et ne doit rien renvoyer.
		 * @param	useCapture Determine si l'écouteur utilise la phase de capture phase ou les phases de
		 *   bubbling et target. La valeur par défaut est <code>false</code>.
		 * @param	priority Le niveau de priorité de l'écouteur, par défaut égal à 0.
		 * @param	useWeakReference Determine si la reference à l'écouteur est forte ou faible. Faible par défaut.
		 *   
		 */
		public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true ) : void 
		{
			_ed.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		/**
		 * Supprime un écouteur d'événement.
		 */
		public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ) : void 
		{
			_ed.removeEventListener( type, listener, useCapture );
		}
		
		/**
		 * Dispatche un événement
		 */
		public function dispatchEvent( event:Event ) : Boolean 
		{
			return _ed.dispatchEvent( event );
		}
		
		/**
		 * Returns whether an event listener exists.
		 */
		public function hasEventListener( type:String ) : Boolean 
		{
			return _ed.hasEventListener( type );
		}
		
		/**
		 * Returns whether an event will trigger.
		 */
		public function willTrigger(type:String) : Boolean 
		{
			return _ed.willTrigger( type );
		}
		
	}	
}