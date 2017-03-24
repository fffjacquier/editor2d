package classes.views.equipements 
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.controls.EndMovingPieceEvent;
	import classes.controls.History;
	import classes.controls.HomeResizeEvent;
	import classes.controls.ZoomEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.GeomUtils;
	import classes.utils.Measure;
	import classes.utils.ObjectUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.YesNoAlert;
	import classes.views.Btn;
	import classes.views.EquipementsLayer;
	import classes.views.menus.MenuContainer;
	import classes.views.menus.MenuFactory;
	import classes.views.menus.MenuRenderer;
	import classes.views.plan.Bloc;
	import classes.views.plan.DraggedObject;
	import classes.views.plan.EditorBackground;
	import classes.views.plan.EditorContainer;
	import classes.views.plan.Floor;
	import classes.views.plan.PieceEntity;
	import classes.views.tooltip.Tooltip;
	import classes.vo.ConnectionsCollection;
	import classes.vo.ConnectionVO;
	import classes.vo.EquipementVO;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;	
	
	/* Optimisation de code 
	 * 
	 * Toutes les classes dérivées de EquipementView devront être supprimées. 
	 * Les deux paramètres isConnector et isTerminal sont déjà dans le fichier all.xml et la récupération des paramètres
	 * est déjà codée dans Editor2D (chargement de plan de xml existants) et dans AccordionItemEquipements (fabrication des
	 * items equipements dans l'accordion), dans AppUtils aussi
	 * 
	 * Il reste à virer tout ce qui fait référence à ces classes; il restera à tout baser sur le type ("LiveboxItem"...) et les
	 * deux paramètres déjà cités
	 * Il faut simplifier le code dans le mousemove de l'éditeur2D qui détermine si on est sur un équipement ou pas pour le drag
	 * ligne 608
	 * Partout où il y a des is LiveboxView et autres il faut aussi modifier les conditions pour les connectors, on a déjà prévu des fonctions getter
	 * isLivebox, isDecodeur, isWFE etc... 
	 * Vérifier aussi les is PriseView, plus la condition dans le constructeur de PriseView (setConnection'ethernet')
	 * 
	 * 
	 */
	
	/** 
	 * EquipementView est la classe de base de tous les équipements posés sur le plan. 
	 * 
	 * <p>EquipementView étend DraggedObject car on peut déplacer un équipement.</p>
	 */
	public class EquipementView extends DraggedObject
	{
		public var id:int;
		public var uniqueId:String;/* xml and restitution of connexion purposes*/
		public var vo:EquipementVO;
		public var selectedConnexion:String;
		public var connexionViewsAssociated:Array = new Array();
		//public var connectionsCollection:ConnectionsCollection = new ConnectionsCollection();
		public var isOwned:Boolean = false;
		public var floorId:int;
		public var isConnector:Boolean = false;
		public var isTerminal:Boolean = false;
		public var isConnectionOptimal:Boolean = true;
		// équipement qui crée le module ou est créé par lui
		public var linkedEquipment:EquipementView;
		public var linkedEquipmentStr:String;/* used only when re-creating plan */
		private var _connexionIcon:MovieClip;
		private var _tooltip:Tooltip;
		private var _collection:ConnectionsCollection = ApplicationModel.instance.connectionsCollection;
		private var _bitmap:Bitmap;
		public var equipements:EquipementsLayer;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		protected var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		/**
		 * Crée une instance d'équipement sur le plan.
		 * 
		 * @param	pvo L'équipementVO correspondant à l'équipement de l'accordion <code>EquipementItem</code>
		 * @see classes.views.items.EquipementItem
		 */
		public function EquipementView(pvo:EquipementVO) 
		{
			buttonMode = true;
			vo = pvo;
			//trace("vo", vo.isTerminal, vo.isConnector)
			//floorId = _model.currentFloor.id;  //faux
			super();
		}
		
		override public function toString():String
		{
			return vo.name;
		}
		
		public function get type():String
		{
			return vo.type;
		}
		
		public function get connection():ConnectionVO
		{
			return _collection.getProvidingConnection(this);
		}
		
		public function get provider():EquipementView
		{
			return _collection.getEquipmentProvider(this);
		}
		
		public function get uniqueReceiver():EquipementView
		{	
			return _collection.getUniqueReceiver(this);
		}
		
		public function get oneReceiver():EquipementView
		{	
			return _collection.getOneReceiver(this);
		}
		
		public function get switchAsChild():EquipementView
		{
			return _collection.getSwitchReceiver(this);
		}
		
		override protected function added(e:Event = null):void
		{
			//super.added();
			if(dragCursor == null) {
				dragCursor = new CurseurDeplacement();
				//draw();
			}
				
			addEventListener(Event.REMOVED_FROM_STAGE, removed);
			
			//pas de rollover sur porte et livebox
			if(isLivebox || isLPHD || isWFE || isLPWFD || vo.type === "SwitchItem" || vo.type === "MainDoorItem" || vo.type === "PriseItem") {}else{
				addEventListener(MouseEvent.ROLL_OVER, _onRollOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, _onRollOut, false, 0, true);
			}
			
			_model.addZoomEventListener(_onZoom);
			_model.addHomeResizeEventListener(_onHomeResize);
			_model.addEndMovingPieceEventListener(_onEndMovingPiece);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, _onEditorMouseDown);
			//_onZoom();
			
			scaleX = scaleY = _model.currentScale;
		}
		
		private function _onEndMovingPiece(e:EndMovingPieceEvent):void
		{
			var pieceEntity:PieceEntity = e.piece;
			if (!hitTestObject(pieceEntity.surface) && (parentBloc == pieceEntity.bloc) )
			{
				var bounds:Rectangle = pieceEntity.surface.getBounds(pieceEntity.bloc.equipements);
				x = bounds.x + bounds.width / 2 + Math.random()*40;
				y = bounds.y + bounds.height / 2 + Math.random()*40;
			}
		}
		
		private function _onZoom(e:ZoomEvent=null):void
		{
			//trace("EquipementView::onZoom");
			var prevScale:Number = _model.prevScale;
			var scale:Number = _model.currentScale;
			var scaleFactor:Number = scale / prevScale;
			x *= scaleFactor;
			y *= scaleFactor;
			scaleX = scaleY = scale;
		}
		
		private function _onHomeResize(e:HomeResizeEvent):void
		{
			var scale:Number = e.scale;
			//trace("EquipementView::_onHomeResize", e.scale);
			x *= scale;
			y *= scale;
		}
		
		/*Needs to be overriden by extending classes*/
		public function draw(color:int = 0):void
		{
			//updateColors();
			if(_bitmap) return;
			var loadr:Loader = new Loader();
			loadr.load(new URLRequest(vo.imagePath));
			loadr.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete);
		}
		
		protected function updateColors():void
		{			
			if (selectedConnexion == null) {
				drawBG(Config.COLOR_CONNEXION_NULL);
			} else if (selectedConnexion === "wifi") {
				drawBG(Config.COLOR_CONNEXION_WIFI);
			} else if(selectedConnexion === "usb") {
				drawBG(Config.COLOR_CONNEXION_DECT);
			} else {
				if (vo.type === "PriseView") 
					drawBG(Config.COLOR_CONNEXION_LIVEBOX);
				else
					drawBG(Config.COLOR_CONNEXION_ETHERNET);
			}
			if (this is LiveplugView || this is WifiExtenderView) {
				/*if(selectedConnexion == null) 
					drawBG(Config.COLOR_CONNEXION_NULL);
				else*/
					drawBG(Config.COLOR_CONNEXION_AUTRES);
			}
		}
		
		protected function drawBG(color:Number):void
		{
			/*var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, color, 0);
			g.beginFill(0xffffff, 0);
			g.drawCircle( 0, 0, 32);*/
		}
		
		protected function onImageComplete(e:Event):void
		{
			var lodr:LoaderInfo = e.target as LoaderInfo;
			lodr.removeEventListener(Event.COMPLETE, onImageComplete);
			
			_bitmap = lodr.content as Bitmap;
			_bitmap.smoothing = true;
			var xs:int = 60;
			var ys:int = 60;
			if (isLPHD) {
				xs = 21
				ys = 32;
			} else if (isWFE) {
				xs = ys = 42;
			} else if ( isLPWFD) {
				xs = ys = 56;
			}
			if (vo.type == "PriseItem") {
				ys = 36;
				xs = 40;
			} else if (vo.type == "OrdinateurItem") {
				ys = 50
			}
			var xscale:Number = xs/_bitmap.width;
			var yscale:Number = ys/_bitmap.height;
			_bitmap.scaleX = xscale;
			_bitmap.scaleY = yscale;
			addChild(_bitmap);
			_bitmap.x = - _bitmap.width/2;
			_bitmap.y = - _bitmap.height/2;
			
			addConnexionIcon();
		}
		
		public function addConnexionIcon():void
		{
			if (connection == null) return;
			//trace("addConnexionIcon", this, vo.type, selectedConnexion, connection)
			if (vo.type !== "PriseItem" && !isLPHD && !isLivebox && !isLPWFD && !isWFE && vo.type !== "SwitchItem") 
			{
				_removeConnexionIcon();
				
				//if (selectedConnexion == null) return;
				//if (connection == null) return;
				//FJ code pas suffisant TODO
				// why remove the previous one ?
				if (_connexionIcon == null) draw();
				
				//if (selectedConnexion === "wifi" || selectedConnexion === "wifiextender-wifi" || selectedConnexion === ModesDeConnexion.DUO_WIFI) {
				if(connection.type == ModesDeConnexion.WIFI) {
					_connexionIcon = new BulleWifi();
					addChild(_connexionIcon);
				} else if(connection.type == ModesDeConnexion.ETHERNET) {
					_connexionIcon = new BulleEthernet();
					addChild(_connexionIcon);
				} 
				if (_connexionIcon && _connexionIcon.stage) {
					_connexionIcon.mouseChildren = false;
					_connexionIcon.x = 0//_connexionIcon.width - this.width;
					_connexionIcon.y = 0//_connexionIcon.height - this.height;
					drawColorBulle()
				}
			}
		}
		
		private function _removeConnexionIcon():void
		{
			if (_connexionIcon && _connexionIcon.stage) removeChild(_connexionIcon);
		}
		
		protected function _onRollOver(e:MouseEvent):void
		{
			trace(this, selectedConnexion, connection);
			if (selectedConnexion == null) {
				_tooltip = new Tooltip(this, AppLabels.getString("editor_clickToConnect"));
				return;
			}
		}
		
		private function _onRollOut(e:MouseEvent):void
		{
			if (_tooltip && _tooltip.stage) _tooltip.remove();
		}
		
		public function drawColorBulle():void
		{
			if (connection == null || _connexionIcon == null) return;
			
			var color:Number;
			if (connection.type == ModesDeConnexion.WIFI) color = connection.isAcceptable ? Config.COLOR_GREEN_CONNECT_LINE : Config.COLOR_ORANGE_CONNECT_LINE;
			else color = connection.needsToBeChecked ? Config.COLOR_ORANGE_CONNECT_LINE : Config.COLOR_GREEN_CONNECT_LINE;
			var g:Graphics = _connexionIcon.graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(color);
			g.drawCircle(9, 9, 9);
			
		}
		
		private var _d:Number // distance de l'équipement avant le déplacement d'avecques la Livebox
		private var _oldPosPoint:Point;// what for exactly ? pour mesurer la distance avec la précédente position
		private var _mousePoint:Point;// what for exactly ? qd on drag ca evite qu'on saute au 0,0 de l'objet
		private var _prevPoint:Point;// what for exactly ? for moving linked equipements with them
		override protected function mouseDown():void
		{
			var lb:LiveboxView = EquipementsLayer.getLivebox();
			if (lb != null) _d = getDistance(lb);
			_oldPosPoint = new Point(x, y);
			
			_prevPoint = new Point(x, y);
			var scale:Number = _model.currentScale;
			_mousePoint = new Point(mouseX*scale, mouseY*scale);
			
			equipements.removeEquipement(this, true, true, true);
			_model.currentBlocMaison.equipements.addEquipement(this);
			
			/*var p:Point = new Point(parent.mouseX, parent.mouseY).subtract(_mousePoint);
			x = p.x;
			y = p.y;*/
		}
		
		override protected function mouseMove():void
		{
			var p:Point = new Point(parent.mouseX, parent.mouseY).subtract(_mousePoint);
			x = p.x;
			y = p.y;
			var dep:Point = new Point(x, y).subtract(_prevPoint);
			//les followers se deplacent de dep
			if (linkedEquipment) {
				linkedEquipment.x += dep.x;
				linkedEquipment.y += dep.y;
			}
			_prevPoint = new Point(x, y);
			
			if(isTerminal)
			{
				if (connection == null) return;
				drawColorBulle();
			}
			else
			{
				var childs:Array = _collection.getReceivingConnections(this);
				for (var i:int = 0; i < childs.length; i++) 
				{
					var eq:EquipementView = (childs[i] as ConnectionVO).receiver;
					if(eq.isTerminal) eq.drawColorBulle();
				}	
			}
		}
		
		override public function onMouseUpEvent(e:MouseEvent = null):void
		{
			super.onMouseUpEvent(e);
			_mousePoint = null;
		}
		
		override protected function mouseUpWhileDrag():void
		{			
			var bloc:Bloc = _isOverBloc();
			if (bloc && bloc.isPiece)
			{
				_model.currentBlocMaison.equipements.removeEquipement(this, true, true, true);
				bloc.equipements.addEquipement(this);
				var p:Point = new Point(parent.mouseX, parent.mouseY).subtract(_mousePoint);
				x = p.x;
				y = p.y;
			}
			if (connection) {
				// a vérifier la connexion si on a déplacé l'équipement de plus de 3.5m
				var d:Number = Measure.realSize(Point.distance(new Point(x, y), _oldPosPoint));
				connection.needsToBeChecked = (d > Config.DISTANCE_PRECO_LIVEPLUG);
				//trace(d.toFixed(2), Config.DISTANCE_PRECO_LIVEPLUG.toFixed(2));
				//trace("mouseUpWhileDrag", connection.needsToBeChecked);
				drawColorBulle();
			}
			
			_appmodel.notifySaveStateUpdate(true);
		}
		
		protected function _traceEquipement(element:EquipementView, index:int, arr:Array):String 
		{
            //trace("_traceEquipement", element.name + ":"+element.uniqueId)
            return element+ ":"+element.uniqueId;	
		}
		
		override protected function mouseUp():void
		{			
			showConnections();
			
			var bloc:Bloc = _isOverBloc();
			if (bloc && bloc.isPiece)
			{
				if(stage) equipements.removeEquipement(this, true, true, true);
				bloc.equipements.addEquipement(this);
				var p:Point = new Point(parent.mouseX, parent.mouseY).subtract(_mousePoint);
				x = p.x;
				y = p.y;
			}
			
			var menu:MenuRenderer = MenuFactory.createMenu(this, EditorContainer.instance);
			//var mousePos:Point = new Point(EditorContainer.instance.mouseX, EditorContainer.instance.mouseY);
			//trace("mouseUp", vo.type, selectedConnexion);
		}
		
		public function get isLivebox():Boolean
		{
			return vo.type === "LiveboxItem"
		}
		
		public function get isDecodeur():Boolean
		{
			return vo.type === "DecodeurItem"
		}
		
		public function get isWFE():Boolean
		{
			return vo.type === "WifiExtenderItem"
		}
		
		public function get isLPWFD():Boolean
		{
			return vo.type === "WifiDuoItem"
		}
		
		public function get isLPHD():Boolean
		{
			return vo.type === "LivePlugItem"
		}
		
		public function get isSwitch():Boolean
		{
			return vo.type === "SwitchItem"
		}
		
		public function get isNearLivebox():Boolean
		{
			if(isLivebox) return true;
			//trace("isNearLivebox", isConnector, connection.provider.isLivebox);
			if(isConnector && connection.provider.isLivebox) return true;
			return false;
		}
		
		//soit c'est un decodeur
		//soit le pere ou grandpere d'un decodeur 
		public function get isDecoderConnectionSource():Boolean
		{			
			if(isDecodeur) return true;
			if(isTerminal) return false;
			var cvo:ConnectionVO;
			var connections:Array = _collection.connections;
			for (var i:int = 0; i < connections.length; i++) 
			{
				cvo = connections[i] as  ConnectionVO;
				if (cvo.receiver.isDecodeur) {
					if(cvo.provider == this) return true;
					if(cvo.grandProvider == this) return true;
				}
			}
			return false;
		}
		
		override public function get isLocked():Boolean
		{
			return false;
		}
		
		public function setConnexion(str:String):void
		{
			//trace("EquipementView::setConnexion", str, this);
			selectedConnexion = str;
			if (selectedConnexion == null) {
				connexionViewsAssociated = [];
			}
			updateColors();
			if(!str) _removeConnexionIcon();
		}
		
		public function resetConnexion():void
		{
			setConnexion(null);
			drawBG(Config.COLOR_LIGHT_GREY);
		}
		
		public function rotateRight():void
		{
			trace("EquipementView::rotateRight");
		}
		
		public function rotateLeft():void
		{
			trace("EquipementView::rotateLeft");
		}
		
		public function deleteEquipementsAssocies():void
		{
			trace("deleteEquipementsAssocies()");
			if (this is WifiDuoView) return;
			
			// delete only the equipement associated 
			// and delete master if the liveplug master is the only reminder (no other slaves)
			/*for (var i:int = 0; i < connexionViewsAssociated.length; i++)
			{
				var eqView:EquipementView = connexionViewsAssociated[i] as EquipementView;
				trace("deleteEquipementsAssocies", eqView);
				var master:*;
				if (eqView is LiveplugView) {
					master = LiveplugView(eqView).master as LiveplugView;
				} else if (eqView is WifiExtenderView) {
					master = WifiExtenderView(eqView).master as LiveplugView;
				} else if (eqView is WifiDuoView) {
					master = WifiDuoView(eqView).master as WifiDuoView;
				}
				if (master.slaves.length <= 1) {
					var bloc:Bloc = eqView.parentBloc;
					if (bloc) bloc.equipements.removeEquipement(eqView);
					bloc = master.parentBloc;
					if (bloc) bloc.equipements.removeEquipement(master);
				} else {
					bloc = eqView.parentBloc;
					if (bloc) bloc.equipements.removeEquipement(eqView);
					var index:int = master.slaves.indexOf(eqView);
					master.slaves.splice(index, 1);
				}
			}
			EquipementsLayer.updateEquipement(eqView);*/
		}
		
		private function _isLiveplug(element:EquipementView, index:int, arr:Array):Boolean 
		{
            return (element is LiveplugView);
		}
		
		public function changeLevelUp():void
		{
			//trace("changeLevelUp", this, floorId, floorId +1);
			changeLevel(floorId + 1);
		}
		
		public function changeLevel(num:int):void
		{
			//trace("changeLevel", this, floorId, num);
			// les éléments vont se supprimer
			var equipmentsArr:Array = _model.currentBlocMaison.equipements.equipementsArr.concat();
			// parcourir toutes les pieces et ajouter en concat tous les equipements arr
			// trace("len",_model.currentBlocMaison.pieces.piecesArr.length);
			var len:int = _model.currentBlocMaison.pieces.piecesArr.length;
			for (var k:int = 0; k < len; k++) {
				//trace(k, "-", (_model.currentBlocMaison.pieces.piecesArr[k] as Bloc).equipements.equipementsArr);
				equipmentsArr = equipmentsArr.concat((_model.currentBlocMaison.pieces.piecesArr[k] as Bloc).equipements.equipementsArr);
			}
			var floor:Floor = _model.getFloorById(num);
			trace("changelevel", floor);
			var equipementsLayer:EquipementsLayer = floor.blocMaison.equipements;
			trace("changelevel", equipementsLayer);
			if (equipementsLayer == null) return;
			var arr:Array = new Array();
			for (var i:int = 0; i < equipmentsArr.length; i++)
			{
				var equipement:EquipementView = equipmentsArr[i] as EquipementView;
				trace("changeLevel loop", i, equipement);
				// si eq attaché à la LB ou eq is LB
				if(equipement.isNearLivebox) 
				{
					equipementsLayer.addEquipement(equipement, false);
					trace("adding looping " + i);
					arr.push(equipement);
				}
			}
			// FJ comment -- bug si LB connectée à un LP, le premier changement d'étage est correct, 
			//               mais ensuite, seule la LB se déplace, et plus les modules associés
			
			setTimeout(function():void { _model.currentFloor = floor; trace("changing floor"); }, 300);
			MenuContainer.instance.closeMenu();
			_appmodel.notifySaveStateUpdate(true);
		}
		
		public function changeLevelDn():void
		{
			//trace("changeLevelDn", this, floorId, floorId -1);
			changeLevel(floorId -1);
		}
		
		public function deleteObj():void
		{
			trace("EquipementView::deleteObj");
			if (vo.type == "LiveboxItem") {
				//var popup:YesNoAlert = new YesNoAlert("supprimer la Livebox", "voulez-vous supprimer la Livebox et les connexions associées ?", _yesDeleteLivebox, _no);
				//AlertManager.addPopup(popup, Main.instance);
				//AppUtils.appCenter(popup);
				return;
			} 
			
			remove();
			MenuContainer.instance.closeMenu();
			
			// dont push this action in history for the moment and clear history
			History.instance.clearHistory();
			return;
		}
		
		public function remove():void
		{
			//disconnect();
			if(equipements && equipements.stage) equipements.removeEquipement(this);
		}
		
		private function _yesDeleteLivebox():void
		{
			//remove livebox + all connexions and Liveplugs and wifiextenders
			EquipementsLayer.resetConnexions();
			
			// delete equipement
			equipements.removeEquipement(this);
			
			// dont push in history for the moment
			History.instance.clearHistory();
		}
		
		private function _no():void
		{
			//do nothing
			AlertManager.removePopup();
		}
		
		public function getDistance(view:EquipementView):Number
		{
			if (this == view) {
				return 0;
			}
			
			var dy:int = Math.abs(floorId - view.floorId);
			var Y:Number = 0;
			if (dy > 0) {
				Y = Config.HAUTEUR_PIECE * dy;
			}
			
			var viewPoint:Point = new Point(view.x, view.y);
			
			var pt1:Point = GeomUtils.localToLocal(viewPoint, parent, EditorBackground.instance);
			var pt2:Point = GeomUtils.localToLocal(new Point(x,y), parent, EditorBackground.instance);
			
			var X:Number = Measure.pixelToMetric(Point.distance(pt2, pt1));
			
			return Math.sqrt(X*X + Y*Y);
		}
		
		public function distanceLivebox():Number
		{
			return getDistance(EquipementsLayer.getLivebox());
		}
		
		public function distanceWifi():Number
		{
			if (EquipementsLayer.WIFI_POINTS.length === 0) return distanceLivebox();
			
			var values:Array = new Array();
			for (var i:int = 0; i < EquipementsLayer.WIFI_POINTS.length; i++)
			{
				var wifiext:* = EquipementsLayer.WIFI_POINTS[i];
				if(wifiext.floorId === floorId) values.push(getDistance(wifiext));
			}
			if (values.length === 0) return 100;
			return Math.min.apply(null, values);
		}
		
		public function changeConnexion():void
		{
			trace("changeConnexion");
			// we do not need to change connexion for these equipements
			
			//if (this is LiveboxView || this is LivePhoneView || this is TelephoneView) return;
			if (vo.type == "LiveboxItem" || vo.type == "LivephoneItem" || vo.type == "TelephoneItem") return;
			
			//var popup:AlertModesDeConnexion = new AlertModesDeConnexion(vo, this);
			//AlertManager.addPopup(popup, Main.instance);
			//AppUtils.appCenter(popup);
		}
		
		/*public function get equipements():EquipementsLayer
		{
			return parent as EquipementsLayer;
		}*/
		
		public function get parentBloc():Bloc
		{
			//FJ: sometimes equipements is null - 06/01/2012 12:13
			//trace("equipmentView get parentBloc " + this + " stage : " + stage);
			if (equipements == null) return null;
			return equipements.parent as Bloc;
		}
		
		private function _isOverBloc():Bloc
		{
			var p:Point = GeomUtils.localToLocal(new Point(mouseX, mouseY), this, Main.instance);
			var i:int;
			var blocs:Array; 
			var bloc:Bloc;
			if (_model.currentBlocMaison == null) return null;
			if (_model.currentMaisonPieces == null) return null;
			
			blocs = _model.currentMaisonPieces.piecesArr;
			for (i = blocs.length-1; i >=0 ; i--)
			{
				bloc = blocs[i];
				
				if (bloc.hitTestPoint(p.x, p.y, true))
				{
					//trace("DraggableItem::isOver ", bloc.type);
				    return bloc;
				}
			}
			
			blocs = _model.currentFloor.blocs;
			for (i = 0; i < blocs.length ; i++)
			{
				bloc = blocs[i];
				
				if (bloc.hitTestPoint(p.x, p.y, true))
				{
					//trace("DraggableItem::isOver ", bloc.type);
				    return bloc;
				}
			}
			return null;
		}
		
		private function getUniqueId(element:EquipementView, index:int, arr:Array):String 
		{
            return element.uniqueId;
		}
		
		public function toXML():XML
		{
			var arr:Array = [];
			for (var i:int = 0; i < connexionViewsAssociated.length; i++)
			{
				var e:EquipementView = connexionViewsAssociated[i] as EquipementView;
				if(e != null) arr.push(e.uniqueId);
			}
			// pass the data isModuleDeBase and master for LiveplugView and WiFiExtenderView only
			var moduledebaseAttr:String;
			if (vo.type === "LivePlugItem") {
				var masterStr:String = ""//(LiveplugView(this).isModuleDeBase) ? "" : "master=\"" + LiveplugView(this).master.uniqueId + "\" ";
				moduledebaseAttr = masterStr + "isModuleDeBase=\"" + LiveplugView(this).isModuleDeBase + "\"";
			} else if (vo.type === "WifiExtenderItem") {
				//moduledebaseAttr = "master=\"" + WifiExtenderView(this).master.uniqueId + "\" isModuleDeBase=\"" + WifiExtenderView(this).isModuleDeBase + "\"";
				moduledebaseAttr = "isModuleDeBase=\"" + WifiExtenderView(this).isModuleDeBase + "\"";
			} else if (vo.type === "WifiDuoItem") {
				masterStr = ""//(WifiDuoView(this).isModuleDeBase) ? "" : "master=\"" + WifiDuoView(this).master.uniqueId + "\" ";
				moduledebaseAttr = masterStr + "isModuleDeBase=\"" + WifiDuoView(this).isModuleDeBase + "\"";
			} else {
				moduledebaseAttr = "";
			}
			
			var linkedEquipementId:String;
			var linkedEquipementNode:XML;
			if (linkedEquipment != null) {
				linkedEquipementId = linkedEquipment.uniqueId;
				moduledebaseAttr += " linked=\"" + linkedEquipementId + "\"";
			}
			var labelNode:XML = new XML("<equipement uniqueId=\""+uniqueId+"\" vo=\""+vo.name+"\" type=\""+vo.type+"\" x=\""+ x / _model.currentScale +"\" y=\""+ y / _model.currentScale +"\" isOwned=\""+isOwned+"\" mdc=\""+selectedConnexion+"\" asso=\""+arr+"\" "+moduledebaseAttr+"></equipement>");
			
			return labelNode;
		}
		
		public function showConnections():void
		{
			//la connection parent
			var cvo:ConnectionVO  = connection;
			if(cvo) cvo.displayLine(true);
			//les childs 
			var connections:Array = _collection.connections;
			for (var i:int = 0; i < connections.length; i++) 
			{
				cvo = connections[i] as  ConnectionVO;
				if (cvo.providerIs(this) ) {
					cvo.displayLine();
				}
			}
		}
		
		public function hideConnections():void
		{
			//la connection parent
			var cvo:ConnectionVO = connection;
			if(cvo) cvo.hideLine(true);
			//les childs 
			var connections:Array = _collection.connections;
			for (var i:int = 0; i < connections.length; i++) 
			{
				cvo = connections[i] as  ConnectionVO;
				if (cvo.providerIs(this) ) {
					cvo.hideLine();
				}
			}
		}
		
		private function _onEditorMouseDown(e:MouseEvent):void
		{
			// on ne veut pas que la connexion affichée disparaisse si on clique sur un élément de menu 
			if (ObjectUtils.isChildOf(e.target as DisplayObject, MenuContainer.instance)) return;
			hideConnections();
		}
		
		protected function removed(e:Event):void
		{
			//trace("EquipementView::removed", this);
			_model.removeZoomEventListener(_onZoom);
			_model.removeHomeResizeEventListener(_onHomeResize);
			removeEventListener(MouseEvent.ROLL_OVER, _onRollOver);
			removeEventListener(MouseEvent.ROLL_OUT, _onRollOut);
			removeEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
		
	}
}