package classes.views.equipements 
{
	import classes.vo.EquipementVO;
	
	public class LiveplugView extends EquipementView
	{
		public var equipement:EquipementView;
		
		// used only when recreating plan form xml, see Editor2D.createFromXML() - FJ 17/02/2012 12:25
		public var equipementStr:String;
		public var masterStr:String;
		public var slavesStr:String;
		
		public var isModuleDeBase:Boolean = false;
		public static var count:int = 0;// not needed anymore*/
		public var master:LiveplugView;/* should contain the related liveplug master*/
		public var slaves:Array = [];/* an array of all the slaves */
		
		public function LiveplugView(pvo:EquipementVO = null) 
		{
			super(pvo);
			isConnector = true;
			//id = count;
			//++count;
			//trace("LiveplugView::count",count)
		}
		
		public function addSlave(e:EquipementView):void
		{
			if (!isModuleDeBase) return;
			
			if (slaves.indexOf(e) == -1) {
				slaves.push(e);	
				/*var connection:ConnectionVO = new ConnectionVO(this, e, "liveplug");//milou
				trace("connection " + connection.toString());
				_appmodel.connectionsCollection.push(connection);
				trace(_appmodel.connectionsCollection.toString());*/
			}
		}
		
		public function removeSlave(e:EquipementView):void
		{
			if (!isModuleDeBase) return;
			
			var index:int = slaves.indexOf(e);
			slaves.splice(index, 1);
		}
		
		override public function deleteObj():void
		{
			//--count;
			//trace("LivePlugView::deleteObj()");
			super.deleteObj();
			// check if master or not
			// if this is the last slave, remove the master too
			/*var master:LiveplugView = LiveplugView(this).master;
			if (master != null && master.slaves.length == 1 && (master.slaves[0] == this) ) {
				if(master.equipement != null) master.equipement.setConnexion(null);
				equipements.removeEquipement(master);
				// on enleve l'equipement de la liste des slaves
				master.removeSlave(this);
			}*/
		}
	}

}