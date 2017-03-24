package classes.views.alert 
{
	import classes.views.equipements.EquipementView;
	
	public class ConnectionsOption 
	{
		/**
		 * Le type d'option, le mode de connexion possible 
		 * 
		 * @see classes.config.ModesDeConnexion
		 */
		public var type:String;
		/**
		 * Le nom de la fonction qui va afficher le choix
		 */
		public var display:Function;
		/**
		 * Le nom de la fonction sous forme de String - debug purpose
		 */
		public var funcName:String;
		/**
		 * définit la priorité de l'option par rapport aux autres
		 */
		public var priority:Number;
		/**
		 * Un Array de conditions pour la disponibilité de l'option ou non
		 */
		public var conditions:Array = new Array();
		/**
		 * le --possible-- module associé à cette option
		 */
		public var moduleDetected:EquipementView = null;
		/**
		 * L'équipement auquel se rattache l'option
		 */
		private var _eqView:EquipementView;
		
		public function ConnectionsOption(eq:EquipementView) 
		{
			_eqView = eq;
		}
		
		public function toString():String
		{
			return funcName +" " +priority.toString() +" "+conditions;
		}
		
		public function condition():Boolean
		{
			// loop through the array of conditions and return true if all conditions are set
			//trace("conditon -- :",  _eqView, _eqView.selectedConnexion, type);
			/*trace("conditions", conditions);*/
			// on vérifie que toutes les conditions sont ok, et qu'on n'est pas dans la connexion actuelle 
			// sauf si elle a besoin d'etre checkée
			return ( conditions.every(_isTrue) && (_eqView.selectedConnexion != type || (_eqView.connection && _eqView.connection.needsToBeChecked)) );
		}
		
		private function _isTrue(element:Boolean, index:int, arr:Array):Boolean
		{
			//trace("\t_isTrue", index, "istrue", element);
			return (element);
		}
		
		public function needForSwitch():Boolean
		{
			return true;
		}
	}

}