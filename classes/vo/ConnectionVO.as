package classes.vo
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.controls.DeleteConnectionEvent;
	import classes.controls.UpdateEquipementViewEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.GeomUtils;
	import classes.utils.Measure;
	import classes.views.equipements.WifiExtenderView;
	import classes.views.EquipementsLayer;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.LiveboxView;
	import classes.views.equipements.LiveplugView;
	import classes.views.equipements.SwitchView;
	import classes.views.plan.ConnectionLine;
	import classes.views.plan.Editor2D;
	import classes.views.plan.IntersectionPoint;
	
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class ConnectionVO
	{
		public var provider:EquipementView;
		public var receiver:EquipementView;
		public var providerId:String;
		public var receiverId:String;
		public var type:String;
		public var parentId:String;
		private var _line:ConnectionLine;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _appModel:ApplicationModel = ApplicationModel.instance;
		private var _collection:ConnectionsCollection = ApplicationModel.instance.connectionsCollection;
		
		public var needsToBeChecked:Boolean = false;/* si on a déplacé un équipement de plus de x metres */
		
		/**
		 * Chaque connexion ou ConnectionVO peut se définir par 4 éléments:
		 * - son provider
		 * - son receiver
		 * - son type de connexion
		 * - son parentConnection
		 * 
		 * provider: l'équipement qui fournit la connexion, correspond à id1, forcément un connector
		 * receiver: est l'équipement qui reçoit la connexion d'un provider, id2, il peut être un terminal ou un connector
		 * parentConnection: chaque connection a un parent qui est le provider de son provider dans une connexion dite 'parentConnection', celle qui est juste en amont, peut être null dans le cas d'un équipement connecté directement à la Livebox
		 * 
		 * @param id1 Cet id1 nous donne l'équipement fournisseur (provider)
		 * @param id2 Cet id2  nous donne l'équipement receveur (receiver)
		 * @param connectionType Valeurs possibles : 'wifi', 'cpl' or 'ethernet'
		 * @param parentEquipmentId	L'id du provider du provider
		 */
		public function ConnectionVO(id1:String, id2:String, connectionType:String, parentEquipmentId:String = null)
		{ 
			//a faire si tout fonctionne : virer le parametre parentEquipmentId ici et dans tous les appels a la fonction
			// parentId est setté plus bas dans //grandProviders updates
			//parentId = parentEquipmentId;
			providerId = id1;
			receiverId = id2;
			provider = EquipementsLayer.getEquipement(providerId);
			receiver = EquipementsLayer.getEquipement(receiverId);
			
			if(provider == null) return;
			if(receiver == null) return;
			
			//grandProviders updates
			if (provider.connection) parentId = provider.connection.providerId;
			//20/06 attention 
			var childs:Array = _collection.getReceivingConnections(receiver);
			for (var i:int = 0; i < childs.length; i++) 
			{
				var c:ConnectionVO = (childs[i] as ConnectionVO);
				c.updateGrandProvider(provider);
			}	
			
			type = connectionType;
			trace("ConnectionVO", type, provider, receiver);
			_line = new ConnectionLine(this);
			//on doit pusher ici la connexion pour que l'equipement puisse desssiner son icone 
			//cela permet juste à l'equipement de connaitre sa connexion car on n'a pas mis de variable locale renseignant de la connexion
			//on parcourt _collection pour celà; peut être faudra-t-il changer ça si ça pôur optimiser la CPU
			_collection.push(this);
			if(receiver.isTerminal) receiver.addConnexionIcon();
			
			_appModel.addDeleteConnectionListener(_onConnectionDelete);
			_appModel.addUpdateEquipementListener(_onUpdateEquipement);
		}
		
		public static function createId():int
		{
			return (new Date().time);
		}
		
		public function get parentConnection():ConnectionVO
		{
			if(parentId == null) return null;
			
			return  _collection.getByEquipmentsId(parentId, providerId);
		}
		
		public function updateGrandProvider(grandPa:EquipementView):void
		{
			parentId = grandPa.uniqueId;
		}
		
		public function get grandProvider():EquipementView
		{
			if (parentId == null) return null;
			// FJ patch 20/06 debug parentConnection null cas des connexions directes uniquement
			if (parentConnection == null) return null;
			
			return  parentConnection.provider;
		}
		
		public function update(type:String):void
		{
			this.type = type;
		}
		
		public function getOther(eq:EquipementView):EquipementView
		{
			if (eq == provider) return receiver;
			else return provider;
		}
		
		public function contains(eq:EquipementView):Boolean
		{
			if (eq == provider) return true;
			if (eq == receiver) return true;
			return false;
		}
		
		public function receiverIs(eq:EquipementView):Boolean
		{
			if (eq == receiver) return true;
			return false;
		}
		
		public function providerIs(eq:EquipementView):Boolean
		{
			if (eq == provider) return true;
			return false;
		}
		
		public function get p1():Point
		{
			return new Point(provider.x, provider.y);
		}
		
		public function get p2():Point
		{
			return new Point(receiver.x, receiver.y);
		}
		
		public function hasSameEquipments(connection:ConnectionVO):Boolean
		{
			if(provider == connection.provider && receiver == connection.receiver) return true;
			return false;
		}
		
		public function equals(connection:ConnectionVO):Boolean
		{
			if(hasSameEquipments(connection) && type == connection.type) return true;
			return false;
		}
		
		public function toString():String
		{
			return provider + " " + receiver + " " + type + " " + grandProvider;
		}
		
		public function get distance():Number
		{
			return Measure.realSize(Point.distance(p1, p2));
		}
		
		public function get isAcceptable():Boolean
		{
			//rajouter detection de murs etc
			//checkIntersections();
			var distanceOK:Boolean = true;
			if (type == ModesDeConnexion.WIFI) distanceOK = (distance <= Config.DISTANCE_WIFI);
			else if(type == ModesDeConnexion.ETHERNET) {
				distanceOK = !needsToBeChecked;
				//trace("isAcceptable", distanceOK);
			} else {
				//trace("CRAIGNOS !!", type);
			}
			return distanceOK;
		}
		
		public function checkIntersections():void
		{
			var intersectionPoints:Array = GeomUtils.getHittingPoints(p1, p2, _line);
			/*trace("-----------------------------------");
			trace("distance " + Measure.roundedPixelToMetric(Point.distance(p1, p2)));
			trace(intersectionPoints.length + " murs traversés");*/
			var mursPorteursCount:int = 0;
			for(var i:int = 0; i< intersectionPoints.length; i++)
			{
				var intersection:IntersectionPoint = intersectionPoints[i];
				if(intersection.mur.murPorteur) mursPorteursCount++;
			}
			/*trace("Nombre de murs porteurs " + mursPorteursCount);
			trace("nombre de plafonds traversés " + Math.abs(provider.floorId - receiver.floorId));*/
		}
		
		
		public function displayLine(displayParent:Boolean = false):void
		{
			if(!_line) return;
			if(!provider) return;
			_line.draw();
			
			if(displayParent && parentConnection)
			{
				parentConnection.displayLine(true);
			}
			
			var lb:LiveboxView = EquipementsLayer.getLivebox();
			//l'equipement layer de l'étage de la livebox (different de currenfloor) est déjà en alpha .5
			var aleph:Number = (receiver.floorId == lb.floorId) ?  1 : .5;
			if(provider.floorId != _model.currentFloorId && ! provider.isLivebox) 
			{
				provider.visible = true;
				provider.alpha = aleph;
			}
			if(receiver.floorId != _model.currentFloorId) 
			{
				receiver.visible = true;
				receiver.alpha = aleph;
			}
		}
		
		public function hideLine(hideParent:Boolean = false):void
		{
			if(!_line) return;
			_line.clear();
			if(hideParent && parentConnection)
			{
				parentConnection.hideLine(true);
			}
			if(provider.floorId != _model.currentFloorId  && ! provider.isLivebox) 
			{
				provider.visible = false;
				provider.alpha = 1;
			}
			if(receiver.floorId != _model.currentFloorId) 
			{
				receiver.visible = false;
				receiver.alpha = 1;
			}
		}
		 
		private function _onConnectionDelete(e:DeleteConnectionEvent):void
		{
			var deletedConnection:ConnectionVO = e.connection;
			var parent:ConnectionVO = deletedConnection.parentConnection;			 
			
			if(parent == this) 
			{
				// si le receiver et le provider sont des lphd
				// et si la connection qui se supprime a un switch
				// pas de remove
				
				var wifiCo:int = (_collection.getReceivingConnections(receiver, ModesDeConnexion.WIFI).length);
				if (receiver is WifiExtenderView/* && deletedConnection.type == ModesDeConnexion.WIFI*/) {
					trace("_onConnectionDelete()", receiver.connection);
					/*var connections:Array = _collection.connections;
					for (var i:int = 0; i < connections.length; i++) 
					{
						var cvo:ConnectionVO = connections[i] as  ConnectionVO;
						if (cvo.providerIs(receiver) ) {
							trace("AAA",cvo);
						}
					}*/
					
					var ethCo:int = (_collection.getReceivingConnections(receiver, ModesDeConnexion.ETHERNET).length);
					trace("wifiCo",wifiCo, "ethCo",ethCo, (wifiCo + ethCo) > 0);
					// on check les connexions sur ce receiver wifi et ethernet
					if ((wifiCo + ethCo) > 0) {
						//return;
					} else {
						remove();
						return;
					}
				}
				
				//on est dans la connexion parente de la connexion supprimée, il y en a une seule
				//array des connexions du receveur 
				var connections:Array = _collection.getReceivingConnections(receiver, ModesDeConnexion.ETHERNET);
				//trace("_onConnectionDelete", receiver, provider, deletedConnection.type, deletedConnection.receiver, deletedConnection.provider, connections.length);
				
				if(receiver is SwitchView  && (deletedConnection.type == ModesDeConnexion.ETHERNET || deletedConnection.type == ModesDeConnexion.CPL)) 
				{	
					if(connections.length == 1) 
				    {
					   //il s'agit d'un switch les connexions sont toutes ethernet , la fonction qui cherche si c'est un  uniqueReceiver utilise getReceivingConnections sans parametre mais comme il n'y a aura pas de connexion wifi ça convient 
						var equipment:EquipementView = receiver.uniqueReceiver;
					 
					   var selectedconnection:String = equipment.selectedConnexion;
					   equipment.connection.remove();	
					   //click dans deconnexion il y a suppression des équipements donc des connexions
					   //on empeche la création automatique de cette nouvelle connexion 
					   if(_appModel.screen != ApplicationModel.SCREEN_EDITOR) return;
					   _collection.createConnection(provider, equipment, ModesDeConnexion.ETHERNET, provider.provider)
					   equipment.selectedConnexion = selectedconnection;					
					   equipment.draw();
					   if(equipment.isTerminal) equipment.showConnections();
					   //trace("_onConnectionDelete2", equipment);
				    }					
				}
				//trace("isSwitch", deletedConnection.receiver.isSwitch);
				if(deletedConnection.receiver.isSwitch /*&& deletedConnection.provider is LiveplugView*/) return;
				//trace("deletedConnection", deletedConnection, deletedConnection.parentConnection, deletedConnection.provider, deletedConnection.receiver);
				//trace("\tparent", this, provider, receiver)
				if (connections.length == 0 && wifiCo == 0) {
					remove();
				}
			}			
		}
		 
		private function _onUpdateEquipement(e:UpdateEquipementViewEvent):void
		{
			if(e.action !=  UpdateEquipementViewEvent.ACTION_DELETE) return;
			if(e.item.isTerminal && e.item == receiver) remove();
		}
		
		/**
		 * enlever une connexion
		 * 
		 * @param fillSlot Pour le brancher au switch
		 * @param doRemoveConnector Pour ne pas le supprimer qd il est avec une seule connexion
		 * 
		 */
		public function remove(fillSlot:Boolean = true, doRemoveConnector:Boolean = true):void
		{
			_appModel.removeDeleteConnectionListener(_onConnectionDelete);
			_appModel.removeUpdateEquipementListener(_onUpdateEquipement);
			hideLine();
			var connection:ConnectionVO = this;
			if (provider && receiver) {
				if(provider.linkedEquipment != null && receiver.linkedEquipment != null) {
					provider.linkedEquipment = null;
					receiver.linkedEquipment = null;
				}
			}
			_collection.remove(this); 
			//dans ce cas on a teste en mettant doRemoveConnector=false 
			trace("ConnectionVO::remove() terminal:", receiver.isTerminal, "connector", receiver.isConnector);
			if(receiver.isTerminal)
			{
				receiver.resetConnexion();
				if(! (doRemoveConnector == false && provider.isLPHD) )  _appModel.notifyDeleteConnection(connection);
			}
			else if(receiver.isConnector)
			{
				//si le provider est un switch et le receveur un connector (liveplug) on ne doit pas supprimer le liveplug car il doit etre rebranche à la livebox
				//1906    + on a un switch avec un seul receiver qd on remove un objet du switch avec 2 receivers
				
				/*if (provider && provider.isSwitch && receiver.isLPHD) {
					//provider.remove();
					receiver.remove();
				}
				else
				{
					if(doRemoveConnector) receiver.remove();
				}*/
				trace("ConnectionVO::remove() isConnector", provider + " : " + receiver + " : " + _collection.getReceivingConnections(receiver, ModesDeConnexion.ETHERNET).length);
				doRemoveConnector = (_collection.getReceivingConnections(receiver, ModesDeConnexion.ETHERNET).length == 0 /*&& _collection.getReceivingConnections(receiver, ModesDeConnexion.WIFI).length == 0*/) ? true : false;
				if(doRemoveConnector) receiver.remove();
				if (provider && provider.isSwitch && receiver.isLPHD)
				{
					_appModel.notifyDeleteConnection(connection);
				}
				else
				{
					if(doRemoveConnector) _appModel.notifyDeleteConnection(connection);
				}
			}
			trace("connectionVO::remove doRemoveConnector ", doRemoveConnector);
			
			//cas des connection ethernet uniquement
			if(type != ModesDeConnexion.ETHERNET) return;
			//si on supprime la connection ethernet d'un equipement de son provider alors que le provider a un switchview, 
			//on doit remplacer le port vide par un equipement connecté au switch			
			//on détecte si on est dans ce cas
			//mais ceci ne doit pas avoir lieu quand on branche un decodeur
			//trace("connectionVO::remove", fillSlot, doRemoveConnector, provider); 
			if(!fillSlot) return;
			if(!provider) return;
			var switchView:SwitchView = provider.switchAsChild as SwitchView;
			
			//trace("connectionVO::remove, switchView:", switchView, "provider:", provider);
			if(switchView)
			{
				//dans ce cas, on chosit une connection au hasard du switch et on le branche au provider
				var eq:EquipementView = switchView.oneReceiver;
				//trace("oneReceiver", eq);
				connection = _collection.getByEquipments(switchView, eq);
				trace("fin de ConnectionVO::remove conexion " + connection + " : " + provider + " : " + eq);
				if(connection) connection.remove();
				else trace("attention, connection devrait exister");
					
				_collection.createConnection(provider, eq, ModesDeConnexion.ETHERNET, provider.provider);
				eq.setConnexion(ModesDeConnexion.ETHERNET); //remettre ici le selectedConnexion de l'equipement plutot? 
				if(eq.isTerminal) eq.addConnexionIcon();
			}
		}
		 
		//------------ XML ----------------
		public function toXML():XML
		{
			var connectionNode:XML = new XML("<connection></connection>");
			connectionNode.@eq1 = providerId;
			connectionNode.@eq2 = receiverId;
			connectionNode.@type = type;
			connectionNode.@needsCheck = needsToBeChecked;
			//connectionNode.@distance = distance;
			if(parentId) connectionNode.@parent = parentId;
			return connectionNode;
		}		 	
	}
}