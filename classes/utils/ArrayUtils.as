package classes.utils
{
	public class ArrayUtils
	{
		public function ArrayUtils()
		{
		}
		
		public static function randomize(arr:Array):Array
		{
			return arr.sort(function ():int { return Math.random()<.5 ? 1 : -1;	} );
		}
				
		public static function pushUnique(arr:Array, obj:Object):void
		{
			if(!exist(arr, obj))   arr.push(obj);
		}
		
		public static function exist(arr:Array, obj:Object):Boolean
		{
			//here array of objs with 'label' as property
			for  (var i:int = 0; i< arr.length; i++)
			{
				if(arr[i].label && arr[i].label == obj.label) return true;
			}
			return false;			
		}
		
		public static function contains(arr:Array, elt:*):Boolean
		{			
			return (indexOf(arr, elt) == -1) ? false : true;
		}
		
		public static function indexOf(arr:Array, elt:*):int
		{
			for  (var i:int = 0; i< arr.length; i++)
			{
				if(arr[i] == elt) return i;
			}
			return -1;		
		}
		
		public static function arraySwap(arr:Array, elt:*, index:int):Array
		{
			var prevIndex:int = indexOf(arr, elt); 
			if (prevIndex != -1)
			{
				arr.splice(prevIndex, 1);
				arr.splice(index, 0, elt);
			}
			return arr;
		}
		
		//returns the nieme occurrency of an elt in an array
		public static function  return0ccurence(arr:Array, nOcc:int, elt:*):int
		{
			var j:int = 0;
			for (var i:int = 0; i< arr.length; i++)
			{				
				if(arr[i] == elt) 
				{			
					if(j >= nOcc) return i;
					j++;
				}				
			}
			return return0ccurence(arr, 0, elt);
		}
		
		//vider un array des tous ses éléments ayant pour valeur l'argument
		public static function  empty(arr:Array, elt:*):void
		{
			for (var n:int = 0; n <arr.length; n++) {
				if (arr[n] ==  elt) {
					arr.splice(n, 1);
					empty(arr, elt);
				}
			}
		};
		//--------------
		// enlever les doublons d'un array / sans faire attention à l'ordre des éléments
		public static function  clean_(arr:Array):void
		{
			for (var n:int = 0; n <arr.length; n++) {
				var elt:* = arr[n];
				arr.splice(n, 1);
				empty(arr, elt);
				arr.unshift(elt);
			}
		};
		
		public static function  clean(arr:Array):void
		{
			var newArr:Array = new Array();
			for (var n:int = 0; n <arr.length; n++) {
				var elt:* = arr[n];
				if (newArr.indexOf(elt) == -1)
				{
					newArr.push(elt);
				}
			}
			arr = newArr;
		};
	}
}