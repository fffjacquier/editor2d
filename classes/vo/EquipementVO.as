package classes.vo 
{
	
	public class EquipementVO 
	{
		/** 
		 * Utilisé pour savoir si un client possède l'équipement 
		 * <p>Cette donnée provient de ce que le client renseigne lors de l'inscription</p>
		 * <p>Si le client a saisi qu'il avait la Livebox 1.1 lors de son inscription, on en tient compte 
		 * et on présuppose donc qu'il possède déjà la Livebox</p>
		 * <p>Cette façon de procéder tient plus du bricolage que du codage</p>
		 */
		public var id:int;
		/**
		 * Le type d'équipement :Prise, Livebox, décodeur, livephone....
		 * 
		 * @see "all.xml dans bin"
		 */
		public var type:String;
		/**
		 * Le nom de l'équipement tel qu'il doit apparaitre à l'écran
		 */
		public var screenLabel:String;
		public var name:String;
		public var infos:String;
		public var imagePath:String;
		public var max:int;
		public var modesDeConnexionPossibles:Array = [];
		public var diaporama360:String;
		public var linkArticleShop:String;
		public var nbPortsEthernet:int;
		public var isTerminal:Boolean;
		public var isConnector:Boolean;
		public var isOrange:String;
		public var videosArr:Array = [];
		
		public function EquipementVO() 
		{	
		}
	
		public function toString():String
		{
			return "EquipementVO: " + name + "//"+ screenLabel + "//" + type+"//"+modesDeConnexionPossibles;
		}
	}

}