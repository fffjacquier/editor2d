package classes.services 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	
	/*
	 * Recupère la liste des équipements contenus dans le fichier all.xml
	 */
	public class GetEquipementsXML extends Request 
	{
		/**
		 * Permet de savoir dans quel node de l'arborescence xml aller chercher les données
		 * <p>Exemple: "Equipements" ou "Prises" ou "Mobilier" ...</p>
		 */
		private var _type:String;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function GetEquipementsXML(typ:String, func:Function=null)
		{
			_type = typ;
			var file:String = Config.XML_URL + "all.xml";
			super(file, func);
		}
		
		override protected function parseXML(stringsXML:XML):void
		{
			var equipements : XMLList;
			
			if (_type == "Equipements") {
				equipements = stringsXML.equipements.children();
			} else if (_type == "Prises") {	
				equipements = stringsXML.prises.children();
			} else if (_type == "Mobilier") {
				equipements = stringsXML.meubles.children();
			}/*else if (_type == "Connexions") {
				equipements = stringsXML.connexions.children();
			} else {
			}*/
			if (_appmodel.VOs == null) {
				_appmodel.VOs = stringsXML;
			}
			
			if(callBack != null) callBack(equipements);
		}
		
	}

}