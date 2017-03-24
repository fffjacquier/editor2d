package classes.vo
{
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	
	public class VendeurVO
	{
		public var id:int = -1;
		public var id_orange:String;
		public var id_agence:int;
		public var id_profil:int;
		public var str_profil:String;
		public var nom:String;
		public var prenom:String;
		
		private var _callbackLoad:Function;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function VendeurVO()
		{
		}
			
		public function toString():String
		{
			var str:String = "\n"
			
			str += "-- Vendeur VO -----------\n";
			
			str += "id=" + id + "\n";
			str += "id_orange=" + id_orange + " / ";
			str += "id_agence=" + id_agence + "\n";
			
			str += "nom=" + nom + " / prenom=" + prenom+"\n";
						
			str += "----------------------------------\n";
						
			return str;
		}
	}
}