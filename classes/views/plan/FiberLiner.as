package classes.views.plan
{
	import classes.commands.fiber.AddFiberLineCommand;
	import classes.components.ScrollBar;
	import classes.config.Config;
	import classes.model.EditorModelLocator;
	import classes.utils.GeomUtils;
	import classes.utils.ObjectUtils;
	import classes.views.accordion.Accordion;
	import classes.views.equipements.EquipementView;
	import classes.views.EquipementsLayer;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	/**
	 * FiberLiner permet de construire la Fibre.
	 */
	public class FiberLiner
	{
		private var _scope:Sprite;
		private var _cursor:DrawingCursor;
		private var _fiberLine:FiberLineEntity;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _point:Point;
		private var _mousePoint:Point;
		private var _greyLine:Sprite;
		
		/**
		 * FiberLiner permet de construire la Fibre. Une ligne dans un sprite nommé _greyLine est tracé 
		 * depuis le dernier point de la fibre, au clic, cette greyLine disparait, un segment de même 
		 * extrémités que _greyLine est ajouté à la Fibre.
		 * 
		 * @param scope le Sprite dans lequel est ajouté FiberLineEntity 
		 */
		public function FiberLiner(scope:Sprite)
		{
			_scope = scope;
			_startDrawing();
		}
		
		private function _onMouseMove(e:MouseEvent):void
		{
			if(ObjectUtils.isChildOf(e.target as DisplayObject, Accordion.instance) )
			{
				Mouse.show();
				//_greyLine.visible = false;
				_cursor.visible = false;
			}
			else
			{
				Mouse.hide();
				_greyLine.visible = true;
				_cursor.visible = true;
			}
			_mousePoint = new Point(_scope.mouseX, _scope.mouseY);
			_mousePoint = GeomUtils.magnetPoint(_mousePoint, _scope);
			_cursor.x = _mousePoint.x;
			_cursor.y = _mousePoint.y;
			var g:Graphics = _greyLine.graphics;
			g.clear();
			g.lineStyle(1, Config.COLOR_GREY);
			g.moveTo(_point.x, _point.y);
			g.lineTo(_mousePoint.x, _mousePoint.y);
		}
		
		
		private function _startDrawing():void
		{
			ScrollBar.instance.removeMouseWheel();
			if(!_greyLine)
			{
				_greyLine = new Sprite();
				_scope.addChild(_greyLine);
			}
			if(!_cursor)
			{
				_cursor = new DrawingCursor();
				_scope.addChild(_cursor);
				_cursor.x = _scope.mouseX;
				_cursor.y = _scope.mouseY;
			}
			_cursor.addEventListener(MouseEvent.CLICK, _onClick);
			Mouse.hide();
			var livebox:EquipementView =  EquipementsLayer.getLivebox();
			_fiberLine = _model.currentFloor.fiberLine;
			if(!_fiberLine) 
			{
				_point = new Point(livebox.x, livebox.y);
				_point = GeomUtils.localToLocal(_point, livebox.parent, _scope);
			}
			else
			{
				_point = _fiberLine.lastPoint.point;
			}
			_greyLine.visible = true;
			_cursor.visible = true;
			
			Main.instance.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
		}
		
		public function _stopDrawing():void
		{
			if(!drawing) return;
			ScrollBar.instance.addMouseWheel();
			_greyLine.graphics.clear();
			Main.instance.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
		}
		
		public function get drawing():Boolean
		{
			return Main.instance.hasEventListener(MouseEvent.MOUSE_MOVE);
		}
		
		public function stopLiner():void
		{
			Mouse.show();
			_stopDrawing();
			if(_cursor && _cursor.stage) 
			{
				_cursor.removeEventListener(MouseEvent.CLICK, _onClick);
				_scope.removeChild(_cursor);
				_cursor = null;
			}
			_fiberLine = null;
			_scope = null;
		}
		
		private function _onClick(e:MouseEvent):void
		{
			_stopDrawing();
			_mousePoint = new Point(_scope.mouseX, _scope.mouseY);
			_mousePoint = GeomUtils.magnetPoint(_mousePoint, _scope);
			var points:Array;
			if(!_fiberLine)
			{
				points = [_point, _mousePoint];
				new AddFiberLineCommand(_model.currentBlocMaison, points).run();
			}
			else
			{
				_fiberLine.addEndingSegment(_mousePoint.clone());
			}
			_startDrawing();
		}
	}
}