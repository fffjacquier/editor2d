package classes.vo 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.plan.Floor;
	
	/**
	 * EditorVO contains references to all FloorsVO i.e. what floors are present 
	 */
	public class EditorVO 
	{
		public var floorsV0s:Array;
		public var title:String;
		public var projectType:String;
		
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		public function EditorVO(title:String) 
		{
			this.title = title;
			floorsV0s = [];
			//trace("new EditorVO", title);
		}
		
		public function fromXML(xml:XML):void
		{
			
		}
		
		public function toXML():XML
		{
			var xml:XML = <maison></maison>;
			// ajout de l'attribut lb afin de définir quel type de LB est choisi et ainsi filtrer dans le menu accordéon des équipements
			xml.@lb = ApplicationModel.instance.selectedLivebox;
			
			var titleNode:XML = <title></title>;
			var titleData:XML = new XML("<![CDATA[" + title + "]]>");
			titleNode.appendChild(titleData);
			xml.appendChild(titleNode);
			
			var floors:int = floorsV0s.length;
			if (floors) {
				var floorsNode:XML = <floors></floors>;
				var i:int = 0;
				for (; i < floorsV0s.length; i++)
				{
					var floor:Floor = floorsV0s[i] as Floor;
					floorsNode.appendChild(floor.toXML());
				}
				xml.appendChild(floorsNode);
			}
			var collection:ConnectionsCollection = ApplicationModel.instance.connectionsCollection;
			if(collection.length > 0) xml.appendChild(collection.toXML());
			return xml;
		}
	}

}