package classes.vo 
{
	public class AccordionItemVO 
	{
		public var label:String;
		public var classz:Class;
		public var id:int;
		
		public function AccordionItemVO(label:String, classz:Class, id:int) 
		{
			this.label = label;
			this.classz = classz;
			this.id = id;
			//trace("AccordionItemVO", id);
		}
		
	}

}