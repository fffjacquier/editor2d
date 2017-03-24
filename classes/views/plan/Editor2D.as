package classes.views.plan
{
	import classes.commands.AddNewFloorCommand;
	import classes.commands.AddNewSurfaceCommand;
	import classes.commands.ClearAllCommand;
	import classes.commands.cloisons.AddCloisonCommand;
	import classes.commands.fiber.AddFiberLineCommand;
	import classes.controls.History;
	import classes.controls.ZoomEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.Measure;
	import classes.utils.ObjectUtils;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.LiveplugView;
	import classes.views.equipements.WifiDuoView;
	import classes.views.equipements.WifiExtenderView;
	import classes.views.EquipementsLayer;
	import classes.views.menus.MenuContainer;
	import classes.views.menus.MenuItemRenderer;
	import classes.views.NomPieceView;
	import classes.views.plan.DraggedObject;
	import classes.vo.EditorVO;
	import classes.vo.EquipementVO;
	import classes.vo.Shapes;
	import classes.vo.ShapeVO;
	import classes.vo.Texture;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	/**
	 * Editor2D contient exclusivement le plan de maison avec ses divers objets, ajoutés dans la classe Floors, la grille, et un background.
	 * <p>Editor2D étend DraggedObject car on peut déplacer l'éditeur par cliquer-glisser.</p>
	 * 
	 */
	public class Editor2D extends DraggedObject
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var displayMeasuresArr:Array;
		public var displayMeasuresCheckBoxValue:Boolean = false;
		private var _time:Number;
		private var _delay:int = 0;
		private var startY:Number;
		private var startX:Number;
		
		private var surface:Surface;
		private var measuresContainer:Sprite;
		private var pointsContainer:Sprite;
		private var t:TextField;
		
		private var _draggedObject:DraggedObject;
		private var _dragCursor:CurseurDeplacementEditeur;		
		private var _editorContainer:EditorContainer;
		
		public var floors:Floors;
		public var points:Array;
		public static const SCALE_MAX:Number = 4;
		public static const SCALE_MIN:Number = .5;
		private var _measuresTimeId:int;
		
		private static var _self:Editor2D;
		public static function get instance():Editor2D
		{
			return _self;
		}
		
		/**
		 * Editor2D est un singleton, un getter public statique réfère à son instance. Il contient les singletons Floors, Grid et EditorBackground.
		 * <p>Il est ajouté au Sprite EditorContainer qui contient aussi les différents outils permettant la création du plan.</p>
		 * <p>Editor2D étend DraggedObject car on peut le déplacer par cliquer-glisser.</p>
		 * <p>Sa méthode onMouseDown permet de gérer les différents clicks sur tous ses objets</p>
		 * 
		 */
		public function Editor2D() 
		{
			if (_self == null) {
				_self = this;
				super()
			}
		}
		
		override protected function added(e:Event = null):void
		{
			super.added(e);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			_editorContainer = EditorContainer.instance; //the parent
			
			addChild(new EditorBackground());
			addChild(new Grid());
			
			floors = new Floors();
			addChild(floors);
			
			//addFirstFloor();//FJ: called from parent (EditorContainer) 23/01/2012 15:57
			
			dragCursor = new CurseurDeplacementEditeur();
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownEvent);
			//_model.addZoomEventListener(_onZoom);
		}
		
		public function addFirstFloor():void
		{
			//trace("addFirstFloor", _model.currentFloor)
			if (_model.currentFloor == null) {
				var label:String = AppLabels.getString("editor_level0");
				new AddNewFloorCommand(label, 0).run(createDefaultSurface);
			}
		}
		
		public function createDefaultSurface():void
		{
			//first stare case on init 
			Shapes.instance.update();
			var points:Array = (Shapes.instance.blocsMaison[_appmodel.shape] as ShapeVO).pointsClone;
			new AddNewSurfaceCommand(points).run();
		}
		
		public function shootEtages(callBack:Function=null):void
		{
			//trace("shootEtages " + floors.length);
			_appmodel.capturesArr = new Vector.<BitmapData>;
			_appmodel.etages = new Vector.<String>;
			_appmodel.pdfCapturesArr = new Vector.<BitmapData>;
			_appmodel.floorIds = [];
			if (floors.length == 0)
			{
				if (callBack != null) callBack();
				return;
			}
			
			if (floors.length == 1 && !_model.currentBlocMaison)
			{
				if (callBack != null) callBack();
				return;
			}
			//floors.floorsArr.sortOn("id");
			
			var prevScale:Number = _model.currentScale;
			_model.currentScale = 1;
			var bounds:Rectangle = floors.getBounds(this);
			shootEtage(0, bounds, prevScale, true, callBack);
		}
		
		public function shootEtage(i:int, bounds:Rectangle, prevScale:Number, loop:Boolean, callBack:Function=null):void
		{
			var floor:Floor = floors.floorsArr[i];
			if (floor.blocMaison != null) {
			
				floor.reset();
				//var step; int = _appmodel.currentStep;
				_appmodel.currentStep = ApplicationModel.STEP_EQUIPEMENTS;
				//afficher les intesections de la fibre 
				var fiberLine:FiberLineEntity = floor.blocMaison.fiberLine; 
				if(fiberLine) {fiberLine.displayIntersectionPoints(); fiberLine.goAtTop();};
				
				//screenRecap
				var w:int = 400;
				var margin:int = 20;
				var scale:Number = w / (bounds.width + margin * 2) ;
				//trace("w::scale", w, scale)
				//trace(bounds.width, bounds.height);
				var ratio:Number = bounds.width / bounds.height;
				//trace(ratio, 400 / 255);
				var matrix:Matrix = new Matrix();
				var bmd:BitmapData = new BitmapData((bounds.width + margin * 2) * scale, (bounds.height + margin * 2) * scale, false, 0xffffff);//0xefefef
				matrix.translate( margin - bounds.x, margin-bounds.y);
				if(ratio >= 400/255) {
					matrix.scale(scale, scale); 
				} else {
					var s:Number = 255 / (bounds.height + margin * 2);
					matrix.scale(s, s);
				}
				bmd.draw(floor, matrix, null, null, null, true);
				/*_appmodel.capturesArr[i] = bmd.clone();
				_appmodel.etages[i] = floor.floorName;*/
				_appmodel.capturesArr.push(bmd.clone());
				_appmodel.etages.push(floor.floorName);
				//AppUtils.TRACE("floor id:" + floor.id);
				_appmodel.floorIds.push(floor.id);
				//AppUtils.TRACE("floorIds:" + _appmodel.floorIds);
				bmd.dispose();
				
				//pdf
				w = 800;
				margin = 20;
				scale = w / (bounds.width + margin * 2) ;
				matrix = new Matrix();
				matrix.translate( margin - bounds.x, margin - bounds.y);
				if (bounds.width >= bounds.height)
				{
					bmd = new BitmapData((bounds.height + margin*2)*scale, (bounds.width + margin*2)*scale, false, 0xffffff);//0xefefef
					matrix.scale(scale, scale);
					matrix.rotate(-Math.PI/2);
					matrix.translate(0, (bounds.width + margin * 2) * scale);
				}
				else
				{
					bmd = new BitmapData((bounds.width + margin*2)*scale, (bounds.height + margin*2)*scale, false, 0xefefef);
					matrix.scale(scale, scale);
				}
				
				bmd.draw(floor, matrix, null, null, null, true);
				//_appmodel.pdfCapturesArr[i] = (bmd.clone());
				_appmodel.pdfCapturesArr.push(bmd.clone());
				bmd.dispose();
				if(fiberLine) {fiberLine.clearIntersectionPoints(); fiberLine.goAtBottom();};
			}
			
			if (loop)
			{
			    if( i < floors.length - 1)
				{
					shootEtage(i + 1, bounds, prevScale, true, callBack);
				}
				else
				{
					_model.currentScale = prevScale;
					if (callBack != null) callBack();
				}
			}
			//addChild(new Bitmap(bmd));
		}
		
		/**
		 * Méthode pour créer un plan à partir d'un fichier xml
		 * 
		 * @param xml Le fichier xml à utiliser
		 */
		public function createFromXML(xml:XML):void
		{
			if(_model.currentFloor != null) {
				new ClearAllCommand().run();
			}
			
			//if empty
			_model.editorVO  = new EditorVO(xml.title);
			
			//dispatch the title to project name clip
			_appmodel.projectLabel = xml.title;
			//met à jour le nom du type de Livebox choisie : si pas renseigné, forcément 'Livebox2'
			// mais on vérifie quand même que pas de LiveboxPlay dans les vo des équipements présents
			if (String(xml.@lb) === "") {
				if (String(xml.floors.floor.blocs.bloc.equipements.equipement.@vo).indexOf("LiveboxPlay") != -1) {
					_appmodel.selectedLivebox = "LiveboxPlay";
				} else {
					_appmodel.selectedLivebox = "Livebox2";
				}
			} else {
				_appmodel.selectedLivebox = xml.@lb;
			}
			//temp patch for sometimes loss of the right title
			if (xml.title != _appmodel.projetvo.nom) {
				_appmodel.projectLabel = _appmodel.projetvo.nom
			}
			
			// create the floors
			var i:int;
			for each(var floorxml:XML in xml.floors.*) 
			{
				_createFloorFromXML(floorxml, i);
				i++;
			}
			
			// affect the connexions after all the equipements on all floors have been created
			_affectConnexions(xml.connections);
			
			if (ApplicationModel.instance.floorIdToGo != _model.currentFloor.id) _model.currentFloor = _model.getFloorById(ApplicationModel.instance.floorIdToGo);
			History.initialized = true;
			//trace("createFromXML");
		}
		
		private function _createFloorFromXML(floorxml:XML, i:int):void
		{
			//if(i == 1) Navigator.firstTimeEtage = true;

			//trace(floorxml.@index, floorxml.@id, floorxml.name);
			new AddNewFloorCommand(floorxml.name, floorxml.@id).run();
			
			var floor:Floor = _model.currentFloor;
			floor.floorName = floorxml.name;
			floor.plancher = floorxml.@plancher;
			
			for each(var blocxml:XML in floorxml.blocs.*) {
				
				var points:Array = new Array();
				var type:String = blocxml.@type;
				var classz:Class = blocxml.@classz as Class;
				if (String(blocxml.@mursPorteurs) != "") var mursPorteurs:Array = String(blocxml.@mursPorteurs).split(",");
				else mursPorteurs = null;
				if (String(blocxml.@coeffMurs) != "") var coeffMurs:Array = String(blocxml.@coeffMurs).split(",");
				for each(var point:XML in blocxml.points.*) {
					points.push(new Point(Number(point.@x), Number(point.@y)));
				}
				var p:Point; 
				if (classz != MainEntity) {
					p = new Point(blocxml.@positionx, blocxml.@positiony);
				}
				var texture:Texture = null;
				
				var alphaSurface:String = String(blocxml.@alphaSurface) || "";
				if(alphaSurface.length>0)
				{
					var alfa:Number = Number(alphaSurface);
					var textureSurface:String = String(blocxml.@textureSurface) || "";
					if(textureSurface.length == 0) texture = new Texture(int(blocxml.@colorSurface), alfa);
					else texture = new Texture(textureSurface, alfa);
				}
				var surfaceType:String = String(blocxml.@surfaceType) == Surface.TYPE_FREE ? Surface.TYPE_FREE : Surface.TYPE_SQUARE;
				new AddNewSurfaceCommand(points, type, p, mursPorteurs, coeffMurs, texture, surfaceType ).run();
				
				//cloisons
				for each(var cloison:XML in blocxml.cloisons.*) {
					points = new Array();
					if (String(cloison.@mursPorteurs) != "") mursPorteurs = String(cloison.@mursPorteurs).split(",");
					else mursPorteurs = null;
					if (String(cloison.@coeffMurs) != "") coeffMurs = String(cloison.@coeffMurs).split(",");
					for each(point in cloison.*) {
						points.push(new Point(Number(point.@x), Number(point.@y)));
					}
					
					new AddCloisonCommand(_model.currentMaisonCloisons, points, mursPorteurs, coeffMurs).run();
				}
				
				//get last added bloc (for adding equipements below)
				var bloc:Bloc = _model.currentFloor.blocs[_model.currentFloor.blocs.length -1];
				//trace(bloc, bloc.type);
				
				//equipements
				for each(var equipement:XML in blocxml.equipements.children()) {
					trace("\tequipement:", equipement.@type, equipement.@isOwned, equipement.@mdc, equipement.connectedTo.@isModuleDeBase.equipement.connectedTo);
					//get and create vo
					var vo:EquipementVO;
					if (equipement.vo != undefined) {
						// cas des xml contenant pour chaque équipement toutes les données de son vo
						vo = new EquipementVO();
						vo.type = equipement.@type;
						vo.name = equipement.vo.name;
						vo.screenLabel = equipement.vo.name;
						vo.id = equipement.vo.id;
						vo.infos = equipement.vo.infos;
						vo.modesDeConnexionPossibles = equipement.vo.modesDeConnexionPossibles.split(",");
						vo.max = equipement.vo.max;
						vo.imagePath = equipement.vo.imagePath;
						vo.isOrange = equipement.vo.isOrange;
						vo.diaporama360 = equipement.vo.diaporama360;
						vo.linkArticleShop = equipement.vo.linkArticleShop;
						vo.nbPortsEthernet = equipement.vo.data.nbPortsEthernet;
					} else {
						// cas des xml optimisés: les données des vos ne sont plus stockées dans le plan
						vo = _appmodel.getVOFromXML(equipement.@vo);
					}
					
					//create equipement
					var klass:Class = AppUtils.getClassView(vo.type);
					var equipementView:EquipementView = new klass(vo);
					//equipementView.type = equipement.@type;
					// if attribute 'uniqueId' exists
					if ("@uniqueId" in equipement) {
						equipementView.uniqueId = equipement.@uniqueId;
					} else {
						equipementView.uniqueId = ObjectUtils.createUID();
					}
					if (String(equipement.@asso) === "") {
						equipementView.connexionViewsAssociated = [];
					} else {
						equipementView.connexionViewsAssociated = equipement.@asso.split(",");
					}
					
					if (klass == LiveplugView) {
						if ("@isModuleDeBase" in equipement) {
							LiveplugView(equipementView).isModuleDeBase = (equipement.@isModuleDeBase == "true") ? true : false;
						} else {
							LiveplugView(equipementView).isModuleDeBase = (equipement.connectedTo.@isModuleDeBase == "true") ? true : false;
						}
						/*LiveplugView(equipementView).equipementStr = (String(equipement.connectedTo) === "") ? null : equipement.connectedTo;
						LiveplugView(equipementView).slavesStr = (String(equipement.slaves) === "") ? null : equipement.slaves;
						if ("@master" in equipement) {
							LiveplugView(equipementView).masterStr = equipement.@master;
						}*/
						
					}
					/*if (klass == WifiExtenderView) {
						if ("@master" in equipement) {
							WifiExtenderView(equipementView).masterStr = equipement.@master;
						}
						WifiExtenderView(equipementView).equipementEthStr = (equipement.connectedTo == undefined) ? "null" : equipement.connectedTo;
						trace("récup equipementEthStr="+WifiExtenderView(equipementView).equipementEthStr);
						WifiExtenderView(equipementView).equipementWifiStr = (equipement.connectedToWifi == undefined) ? "null" : equipement.connectedToWifi;
						trace("récup equipementWifiStr="+WifiExtenderView(equipementView).equipementWifiStr);
					}*/
					if (klass == WifiDuoView) {
						/*if ("@master" in equipement) {
							WifiDuoView(equipementView).masterStr = equipement.@master;
						}*/
						//trace(WifiDuoView(equipementView).masterStr);
						if ("@isModuleDeBase" in equipement) {
							WifiDuoView(equipementView).isModuleDeBase = (equipement.@isModuleDeBase == "true") ? true : false;
						} else {
							WifiDuoView(equipementView).isModuleDeBase = (equipement.connectedTo.@isModuleDeBase == "true") ? true : false;
						}
						//WifiDuoView(equipementView).equipementEthStr = (equipement.connectedTo == undefined) ? "null" : equipement.connectedTo;
						//trace("récup equipementEthStr="+WifiDuoView(equipementView).equipementEthStr);
					}
					equipementView.linkedEquipmentStr = (String(equipement.@linked) === "") ? null : equipement.@linked;
					equipementView.isOwned = (equipement.@isOwned == "true") ? true : false;
					equipementView.selectedConnexion = (equipement.@mdc == "null") ? null : equipement.@mdc;
					equipementView.draw();
					equipementView.x = equipement.@x;
					equipementView.y = equipement.@y;
					
					bloc.equipements.addEquipement(equipementView);
				}
				
				//add Fiber line if there is one 
				var fiber:XMLList = blocxml.fiberLine;
				//trace("fromXML " + fiber + " " + fiber.length);
				if(fiber && fiber.length()>0) 
				{
					points = new Array();
					for each(point in fiber.*) {
						points.push(new Point(Number(point.@x), Number(point.@y)));
					}
					new AddFiberLineCommand(_model.currentBlocMaison, points).run();
				}
			}
			
			//labels
			for each(var label:XML in floorxml.labels.*) {
				var nameRoom:NomPieceView = new NomPieceView(label.@text);
				nameRoom.x = label.@x;
				nameRoom.y = label.@y;
				nameRoom.nouveau = false;
				
				floor.addLabel(nameRoom);
			}
			
		}
		
		public function get hasUnderground():Boolean
		{
			for (var i:int = 0; i < floors.floorsArr.length; i++)
			{
				var floor:Floor = floors.floorsArr[i];
				if(floor.id == -1)
				{
					return true;
				}
			}
			return false;
		}
		
		private function _affectConnexions(xml:XMLList = null):void
		{
			// set special connexions
			//for equipements connected to LP or WFE
			//for LP and WFE which equipements they are connected to
			
			var equipements:Array = EquipementsLayer.EQUIPEMENTS;
			for (var i:int = 0; i < equipements.length; i++)
			{
				var eqv:EquipementView = equipements[i] as EquipementView;
				//trace("//--- ", eqv);
				eqv.linkedEquipment = EquipementsLayer.getEquipement(eqv.linkedEquipmentStr);
			}
			
			_appmodel.connectionsCollection.fromXML(xml);
			
		}
		
		private function _closeMenus():void
		{
			var menu:MenuContainer = MenuContainer.instance;
			if (menu && menu.stage) menu.closeMenu();
		}
		
		private var _timeOutId:int;
		private var _timeIntevalId:int;
		public function agrandir():void
		{
			trace("agrandir");
			MenuItemRenderer.DOCLOSE = false;
			MenuItemRenderer.DO_MOUSE_UP = stopResize;
			MeasuresContainer.showMeasures(true);
			clearTimeout(_timeOutId);
			clearInterval(_timeIntevalId);
			_timeIntevalId = setInterval(_startEnlarge, 100);
		}
		
		public function reduire():void
		{
			trace("reduire");
			MenuItemRenderer.DOCLOSE = false;
			MenuItemRenderer.DO_MOUSE_UP = stopResize;
			MeasuresContainer.showMeasures(true);
			clearTimeout(_timeOutId);
			clearInterval(_timeIntevalId);
			_timeIntevalId = setInterval(_startReduce, 100);
		}
		
		private function _startEnlarge():void
		{
			var bounds:Rectangle =  _model.currentMainEntity.surface.getBounds(EditorBackground.instance);
			if (Measure.pixelToMetric(bounds.width) > 20 || Measure.pixelToMetric(bounds.height) > 20)
			{
				stopResize();
				return;
			}
			_model.homeScale = 1.2;
		}
		
		private function _startReduce():void
		{
			var bounds:Rectangle = _model.currentMainEntity.surface.getBounds(EditorBackground.instance);
			if (Measure.pixelToMetric(bounds.width) < 4 || Measure.pixelToMetric(bounds.height) < 4)
			{
				stopResize();
				return;
			}
			_model.homeScale = .8;
		}
		
		public function stopResize():void
		{
			clearInterval(_timeIntevalId);
			clearTimeout(_timeOutId);
			_timeOutId = setTimeout(MeasuresContainer.showMeasures, 1000, false);
			_model.notifyHomeResizeEndEvent();
		}
		
		private function _isAllowedToDragEditor(displayObj:Object):Boolean
		{
			if (displayObj is CurseurDeplacementEditeur) return true;
			if (displayObj is Editor2D) return true;
			if (displayObj is Grid) return true;
			if (displayObj is EditorBackground) return true;
			if (displayObj is Surface && Surface(displayObj).isMainSurface) return true;
			return false;
		}
		
		/**
		 * Cette méthode met en place les différents actions à utiliser pour les objets DraggedObject de l'éditeur, 
		 * l'éditeur (Editor2d) étant lui-même un DraggedObject
		 * 
		 * @param	e (MouseEvent) l'évènement click
		 */
		override public function onMouseDownEvent(e:MouseEvent):void
		{
			//trace("Editor2d::_onMouseDown() target ", e.target );
			_closeMenus();
			//_model.editorIsZooming = false;
			_model.notifyZoomEndEvent();
			var target:DisplayObject = e.target as DisplayObject;
			
			if (target is DragPointHandle)
			{
				var pointView:PointView = DragPointHandle(target).pointView;
				_draggedObject = pointView;
				
				//if (!_draggedObject.isLocked) 
				//	pointView.pointVO.removeAssociatedSegment();
			}
			else if (target is DragSegmentHandle)
			{
				
				var segment:Segment = DragSegmentHandle(target).segment;
				/*var homeSegment:Segment = segment.stickToHomeSegment();
				trace("homeSegment " + homeSegment);
				if (homeSegment) _draggedObject = homeSegment;
				else */_draggedObject = segment;
				
			}
			else if (_isAllowedToDragEditor(target))
			{
				_draggedObject = this;
				if (target is Surface) {
					_measuresTimeId = setTimeout(MeasuresContainer.showMeasures,200, true);
				}
				
				//MeasuresContainer.update();
			}
			else if (target is NomPieceView)
			{
				_draggedObject = DraggedObject(target);
			}
			else if (target is Surface && ApplicationModel.instance.currentStep <= ApplicationModel.STEP_SURFACE) 
			{
				//_closeMenus();
				var surface:Surface = target as Surface;
				var bloc:Bloc = surface.obj2D.bloc;
				_draggedObject = bloc;
			}
			//target est le curseur de deplacement
			else if (target is MovieClip && target.parent is DraggedObject)
			{
				_draggedObject = target.parent as DraggedObject;
			}
			else if(ObjectUtils.hineritFromClass(target, EquipementView))//Optimisation : if target is EquipementView voir EquipementView
			{
				_draggedObject = DraggedObject(target);
			}
			else
			{
				//nothing
			}
			
			addEventListener(MouseEvent.MOUSE_UP, onMouseUpEvent);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
			Segment.FRIENDS = new Array();
			
			if (!_draggedObject) return;
			
			//trace("Editor2d::_onMouseDown() draggeObject ", _draggedObject,  _draggedObject is Bloc && Bloc(_draggedObject).isBlocMaison);
			
			if (_draggedObject is Editor2D)
			{
				//dragged object est l'editeur
				super.onMouseDownEvent(e);
			}
			else
			{
				//autre objets que l'editeur 
				_draggedObject.onMouseDownEvent(e);
			}
			
			if (!_draggedObject.isLocked)			
				addEventListener(MouseEvent.MOUSE_MOVE, _draggedObject.onMouseMoveEvent);
		}
		
		private var _mousePoint:Point
		override protected function mouseDown():void
		{
			//trace("Editor2D::mouseDown"); 
			_mousePoint = new Point(mouseX, mouseY);
			
		}
		
		override public function onMouseMoveEvent(e:MouseEvent):void
		{
			super.onMouseMoveEvent(e);
		}
		
		override protected function mouseMove():void
		{
			if (! _mousePoint) return;
			var p:Point = new Point(parent.mouseX, parent.mouseY).subtract(_mousePoint);
			x = p.x;
			y = p.y;
			dragCursor.x = mouseX;
			dragCursor.y = mouseY;
		}
		
		private function _onStageMouseUp(e:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUpEvent);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
			//trace("_onStageMouseUp", e.target);
			
			if (isDragging && !_isAllowedToDragEditor(e.target)) {
				
				onMouseUpEvent(e);
			}
		}
		
		override public function onMouseUpEvent(e:MouseEvent=null):void
		{
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUpEvent);	
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
			Segment.FRIENDS = new Array();
			
			if (_draggedObject) 
			{
				//trace("_draggedObject MOUSE_UP");
				removeEventListener(MouseEvent.MOUSE_MOVE, _draggedObject.onMouseMoveEvent);
				if (_draggedObject is Editor2D) 
				{
					if (e.target is Surface) 
					{
						clearTimeout(_measuresTimeId);
						if (isDragging)
						{
							MeasuresContainer.showMeasures(false);
						}
						else
						{
							if (MeasuresContainer.isON)
							{
								MeasuresContainer.showMeasures(false);
							}
							else
							{
								Surface(e.target).onClickOnSurface();
							}
						}
						
					}
					
					super.onMouseUpEvent(e);
					
				}
				else
				{
					_model.draggedSegment= null;
					_model.pointIsDragged = false;
					_draggedObject.onMouseUpEvent(e);
				}
				_draggedObject = null;
				
			}
			
			/*var isEditor2DReleaseOutside:Boolean = (e.target is Editor2D);
			if (!isEditor2DReleaseOutside) {
				mouseUpWhileDrag();
			}*/
		}
		
		override protected function mouseUp():void
		{
			//trace("editor::onMouseUp open menu");
		}
		
		override protected function mouseUpWhileDrag():void
		{
			//trace("ediotr::onMouseup");
			if (_mousePoint) _mousePoint = null;
		}
		
		private function _removed(e:Event):void
		{
			//trace("Editor2d::_removed");
			_self = null;
			//floors = null;
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		private function _onZoom(e:ZoomEvent):void
		{
			//trace("center point " + localToGlobal(centerPoint));
		}
	}

}