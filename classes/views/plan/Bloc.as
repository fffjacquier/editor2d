package classes.views.plan 
{
	import classes.commands.AddNewSurfaceCommand;
	import classes.commands.FollowingPointsCommand;
	import classes.controls.HomeResizeEvent;
	import classes.controls.UpdatePointsVOEvent;
	import classes.controls.ZoomEndEvent;
	import classes.controls.ZoomEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.AppUtils;
	import classes.utils.GeomUtils;
	import classes.utils.ObjectUtils;
	import classes.views.equipements.EquipementView;
	import classes.views.EquipementsLayer;
	import classes.views.plan.BalconyEntity;
	import classes.views.plan.DraggedObject;
	import classes.vo.BlocVO;
	import classes.vo.PointVO;
	import classes.vo.Texture;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/*  Optimisation de code
	
		Optimisation du fonctionnement	
		Faire en sorte que lorsqu'on bouge des blocs qui contiennent des cloisons, ces cloisons suivent
		ce mouvement fidèllement et non pas de façon anarchique
	
	*/

	/**
	 * Bloc est la classe de base de toutes les surfaces de l'appartement.
	 * 
	 * <p>Bloc étend DraggedObject car on peut parfois déplacer un bloc.</p>
	 * <p>Les blocs sont constitués d'un objet nommé entity héritant de la classe Object2D, doté d'une surface.</p>
	 * <p>Chaque étage a son bloc principal délimitant les murs de la maison, directement contenu dans l'étage dont l'entity est MainEntity. 
	 * Ce bloc principal peut contenir les autres blocs, à savoir les pièces, dont les entity sont BalconEntity ou RoomEntity toutes deux héritant de PieceEntity.</p>
	 */
	public class Bloc extends DraggedObject
	{
		public var type:String;
		private var _points:Array;
		public var texture:Texture;
		
		protected var model:EditorModelLocator = EditorModelLocator.instance;
		
		
		public var entities:Array = new Array();
		public var mainEntity:MainEntity;
		private var _entity:Object2D;
		private var _fiberLine:FiberLineEntity;
		private var _surfaceType:String;
		
		public var cloisons:Cloisons;
		public var pieces:Pieces;
		public var equipements:EquipementsLayer;
		public var connectionsLayer:Sprite;
		public var fiberLineContainer:Sprite;
		
		public var floorId:int;
		
		/* 	Optimisation de code
		   	mettre variable mainEntity en getter public de la variable privée _entity
		   	renommer _entity en mainEntity
		
		   	Optimisation du fonctionnement	
		   	mouseupWhileDrag, pour les pieces, recupérer en parametre le déplacement effectué
			lors du sticktogrid et de l'attachpoints et l'affecter aux cloisons et aux équipements
			qui se trouvent actuellment décalés de leru position d'origine lorsqu'on déplace les blocs. 
		
		*/
		
		
		
		/**
		 * <p>Les blocs en fonction de leur type créent leur squelette fait de segments et de points nommé entité et leur surface.</p>
		 * <p>le constructeur est appelé dans la commande AddNewSurfaceCommand</p>
		 * @param type Le type de surface, par défaut "blocMaison", autres valeurs possibles "blocPiece", "blocBalcon"...
		 * @param pointsArr Un tableau de points correspondant aux sommets de la surface
		 * @param texture La texture du bloc ou sa couleur
		 * @param surfaceType Forme libre ou rectangle
		 */
		public function Bloc(type:String, pointsArr:Array, texture:Texture=null, surfaceType:String=null) 
		{
			this.type = type;
			_surfaceType = surfaceType || Surface.TYPE_FREE;
			var rd:int = Math.random() *100;
			this.texture = texture;
			floorId = model.currentFloorId;
			
			_points = pointsArr; /* added for history undo purpose */
			addEntity(_points);
			
			model.addPointsVOUpdateListener(onPointsVOUpdate);
			
			if (isBlocMaison)
			{
				pieces = new Pieces();
				addChild(pieces);
			}
			else
			{
				dragCursor = new CurseurDeplacement();
				dragCursor.x = 0;
			    dragCursor.y = 0;
				model.addHomeResizeEventListener(_onHomeResize);
			}
			
			cloisons = new Cloisons();
			addChild(cloisons);
			
			equipements = new EquipementsLayer();
			addChild(equipements);
			
			if (!isPiece) 
			{
				model.addZoomEventListener(_onZoom);
				model.addZoomEndEventListener(_onEndZoom);
				if(parent) _onZoom();
			}
			
			if (isBlocMaison)
			{
				connectionsLayer = new Sprite();
				addChild(connectionsLayer);
			}
			
			addEventListener(Event.REMOVED_FROM_STAGE, _clean);
		}
		
		private function _onZoom(e:ZoomEvent=null):void
		{
			if (isPiece) return;
			var prevScale:Number = model.prevScale;
			var scale:Number = model.currentScale;
			var scaleFactor:Number = scale / prevScale;
			x *= scaleFactor;
			y *= scaleFactor;
		}
		
		private function _onEndZoom(e:ZoomEndEvent=null):void
		{
			trace("endzoom")
			if (!isPiece)
			{
				stickToGrid();
			}
		}
		
		private function _onHomeResize(e:HomeResizeEvent):void
		{
			//if (isBlocMaison) return;
			if (isPiece) return;
			//trace("bloc " + this + " homeResize ");
			var scale:Number = e.scale;
			x *= scale;
			y *= scale;
			stickToGrid();
		}
		
		protected function onPointsVOUpdate(e:UpdatePointsVOEvent):void
		{
		}
		
		public function get points():Array {
			return _entity.points;
		}
		
		public function addEntity(points:Array):void
		{
			switch(type)
			{
				case BlocVO.BLOC_MAISON : 
					mainEntity = new MainEntity(0, points);
					_entity = mainEntity;
					addChild(mainEntity);
					entities.push(mainEntity);
					break;
					
				case BlocVO.BLOC_ROOM :
					var roomEntity:RoomEntity = new RoomEntity(0, points, _surfaceType);
					_entity = roomEntity;
					addChild(roomEntity);
					entities.push(roomEntity);
					break;
				
				case BlocVO.BLOC_BALCONY :
					var balconyEntity:BalconyEntity = new BalconyEntity(0, points,_surfaceType);
					_entity = balconyEntity;
					addChild(balconyEntity);
					entities.push(balconyEntity);
					break;
					
				case BlocVO.BLOC_DEPENDANCE :
					var dependanceEntity:DependanceEntity = new DependanceEntity(0, points);
					_entity = dependanceEntity;
					addChild(dependanceEntity);
					entities.push(dependanceEntity);
					break;
					
				case BlocVO.BLOC_JARDIN :
					var gardenEntity:GardenEntity = new GardenEntity(0, points);
					_entity = gardenEntity;
					addChildAt(gardenEntity, 0);
					entities.push(gardenEntity);
					break;
			}
		}
		
		public function get isBlocMaison():Boolean
		{
			return (type == BlocVO.BLOC_MAISON);
		}
		
		public function get isPiece():Boolean
		{
			return _entity.inheritFromPieceEntity;
		}
		
		public function get obj2D():Object2D
		{
			return _entity;
		}
		
		public function get surface():Surface
		{
			return obj2D.surface;
		}
		
		public function onclickOnSurface():void
		{
			surface.onClickOnSurface();
		}
		
		public function unlock():void
		{
			obj2D.unlock();
			cloisons.mouseChildren = false;
			pieces.mouseChildren = false;
			cloisons.alpha = .5;
			pieces.alpha = .5;
		}
		
		public function lock():void
		{
			obj2D.lock();
			cloisons.mouseChildren = true;
			pieces.mouseChildren = true;
			cloisons.alpha = 1;
			pieces.alpha = 1;
		}
		
		public function backToFront():void
		{
			/*if (!isPiece) return;
			var pieces:Pieces = model.currentBlocMaison.pieces;
			var index:int = pieces.getChildIndex(this);
			pieces.swapChildrenAt(index, pieces.numChildren -1);*/
			if (!parent) return;
			if (parent.numChildren <= 1) return;
			var index:int = parent.getChildIndex(this);
			parent.swapChildrenAt(index, parent.numChildren -1);
		}
		
		//-----------------  FIBER  ----------------
		//only in bloc maison 
		public function createFiberLineContainer():void
		{
			if(fiberLineContainer) return;
			fiberLineContainer = new Sprite();
			addChild(fiberLineContainer);
		}
		
		public function addFiberline(fiberLine:FiberLineEntity):void
		{
			
			if(!fiberLineContainer) createFiberLineContainer();
			_fiberLine = fiberLine;
			fiberLineContainer.addChildAt(fiberLine,0);
		}
		
		public function removeFiberline():void
		{
			if(!_fiberLine) return;
			fiberLineContainer.removeChild(fiberLine);
			_fiberLine = null;
		}
		
		public function get fiberLine():FiberLineEntity
		{
			return _fiberLine;
		}
		
		//------------- MOUSE EVENTS ----------
		
		private var _mousePoint:Point
		private var _oldMousepoint:Point;
		private var _beforeDragPoint:Point;
		private var _followingPointsCommand:FollowingPointsCommand;
		override protected function mouseDown():void
		{
			// FJ 18/10/2012 si on est en mode install pas de déplacement de pièce
			if (!model.isDrawStep) return;
			if (ApplicationModel.instance.currentStep != ApplicationModel.STEP_SURFACE) return;
			
			_mousePoint = new Point(mouseX, mouseY);
			
			placeDragCursor();
			_oldMousepoint = new Point(parent.mouseX, parent.mouseY);
			_beforeDragPoint = new Point(parent.mouseX, parent.mouseY);
			if (isPiece)
			{
				/*_count = 0; */
			//	obj2D.dontGlue = true;
				backToFront();
				_followingPointsCommand = new FollowingPointsCommand();
				
			     obj2D.removeAllAssociations(true, true);
				 obj2D.adjutSquarePoints();
			}
		}
		
		public function placeDragCursor(cursor:Sprite=null):void
		{
			if(cursor == null) cursor = dragCursor;
			var bounds:Rectangle = surface.getBounds(this);
			cursor.x = bounds.x + bounds.width / 2;
			cursor.y = bounds.y + bounds.height / 2;
		}
		
		public function translate(dep:Point):void
		{
			//if (!isPiece) return;
			obj2D.translate(dep);
			equipements.moveWidthPiece(dep);
			cloisons.moveWidthPiece(dep);
				
		}
		
		override protected function mouseMove():void
		{
			// FJ 18/10/2012 si on est en mode install pas de déplacement de pièce
			trace("Bloc::mouseMove()", model.isDrawStep,ApplicationModel.instance.currentStep, ApplicationModel.STEP_SURFACE);
			if (!model.isDrawStep) return;
			if (ApplicationModel.instance.currentStep != ApplicationModel.STEP_SURFACE) return;
			
			if (isPiece)
			{
				/*Segment.FRIENDS = new Array();
				_count++;
				obj2D.dontGlue = true;
				obj2D.removeAssociatedPoints();
				trace(_count);
				if (_count > 10)
				{
					trace("_count>10")
					////if (obj2D.hasAssociatedPoint())
					//	Editor2D.instance.onMouseUpEvent();
						
					obj2D.dontGlue = false;
				}*/
				var mousePoint:Point = new Point(parent.mouseX, parent.mouseY);
				var dep:Point = mousePoint.subtract(_oldMousepoint);
				_oldMousepoint = mousePoint;
				translate(dep);
				var bounds:Rectangle = surface.getBounds(this);
				dragCursor.x = bounds.x + bounds.width / 2;
				dragCursor.y = bounds.y + bounds.height / 2;
				
				return;
			}
			//pour dependances et autres exterieurs
			if (!_mousePoint) return;
			var p:Point = new Point(parent.mouseX, parent.mouseY).subtract(_mousePoint);
			x = p.x;
			y = p.y;
			if(!isSquare)  stickToGrid();  //a virer si ça bug) 
		}
		
		public function get isSquare():Boolean
		{
			return obj2D.isSquare;
		}
		
		public function stickToGrid():void
		{
			//aimentation : ici on deplace le bloc et non les points, maos le calcul se fait sur les points
			var pointV0:PointVO = obj2D.pointsVOArr[0];
			/*if (!pointV0) return;
			if (!pointV0.pointView) return;
			if (!pointV0.pointView.parent) return;
			var magnetPoint:Point = GeomUtils.magnetPoint(pointV0.point, pointV0.pointView.parent);*/
			var magnetPoint:Point = GeomUtils.magnetPoint(pointV0.point, obj2D);
			var diffPoint:Point = magnetPoint.subtract(pointV0.point);
			x += diffPoint.x;
			y += diffPoint.y;
		}
		
		override protected function mouseUp():void
		{
			onclickOnSurface();
			if (isPiece)
			{
				/*obj2D.stickToGrid(); 
				obj2D.keepShape = true;
				obj2D.testAndAttachPoints();
				obj2D.keepShape = false;
				obj2D.adjutSquarePoints();*/
				//2aout  inutile de daplacer les points et cloisons puisqu'ilsn e bougent pas 
				//il suffit juste de reassocier les points dissociés en mousedown
				cloisons.attachPoints();
			}
			/*if (isPiece)
			{
				obj2D.dontGlue = false;
				//Segment.FRIENDS = new Array();
				//_count = 0;
			}*/
			
		}
		
		
		override protected function mouseUpWhileDrag():void
		{
			if (_mousePoint) _mousePoint = null;
			//pas de déplacement on ne fait rien. Surtout on n'enregistre pas de déplacement.
			var mousePoint:Point = new Point(parent.mouseX, parent.mouseY);
			if (mousePoint.equals(_beforeDragPoint)) return;
			
			if (isPiece)
			{
			    obj2D.stickToGrid(); 
				obj2D.keepShape = true;
				obj2D.testAndAttachPoints();
				obj2D.keepShape = false;
				obj2D.adjutSquarePoints();
				cloisons.attachPoints();
				if(_followingPointsCommand != null) _followingPointsCommand.run();
				_followingPointsCommand = null;
			}
		}
		//--------texture ----------
		public function setTexture(newTexture:Texture):void
		{
			if(!texture) texture = newTexture.clone();
			else texture.copy(newTexture);
		}
		//----------------------------------------------
		
		public function toXML():XML
		{
			var segmentsArrMurPorteurs:Array = _getMurPorteursArr(obj2D);
			var coeffsArr:Array = getMursCoeffArr(obj2D);
			var blocNode:XML = new XML("<bloc type=\"" + this.type + "\" classz=\"" + ObjectUtils.getClass(obj2D) + "\" positionx=\"" + x / model.currentScale + "\" positiony=\"" + y / model.currentScale + "\" mursPorteurs=\""+segmentsArrMurPorteurs+"\" coeffMurs=\""+coeffsArr+"\"></bloc>");
			if(!surface.hasDefaultTexture)
			{
				blocNode.@alphaSurface = texture.alfa;
				if(texture.isColor) blocNode.@colorSurface = texture.color;
				else blocNode.@textureSurface = texture.texturePath;
			}
			if(!obj2D.isSquare) blocNode.@surfaceType = Surface.TYPE_FREE;
			var pointsNode:XML = new XML("<points></points>");
			var i:int;  
			var aPoints:Array = points;
			for (i = 0; i < (aPoints.length); i++) {  
				var point:Point = aPoints[i] as Point;
				var pointNode:XML = new XML("<point x=\"" + point.x / model.currentScale + "\" y=\"" + point.y / model.currentScale + "\" id=\""+i+"\" />");
				pointsNode.appendChild(pointNode);
			}  
			blocNode.appendChild(pointsNode);
			
			var cloisonsNode:XML = new XML("<cloisons></cloisons>");
			for (i = 0; i < cloisons.numChildren; i++) {  
				var cloison:CloisonEntity = cloisons.getChildAt(i) as CloisonEntity;
				var mursPorteur:Array = _getMurPorteursArr(cloison, true);
				var coeffMurs:Array = getMursCoeffArr(cloison, true);
				var cloisonNode:XML = new XML("<cloison mursPorteurs=\"" + mursPorteur + "\" coeffMurs=\"" + coeffMurs + "\"></cloison>");
				var ii:int;  
				aPoints = cloison.points;
				for (ii = 0; ii < (aPoints.length); ii++) { 
					point = (aPoints[ii] as Point);
					var pointsCloisonNode:XML = new XML("<point x=\"" + point.x / model.currentScale + "\" y=\"" + point.y / model.currentScale + "\" id=\""+ii+"\" />");
					cloisonNode.appendChild(pointsCloisonNode);
				}
				cloisonsNode.appendChild(cloisonNode);
			}  
			blocNode.appendChild(cloisonsNode);
			
			var equipementsNode:XML = new XML("<equipements></equipements>");
			for (i = 0; i < (equipements.numChildren); i++) {  
				var equipement:EquipementView = equipements.getChildAt(i) as EquipementView;
				var equipementNode:XML = equipement.toXML();
				equipementsNode.appendChild(equipementNode);
			}  
			blocNode.appendChild(equipementsNode);
			
			if(fiberLine)
			{
				var fiberNode:XML = new XML("<fiberLine></fiberLine>");
				aPoints = fiberLine.points;
				for (i = 0; i < (aPoints.length); i++) { 
					point = (aPoints[i] as Point);
					var FiberPointsNode:XML = new XML("<point x=\"" + point.x / model.currentScale + "\" y=\"" + point.y / model.currentScale + "\" id=\""+i+"\" />");
					fiberNode.appendChild(FiberPointsNode);
				}
				blocNode.appendChild(fiberNode);
			}
			
			return blocNode;
		}
		
		public function _getMurPorteursArr(obj2D:Object2D, cloison:Boolean= false):Array
		{
			var tmp:Array = [];
			if (this.type == "blocPiece") {
				var len:int = obj2D.segmentsArr.length;
				for (var i:int = 0; i < len; i++) 
				{
					//trace("segment", i, "murporteur", (obj2D.segmentsArr[i] as Segment).murPorteur);
					if ((obj2D.segmentsArr[i] as Segment).murPorteur) {
						tmp.push(i);
					}
				}
			} else if (cloison) {
				len = obj2D.segmentsArr.length;
				for (i = 0; i < len; i++) 
				{
					//trace("segment", i, "murporteur", (obj2D.segmentsArr[i] as Segment).murPorteur);
					if ((obj2D.segmentsArr[i] as Segment).murPorteur) {
						tmp.push(i);
					}
				}
			}
			return tmp;
		}
		
		public function getMursCoeffArr(obj2D:Object2D, cloison:Boolean= false):Array
		{
			var tmp:Array = [];
			if (this.type == "blocMaison") {
				var len:int = obj2D.segmentsArr.length;
				for (var i:int = 0; i < len; i++) 
				{
					//trace("segment", i, "murporteur", (obj2D.segmentsArr[i] as Segment).murPorteur);
					var seg:Segment = (obj2D.segmentsArr[i] as Segment);
					tmp.push(seg.coeff);
				}
			} else {
				if (this.type == "blocPiece") {
					len = obj2D.segmentsArr.length;
					for (i = 0; i < len; i++) 
					{
						//trace("segment", i, "murporteur", (obj2D.segmentsArr[i] as Segment).murPorteur);
						seg = (obj2D.segmentsArr[i] as Segment);
						tmp.push(seg.coeff);
						/*if (seg.murPorteur) {
							tmp.push(i);
						}*/
					}
				} else if (cloison) {
					len = obj2D.segmentsArr.length;
					for (i = 0; i < len; i++) 
					{
						seg = (obj2D.segmentsArr[i] as Segment);
						tmp.push(seg.coeff);
						/*if (seg.murPorteur) {
							tmp.push(i);
						}*/
					}
				}
			}
			return tmp;
		}
		
		public function get surfaceType():String
		{
			return obj2D.surfaceType;
		}
		
		public function changeSurfaceType():void
		{
			//change to free surface only
			if(surfaceType == Surface.TYPE_FREE) return;
			var pts:Array = points.concat();
			new AddNewSurfaceCommand(pts, type, null, _getMurPorteursArr(obj2D), getMursCoeffArr(obj2D), texture, Surface.TYPE_FREE, this).run();
		    //on a deja recupéré les éventuels equipements, sans les deconnecter. 
			//donc equipementLayer dde ce bloc devrait etre vide
			equipements.equipementsArr = new Array();
			model.currentFloor.removeBloc(this);
		}
		
		//----------- cacher blocs et leur equipments un a un et non en groupe
		public function hideAll():void
		{
			AppUtils.setVisibleChildrenOf(equipements, false);
			AppUtils.setVisibleChildrenOf(cloisons, false);
			if(isBlocMaison)
			{
				pieces.hidePieces();
				obj2D.alpha = 0;
				surface.alpha = 0;				
			}
			else
			{
				AppUtils.setVisibleChildrenOf(obj2D, false);
			}
			obj2D.pointsViewContainer.visible = false;
		}
		
		public function showAll():void
		{
			AppUtils.setVisibleChildrenOf(equipements, true);
			AppUtils.setVisibleChildrenOf(cloisons, true);
			if(isBlocMaison)
			{
				pieces.showPieces();
				obj2D.alpha = 1;
				surface.alpha = 1;
			}
			else
			{
				AppUtils.setVisibleChildrenOf(obj2D, true);
			}
		}
		
		private function _clean(e:Event):void
		{
			model.removePointsVOUpdateListener(onPointsVOUpdate);		
			model.removeZoomEventListener(_onZoom);	
			model.removeHomeResizeEventListener(_onHomeResize);
			removeEventListener(Event.REMOVED_FROM_STAGE, _clean);
		}
	}
}