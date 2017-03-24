package classes.views 
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.views.equipements.DecodeurView;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.LiveboxView;
	import classes.views.equipements.LiveplugView;
	import classes.views.equipements.PriseView;
	import classes.views.equipements.WifiDuoView;
	import classes.views.equipements.WifiExtenderView;
	import classes.views.plan.Bloc;
	import classes.views.plan.Floor;
	import classes.vo.ConnectionVO;
	import classes.vo.EquipementVO;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Classe qui contient un ensemble de méthodes et d'utilités permettant de gérer ou récupérer des infos sur les équipements et leurs connexions
	 * 
	 * <p><strong>Remarque :</strong> Chaque Bloc contient son equipementsLayers sous forme de variable publique <code>equipements</code></p>
	 */
	public class EquipementsLayer extends Sprite 
	{
		public var equipementsArr:Array = new Array();
		public static var EQUIPEMENTS:Array = new Array();
		public static var LIVEBOX:Array = new Array();
		public static var WIFI_POINTS:Array = new Array();
		private var appmodel:ApplicationModel = ApplicationModel.instance;
		
		public static const NO_MASTER:String = "nomaster";
		public static const LIVEPLUG_MASTER:String = "liveplugmaster";
		public static const DUO_MASTER:String = "duomaster";
		
		public function EquipementsLayer() 
		{
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		public function get bloc():Bloc
		{
			return parent as Bloc;
		}
		
		public function get floorId():int
		{
			return bloc.floorId;
		}
		
		/**
		 * Ajoute un équipement dans le layer equipements de l'étage en cours
		 * 
		 * @param equipement L'équipement EquipementView qu'on veut ajouter
		 * @param addToStaticArrs Valeur Booléenne utilisée lors de déplacements d'equipements d'un bloc a l'autre ou d'un etage a l'autre (livebox) 
		 * (on passe pas toujours par removeEquipement())
		 */
		public function addEquipement(equipement:EquipementView, addToStaticArrs:Boolean = true):void
		{
			addChild(equipement);
			equipement.equipements = this;
			equipement.floorId = floorId;
			equipementsArr.push(equipement);
			//trace("addEquipement", equipement, equipement.parentBloc, equipement.parentBloc.equipements, equipementsArr);
			if(addToStaticArrs)
			{
				EQUIPEMENTS.push(equipement);
				if (equipement is LiveboxView) {
					LIVEBOX.push(equipement);
				}
				if (equipement is WifiExtenderView && !(equipement as WifiExtenderView).isModuleDeBase) {
					WIFI_POINTS.push(equipement);
				}
				if (equipement is WifiDuoView && !(equipement as WifiDuoView).isModuleDeBase) {
					WIFI_POINTS.push(equipement);
				}
				updateListeCourses();
			}
			//traceEquipements();
			appmodel.notifyUpdateEquipement(equipement, "add");
		}
		
		/**
		 * Supprime un équipement du layer equipements de l'étage actuel
		 * 
		 * @param equipement L'équipement view à enlever
		 * @param dosplice Valeur booléenne pour enlever l'équipement du tableau equipementsArr
		 * @param keepdata Valeur booléenne pour mettre à jour ou non la liste de courses
		 * @param dontnotify Valeur booléenne pour notifier ou non une mise à jour d'équipement
		 */
		public function removeEquipement(equipement:EquipementView, dosplice:Boolean= true, keepdata:Boolean= true, dontnotify:Boolean = false):void
		{
			//trace("removeEquipement", equipement);
			if (equipement && equipement.stage) {
				removeChild(equipement);
				var index:int;
				if(dosplice) {
					index = equipementsArr.indexOf(equipement);
					equipementsArr.splice(index, 1);
				}
				index = EQUIPEMENTS.indexOf(equipement);
				EQUIPEMENTS.splice(index, 1);
				if (equipement is LiveboxView) 
				{
					index = LIVEBOX.indexOf(equipement);
					LIVEBOX.splice(index, 1);
				}
				if (equipement is WifiExtenderView && !(equipement as WifiExtenderView).isModuleDeBase) {
					index = WIFI_POINTS.indexOf(equipement);
					WIFI_POINTS.splice(index, 1);
				}
				if (equipement is WifiDuoView && !(equipement as WifiDuoView).isModuleDeBase) {
					index = WIFI_POINTS.indexOf(equipement);
					WIFI_POINTS.splice(index, 1);
				}
				if(keepdata) 
					updateListeCourses();
				
				//traceEquipements();
				
				appmodel.notifySaveStateUpdate(true);
				
				if(!dontnotify) appmodel.notifyUpdateEquipement(equipement, "delete");
			}
		}
		
		public function moveWidthPiece(dep:Point):void
		{
			for (var i:int=0; i < equipementsArr.length; i++)
			{
				var equipement:EquipementView = equipementsArr[i];
				equipement.x += dep.x;
				equipement.y += dep.y;
			}
		}
		
		//----------------  private functions -------------------------------
		
		private function _removed(e:Event):void
		{
			//updateListeCourses();
			//trace("EquipementsLayer::_removed", equipementsArr.length)
			for (var i:int = 0; i < equipementsArr.length; i++)
			{
				var equipement:EquipementView = equipementsArr[i] as EquipementView;
				var bloc:Bloc = equipement.parentBloc;
				//trace(i, equipementsArr.length, equipement, bloc, "equipt etage;", equipement.floorId, "floor id:")
				if (bloc) 
				{
					bloc.equipements.removeEquipement(equipement, false, false);
				}
			}
			equipementsArr = new Array();
			
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		//------ public static functions ---------------------
		
		public static function getEquipement(uniqueId:String):EquipementView
		{
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.uniqueId === uniqueId) return e;
			}
			return null;
		}
		
		public static function getMasterAndServants(klass:Class):Array
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e is klass) tmp.push(e);
			}
			return tmp;
		}
		
		/**
		 * Renvoie le Liveplug maitre connecté sur la Livebox
		 * 
		 * @return Le LiveplugView connecté sur la Livebox ou un switch sur LB ou null si n'existe pas
		 */
		public static function getLiveplugMaster():LiveplugView
		{
			var tmp:Array = [];
			
			// on prend les connexions directes sur la Livebox
			var c:Array = ApplicationModel.instance.connectionsCollection.getDirectConnections(getLivebox());
			
			//if (c.length == 1) return connection.receiver;
			//trace("getLiveplugMaster() start")
			//trace("================");
			for (var i:int = 0; i< c.length; i++)
			{
				var connection:ConnectionVO = c[i] as  ConnectionVO;
				//trace("Connexion " +i+ " : "+connection);
				//trace("receiver:",connection.receiver.vo.type, "isDecodeurConnectionSource:", connection.receiver.isDecoderConnectionSource);
				// si c'est un liveplug et que ce LP ne mene pas à un décodeur 
				if (connection.receiver.vo.type == "LivePlugItem") {
					//return connection.receiver;
					if (ApplicationModel.instance.projectType === "adsl2tv"/* || ApplicationModel.instance.projectType === "adslSat"*/) {
						if(!connection.receiver.isDecoderConnectionSource) tmp.push(connection.receiver)
					} else {
						tmp.push(connection.receiver)
					}
				} 
				// FJ comment: la condition suivante vise à corriger le bug de mauvaise détection du Liveplug maitre s'il est branché sur switch au lieu de LB
				// si c'est un switch, on vérifie les connexions du switch pour voir s'il y a un Liveplug et que ce LP ne mène pas à un décodeur
				if (connection.receiver.vo.type == "SwitchItem") {
					var switchConnections:Array = ApplicationModel.instance.connectionsCollection.getDirectConnections(connection.receiver);
					for (var ii:int = 0; ii< switchConnections.length; ii++)
					{
						var co:ConnectionVO = switchConnections[ii] as ConnectionVO;
						//trace(co.receiver, co.provider);
						if (co.receiver.vo.type == "LivePlugItem") {
							//trace("Liveplug connecté au switch")
							if (ApplicationModel.instance.projectType === "adsl2tv") {
								if (!co.receiver.isDecoderConnectionSource) {
									//trace("Liveplug pas relié à un décodeur en adsl2tv");
									tmp.push(co.receiver)
								}
							} else {
								//trace("push Liveplug")
								tmp.push(co.receiver)
							}
						}
					}
				}
				//trace("-------------")
			}
			//trace("================");
			//return false
			
			//trace("getLiveplugMaster() end", tmp)
			return tmp[0];
		}
		
		public static function getClosestPrise(lb:LiveboxView):PriseView
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e is PriseView) {
					var p:PriseView = PriseView(e);
					// si pas le module de base et meme étage et distance < 15m /*et ports libres : 3 ethernet et 5 wifis*/
					if ( lb.floorId === p.floorId) {
						tmp.push(e);
					}
					/*if ( !w.isModuleDeBase && equipement.floorId === w.floorId && equipement.getDistance(w) < Config.DISTANCE_WIFI) 
					{
						tmp.push(e);
					}*/
				}
			}
			//trace("getClosestPrise", tmp);
			var values:Array = [];
			for (i = 0; i < tmp.length; i++)
			{
				var pv:PriseView = tmp[i] as PriseView;
				values.push({"distance":pv.getDistance(lb), "equipement":pv});
				//trace(values[i].distance, values[i].equipement);
			}
			values.sortOn("distance");
			for (i = 0; i < values.length; i++)
			{
				//trace(values[i].distance, values[i].equipement);
			}
			if (values.length == 0) return null;
			
			return values[0].equipement;
			//return tmp;
		}
		
		public static function getClosestWifiObjectsArray(equipement:EquipementView):Array
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e is WifiExtenderView || e is WifiDuoView) {
					var w:*;
					if (e is WifiExtenderView) {
						w = WifiExtenderView(e);
					}
					/*if (e is WifiDuoView) {
						w = WifiDuoView(e);
					}*/
					// si pas le module de base et meme étage et distance < 15m /*et ports libres : 3 ethernet et 5 wifis*/
					if (w != null && !w.isModuleDeBase && equipement.floorId === w.floorId && equipement.getDistance(w) < Config.DISTANCE_WIFI) 
					{
						tmp.push(e);
					}
				}
			}
			//trace("getClosestWifiExtender", tmp);
			return tmp;
		}
		
		public static function getWifiExtenderArray(equipement:EquipementView):Array
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.vo.type === "WifiExtenderItem") {
					var w:WifiExtenderView = WifiExtenderView(e);
					// si au meme étage que l'équipement et distance ok
					if ( equipement.floorId === w.floorId && equipement.getDistance(w) < Config.DISTANCE_WIFI) 
					{
						tmp.push(e);
					}
				}
			}
			//trace("getWifiExtenderArray", tmp);
			return tmp;
		}
		
		public static function getLiveplugHDArray(equipement:EquipementView):Array
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.vo.type === "LivePlugItem") {
					var w:LiveplugView = LiveplugView(e);
					// si au meme étage que l'équipement et distance ok et pas un master
					if ( !w.isModuleDeBase && equipement.floorId === w.floorId && equipement.getDistance(w) < Config.DISTANCE_ETHERNET) 
					{
						tmp.push(e);
					}
				}
			}
			//trace("getLiveplugHDArray", tmp);
			return tmp;
		}
		
		public static function getClosestWifiDuoArray(equipement:EquipementView):Array
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.vo.type == "WifiDuoItem") {
					var w:WifiDuoView = WifiDuoView(e);
					// si pas le module de base et meme étage et distance < 15m /*et ports libres : 3 ethernet et 5 wifis*/
					if (!w.isModuleDeBase && equipement.floorId === w.floorId && equipement.getDistance(w) < Config.DISTANCE_WIFI) 
					{
						tmp.push(e);
					}
				}
			}
			//trace("getClosestWifiDuoArray", tmp);
			return tmp;
		}
		
		public static function getClosestModule(equipement:EquipementView, func:Function):EquipementView /*could be WifiExtenderView or WifiDuoView*/
		{
			var arr:Array = func(equipement);
			return getClosestEquipement(arr, equipement);
		}
		
		public static function getClosestEquipement(arr:Array, equipement:EquipementView):EquipementView
		{
			var values:Array = [];
			for (var i:int = 0; i < arr.length; i++)
			{
				values.push({"distance":equipement.getDistance(arr[i]), "equipement":arr[i]});
				//trace("-- getClosestEquipement--",values[i].distance, values[i].equipement);
			}
			values.sortOn("distance");
			return (values.length > 0) ? values[0].equipement : null;
		}
		
		public static function getLivebox():LiveboxView
		{
			return LIVEBOX[0] as LiveboxView;
		}
		
		public static function isLiveboxPlay():Boolean
		{
			var lb:LiveboxView = LIVEBOX[0] as LiveboxView;
			if (lb != null) {
				return (lb.vo.name === "LiveboxPlay");
			} else {
				var xml:XML = ApplicationModel.instance.projetvo.xml_plan;
				//trace(String(xml.floors.floor.blocs.bloc.equipements.equipement.@vo).indexOf("LiveboxPlay"));
				return (String(xml.floors.floor.blocs.bloc.equipements.equipement.@vo).indexOf("LiveboxPlay") != -1)
			}
		}
		
		public static function resetConnexions():void
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				e.resetConnexion();
			}
		}
		
		/* Récupère le nombre d'équipements du meme type afin de déterminer si le nb maximal autorisé est atteint*/
		public static function getEquipements(klass:Class=null, type:String= null):int
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (type == null) {
					if (e is klass) tmp.push(e);
				} else {
					if (e is klass && e.vo.name == type) tmp.push(e);
				}
			}
			return tmp.length;
		}
		
		public static function isThereDecodeurConnected():Boolean
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e is DecodeurView && e.connection != null) return true;
			}
			return false;
		}
		
		public static function hasEquipmentsOnFloor(floor:Floor):Boolean
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				//trace("\tequipement", e.vo.name, e.floorId, floor.id);
				if (e.floorId === floor.id) tmp.push(e);
			}
			//trace("\thasEquipmentsOnFloor", floor.id, tmp.length)
			return (tmp.length > 0) ? true : false;
		}
		
		public static function getWifiConnectedEquipements():int
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.selectedConnexion === "wifi") tmp.push(e);
			}
			return tmp.length;
		}
		
		public static function getWifiExtenderConnectedEquipements():int
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.selectedConnexion === "wifiextender-wifi") tmp.push(e);
			}
			return tmp.length;
		}
		
		public static function getPortsLiveplugWifi():int
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				//trace("-----",e, e.selectedConnexion);
				if (e.selectedConnexion === ModesDeConnexion.DUO_ETHERNET) tmp.push(e);
			}
			return tmp.length;
		}
		
		public static function updateEquipement(equipement:EquipementView):void
		{
			return;
			var index:int = EQUIPEMENTS.indexOf(equipement);
			EQUIPEMENTS[index] = equipement;
			if (equipement is LiveboxView) {
				index = LIVEBOX.indexOf(equipement);
				LIVEBOX[index] = equipement;
			}
			if (equipement is WifiExtenderView && !(equipement as WifiExtenderView).isModuleDeBase) {
				index = WIFI_POINTS.indexOf(equipement);
				WIFI_POINTS[index] = equipement;
			}
		}
		
		public static function updateEquipementById(id:String):void
		{
			var lp:EquipementView = getEquipement(id);
			updateEquipement(lp);
		}
		
		public static function isThereAConnexionToLivebox():Boolean
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				//trace("isThereAConnexionToLivebox", e.selectedConnexion, e.vo.type, e.vo.name);
				//if (e is LiveplugView) trace (LiveplugView(e).equipement);
				if (e.selectedConnexion != null && e.vo.type !== "PriseItem" && e.vo.type != "LiveboxItem") tmp.push(e);
			}
			//trace("isThereAConnexionToLivebox", tmp.length)
			return (tmp.length > 0) ? true : false;
		}
		
		public static function isThereALiveplugModuleDeBase():Boolean
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.vo.type === "LivePlugItem" && (e as LiveplugView).isModuleDeBase) tmp.push(e);
			}
			trace("isThereALiveplugModuleDeBase", tmp.length)
			return (tmp.length > 0) ? true : false;
		}
		
		public static function isthereLiveplugMasterConnectedAndUsable():Boolean
		{
			var tmp:Array = [];
			
			// on prend les connexions directes sur la Livebox
			var c:Array = ApplicationModel.instance.connectionsCollection.getDirectConnections(getLivebox());
			for (var i:int = 0; i< c.length; i++)
			{
				var connection:ConnectionVO = c[i] as  ConnectionVO;
				trace(connection);
				trace(connection.receiver.isDecoderConnectionSource, (ApplicationModel.instance.projectType === "adsl2tv"));
				// si c'est un liveplug et que ce LP ne mene pas à un décodeur 
				if (connection.receiver.vo.type == "LivePlugItem") {
					
					if (ApplicationModel.instance.projectType === "adsl2tv") {
						if(!connection.receiver.isDecoderConnectionSource) tmp.push(connection.receiver);
					} else {
						tmp.push(connection.receiver);
					}					
				}
				
				//trace("-------------")
			}
				// FJ comment: la condition suivante vise à corriger le bug de mauvaise détection du Liveplug maitre
				// s'il est branché sur switch au lieu de LB
				// si c'est un switch, on vérifie les connexions du switch pour voir s'il y a un Liveplug et que ce LP ne mène pas à un décodeur
				if (connection != null && connection.receiver.vo.type == "SwitchItem") {
					var switchConnections:Array = ApplicationModel.instance.connectionsCollection.getDirectConnections(connection.receiver);
					for (var ii:int = 0; ii< switchConnections.length; ii++)
					{
						var co:ConnectionVO = switchConnections[ii] as ConnectionVO;
						//trace(co.receiver, co.provider);
						if (co.receiver.vo.type == "LivePlugItem") {
							//trace("Liveplug connecté au switch")
							if (ApplicationModel.instance.projectType === "adsl2tv") {
								if (!co.receiver.isDecoderConnectionSource) {
									//trace("Liveplug pas relié à un décodeur en adsl2tv");
									tmp.push(co.receiver)
								}
							} else {
								//trace("push Liveplug")
								tmp.push(co.receiver)
							}
						}
					}
				}
			trace("isthereLiveplugMasterConnectedAndUsable? num=", tmp.length)
			return (tmp.length > 0) ? true : false;
		}
		
		/**
		 * Indique s'il existe un LivepluHD+ présent et qui ne soit pas la source d'un décodeur
		 * 
		 * @return Boolean Renvoie true si présence d'un LiveplugHD pas source d'un décodeur
		 */
		public static function isThereLPHDNotDecodeurSource():Boolean
		{
			var c:Array = ApplicationModel.instance.connectionsCollection.connections;
			//trace("================");
			// on prend les connexions directes sur la Livebox
			c = ApplicationModel.instance.connectionsCollection.getDirectConnections(getLivebox());
			for (var i:int = 0; i< c.length; i++)
			{
				var connection:ConnectionVO = c[i] as  ConnectionVO;
				//trace(connection);
				//trace(connection.receiver.isDecoderConnectionSource);
				// si c'est un liveplug et que ce LP ne mene pas à un décodeur 
				if (connection.receiver.vo.type == "LivePlugItem" && !connection.receiver.isDecoderConnectionSource) {
					return true;
				}
				// FJ comment: la condition suivante vise à corriger le bug de mauvaise détection du Liveplug maitre s'il est branché sur switch au lieu de LB
				// si c'est un switch, on vérifie les connexions du switch pour voir s'il y a un Liveplug et que ce LP ne mène pas à un décodeur
				if (connection.receiver.vo.type == "SwitchItem") {
					var switchConnections:Array = ApplicationModel.instance.connectionsCollection.getDirectConnections(connection.receiver);
					for (var ii:int = 0; ii< switchConnections.length; ii++)
					{
						var co:ConnectionVO = switchConnections[ii] as ConnectionVO;
						//trace(co.receiver, co.provider);
						if (co.receiver.vo.type == "LivePlugItem"  && !connection.receiver.isDecoderConnectionSource) {
							//trace("Liveplug connecté au switch")
							return true;
						}
					}
				}
				//trace("-------------")
			}
			//trace("================");
			return false
		}
		
		public static function isThereLiveplugDecodeur():Boolean
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.vo.type === "DecodeurItem" && e.selectedConnexion === ModesDeConnexion.LIVEPLUG) tmp.push(e);
			}
			//trace("isThereLiveplugDecodeur? num=", tmp.length)
			return (tmp.length > 0) ? true : false;
		}
		
		public static function isThereAWifiDuo():Boolean
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e.vo.type === "WifiDuoItem") tmp.push(e);
			}
			//trace("isThereAWifiDuo? num=", tmp.length)
			return (tmp.length > 0) ? true : false;
		}
		
		public static function isThereAWifiSolo():Boolean
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (isLiveboxPlay() && e.vo.type === "WifiDuoItem" && !WifiDuoView(e).isModuleDeBase) tmp.push(e);
			}
			//trace("isThereAWifiSolo? num=", tmp.length)
			return (tmp.length > 0) ? true : false;
		}
		
		public static function getWifiDuo():WifiDuoView
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e is WifiDuoView && !WifiDuoView(e).isModuleDeBase) tmp.push(e);
			}
			return tmp[0];
		}
		
		public static function getDuoMaster():WifiDuoView
		{
			var tmp:Array = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				if (e is WifiDuoView && WifiDuoView(e).isModuleDeBase) tmp.push(e);
			}
			return tmp[0];
		}
		
		/**
		 * Fonction statique qui génère la liste de courses dans un certain ordre : 
			 * 
		 * <ul>
		 * 		<li>Livebox et décodeurs en premier,</li>
		 * 		<li>si Liveplug ou WifiExtender, afficher une paire et le reste en solo, par exemple, 1 paire et solo (2)</li>
		 * 		<li>Modif G1R1C2: Si WifiExtender, mettre Kit Wifi extender en incluant un Liveplug, et déduire ce Liveplug dans Liveplugs</li>
		 * 		<li>Modif G1R1C2: Pour les Liveplug HD+, afficher liveplugs (nombre) (en tenant compte du cas précédent, -1 du total réél si Kit WFE)</li>
		 * </ul>
		 */
		public static function updateListeCourses():void
		{
			var liveboxArr:Array = [];
			var decodeursArr:Array = [];
			var liveplugArr:Array = [];
			var wifiextArr:Array = [];
			var wifiduoArr:Array = [];
			var tmp:Array = [];
			ApplicationModel.instance.equipementsRecap = [];
			for (var i:int = 0; i < EQUIPEMENTS.length; i++)
			{
				var e:EquipementView = EQUIPEMENTS[i] as EquipementView;
				ApplicationModel.instance.equipementsRecap.push(e);
			}
			for (i = 0; i < EQUIPEMENTS.length; i++)
			{
				var equipement:EquipementView = EQUIPEMENTS[i] as EquipementView;
				//trace("updateListeCourses" , equipement, equipement.vo.type, equipement.vo.isOrange, equipement.isOwned);
				if ( equipement.vo.isOrange === "true" && !equipement.isOwned )
				{
					if (equipement.vo.type === "LiveboxItem") {
						if(ApplicationModel.instance.clientvo.id_livebox != equipement.vo.id) liveboxArr.push(equipement);
					} else if (equipement.vo.type === "DecodeurItem") {
						if (ApplicationModel.instance.clientvo.id_decodeur != equipement.vo.id) {
							decodeursArr.push(equipement);
						} else {
							// special case for decodeur 86 (not in the xml list anymore)
							if (ApplicationModel.instance.clientvo.id_decodeur == 3 && equipement.vo.id == 4) {
								decodeursArr.push(equipement);
							}
						}
					} else if (equipement.vo.type === "LivePlugItem") {
						liveplugArr.push(equipement);
					} else if (equipement.vo.type === "WifiExtenderItem") {
						wifiextArr.push(equipement);
					} else if (equipement.vo.type === "WifiDuoItem") {
						wifiduoArr.push(equipement);
					} else {
						tmp.push(equipement);
					}
				}
			}
			
			// on ajoute les câbles ethernet dans le cas où il y a une connexion ethernet dans le xml
			var itemWiresNeeded:Boolean = (ApplicationModel.instance.projetvo.xml_plan != null && ApplicationModel.instance.projetvo.xml_plan.connections.connection.(@type == "ethernet").length() > 0);
			if (itemWiresNeeded) {
				var wireVO:EquipementVO = new EquipementVO();
				wireVO.imagePath = "images/cableEthernet.png";
				wireVO.type = "WireItem";
				wireVO.linkArticleShop = AppLabels.getString("check_ethernetWireLinkShop");
				//wireVO.screenLabel = "Câbles Ethernet";// managed in 
				var wiresEq:EquipementView = new EquipementView(wireVO);
				tmp.push(wiresEq);
			}
			//trace("AAAA nb de connections ethernet", ApplicationModel.instance.projetvo.xml_plan.connections.connection.(@type == "ethernet").length());
			
			/* if there is at least one wifiextender we need to remove one liveplug*/
			/*if (wifiextArr.length > 1) {
				liveplugArr.splice(0, 1);
			}*/
			/*if (liveplugArr.length > 1) {
				liveplugArr.splice(0, 1);
			}*/
			//trace("===>updateListeCourses", liveboxArr.concat(decodeursArr, liveplugArr, wifiextArr, tmp));
			ApplicationModel.instance.listeDeCourses = [];
			ApplicationModel.instance.listeDeCourses = liveboxArr.concat(decodeursArr, wifiduoArr, liveplugArr, wifiextArr, tmp);
			//trace("===>updateListeCourses", ApplicationModel.instance.listeDeCourses);
		}
		
	}

}