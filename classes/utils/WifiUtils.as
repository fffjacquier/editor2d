package classes.utils 
{
	public class WifiUtils 
	{
		//private static var _puissance:int;
		private static var _zoneDenseParam:int = 6;
		
		private static var coeffCloisonBase:int = 3;
		private static var coeffMurPotteurMoyen:int = 7;
		private static var coeffMurPotteurEpais:int = 10;
		private static var coeffPlafondBois:int = 7;
		private static var coeffPlafondBeton:int = 12;
		
		public static var RED:int = -1;
		public static var YELLOW:int = 1;
		public static var GREEN:int = 2;
		public static var ORANGE:int = 0;
		
		public static const THICKNESS_NSP:String = "nsp";
		public static const THICKNESS_THICK:String = "epais";
		public static const THICKNESS_MEDIUM:String = "moyen";
		public static const THICKNESS_NO:String = "no";
		
		public function WifiUtils() 
		{
		}
		
		public static function puissance(pertes:int, /*nbmurs:int, nbmursP:int, nbplafonds:int, */d:Number, /*coeffMur:int=7, coeffDalle:int=12,*/ f:int = 2400 ):int
		{
			var pertes:int = pertes;// (nbmurs * coeffCloisonBase) + (nbmursP * coeffMur) + (nbplafonds * coeffDalle);
			var p:Number = 20 - ((20 * NumberUtils.log10(d)) + (20 * NumberUtils.log10(f)) -27.56 + pertes + 17);
			trace("\tWifiUtils::puissance() d:", d, "pertes", pertes, "puissance wifi:", p);
			//_puissance = p;
			return p; 
		}
		
		public static function getColor(puissance:Number):int
		{
			var n:int;
			if (puissance <= -86) {
				n = RED;
			} else if (puissance >= -85 && puissance <= -81) {
				n = ORANGE;
			} else if (puissance >= -75 && puissance <= -80) {
				n = YELLOW;
			} else if (puissance >= -74) {
				n = GREEN;
			}
			return n;
		}
		
		public static function coeffCloison(val:String):int
		{
			var n:int;
			switch(val) {
				case THICKNESS_NSP:
					n = 10;
					break;
				case THICKNESS_THICK:
					n = 10;
					break;
				case THICKNESS_MEDIUM:
					n = 7;
					break;
				case THICKNESS_NO:
					n = 0;
				default:
					n = coeffCloisonBase;
			}
			return n;
		}
		
		public static function coeffPlafond(val:String):int
		{
			var n:int;
			switch(val) {
				case "beton":
					n = 12;
					break;
				default:
					n = 7;
					break;
			}
			return n;
		}
	}

}