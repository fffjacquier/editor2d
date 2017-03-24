package classes.services 
{
	public class GetXMLInfoProduct extends Request 
	{
		
		public function GetXMLInfoProduct(func:Function, pFile:String)
		{
			var file:String = "swf/" + pFile + ".xml";
			//trace("GetXMLInfoProduct", file);
			super(file, func);			
		}
		
		override protected function parseXML(stringsXML:XML):void
		{
			callBack(stringsXML.title, stringsXML.content.split("\\n").join(String.fromCharCode(13)));
		}
		
	}

}