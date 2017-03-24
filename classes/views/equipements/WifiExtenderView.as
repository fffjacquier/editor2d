package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	import flash.events.Event;
	
	public class WifiExtenderView extends EquipementView 
	{
		public var equipement:EquipementView;
		public var connectedWifiEquipements:Array = new Array();
		public var connectedEthernetEquipements:Array = new Array();
		public var isModuleDeBase:Boolean = false;
		public static var count:int = 0;
		public var master:LiveplugView;/* should contain the related liveplug master*/
		public var masterStr:String; /* used only when re-creating plan */
		public var equipementEthStr:String;/* use only when recreating plan, temporary stock of uniqueId - ethernet */
		public var equipementWifiStr:String;/* use only when recreating plan, temporary stock of uniqueId - wifi */
	
		public function WifiExtenderView(pvo:EquipementVO) 
		{
			super(pvo);
			isConnector = true;
			//id = count;
			//++count;
		}
		
	}

}