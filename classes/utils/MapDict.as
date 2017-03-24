package classes.utils 
{
	import classes.views.items.ItemListeCourse;
	import flash.utils.Dictionary;
	
	public class MapDict
	{
		private var _map:Dictionary;
		
		public function MapDict(weak:Boolean = true)
		{
			_map = new Dictionary(weak);
		}
		
		public function put(key:*, value:*) : void
		{
			_map[key] = value;			
		}
		
        public function remove(key:*) : void
		{
			delete _map[key];			
		}
		
        public function containsKey(key:*) : Boolean
		{
			//trace("containsKey", key, (_map[key] != null));
			return (_map[key] != null);
		}
		
        public function getValue(key:*) : *
		{
            return _map[key];
		}
		
		public function getKey(value:*) : *
		{
			for (var key:* in _map) {
				if(_map[key] == value)
					return key;
			}
			return null;
		}
		
        public function getValues() : Array
		{
			var values:Array = [];
			for (var key:* in _map) {
				values.push(_map[key]);
            }
            return values;
		}
		
        public function get length():uint
		{
			return getValues().length;
		}
		
		public function get map():Dictionary
		{
			return _map;
		}
		
        public function clear() : void
		{
            for ( var key:* in _map ) {
                remove( key );
            }
		}
		
		// iterate purpose
		public function getKeys():Array {
			var keys:Array = [];
            for ( var key:* in _map ) {
                keys.push( key );
            }
            return keys;
		}
		
		// debug purpose
		public function toString():String
		{
			var arr:Array = this.getKeys();	
			var str:String = "MapDict::toString() [";
			for (var i:Number = 0; i < arr.length; ++i) {
				var value:* = (getValue(arr[i]) as ItemListeCourse).nombre+"/"+(getValue(arr[i]) as ItemListeCourse).ordre;
				str += arr[i] + ": "+value+ ",";
			}
			str += "]";
			return str;
		}
	}
	
}