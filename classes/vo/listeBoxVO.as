package classes.vo
{
	import fl.data.DataProvider;
	import classes.utils.AppUtils;
	
	public class listeBoxVO
	{
		public var ref:String;
		public var label:String;
		public var dp:DataProvider;
		
		public function listeBoxVO(pRef:String, pLabel:String, pDp:DataProvider)
		{
			ref = pRef;
			label = pLabel;
			dp = pDp;
			//AppUtils.TRACE("listeBoxVO(" + ref + ", " + label + ", " + dp + ")");
		}
		
		public function toString():String
		{
			var strRetour:String = "";
			var item:Object;
			for (var i:int = 0; i < dp.length; i++)
			{
				if (strRetour != "")
					strRetour += ", ";
				item = dp.getItemAt(i);
				strRetour += item.data + ":" + item.label;
			}
			return "listeBoxVO[" + ref + ", " + label + ", " + strRetour + "]";
		}
	}
}