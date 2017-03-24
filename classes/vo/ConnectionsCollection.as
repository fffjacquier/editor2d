package classes.vo
{
	import classes.config.ModesDeConnexion;
	import classes.model.ApplicationModel;
	import classes.views.EquipementsLayer;
	import classes.views.equipements.DecodeurView;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.LiveplugView;
	import classes.views.equipements.SwitchView;
	import classes.views.equipements.WifiDuoView;

	public class ConnectionsCollection
	{
		private var _connections:Array = new Array();
		
		public function ConnectionsCollection()
		{
		}
		
		public function fromXML(connectionsXML:XMLList):void
		{
			var connection:ConnectionVO
			
			for each(var xml:XML in connectionsXML.*) 
			{
				var parentId:String = xml.@parent || null;
				createConnectionById(xml.@eq1, xml.@eq2, xml.@type, parentId, xml.@needsCheck);
			}
		}
		
		public function toXML():XML
		{
			var connectionNode:XML = new XML("<connections></connections>");
			for (var i:int = 0; i< length; i++)
			{
				var connection:ConnectionVO = _connections[i] as ConnectionVO;
				connectionNode.appendChild(connection.toXML());
			}
			return connectionNode;
		}
		
		public function createConnectionById(eq1Id:String, eq2Id:String, connectionType:String, parentEquipmentId:String = null, needsCheck:String = "false"):void
		{			
			var connection:ConnectionVO = new ConnectionVO(eq1Id, eq2Id, connectionType, parentEquipmentId);				
			if (needsCheck == "true") connection.needsToBeChecked = true;
			else connection.needsToBeChecked = false;
		}
		
		
		public function createConnection(eq1:EquipementView, eq2:EquipementView, connectionType:String, parentEquipment:EquipementView = null):void
		{
			if(ApplicationModel.instance.flagForEditorDeletion) return;
			//trace("createConnection", eq1, eq2);
			var parentId:String = parentEquipment ? parentEquipment.uniqueId : null;
			/*if (connectionType === ModesDeConnexion.ETHERNET) {
				trace("crerateconnection() nb ethernets connectés:", getReceiverConnections(eq1).length, eq1.vo.nbPortsEthernet);
			}*/
			createConnectionById(eq1.uniqueId, eq2.uniqueId, connectionType, parentId)			
			
		}
		
		public function push(argument:*):void
		{
			if(argument is ConnectionVO)
			{
				var newConnection:ConnectionVO = argument as ConnectionVO;
				for (var i:int = 0; i< length; i++)
				{
					var connection:ConnectionVO = _connections[i] as ConnectionVO;
					if(connection.hasSameEquipments(newConnection))
					{
						connection.type == newConnection.type;
						connection.parentId = newConnection.parentId;
						return;
						//connection.hideLine();
						//_connections.splice(i, 1);
					}					
				}
				_connections.push(newConnection);
				//return newConnection;
			}
			else if(argument is Array)
			{
				var arr:Array = argument;
				for (i = 0; i< arr.length; i++)
				{
					push(arr[i] as ConnectionVO);
				}
			}
		}
		
		public function get connections ():Array
		{
			return _connections;
		}
		
		public function getGrandParent(eq:EquipementView):EquipementView
		{
			var providerCnnection:ConnectionVO = getProvidingConnection(eq);
			if(providerCnnection) return providerCnnection.provider;
			return null;
		}
		
		//la  connexion dont l'équipement est le receveur
		public function getProvidingConnection(eq:EquipementView):ConnectionVO
		{
			for (var i:int = 0; i < _connections.length; i++) 
			{
				var connection:ConnectionVO = _connections[i] as  ConnectionVO;
				if (connection.receiverIs(eq) ) {
					return connection;
				}
			}
			return null;
		}
		
		//les  connexions dont l'équipement est le provider
		// FJ patch attribut filterType 20/06 car retour incorrect quand on teste le nb de ports Ethernet libres 
		//(Wi-Fi pris en compte)
		// 
		//public function getReceivingConnections(eq:EquipementView, filterType:String="ethernet"):Array
		public function getReceivingConnections(eq:EquipementView, filterType:String= null):Array
		{
			var tmp:Array = new Array();
			for (var i:int = 0; i < _connections.length; i++) 
			{
				var connection:ConnectionVO = _connections[i] as  ConnectionVO;
				if (connection.providerIs(eq)) {
					if (filterType == null) {// si on a besoin d'avoir wifi et ethernet // attention si on ne met rien en parametre pour filterType ça va etre ethernet par defaut, on n'aura jamais  filterType == null donc là il faut changer 
												//idealement mettre null par defaut (FilterType:String="ethernet") pour avoir wifi et ethernet et remplir si on veut juste wifi ou ethernet - bon je le fais maintenant pour tester 
						tmp.push(connection);
					} else if (filterType == ModesDeConnexion.WIFI){
						if (connection.type == filterType) {
							tmp.push(connection);
						}
					} else {
						if (connection.type == filterType || connection.type == ModesDeConnexion.CPL) {
							tmp.push(connection);
						}
					}
				}
			}
			trace("getReceivingConnections ", filterType, eq, tmp.length);
			return tmp;
		}
		
		//toutes les connexions dont l'équipement fait partie en tant que receveur ou provider
		//utilisé pour le panneau info du menuHeader
		public function getDirectConnections(eq:EquipementView):Array
		{
			var tmp:Array = new Array();
			for (var i:int = 0; i < _connections.length; i++) 
			{
				var c:ConnectionVO = getConnectionAt(i);
				if (c.contains(eq)) {
					tmp.push(c);
				}
			}
			return tmp;
		}

		/**
		 * Cette fonction doit nous renvoyer quel équipement il est possible d'enlever pour le brancher sur un switch
		 * Ce ne peut pas etre un décodeur, ni un liveplugHD+ s'il a un décodeur en fin de ligne, ni un liveplug wifi duo
		 * 
		 * @param eq L'EquipementView
		 * @return Renvoie l'EquipementView ou null
		 */
		public function getRemovableEquipment(eq:EquipementView):EquipementView
		{
			//trace("getRemovableEquipment " + eq);
			for (var i:int = 0; i < _connections.length; i++) 
			{
				var connection:ConnectionVO = _connections[i] as  ConnectionVO;
				//trace("connection.receiver "+i+", " + connection.receiver, connection.provider);
				if (connection.providerIs(eq)) {
					var receiver:EquipementView =  connection.receiver;
					//trace("Receiver:", receiver, "istermnial:", receiver.isTerminal, "isSwitch:", receiver.isSwitch, "isDecoderConnectionSource:", receiver.isDecoderConnectionSource, receiver.isDecodeur);
					//if(!(receiver is DecodeurView) && !(receiver is LiveplugView) && !(receiver is WifiDuoView)) return receiver;
					if(receiver.isTerminal && !receiver.isDecodeur && connection.type != ModesDeConnexion.WIFI) return receiver;
					if(!(receiver.isSwitch) && !(receiver.isDecoderConnectionSource)  && connection.type != ModesDeConnexion.WIFI) return receiver;
				}
			}
			return null;
		}
		
		/**
		 * Récupérer le provider qui fournit la connexion à l'équipement
		 * 
		 * @param eq L'equipmentView dont on cherche le provider
		 * @return Le provider de eq s'il y en a un 
		 */
		public function getEquipmentProvider(eq:EquipementView):EquipementView
		{
			var connection:ConnectionVO =  getProvidingConnection(eq);
			if(!connection) return null;
			return connection.provider;
		}
		
		public function getUniqueReceiver(eq:EquipementView):EquipementView
		{
			if(getReceivingConnections(eq).length != 1) return null;
			for (var i:int = 0; i < _connections.length; i++) 
			{
				var connection:ConnectionVO = _connections[i] as  ConnectionVO;
				if (connection.providerIs(eq)) {
					return connection.receiver;
				}
			}
			return null;
		}
		
		//non utilise
		public function getOneReceiver(eq:EquipementView):EquipementView
		{
			for (var i:int = 0; i < _connections.length; i++) 
			{
				var connection:ConnectionVO = _connections[i] as  ConnectionVO;
				if (connection.providerIs(eq)) {
					return connection.receiver;
				}
			}
			return null;
		}
		
		public function getSwitchReceiver(eq:EquipementView):EquipementView
		{
			//trace("getSwitchReceiver " + eq);
			
			for (var i:int = 0; i < _connections.length; i++) 
			{
				var connection:ConnectionVO = _connections[i] as  ConnectionVO;
				//trace("getSwitchReceiver " + connection.receiver);
				if (connection.providerIs(eq) && connection.receiver is SwitchView ) {
					//trace("getSwitchReceiver eq " + eq + " " +connection.receiver);
					return connection.receiver;
				}
			}
			return null;
		}
		
		public function getConnectionAt (i:int):ConnectionVO
		{
			return _connections[i] as ConnectionVO;
		}
		
		public function getByEquipmentsId (providerId:String, receiverId:String):ConnectionVO
		{
			for (var i:int = 0; i< length; i++)
			{
				var connection:ConnectionVO = _connections[i] as  ConnectionVO;
				if(connection.providerId == providerId &&  connection.receiverId == receiverId)
				{
					return connection;
				}				
			}
			return null;
		}
		
		public function getByEquipments (provider:EquipementView, receiver:EquipementView):ConnectionVO
		{
			for (var i:int = 0; i< length; i++)
			{
				var connection:ConnectionVO = _connections[i] as  ConnectionVO;
				if(connection.provider == provider &&  connection.receiver == receiver)
				{
					return connection;
				}				
			}
			return null;
		}
	
		
		public function getIndex (connection:ConnectionVO):int
		{
			for (var i:int = 0; i< length; i++)
			{
				//if(getConnectionAt(i).hasSameEquipments(connection))
				if( _connections[i] == connection)
				{
					return i;
				}				
			}
			return -1;
		}
		
		public function remove(connection:ConnectionVO):void
		{
			var index:int = getIndex(connection);
			//trace("INDEX " + index);
			_connections.splice(index, 1);
			//trace("ConnectionsCollection::remove", _connections.length); 
		}
		
		public function get length ():int
		{
			return _connections.length;
		}
		
		public function toString():String
		{
			return _connections.map(function(connection:ConnectionVO,index:int, arr:Array):String{return "("+connection.toString() +")";}).toString();
		}
	}
}