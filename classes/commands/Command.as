package classes.commands 
{
	import classes.controls.History;
	import classes.error.AbstractError;
	import classes.model.EditorModelLocator;
	
	public class Command implements ICommand
	{
		private var sender:Object;
		protected var history:History = History.instance;
		protected var doNotify:Boolean = true;		
		public var params:Object;
		public var onError:Function;		
		
		public function Command(sender:Object = null) 
		{
			this.sender = sender;
			if(doNotify) EditorModelLocator.instance.notifyNewCommandEvent(this);
		}
		
		/**
		 * Méthode d'appel de la commande
		 * 
		 * @param callback le callback
		 * 
		 */
		public function run(callback:Function=null) : void
		{
			throw new AbstractError();
		}
		
		/**
		 * Doit etre overriden par les classes descendantes
		 */
		public function undo():void
		{
		}
		
		/**
		 * Permet de gérer le fait de ne pas relancer une commande ou une requete si elle est déjà appelée.
		 * 
		 * @param registry Objet de registre
		 * @param id Id de l'objet
		 * @return True si la requete est ajoutée, false autrement
		 */
		private static function addRequest(registry:Object, id:Object):Boolean
		{
			if (id == null) return true;
			
			var sid:String = String(id);
			
			if (registry[sid] != undefined) {
				//trace("Command::addRequest(id = " + sid + ") pending");
				return false;
			}
			//trace("Command::addRequest(id = " + sid + ") added");
			registry[sid] = id;
			return true;
		}
		
		/**
		 * Permet d'enlever une commande du registre (une fois traitée)
		 * 
		 * @param registry objet de registre
		 * @param id id de l'objet
		 */
		private static function removeRequest(registry:Object, id:Object):void
		{
			if (id == null) return;

			var sid:String = String(id);
			
			trace("Command::removeRequest(id = " + sid + ")");
			delete registry[sid];
		}
		
	}

}