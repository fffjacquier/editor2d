package classes.views.equipements 
{
	import classes.utils.MapDict;
	import classes.views.items.ItemListeCourse;
	
	public final class Liste extends MapDict 
	{
		
		public function Liste(weak:Boolean=true) 
		{
			super(weak);
		}
		
		public function updateValue(key:*, howmany:Number ):void
		{
			(map[key] as ItemListeCourse).nombre += howmany;
			trace("Liste::updateValue", key, ":", (map[key] as ItemListeCourse).nombre);
			if ((map[key] as ItemListeCourse).nombre == 0) {
				remove(key);
				return;
			}
			(map[key] as ItemListeCourse).renderText();			
		}
	}

}