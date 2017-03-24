package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class DecodeurView extends EquipementView
	{
		private static var _id:int = 0;
		
		public function DecodeurView(pvo:EquipementVO) 
		{
			++_id;
			super(pvo);
			isTerminal = true;
			//trace("DecodeurView", _id);
		}
		
		override protected function mouseUpWhileDrag():void
		{
			super.mouseUpWhileDrag();
			/*
			if (selectedConnexion != null) 
			{
				// ethernet case
				var d:Number = distanceLivebox();
				if (d > Config.DISTANCE_ETHERNET) {
					var connectedTo:String;
					if (selectedConnexion === "ethernet-liveplug") {
						connectedTo = "son liveplug";
					} else {
						connectedTo = "la Livebox";
					}
					var messg:String = "ce décodeur est à plus de " + Config.DISTANCE_ETHERNET + "m de "+connectedTo+". Vous devez le rapprocher ou vous procurer des câbles plus longs.";
					var popup:YesAlert = new YesAlert(messg, true, true);
					AlertManager.addPopup(popup, Main.instance);
					AppUtils.appCenter(popup);
				}
			}*/
		}		
	}

}