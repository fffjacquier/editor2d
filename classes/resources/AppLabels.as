package classes.resources 
{
	/**
	 * Contient toutes les valeurs de textes pour l'application 
	 * sous la forme clé-valeur
	 */
	public class AppLabels 
	{
		/**
		 * This variable is a dictionary of dictionaries
		 */
		public static var LABELS:Object;
		
		public function AppLabels() 
		{
		}
		
		/**
		 * Méthode pour obtenir le bon label pour une clé. 
		 * S'il n'y a pas de valeur correspondant à une clé, renvoie la clé
		 * 
		 * La clé se divise en deux parties séparées par un "_" :
		 * id de la view dans le xml + "_" + id du label de la view
		 * 
		 * L'idée étant de rassembler par vues les labels afin de pouvoir les modifier et retrouver plus rapidement
		 * 
		 * @param key La clé à aller chercher
		 * @return La valeur locale à afficher
		 */
		public static function getString(key:String) : String
		{
			// on échappe le retour chariot du CDATA en carriage return (decimal 13)
			var value:String = String(LABELS[key]).split("\\n").join(String.fromCharCode(13));
			return value || key;
		}
		/* @example
		* <?xml version="1.0" encoding="utf-8" ?>
		* <labels language="fr">
		*		<view name="buttons" id="buttons">
		*			<label id="newClient"><![CDATA[nouveau client]]></label>
		* 
		* le label à appeler dans le cas présent pour afficher le texte 'nouveau client' serait 
		* <code>AppLabels.getString("buttons_newClient")</code>
		*/
	}

}