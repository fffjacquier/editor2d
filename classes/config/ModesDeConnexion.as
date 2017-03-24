package classes.config 
{
	import classes.resources.AppLabels;
	
	/**
	 * La classe ModesDeConnexion contient les valeurs des différents modes de connexion des équipements, 
	 * et un raccourci pour récupérer les valeurs correspondantes pour afficher le type de connexion à l'écran.
	 */
	public class ModesDeConnexion 
	{
		/**
		 * Valeur d'une connexion Ethernet en direct sur un équipement
		 */
		public static const ETHERNET:String 			= "ethernet";
		/**
		 * Valeur d'une connexion Ethernet qui passe par un Liveplug HD+
		 */
		public static const LIVEPLUG:String				= "ethernet-liveplug";
		/**
		 * Valeur temporaire d'une connexion Ethernet qui signifie l'obligation d'ajouter un Liveplug HD+ pour connecter un équipement
		 */
		public static const LIVEPLUG_NEW:String			= "ethernet-liveplug-nouveau";
		/**
		 * Valeur d'une connexion Wi-Fi seule
		 */
		public static const WIFI:String					= "wifi";
		/**
		 * Valeur d'une connexion Wi-Fi qui passe par un connecteur Wi-FI Extender déjà présent sur le plan
		 */
		public static const WIFIEXTENDER_WIFI:String	= "wifiextender-wifi";
		/**
		 * Valeur temporaire d'une connexion Wi-Fi qui passe par un connecteur Wi-FI Extender pas encore présent sur le plan, 
		 * et que l'on va devoir ajouter
		 */
		public static const WIFIEXTENDER_WIFI_NEW:String = "wifiextender-wifi-nouveau";
		/**
		 * Valeur d'une connexion Ethernet qui passe par un connecteur Wi-FI Extender déjà présent sur le plan
		 */
		public static const WIFIEXTENDER_ETHERNET:String = "wifiextender-ethernet";
		/**
		 * Valeur temporaire d'une connexion Ethernet qui passe par un connecteur Wi-FI Extender pas encore présent sur le plan, 
		 * et que l'on va devoir ajouter
		 */
		public static const WIFIEXTENDER_ETHERNET_NEW:String = "wifiextender-ethernet-nouveau";
		/**
		 * Valeur d'une connexion Wi-Fi qui passe par un Liveplug Wi-Fi Duo
		 */
		public static const DUO_WIFI:String 			= "duo-wifi";
		/**
		 * Valeur d'une connexion Ethernet qui passe par un Liveplug Wi-Fi Duo
		 */
		public static const DUO_ETHERNET:String 		= "duo-ethernet";
		/**
		 * Valeur d'une connexion CPL (courant porteur en ligne) : connexion qui relie deux Liveplugs HD ou deux Liveplugs 
		 * Wi-Fi Duo ou un Liveplug HD et un Wi-Fi Extender
		 */
		public static const CPL:String 					= "cpl";
		
		public function ModesDeConnexion() 
		{			
		}
		
		/**
		 * Permet de récupérer le label à afficher pour le mode de connexion demandé
		 * 
		 * @param	connexion Le Mode de Connexion tel que défini dans cette classe
		 * @return Renvoie une String, la chaîne de caractères à afficher
		 */
		public static function getConnexionLabel(connexion:String):String
		{
			var label:String;
			switch (connexion) {
				case ETHERNET :
					label = AppLabels.getString("connections_ethernetLabel");
					break;
				case LIVEPLUG_NEW :
				case LIVEPLUG :
					label = AppLabels.getString("connections_ethernetLPHDLabel");
					break;
				case DUO_ETHERNET :
					label = AppLabels.getString("connections_ethernetLPWFLabel");
					break;
				case WIFIEXTENDER_ETHERNET :
				case WIFIEXTENDER_ETHERNET_NEW :
					label = AppLabels.getString("connections_ethernetWFELabel");
					break;
				case WIFI :
					label = AppLabels.getString("connections_wifiLabel");
					break;
				case DUO_WIFI :
					label = AppLabels.getString("connections_wifiLPWFLabel");
					break;
				case WIFIEXTENDER_WIFI :
				case WIFIEXTENDER_WIFI_NEW :
					label = AppLabels.getString("connections_wifiWFELabel");
					break;
			}
			return label;
		}
		
		public static function GET_MODE_TYPE(mode:String):String
		{  
			if(mode == WIFI || mode == WIFIEXTENDER_WIFI || mode == WIFIEXTENDER_WIFI_NEW || mode == DUO_WIFI)
			{
				return WIFI;
			}else{
				return ETHERNET;
			}
		}
	}
}