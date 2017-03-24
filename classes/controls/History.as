package classes.controls 
{
	import classes.commands.Command;
	import classes.commands.ICommand;
	import classes.model.EditorModelLocator;
	
	/**
	 * La classe History sert à gérer l'annulation de la dernière action.
	 */
	public class History 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private static var _self:History;
		private var _history:Array;
		public static var initialized:Boolean = false;
		
		/**
		 * Singleton de classe, permet d'accéder à une seule instance de l'objet
		 */
		public static function get instance() : History
		{
			if (_self == null) {
				_self = new History();
			}
			return _self;
		}
		
		/**
		 * Crée un nouvel objet History et vide le tableau des commandes enregistrées dans l'historique.
		 */
		public function History() 
		{
			clearHistory();
		}
		
		/*
		 * 
		 * Since some actions are too dev-time consuming to be pushed in history, this method helps empty history
		 *
		 */
		public function clearHistory():void
		{
			_history = [];
			_model.notifyHistoryUpdate();
		}
		
		/**
		 * Méthode qui met une action ou une commande dans l'historique, afin de pouvoir l'annuler ensuite.
		 * 
		 * @param	cmd La commande à ajouter dans l'historique
		 */ 
		public function pushInHistory(cmd:ICommand):void
		{
			if (!initialized) return;
			
			//_history[0] = cmd; // on ne stocke qu'une action annulable
			// 5 actions annulables
			_history.push(cmd);
			//trace("history.length", _history.length);
			if (_history.length > 5) {
				_history.shift();
			}
			_model.notifyHistoryUpdate();
			//trace("History::pushInHistory() ", cmd, _history.length);
		}
		
		/*
		 * Called from Main.as in the onKeyUp listener (CTRL +Z)
		 */
		/**
		 * Permet de supprimer la dernière action ou commande ajoutée dans l'historique
		 */
		public function popHistory():void
		{
			var cmd:ICommand = _history.pop();
			//trace("History::popHistory ", cmd);
			if (cmd != null) cmd.undo();
			_model.notifyHistoryUpdate();
		}
		
		/**
		 * Renvoie la dernière commande ajoutée dans l'historique
		 */
		public function get lastCommand():Command
		{
			return _history[ _history.length - 1];
		}
		
		/**
		 * Renvoie le nombre d'actions ajoutés dans l'historique
		 */
		public function get length():int
		{
			return _history.length;
		}
	}

}