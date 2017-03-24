package classes.utils
{
	public class MathUtils
	{
		public function MathUtils()
		{
		}
		
		public static function isEven(n:int):Boolean
		{
			return n%2 == 0;
		}
		
		public static function isOdd(n:int):Boolean
		{
			return n%2 == 1;
		}
	}
}