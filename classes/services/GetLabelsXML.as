package classes.services
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	
	/**
	 * Récupère et stocke toutes les données textes de l'appli
	 * Les valeurs sont stockées dans resources AppLabels.as
	 */
	public class GetLabelsXML extends Request
	{
		
		public function GetLabelsXML(func:Function)
		{
			var file:String = Config.XML_URL + "labels_" + ApplicationModel.instance.language + ".xml";
			super(file, func);			
		}
		
		override protected function parseXML(stringsXML:XML):void
		{
			var labels : Object = new Object();
			var keySeparator : String = "_";
			
			var views : XMLList = stringsXML.children();
			for each (var view:XML in views)
			{
				//AppUtils.TRACE("view " + view);
				var viewId : String = view.@id;
				var labelNodes : XMLList = view.children();
				for each (var label:XML in labelNodes)
				{
					var labelId : String = label.@id;
					var labelValue : String = label.children()[0]//.split("\n").join(String.fromCharCode(13));
					var key : String = viewId + keySeparator + labelId;
					labels[key] = labelValue;
				}
			}
			AppLabels.LABELS = labels;
			callBack();
		}
	}
}