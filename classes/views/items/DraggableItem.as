package classes.views.items 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.GeomUtils;
	import classes.views.menus.MenuContainer;
	import classes.views.menus.MenuSurfaceRenderer;
	import classes.views.plan.Bloc;
	import classes.views.Toolbar;
	import classes.vo.Shapes;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * La classe DraggableItem est la classe de base abstraite des différents éléments qui s'affichent dans l'accordion 
	 * (la liste déroulante)
	 */
	public class DraggableItem extends MovieClip 
	{
		protected var type:String;
		protected var id:int;
		protected var ghost:Sprite;
		protected var _cursor:CurseurDeplacement;
		protected var _model:EditorModelLocator = EditorModelLocator.instance;
		protected var appmodel:ApplicationModel = ApplicationModel.instance;
		protected var overBloc:Bloc;
		
		/**
		 * Permet de créer un item drag and droppbale, déposable dans l'éditeur par glisser-déposer, dans la liste déroulante
		 * 
		 * <p>Le constructeur crée un curseur de déplacement</p>
		 * 
		 * <p>Ecoute les evetns <code>MouseEvent.MOUSE_DOWN</code> et <code>Event.REMOVED_FROM_STAGE</code></p>
		 * 
		 * @param	pid L'id de l'item
		 * @param	ptype Le type de l'item
		 */
		public function DraggableItem(pid:int, ptype:String) 
		{
			//trace("DraggableItem", pid, ptype);
			//super();
			type = ptype;
			id = pid;
			buttonMode = true;
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			_cursor = new CurseurDeplacement();
		}
		
		/**
		 * L'event mouseDown crée l'écouteur de déplacement <code>MouseEvent.MOUSE_MOVE</code> et crée le ghost de l'item 
		 * 
		 * @param	e L'event mouseDown
		 */
		protected function mouseDown(e:MouseEvent):void 
		{
			//trace("DraggableItem::mouseDown() target:", e.target);
			if (e.target is IconInfo) return;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
			
			createGhost();			
			move();
			
			stage.addEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			if(!(parent is MenuSurfaceRenderer)) MenuContainer.instance.closeMenu();
		}
		
		protected function createGhost():void
		{
			Shapes.instance.update();
			
			var klass:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
			/*trace("DraggableItem::parent=", parent);
			trace("DraggableItem::klass=", klass);
			trace("DraggableItem::id=", id);*/
			
			ghost = new klass();
			_cursor.x = ghost.width / 2;
			_cursor.y = ghost.height / 2;
			parent.addChild(ghost);
			ghost.addChild(_cursor);
		}
		
		protected function move(e:MouseEvent=null):void 
		{
			ghost.x = parent.mouseX; //- ghost.width / 2;
			ghost.y = parent.mouseY;// - ghost.height / 2;
			overBloc = isOverBloc();
		}
		
		private function _stopDrag(e:MouseEvent):void
		{
			trace("DraggableItem::_stopDrag() target:", e.target);
			ghost.stopDrag();
			if(stage && stage.hasEventListener(MouseEvent.MOUSE_MOVE)) stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);
			
			executeAction();
			
			if(stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) stage.removeEventListener(MouseEvent.MOUSE_UP, _stopDrag);
		}
		
		protected function executeAction():void
		{
			parent.removeChild(ghost);
			
			if (isOverMenu) return;
			
		}
		
		protected function isOverBloc():Bloc
		{
			var p:Point = GeomUtils.localToLocal(new Point(mouseX, mouseY), this, Main.instance);
			
			var blocs:Array = _model.currentFloor.blocs;
			for (var i:int = 0; i < blocs.length ; i++)
			{
				var bloc:Bloc = blocs[i];
				if (bloc.hitTestPoint(p.x, p.y, true))
				{
					//trace("DraggableItem::isOver ", bloc.type);
				    return bloc;
				}
			}
			return null;
		}
		
		protected function get isOverMenu():Boolean
		{
			var p:Point = GeomUtils.localToLocal(new Point(mouseX, mouseY), this, Main.instance);
			//var p:Point = localToGlobal(new Point(mouseX, mouseY));
			if (Toolbar.instance.hitTestPoint(p.x, p.y, false)) 
			{
				return true;
			}
			return false;
		}
		
		protected function _removed(e:Event):void
		{
			if (stage && stage.hasEventListener(MouseEvent.MOUSE_UP)) stage.removeEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			if(stage && stage.hasEventListener(MouseEvent.MOUSE_MOVE)) stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}

}