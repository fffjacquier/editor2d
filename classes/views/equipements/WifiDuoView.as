package classes.views.equipements 
{
	import classes.config.Config;
	import classes.controls.UpdateEquipementViewEvent;
	import classes.views.plan.Bloc;
	import classes.vo.EquipementVO;
	import flash.events.Event;
	
	public class WifiDuoView extends EquipementView 
	{
		public var equipement:EquipementView;
		public var connectedWifiEquipements:Array = new Array();
		public var connectedEthernetEquipements:Array = new Array();
		public var slaves:Array = [];/* an array of all the slaves */
		public var master:WifiDuoView;/* the related master */
		public var isModuleDeBase:Boolean = false;
		public var masterStr:String; /* used only when re-creating plan */
		public var equipementEthStr:String;/* use only when recreating plan, temporary stock of uniqueId - ethernet */
		public var equipementWifiStr:String;/* use only when recreating plan, temporary stock of uniqueId - wifi */
		
		public function WifiDuoView(pvo:EquipementVO) 
		{
			super(pvo);
			isConnector = true;
			_appmodel.addUpdateEquipementListener(_onUpdateEquipement);
		}
		
		override protected function drawBG(color:Number):void
		{
			/*var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, color, 0);
			g.beginFill(0xffffff, 0);
			g.drawCircle( 0, 0, 18);*/
		}
		
		protected function _onUpdateEquipement(e:UpdateEquipementViewEvent):void
		{
			if (e.action == "delete") {
				//trace("WifiDuoView::_onUpdateEquipement() ", isModuleDeBase, e.action, e.item);
				var eq:EquipementView = e.item;
				if (eq == this) return;
				
				if (isModuleDeBase) {
					if (eq is WifiDuoView) {
						deleteObj();
						return;
					} 
				} 
				
				// if master, this is the slave
				if (eq is WifiDuoView /*&& master != null*/) {
					deleteObj();
					return;
				}
				
				if (!isModuleDeBase && connectedEthernetEquipements.indexOf(eq) !== -1) {
					
					var num:int = connectedEthernetEquipements.length;
					
					//trace("WifiDuoView::_onUpdateEquipement() nb equipts connectés:", num);
					// the eq objet is connected to this WifiDuoView
					if (num == 1) {
						connectedEthernetEquipements = [];
						deleteObj();
					} else {
						var index:int = connectedEthernetEquipements.indexOf(eq);
						connectedEthernetEquipements.splice(index, 1);
						//EquipementsLayer.updateEquipementById(uniqueId);
					}
				}
				
			}
		}
		
		override public function deleteObj():void
		{
			trace("WifiDuoView::deleteObj()");
			//--count;
			//super.deleteObj();
			for (var i:int = 0; i < connexionViewsAssociated.length; i++)
			{
				var eqView:EquipementView = connexionViewsAssociated[i] as EquipementView;
				
				var len:int = connectedEthernetEquipements.length;
				var arr:Array = connectedEthernetEquipements.concat();
				for (var ii:int = 0; ii < len; ii++) {
					var eq:EquipementView = arr[ii] as EquipementView;
					eq.setConnexion(null);
					connectedEthernetEquipements.splice(ii, 1);
					//EquipementsLayer.updateEquipement(eq);
				}
				
				/*arr = connectedWifiEquipements.concat();
				len = arr.length;
				for (var iii:int = 0; iii < len; iii++) {
					eq = arr[iii] as EquipementView;
					eq.setConnexion(null);
					connectedWifiEquipements.splice(iii, 1);
					EquipementsLayer.updateEquipement(eq);
				}*/
				
				//EquipementsLayer.updateEquipement(eqView);
			}
				
			var bloc:Bloc = parentBloc;
			if (bloc) bloc.equipements.removeEquipement(this);
		}
		
		public function addSlave(e:EquipementView):void
		{
			if (slaves.indexOf(e) == -1) {
				slaves.push(e);
				/*var connection:ConnectionVO = new ConnectionVO(this, e, "cpl");//milou
				trace("connection " + connection.toString());
				_appmodel.connectionsCollection.push(connection);
				trace(_appmodel.connectionsCollection.toString());*/
			}
		}
		
		public function removeSlave(e:EquipementView):void
		{
			var index:int = slaves.indexOf(e);
			slaves.splice(index, 1);
		}
		
		override protected function mouseUpWhileDrag():void
		{
			super.mouseUpWhileDrag();
			/*if (connectedEthernetEquipements != null && connectedWifiEquipements != null)
			{
				var arr:Array = connectedEthernetEquipements.concat(connectedWifiEquipements);
				//trace("WifiDuoView::mouseUpWhileDrag() ",arr.map(_traceEquipement).join(","));
				var distances:Array = [];
				var distancesWifi:Array = [];
				// si distance apres deplacement > 5m ethernet entre wfe et chaque equipement auquel il est connecté, alerte
				// si distance apres deplacement > 15m wifi entre wfe et chaque equipement auquel il est connecté, alerte
				for (var i:int = 0; i < arr.length; i++)
				{
					var eq:EquipementView = arr[i] as EquipementView;
					trace("distance WiFiDUO->", eq, eq.selectedConnexion, eq.getDistance(this));
					distances.push(eq.getDistance(this));
				}
				if (distances.length > 0) {
					var d:int = (Math.max.apply(null, distances));
					if (d >= Config.DISTANCE_WIFIDUO_MAX) {
						//do something
					}
					if (d < 1) {
						// alert
					}
				}
			}*/
		}
	}

}