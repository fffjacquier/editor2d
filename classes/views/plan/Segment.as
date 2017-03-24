package classes.views.plan 
{
	import classes.commands.InsertOnePointCommand;
	import classes.commands.InsertTwoPointsCommand;
	import classes.commands.MoveSegmentCommand;
	import classes.commands.cloisons.DuplicateCloisonCommand;
	import classes.config.Config;
	import classes.controls.PointMoveEndEvent;
	import classes.controls.PointMoveEvent;
	import classes.controls.PointMoveStartEvent;
	import classes.model.EditorModelLocator;
	import classes.utils.ArrayUtils;
	import classes.utils.GeomUtils;
	import classes.utils.Measure;
	import classes.utils.ObjectUtils;
	import classes.utils.WifiUtils;
	import classes.views.menus.MenuContainer;
	import classes.views.menus.MenuFactory;
	import classes.views.menus.MenuItemRenderer;
	import classes.views.menus.MenuRenderer;
	import classes.views.menus.MenuTypeDeCloison;
	import classes.views.plan.DraggedObject;
	import classes.vo.PointVO;
	
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/*
		Optimisation de code : gérer ou supprimer les id de segments. Au moins refléchir à ce que leur utlisation pourrait amener à l'application
	*/
	
	/**
	 * Segment est l'objet physique permettant de visualiser les murs d'une surface ou cloison.
	 * <p>Il étend DraggedObject car il peut être déplacé par interactivité dans le plan. C'est un Sprite</p>
	 * 
	 */	
	public class Segment extends DraggedObject 
	{	
		private var _id		:int;
		public var p1		:PointVO;
		public var p2		:PointVO;
		private var _obj2D	:Object2D;
		protected var weight:int;
		protected var color :int;
		
		
		protected var zone :Sprite;
		protected var seg  :Sprite;
		
		public var dragHandle        :DragSegmentHandle;
		public var murPorteur        :Boolean = false;
		public var coeff             :int = 3; /* le coefficient multiplicateur pour le caclcul des pertes en wifi, par défaut 3 pour les cloisons de pièces, 0 pour les balcons */
		private var _movingCount     :int;
		private var diffx            :Number;
		private var diffy            :Number;
		private var _oldPos          :Point;
		/**
		 * Calcul de distance en tout début de mouvement pour déterminer s'il est horizontal ou vertical
		 * Cela permet de ne bouger les segments que horizontalement ou verticalement 
		 * et ne pas perdre l'othogonalité des pièces et de la maison
		 */
		private var _firstImpulse    :Point;
		private var _yellow          :Boolean = false;
		public var intersectionPoints:Array; //of IntersectionPoint;
		
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _displayMeasure:DisplayMeasure;
		private var associatedMeasures:Array = new Array();
		public var associatedPoints:Array = new Array();
		public static var FRIENDS:Array = new Array();
		
		/**
		 * Segment se dessine grâce à sa la méthode public draw. 
		 * <p>La classe écoute toute  notification de changement de ccordonnées des points PointVO, et se redessine si contient l'un des points déplacés.</p>
		 * 
		 * @param id non réellement exploité bien que requis 
		 * @param p1 L'un des pointVO su segment
		 * @param p2 L'autre des pointVO du segment
		 * @param obj L'Object2D dont il est l'un des points.
		 * @param weight L'épaisseur par défaut du mur s'il n'est pas un mur porteur. 
		 * @param color La couleur par défaut du trait représentant le mur. 
		 * 
		 */	
		public function Segment(id:int, p1:PointVO, p2:PointVO, obj:Object2D, weight:int = 2, color:int = 0 ) 
		{
			super();
			_id = id;
			_obj2D = obj;
			
			this.color =color;
			this.weight = weight;
			this.p1 = p1;
			this.p2 = p2;
			
			p1.segments.push(this);
			p2.segments.push(this);
			
			//trace(p1.x + p1.y + p2.x + p2.y)
			
			zone = new Sprite();
			seg = new Sprite();
			addChild(zone);
			addChild(seg);
			_displayMeasure = new DisplayMeasure(this);	
			_displayMeasure.selfAdd();
			//_displayMeasure.visible = Editor2D.instance.displayMeasuresCheckBoxValue;
			draw();
			
			if(!dragHandle) dragHandle = new DragSegmentHandle(this);
			if (!dragHandle.stage) addChild(dragHandle);		
			if (!((isInCloison || isInPiece) && ! obj2D.ownerEntity)) 
			{
				dragHandle.scaleX = .5;
				dragHandle.scaleY = .5;	
				over();	
				dragHandle.showHide();
				//setTimeout(hideDragHandle, 1000);
			}
			else 
			{
				dragHandle.visible = false; 
			}
			Editor2D.instance.addEventListener(MouseEvent.MOUSE_UP, _onEditorMouseUp);
		
			addEventListener(MouseEvent.MOUSE_OVER, over)
			addEventListener(MouseEvent.MOUSE_OUT, out);
			_model.addPointMoveListener(onPointMove);
		
			
			addEventListener(Event.REMOVED_FROM_STAGE, _remove);
			addEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _onAdded(e:Event):void
		{
			if(isFiber) 
			{
				hitSegmentsTest();
				_model.addPointMoveStartListener(_onPointMoveStart);
				_model.addPointMoveEndListener(_onPointMoveEnd);
			}
			
			if (isInHome) {
				murPorteur = true;
				coeff = WifiUtils.coeffCloison(WifiUtils.THICKNESS_THICK);
			}
		}
		
		public function hitSegmentsTest():void
		{
			intersectionPoints = GeomUtils.getHittingPoints(p1.point, p2.point, this);
		}
		
		public function get metricSize():Number
		{
			return _displayMeasure.measure;
		}
		
		public function setMurPorteur():void
		{
			murPorteur = !murPorteur;
			//trace("murPorteur changé:", murPorteur);
			draw();
		}
		
		public function menuMurPorteur():void
		{
			//trace("murPorteur actuel:", murPorteur, "coeff", coeff);
			// do not close menu yet si murPorteur
			MenuItemRenderer.DOCLOSE = murPorteur;
			
			setMurPorteur();
			
			// on doit faire apparaitre le popup nature de cloison
			if (murPorteur) {
				var nat:MenuTypeDeCloison = new MenuTypeDeCloison(this);
				nat.name = "rome";
				if(nat.stage == null) MenuContainer.instance.addChild(nat);
				nat.x = (MenuContainer.instance.width - nat.width) /2;
				nat.y = MenuContainer.instance.mouseY + 20;
			} else {
				MenuContainer.instance.closeMenu();
			}
		}
		
		public function setMurCoeff(val:int = -1):void
		{
			if (val == -1) {
				if (obj2D is MainEntity) coeff = WifiUtils.coeffCloison(WifiUtils.THICKNESS_NSP);
				else if (obj2D is BalconyEntity) coeff = WifiUtils.coeffCloison(WifiUtils.THICKNESS_NO);
				else coeff = WifiUtils.coeffCloison("def");
			} else {
				coeff = val;
			}
		}
		
		public function setCoeffAndMurPorteur(val:int):void
		{
			setMurCoeff((!murPorteur) ? -1 : val);
			//trace("coeff=", coeff);
			MenuItemRenderer.DOCLOSE = true;
			MenuContainer.instance.closeMenu();
		}
		
		public function draw(moving:Boolean = false):void
		{
			_yellow = false;
			if (!_model.segmentIsDragged && !_model.pointIsDragged) moving = false;
			
			var g:Graphics;
			
			g = zone.graphics;
			g.clear();
			g.lineStyle(6, 0xffffff, 0);
			g.moveTo(p1.x, p1.y);
			g.lineTo(p2.x, p2.y);
			
			g = seg.graphics;
			g.clear();
			//var color:int = Math.abs((angle % Math.PI/2)) < .005  ? 0 : Config.COLOR_OBLIQUE_SEGMENT;
			var color:int = (murPorteur && !isInHome) ? Config.COLOR_POINTS_EXTERNES_INSIDE : 0;
			//trace("moving " + moving);
			if (isFiber) color = Config.COLOR_FIBERLINE;
			if (isOrtho && moving == true) 
			{
				color = Config.COLOR_ORTHO_SEGMENT;
				_yellow = true;
			}
			//couleur de cloisonItem ghost
			if ((isInCloison || isInPiece) && obj2D.ownerEntity == null) {
				color = Config.COLOR_POINTS_EXTERNES_INSIDE;
			}
			//var capStyle:String = isSingleCloison ? CapsStyle.SQUARE : CapsStyle.ROUND;
			//gaine orange autour de la fibre
			/*if(isFiber)
			{
				g.lineStyle(weight+2, Config.COLOR_ORANGE, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE);
				g.moveTo(p1.x, p1.y);
				g.lineTo(p2.x, p2.y);
			}*/
			var capStyle:String = CapsStyle.ROUND;
			g.lineStyle(weight, color, 1, false, LineScaleMode.NORMAL, capStyle);
			g.moveTo(p1.x, p1.y);
			g.lineTo(p2.x, p2.y);
			
			//if (!_obj2D.ownerEntity && !isInHome) return;
			var arr:Array =new Array();
			if (associatedPoints.length > 0 && !_model.editorIsResizing && !_model.editorIsZooming
			    && _model.pointIsDragged && !_model.segmentIsDragged) 
			{
				for (var i:int = 0; i < associatedPoints.length; i++)
				{
					var associatedPoint:PointVO = associatedPoints[i];
					var doTheJob:Boolean = true;
					//if(isInCloison && !associatedPoint.isInCloison) doTheJob = false;MM2204
					if(associatedPoint.isLocked || associatedPoint.pointView.isCorner) 
					{
						associatedPoint.removeFromAssociator();
					}
					else
					//if (associatedPoint.isActive/*!associatedPoint.isAssociatedToPoint && !associatedPoint.isActive && !associatedPoint.isInPiece*/)
					  //  && !associatedPoint.pointView.isDragging && !associatedPoint.isInDraggingSegment)
					{
						arr.push(associatedPoint);
						var prevPoint:Point = associatedPoint.point;
						if (!associatedPoint.recPoint) associatedPoint.registerRecPoint();
						var stickPoint:Point;
						if (_model.segmentIsDragged && _model.dragDep && associatedPoint.isInPiece)
						{
							//trace("cas possible???   dans segment draw");
							stickPoint = associatedPoint.add(_model.dragDep)
						}
						else
						{
							associatedPoint.setPointPosition(Point.interpolate(p2, p1, associatedPoint.associationFactor));
							stickPoint = associatedPoint.point;
							
							if (isVertical)
							{
								stickPoint = GeomUtils.magnetPointY(stickPoint, associatedPoint.pointView.parent);
							}
							else if (isHorizontal)
							{
								stickPoint = GeomUtils.magnetPointX(stickPoint, associatedPoint.pointView.parent);
							}
						}
					    if(doTheJob)
						{
							associatedPoint.setPos(stickPoint);
							
							associatedPoint.translation = associatedPoint.subtract(prevPoint);
							//friends = friends.concat(associatedPoint.dragFriends(friends));
							//associatedPoint.dragFriends();
							associatedPoint.testAndFree();
							arr.push(associatedPoint);
						}
						
					}
				}
				if (!FRIENDS) FRIENDS = new Array();
				
				//trace("segment draw " + _obj2D + arr + FRIENDS)
				if (FRIENDS.length > 0) arr = arr.concat(FRIENDS);
				
				if(arr.length > 0) _model.notifyPointMove(arr);
			}
			displayMeasuresUpdate();
			if (doesStickToSegment() && _displayMeasure) _displayMeasure.visible = false;
			//showDisplayMeasures(true);
		}
		
		private function _onEditorMouseUp(e:MouseEvent):void
		{
			//trace("_onEditorMouseUp");
			if (_yellow) draw(false);
		}
		
		public function displayMeasuresUpdate():void
		{
			if(obj2D is FiberLineEntity) return;
			for (var i:int = 0; i < associatedMeasures.length; i++)
			{
				var displayMeasure:DisplayMeasure = associatedMeasures[i];
				displayMeasure.update();
			}
			_displayMeasure.update();
		}
			
		public function showDisplayMeasures(doShow:Boolean):void
		{
			if(obj2D is FiberLineEntity) return;
			if (associatedPoints.length == 0)
			{
				_displayMeasure.visible = doShow;
				
				if (doesStickToSegment()) _displayMeasure.visible = false;
				return;
			}
			for (var i:int = 0; i < associatedMeasures.length; i++)
			{
				var displayMeasure:DisplayMeasure = associatedMeasures[i];
				displayMeasure.visible = doShow;
			}
		}
		
		public function hasPoint(pointV0:PointVO):Boolean
		{
			return (pointV0 == p1 || pointV0 == p2);
		}
		
		public  function stickToSegment():Segment
		{
			if (!p1.isAssociated || !p2.isAssociated) return null;
			if (p1.isAssociatedToPoint && p2.isAssociatedToPoint)
			{
				var p:PointVO = p1.associatorPointVO;
				for (var i:int = 0; i < p.segments.length; i++)
				{
					var segment:Segment = p.segments[i];
					if (segment.getFriend(p) == p2.associatorPointVO) return segment;
				}
			}
			else if(p1.isAssociatedToPoint)
			{
				p = p1.associatorPointVO;
				if(p2.associatorSegment.hasPoint(p)) return p2.associatorSegment;
			}
			else if(p2.isAssociatedToPoint)
			{
				p = p2.associatorPointVO;
				if(p1.associatorSegment.hasPoint(p)) return p1.associatorSegment;
			}
			else
			{
				if (p1.associatorSegment == p2.associatorSegment) 
				{
					return p1.associatorSegment;
				}
			}
			
			return null;
		}
		
		public  function doesStickToSegment():Boolean
		{
			//trace("doesStickToSegment " + stickToSegment());
			return stickToSegment() != null;
		}
		
		public  function stickToHomeSegment():Segment
		{
			var segment:Segment = stickToSegment();
			if (!segment) return null;
			if (!segment.isInHome) return null;
			return segment;
		}
		
		protected function onPointMove(e:PointMoveEvent):void
		{
			var points:Array = e.points;
			if (points == null) return;
			if (ArrayUtils.contains(points, p1) || ArrayUtils.contains(points, p2) )
			{
				draw(true);
			}
		}
		
		
		//------------ MOUSE DOWN ------------
		private var _count:int;
		private var _listeners:Array;
		private var _associatedListeners:Array;
		private var _unassociatedListeners:Array;
		private var _measuresTimeId:int;
		private var _moveSegmentCommand:MoveSegmentCommand;
			
		override protected function mouseDown():void
		{
			//if (p1.isAssociatedToSegment) p1.removeassociatorSegment();
			//if (p2.isAssociatedToSegment) p2.removeassociatorSegment();
			_oldPos = new Point(mouseX, mouseY);
			//_firstImpulse nous permet de ssvoir si le mouvement a démarré davantage en x ou en y
			//on conserve la direction dominante pendant tout le mouvement 
			_firstImpulse = null;
			//_count pour que pendant un certain temps quand on decolle une cloison elle ne se recolle pas.
			//sinon dès qu'on decolle la cloison au move le hittest est a nouveau détécté et recolle la cloisosn 
			_count = 0;
			_model.draggedSegment = this;
			if (isInPiece) _model.pieceSegmentIsDragged = true;
			if (isInHome) _model.homeSegmentIsDragged = true;
			_prevPos1 = p1.point;
			_prevPos2 = p2.point;
			obj2D.adjutSquarePoints();
			
			_moveSegmentCommand = new MoveSegmentCommand(this, p1.point, p2.point);
			_measuresTimeId = setTimeout(MeasuresContainer.showMeasures,200, true);
		}
		
		private function _onPointMoveStart(e:PointMoveStartEvent):void
		{
			if(!isFiber) return;
			var points:Array = e.points;
			if (points == null) return;
			if (!ArrayUtils.contains(points, p1) && !ArrayUtils.contains(points, p2) ) return;
			
			if(intersectionPoints) clearIntersectionPoints();
		}
		
		private function _onPointMoveEnd(e:PointMoveEndEvent):void
		{
			if(!isFiber) return;
			hitSegmentsTest();
		}
		
		public function clearIntersectionPoints():void
		{
			if(!intersectionPoints) return;
			if(intersectionPoints.length == 0) return;
				
			for (var i:int = 0; i < intersectionPoints.length; i++)
			{
				var intersectionPoint:IntersectionPoint = intersectionPoints[i] ;
				intersectionPoint.remove();
				//if(intersectionPoint && intersectionPoint.stage) removeChild(intersectionPoint);
			}
			//intersectionPoints = new Array();	
			intersectionPoints = null;
		}
		/**
		 * <p>Quand un segment bouge, on répertorie les points associés à ce segment et ceux qui ne le sont pas.</p> 
		 * <p>Ceux qui sont associés vont bouger avec le segment, ils gardent en mémoire leur position avant le mouvement pour le undo </p>
		 * <p>Si c'est un segment de maison, on cherhe les points de pieces associés</p> 
		 * <p>Segemtn de piece et de maison, on cherhe les points de cloisons associés</p> 
		 */
		private function _getListeners():void
		{
			_listeners = new Array();
			_associatedListeners = new Array();
			_unassociatedListeners = new Array();
			//on drag un mur de la maison 
			if (isInHome)
			{
				for (var i:int = 0; i < _model.currentMaisonPieces.piecesArr.length; i++)
				{
					
					var piece:PieceEntity = (_model.currentMaisonPieces.piecesArr[i] as Bloc).obj2D as PieceEntity;
					if (piece.isAssociatedToMovement) 
					{
						_associatedListeners.push(piece);
						piece.registerRecPoints();
						
					}
					else
					{
						_unassociatedListeners.push(piece);
					}
					piece.removeAllAssociations();
					_listeners.push(piece);
				}
			}
			
			if (isInHome || isInPiece || isInCloison)
			{
				var cloisons:Cloisons = _obj2D.bloc.cloisons;
				
				for (i = 0; i < cloisons.cloisonsArr.length; i++)
				{
					var cloison:CloisonEntity = cloisons.cloisonsArr[i] as CloisonEntity;
					if (cloison.isAssociatedToMovement) 
					{
						_associatedListeners.push(cloison);
						cloison.registerRecPoints();
					}
					else
					{
						_unassociatedListeners.push(cloison);
					}
					cloison.removeAllAssociations();
					_listeners.push(cloison);
				}
			}
			
			if (isInPiece)
			{
				cloisons = _model.currentMaisonCloisons;
			
				for (i = 0; i < cloisons.cloisonsArr.length; i++)
				{
					cloison = cloisons.cloisonsArr[i] as CloisonEntity;
					if (cloison.isAssociatedToMovement) 
					{
						_associatedListeners.push(cloison);
						cloison.registerRecPoints();
					}
					else
					{
						_unassociatedListeners.push(cloison);
					}
					cloison.removeAllAssociations();
					_listeners.push(cloison);
				}
			}
		}
		
		// ---- on drag starting ----------		
		override protected function notifyMovementStart():void
		{
			if(isFiber) _model.notifyPointMoveStart([p1, p2]);
		}
		
		//-------------- MOUSE MOVE ------------------
		
		private var _prevMouse:Point;
		private var _hitSegment1:Segment;
		private var _hitSegment2:Segment;
		public var registerDist:Number;
		
		private var _prevPos1:Point;
		private var _prevPos2:Point;
		
		override protected function mouseMove():void
		{
			if (!_listeners) _getListeners();
			Segment.FRIENDS = new Array();
			var p1PrevPos:Point = p1.point;
			var p2PrevPos:Point = p2.point;
			_count++;
			//on n'affiche les mesures qu'après une enterframe pour les afficher lorsqu'on reste cliqué ou au drag 
			//et ne pas les afficher au click
			if (_count == 1) MeasuresContainer.showMeasures(true);
			
			var mousePoint:Point = new Point(mouseX, mouseY);
		    
			//pour forcer éventuellment horizontalité ou verticalité du mouvement
			if (_firstImpulse == null)
				_firstImpulse = mousePoint.subtract(_oldPos); 
			
			if (!_prevMouse) _prevMouse = mousePoint.clone();
			
			//on detecte l'amplitude du mouvement de souris. 
			//seulement si le segment est une cloison faite d'un seul segment on laisse le segment libre de se déplacer 
			//sinon on force son mouvement perpendiculairement au segement s'il est horizontal ou vertical,
			//si le segment est oblique on garde la direction dominante de la première impulsion du mouvement soit en x soit en y 
			if (isSingleCloison /*&& ! p1.isAssociated  && ! p2.isAssociated*/)
			{
				
				diffx = mousePoint.x - _prevMouse.x;
				diffy = mousePoint.y - _prevMouse.y;
			}
			else
			{
				if (isHorizontal && (isInHome || obj2D.isSquare))
				{
					//trace("horiz")
					diffx = 0;
					diffy = mousePoint.y - _prevMouse.y;
				}
				else if (isVertical && (isInHome || obj2D.isSquare))
				{
					//trace("vert")
					diffx = mousePoint.x - _prevMouse.x;;
					diffy = 0
				}
				else
				{
					if (Math.abs(_firstImpulse.x) > Math.abs(_firstImpulse.y))
					{
						diffx = mousePoint.x - _prevMouse.x;
						diffy =0;
					}
					else
					{
						diffx = 0;
						diffy = mousePoint.y - _prevMouse.y;
					}
				}
			}
			
			//si aucun des points n'est associé on execute un premier déplacement de points
			//if (!(isInCloison && p1.isAssociated && p2.isAssociated))
			{
				p1.translate(diffx, diffy);
				p2.translate(diffx, diffy);
			}
			
			//------------- cas des points associés ou qui peuvent l'être --------------------
			//on supprime toute association des points du segment dès le départ pour que le point se décolle
			var _hitSegment1:Segment;
			var _hitSegment2:Segment;
			var dep:Point;
			
			if (isInCloison || isInPiece)
			{
				var stickPoint:Point;
				
				p1.removeFromAssociator();
				p2.removeFromAssociator();
			   
                //on teste s'il est collé après 6 entreframe parce que si on le fait plus tot le point risqye de ne pas se décoller
				//ici cette sensation de devoir tirer le segment très fort pour pouvoir le décoller. < 6 on décolle plus difficilement, > plus facilement 
				//en fait non car on affecte le déplacement des points malgré tout car on a decide de supprimer l'effet glu 
				//la version précédente on ne déplacait les points qu'après 6 ou 10 enterframe et ca donnait cet effet
				if (_count > 6)
				{
					var d:Point;
					var prevPos:Point = p1.point;
					
					//lors du testAndAttach  p1 change de position 
					if (p1.testAndAttach())
					{
						d = p1.subtract(prevPos); 
						p2.translate(d.x, d.y);
					}
					else
					{
						prevPos = p2.point;
						//lors du testAndAttach  p2 change de position 
						if (p2.testAndAttach())
						{
							d = p2.subtract(prevPos); 
							p1.translate(d.x, d.y);
						}
					}
					
					p1.pointView.draw();
					p2.pointView.draw();
				}
			}
			
			//aimantation
			var pointVO:PointVO = p1;
			var p:Point = pointVO.point;
			
			var magnetPoint:Point = GeomUtils.magnetPoint(p, parent);
			diffx = magnetPoint.x - pointVO.x;
			diffy = magnetPoint.y - pointVO.y;
			p1.translate(diffx, diffy);
			p2.translate(diffx, diffy);
			
			p = Point.interpolate(p2, p1, dragHandle.factor);
			
			dragHandle.x = p.x;
			dragHandle.y = p.y;
			_prevMouse.x = p.x;
			_prevMouse.y = p.y;
			
			dep = p1.subtract(p1PrevPos); 
			_model.dragDep = dep;
			//trace("mousemove dep" + dep)
			_model.notifyPointMove([p1, p2], dep);
			if (!testBlocSizeOk())
			{
				p1.setPos(_prevPos1);
				p2.setPos(_prevPos2);
				p = Point.interpolate(p2, p1, dragHandle.factor);
			
				dragHandle.x = p.x;
				dragHandle.y = p.y;
				dep = p1PrevPos.subtract(p1); 
				_model.dragDep = dep;
				_model.notifyPointMove([p1, p2], dep);
				return;
			}
			
			_prevPos1 = p1.point;
			_prevPos2 = p2.point;
			//trace(" _listeners.length " +  _associatedListeners.length);
			for (var i:int = 0; i < _associatedListeners.length; i++)
			{
				if (_associatedListeners[i] is CloisonEntity)
				{
					(_associatedListeners[i]as Object2D).translate(dep);
				}
				else
				{
					(_associatedListeners[i]as Object2D).bloc.translate(dep);
				}
			}
			
		}
		
		public function testBlocSizeOk():Boolean
		{
			var bounds:Rectangle;
			if (isInHome)
			{
				bounds = _model.currentMainSurface.bg.getBounds(EditorBackground.instance);
				if (Measure.pixelToMetric(bounds.width) < 2 || Measure.pixelToMetric(bounds.height) < 2)
				return false;
			}
			
			if (isInPiece)
			{
				if(!obj2D.flipTest()) return false;  //targets only square pieces
				bounds = bloc.surface.bg.getBounds(EditorBackground.instance);
				if (Measure.pixelToMetric(bounds.width) < .8 || Measure.pixelToMetric(bounds.height) < .8)
				return false;
			}
			
			return true;
		}
		
		//-------------- MOUSE UP ------------------
		private var _recordedPoint:Point;
		override protected function mouseUp():void
		{
			//trace("index : " + obj2D.segmentsArr.indexOf(this));	
			_model.draggedSegment = null;
			if (isInPiece) _model.pieceSegmentIsDragged = false;
			if (isInHome) _model.homeSegmentIsDragged = false;
			
			var mousePos:Point = new Point(mouseX, mouseY);
			//trace("_recordedPoint")
			_recordedPoint = GeomUtils.stickToSegment(mousePos, this);
			
			clearTimeout(_measuresTimeId);
			if (MeasuresContainer.isON)
			{
				MeasuresContainer.showMeasures(false);
				return;
			}
			
			if(obj2D.isSquare && obj2D is BalconyEntity) return;
			//mousePos = GeomUtils.localToLocal(mousePos, this, EditorContainer.instance);
			var menu:MenuRenderer = MenuFactory.createMenu(this, EditorContainer.instance);
			/*menu.x = mousePos.x + 5;
			menu.y = mousePos.y + 5;*/
			//if (menu.x + menu.width > Config.EDITOR_WIDTH) menu.x = mousePos.x - menu.width;
			//if (menu.y + menu.height > Config.EDITOR_HEIGHT) menu.y = mousePos.y - menu.height;
		}
		
		override protected function mouseUpWhileDrag():void
		{
			_prevMouse = null;
			_movingCount = 0;
			_hitSegment1 = null;
			_hitSegment2 = null;
			hideDragHandle();
			
			if (isInCloison ||  isInPiece)
			{
				var dep:Point;
				var prevPos:Point = p1.point;
				
				if (p1.testAndAttach())
				{
					dep = p1.subtract(prevPos); 
					p2.translate(dep.x, dep.y);
				}
				prevPos = p2.point;
				if (p2.testAndAttach())
				{
					dep = p2.subtract(prevPos); 
					p1.translate(dep.x, dep.y);
				}
				
				p1.pointView.draw();
				p2.pointView.draw();
			}
			
			// ctrl+z purpose
			var magnetPoint:Point = GeomUtils.magnetPoint(_oldPos, parent);
			var newPoint:Point = GeomUtils.magnetPoint(new Point(mouseX, mouseY), parent);
			_moveSegmentCommand.run();
			_moveSegmentCommand = null;
			clearTimeout(_measuresTimeId);
			MeasuresContainer.showMeasures(false);
			_model.draggedSegment = null;
			_model.dragDep = null;
			if (isInPiece) _model.pieceSegmentIsDragged = false;
			if (isInHome) _model.homeSegmentIsDragged = false;
			if (isInPiece) _model.notifyEndMovingPieceEvent(obj2D as PieceEntity);
			if (!_listeners) return;
			
			for (var i:int = 0; i < _listeners.length; i++)
			{
				(_listeners[i] as Object2D).testAndAttachPoints();
			}
			_listeners  = null;
			
			if(isFiber) _model.notifyPointMoveEnd([p1, p2]);
		}
		
		//-----------------    hit   -------------------
		
		public function hideDragHandle():void
		{
			if (!dragHandle) return;
			//if (dragHandle.stage) removeChild(dragHandle);
			//dragHandle = null;
			dragHandle.scaleX = dragHandle.scaleY = 1;
			dragHandle.visible = false;
		}
		
		//----------- mouse over - out ----------------
		
		private function over(e:MouseEvent=null):void
		{
			//isOver = true;
			
		//	trace("over ", e.target, e.target.id);
			//if (stickToHomeSegment()) return;
			
			var mousePoint:Point = e ? new Point(mouseX, mouseY) : Point.interpolate(p1, p2, .5);
			
			var stickingPoint:Point = GeomUtils.stickToSegment(mousePoint, this);
			dragHandle.x = stickingPoint.x;
			dragHandle.y = stickingPoint.y;
			//var angle:Number = 
			dragHandle.update();
			if (dragHandle.isCurseurTranslate)
			{
				dragHandle.rotation = degreeAngle;
			}
			
			dragHandle.visible = true;
			if(dragHandle.alpha != 1) dragHandle.alpha = 1;
			var p:Point = new Point(dragHandle.x, dragHandle.y);
			dragHandle.factor = Point.distance(p1, p) / (Point.distance(p1, p) + Point.distance(p, p2));
		
		}
		
		private function out(e:MouseEvent=null):void
		{
			if (isDragging) return;
			hideDragHandle();
		}
		
		// ------ public methods ------------
		
		override public function get isLocked():Boolean
		{
			if (p1.pointView.isLocked) return true;
			if (p2.pointView.isLocked) return true;
			return false;
		}
		
		public function getFriend(pointVO:PointVO):PointVO
		{
			return (pointVO == p1) ? p2 : p1;
		}
		
		public function isAdjacentSegment(segment:Segment):Boolean
		{
			if(obj2D != segment.obj2D) return false;
			
			var segments:Array = p1.segments;
			if(segments.length > 1)
			{
				if( segments.indexOf(segment) != -1) return true;
				
			}
			
			segments = p2.segments;
			if(segments.length > 1)
			{
				if( segments.indexOf(segment) != -1) return true;
				
			}
			return false;
		}
		
		public function get obj2D():Object2D
		{
			return _obj2D;
		}
		
		public function get isInPiece():Boolean
		{
			return (_obj2D is RoomEntity || _obj2D is BalconyEntity);
		}
		
		public function get isInCloison():Boolean
		{
			return (_obj2D is CloisonEntity);
		}
		
		public function get isInHome():Boolean
		{
			return (_obj2D is MainEntity);
		}
		
		public function get isSingleCloison():Boolean
		{
			return (isInCloison && obj2D.length == 2);
		}
		
		
		public function get isInCloisonDePiece():Boolean
		{
			return (isInCloison &&  obj2D.bloc &&  obj2D.bloc.isPiece);
		}
		
		public function get isInCloisonDeMaison():Boolean
		{
			return (isInCloison &&  obj2D.bloc &&  obj2D.bloc.isBlocMaison);
		}
		
		public function get isFiber():Boolean
		{
			return (_obj2D is FiberLineEntity);
		}
		
		
		public function get cloison():CloisonEntity
		{
			return (_obj2D as CloisonEntity);
		}
		
		public function get bloc():Bloc
		{
			return obj2D.bloc;
		}
		
		public function get isInCurrentFloor():Boolean
		{
			return ObjectUtils.isChildOf(this, _model.currentFloor);
		}
		
		public function insertOnePoint():void
		{
			if (!_recordedPoint) return;	
			var p:Point = _recordedPoint.clone();
			new InsertOnePointCommand(_obj2D, this, p).run();
			//_obj2D.insertOnePoint(this, p);
			_recordedPoint = null;
		}
		
		public function insertTwoPoints():void
		{
			if (!_recordedPoint) return;	
			var p:Point = _recordedPoint.clone();
			new InsertTwoPointsCommand(_obj2D, this, p).run();
			//_obj2D.insertTwoPoints(this, p);
			_recordedPoint = null;
		}
		
		public function duplicateCloison():void
		{
			if (! (_obj2D is CloisonEntity)) return;
			new DuplicateCloisonCommand(_obj2D).run();
			/*var cloisonEntity:CloisonEntity = _obj2D as CloisonEntity;
			cloisonEntity.cloisons.addCloison(cloisonEntity.clone());*/
		}
		
		public function get angle():Number
		{
			return GeomUtils.getAngle(p1, p2);
		}
		
		public function get degreeAngle():Number
		{
			return angle * 180/Math.PI;
		}
		
		public function get perpendicularAngle():Number
		{
			return angle + 3* Math.PI/2;
		}
		
		public function get degreePerpendicularAngle():Number
		{
			return perpendicularAngle * 180/Math.PI;
		}
		
		public function get isHorizontal():Boolean
		{
			//return (degreeAngle%180 == 0);
			return (p1.y == p2.y);
		}
		
		public function get isVertical():Boolean
		{
			//return (degreeAngle%180 ==  90);
			return (p1.x == p2.x);
		}
		
		public function get isOrtho():Boolean
		{
			//return (degreeAngle%180 ==  90);
			return (isVertical || isHorizontal);
		}
		
		public function get isQuasiOrtho():Boolean
		{
			//return (degreeAngle%180 ==  90);
			return (isQuasiVertical || isQuasiHorizontal);
		}
		
		public function get isQuasiVertical():Boolean
		{
			//return (degreeAngle%180 ==  90);
			return Math.abs(p1.x - p2.x)< Math.abs(p1.y - p2.y) / 2 ;
		}
		
		public function get isQuasiHorizontal():Boolean
		{
			//return (degreeAngle%180 == 0);
			return  Math.abs(p1.y - p2.y)< Math.abs(p1.x - p2.x) / 2 ;
		}
		
		public function setAssociatedPointPos(associatedPoint:PointVO):void
		{
			//trace("setAssociatedPointPos");
			var prevPos:Point = associatedPoint.point;
			//var scope:DisplayObjectContainer = associatedPoint.pointView.parent;
			var stickPoint:Point = GeomUtils.stickToSegment(associatedPoint, this);
			
			if (associatedPoint.isInPiece && associatedPoint.obj2D.keepShape)
			{
				//if (associatedPoint.pointView.isDragging) return;
				//trace("setAssociatePointPos here in segment piece keepShape")
				
				
				var t:Point = stickPoint.subtract(prevPos);
				associatedPoint.obj2D.translate(t);
				associatedPoint.associationFactor = Point.distance(p1, associatedPoint) / Point.distance(p2, p1);
				return;
			}
			associatedPoint.setPos(stickPoint);
			associatedPoint.associationFactor = Point.distance(p1, associatedPoint) / Point.distance(p2, p1);
			
			/*if (isOrtho)
			{
				//si le segment est horizontal ou vertical on peut trouver un position rapprochante collée à la grille et au segment 
				associatedPoint.setMagnetPointPosition(stickPoint);
			}
			else
			{
				//segment  oblique, priorité a la glu sur le segment, impossible de garantir glu sur la grille 
				associatedPoint.setPointPosition(stickPoint);
			}*/
			//associatedPoint.obj2d.follow(associatedPoint, associatedPoint.point.subtract(prevPos) );
		}
		
		
		public function pushAssociated(associatedPoint:PointVO):void
		{
			if (associatedPoint.isAssociatedToSegment) associatedPoint.removeFromAssociatorSegment();
			if (associatedPoint.isAssociatedToPoint) associatedPoint.removeFromAssociatorPoint();
			associatedPoints.push(associatedPoint);
			associatedPoint.associatorSegment = this;
			setAssociatedPointPos(associatedPoint);
			
			/*if (isVertical)
			{
				//si le segment est horizontal ou vertical on peut trouver un position rapprochante collée à la grille et au segment 
				associatedPoint.setMagnetPointPositionY(posPoint);
			}
			else if (isHorizontal)
			{
				//si le segment est horizontal ou vertical on peut trouver un position rapprochante collée à la grille et au segment 
				associatedPoint.setMagnetPointPositionX(posPoint);
			} 
			else
			{
				//segment  oblique, priorité a la glu sur le segment, impossible de garantir glu sur la grille 
				associatedPoint.setPointPosition(posPoint);
			}*/
			
			associatedPoint.pointView.draw(true);
			if (associatedPoint.isInCloison && this.isInCloison)
			{
				associatedPoint.cloison.backToFront();
			}
			
			if (associatedPoint.isInPiece && this.isInPiece)
			{
				associatedPoint.bloc.backToFront();
			}
			//trace("associationFactor " + associatedPoint.associationFactor)
			associatedPoints.sortOn("associationFactor");
			recreateMeasures();
			draw();
		}
		
		public function removeAssociated(associatedPoint:PointVO):void
		{
			//trace("Segment::removeAssociated");
			var index:int = associatedPoints.lastIndexOf(associatedPoint);
			if (index == -1) return;
			
			associatedPoints.splice(index, 1);
			associatedPoint.associationFactor = new Number();
			associatedPoint.associatorSegment = null;
			associatedPoint.pointView.draw();
			recreateMeasures();
			draw();
		}
		
		public function clearMeasures():void
		{
			for (var i:int = 0; i < associatedMeasures.length; i++)
			{
				var displayMeasure:DisplayMeasure = associatedMeasures[i];
				displayMeasure.selfRemove();
			}
			associatedMeasures = new Array();
			hideMainDisplayMeasure();
		}
		
		public function recreateMeasures():void
		{
			clearMeasures();
			
			if (associatedPoints.length == 0) 
			{
				showMainDisplayMeasure(MeasuresContainer.isON);
				return;
			}
			
			hideMainDisplayMeasure();
			
			//if (p1.isAssociatedToSegment && p2.isAssociatedToSegment
			//    && p1.associatorSegment == p2.associatorSegment) return;
			
			associatedPoints.sortOn("associationFactor");
			
			var displayMeasure:DisplayMeasure;
			for (var i:int = 0; i < associatedPoints.length; ++i)
			{
				var associatedPoint:PointVO = associatedPoints[i];
				var prevPoint:PointVO = i > 0 ? associatedPoints[i -1] : p1;
				displayMeasure = new DisplayMeasure(this, prevPoint, associatedPoint);				
				displayMeasure.selfAdd();
				displayMeasure.visible = MeasuresContainer.isON;
				displayMeasure.update();
				associatedMeasures.push(displayMeasure);
			}
			
			displayMeasure = new DisplayMeasure(this, associatedPoint, p2);				
			displayMeasure.selfAdd();
			//displayMeasure.visible = Editor2D.instance.displayMeasuresCheckBoxValue;
			displayMeasure.visible = MeasuresContainer.isON;
			displayMeasure.update();
			associatedMeasures.push(displayMeasure);
		}
		
		public function get measuresContainer():MeasuresContainer
		{
			return _obj2D.measuresContainer;
		}
		
		public function get hasAssociatedPoints():Boolean
		{
			return (associatedPoints.length > 0);
		}
		
		public function removeAssociatedPoints():void
		{
			for (var i:int = 0; i < associatedPoints.length; i++)
			{
				var associatedPoint:PointVO = associatedPoints[i];
				removeAssociated(associatedPoint);				
			}
		}
		
		//-----------------------------------------------
		
		private function hideMainDisplayMeasure():void
		{
			_displayMeasure.visible = false;
		}
		
		private function showMainDisplayMeasure(doShow:Boolean = true):void
		{
			
			_displayMeasure.visible = doShow;
		}
		
		private function _remove(e:Event):void
		{
			clearMeasures();
			_displayMeasure.selfRemove();
			removeAssociatedPoints();
			
			removeEventListener(MouseEvent.MOUSE_OVER, over)
			removeEventListener(MouseEvent.MOUSE_OUT, out);
			removeEventListener(Event.REMOVED_FROM_STAGE, _remove);
			p1.removeSegment(this);
			p2.removeSegment(this);
		}
		
	}
}