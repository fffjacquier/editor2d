package classes.utils 
{
	
	public class StringUtils 
	{
		
		public function StringUtils() 
		{
		}
		
		public static function capitalize(str:String):String
		{
			if (str == null) return str;
			return str.substr(0, 1).toUpperCase() + str.substr(1);
		}
		
		public static function replace(str:String, oldSubStr:String, newSubStr:String):String 
		{
			return str.split(oldSubStr).join(newSubStr);
		}

		public static function trim(str:String, char:String):String 
		{
			return trimBack(trimFront(str, char), char);
		}

		public static function trimFront(str:String, char:String):String 
		{
			char = stringToCharacter(char);
			if (str.charAt(0) == char) {
				str = trimFront(str.substring(1), char);
			}
			return str;
		}

		public static function trimBack(str:String, char:String):String 
		{
			char = stringToCharacter(char);
			if (str.charAt(str.length - 1) == char) {
				str = trimBack(str.substring(0, str.length - 1), char);
			}
			return str;
		}

		public static function stringToCharacter(str:String):String 
		{
			if (str.length == 1) {
				return str;
			}
			return str.slice(0, 1);
		}
	}

}