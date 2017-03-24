package classes.views 
{
	import classes.commands.DeleteNomPieceCommand;
	import classes.config.Config;
	import classes.controls.ZoomEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.GeomUtils;
	import classes.views.menus.MenuFactory;
	import classes.views.menus.MenuRenderer;
	import classes.views.plan.DraggedObject;
	import classes.views.plan.Editor2D;
	import classes.views.plan.EditorContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	/**
	 * <code>NomPieceView</code> correspond à l'affichage des étiquettes posées par-dessus le plan, le nom que l'on peut
	 * donner aux pièces
	 * 
	 */
	public class NomPieceView extends DraggedObject 
	{
		private static const DEFAULT_VALUE:String = AppLabels.getString("editor_roomName");
		private var _label:String;
		private var t:TextField;
		private var ft:TextFormat;
		private var _w:Number;
		//private var iconMenu:IconCrayonChampEditable;
		private var iconDelete:IconSupprimer;
		private var bg:Sprite;
		private var _newText:String;
		protected var model:EditorModelLocator = EditorModelLocator.instance;
		public var nouveau:Boolean = true;
		
		public function NomPieceView(label:String =null) 
		{
			_label = label ? label : DEFAULT_VALUE;
			super();
		}
		
		override protected function added(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, added);
			
			// on crée le fond, le texte éditable et le bouton icon du menu
			/*bg = new Sprite();
			addChild(bg)*/
			
			t = new TextField();
			t.width = 110;
			t.height = 20;
			t.embedFonts = true;
			t.selectable = false;
			t.mouseEnabled = false;
			
			ft = new TextFormat();
			ft.font = (new Verdana() as Font).fontName;
			ft.color = Config.COLOR_DARK;
			ft.size = 12;
			ft.align = TextFormatAlign.CENTER;
			
			addChild(t);
			t.text = _label;
			t.setTextFormat(ft);
			
			//bg.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
			
			_drawBG();
			
			if(nouveau) renommer();
			
			model.addZoomEventListener(_onZoom);
		}
		
		//------------ MOUSE DOWN ------------
		
		private var _mousePoint:Point
		override protected function mouseDown():void
		{
			_mousePoint = new Point(mouseX, mouseY);
		}
		
		//-------------- MOUSE MOVE ----------------
		
		override protected function mouseMove():void
		{
			var p:Point = new Point(parent.mouseX, parent.mouseY).subtract(_mousePoint);
			x = p.x;
			y = p.y;
		}
		
		//---------------- MOUSE UP ------------------
		
		override public function onMouseUpEvent(e:MouseEvent = null):void
		{
			super.onMouseUpEvent(e);
			_mousePoint = null;
		}
		
		override protected function mouseUp():void
		{
			//trace("mouseUp", this);
			//var mousePos:Point = new Point(EditorContainer.instance.mouseX, EditorContainer.instance.mouseY);
			//var mousePos:Point = new Point(mouseX, mouseY);
			//mousePos = GeomUtils.localToLocal(mousePos, this, EditorContainer.instance);
			
			var menu:MenuRenderer = MenuFactory.createMenu(this, EditorContainer.instance);
			/*menu.x = mousePos.x + 10;
			menu.y = mousePos.y + 20;*/
		}
		
		override protected function mouseUpWhileDrag():void
		{
			ApplicationModel.instance.notifySaveStateUpdate(true);
		}
		
		//----------------------------------------------
		//--- Specific functions
		//----------------------------------------------
		
		public function scale(scaleFactor:Number):void
		{
			x *= scaleFactor;
			y *= scaleFactor;
		}
		
		public function renommer(e:MouseEvent=null):void
		{
			//trace("NomPieceView::renommer");
			t.mouseEnabled = true;
			stage.focus = t;
			//iconMenu.removeEventListener(MouseEvent.CLICK, renommer);
			_edit();
		}
		
		public function deleteObj():void
		{
			new DeleteNomPieceCommand(this).run();
		}
		
		public function toXML():XML
		{
			var labelNode:XML = new XML("<label x=\""+ x / model.currentScale +"\" y=\""+ y / model.currentScale +"\" text=\""+t.text+"\"/>");
			
			return labelNode;
		}
		
		//--- private functions ----
		
		private function _drawBG():void
		{
			var g:Graphics = /*bg.*/graphics;
			g.clear();
			g.lineStyle(1, Config.COLOR_LIGHT_GREY);
			g.beginFill(0xffffff, .9);
			_w = t.textWidth +10;
			var h:int = t.textHeight+6
			g.drawRect(-1, -h/2, _w, h);
			g.endFill();
			t.x = (_w - t.width) / 2;
			t.y = - t.height / 2;
		}
		
		private function _edit(e:MouseEvent = null):void
		{
			//trace("NomPieceView::_edit()", t.text);
			if (t.text !== DEFAULT_VALUE) _newText = t.text;
			//stage.focus = this;
			t.selectable = true;
			t.type = TextFieldType.INPUT;
			t.maxChars = 30;
			t.setSelection(0, t.text.length);
			
			/*t.text = " ";
			t.setTextFormat(ft);*/
			stage.focus = t;
			setTimeout(function():void{stage.focus = t;},50);
			t.addEventListener(Event.CHANGE, _onChange);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			//bg.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			Editor2D.instance.addEventListener(MouseEvent.MOUSE_DOWN, _onFocusOut);
		}
		
		private function _onChange(e:Event):void
		{
			trace("NomPieceView::_onChange", t.text)
			_newText = t.text as String;
			t.setTextFormat(ft);
		}
		
		private function _onKeyDown(e:KeyboardEvent):void
		{
			var reg:RegExp = new RegExp(/\S/);
			if (e.keyCode != Keyboard.ENTER) return;
			// check for non-blank string
			trace("NomPiece::_onKeyDown champ vide?", !reg.test(_newText))
			if (!reg.test(_newText)) 
			{
				_newText = DEFAULT_VALUE;
				return;
			}
			_onFocusOut();
		}
		
		private function _onFocusOut(e:MouseEvent=null):void
		{
			//trace("NomPieceView::_onFocusOut 1");
			if (e && (e.target == this || e.target == t)) return;
			
			if(Editor2D.instance) Editor2D.instance.removeEventListener(MouseEvent.MOUSE_DOWN, _onFocusOut);
			
			t.selectable = false;
			t.type = TextFieldType.DYNAMIC;
			var pattern:RegExp = /\"/g;
			if(_newText != null) _newText = _newText.replace(pattern, "'");
			t.text = _newText || DEFAULT_VALUE;
			t.width = t.textWidth + 20;
			t.setTextFormat(ft);
			t.mouseEnabled = false;
			//trace("NomPieceView::_onFocusOut 2", t.text);
			
			_drawBG();
			//iconMenu.x = bg.width - iconMenu.width/2.5;
			//iconMenu.y = - iconMenu.height;
			
			if(stage) stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			t.removeEventListener(Event.CHANGE, _onChange);
			//bg.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			//iconMenu.addEventListener(MouseEvent.CLICK, renommer);
		}
		
		/*private function _onMouseDown(e:MouseEvent):void
		{
			trace("NomPieceView::_onMouseDown() ", e.currentTarget, e.target)
			addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			_onMouseMove(e);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, _stopdrag);
		}
		
		private function _onMouseMove(e:MouseEvent):void
		{
			var p:Point = GeomUtils.localToEditor(new Point(mouseX, mouseY), this);
			x = p.x - width/2;
			y = p.y //+ height/2;
		}
		
		private function _stopdrag(e:MouseEvent):void
		{
			trace("NomPieceView::_stopdrag");
			removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _stopdrag);
		}*/
		
		protected function _onZoom(e:ZoomEvent=null):void
		{
			var prevScale:Number = model.prevScale;
			var scale:Number = model.currentScale;
			var scaleFactor:Number = scale / prevScale;
			
			this.scale(scaleFactor);
		}
		
		private function cleanup(e:Event):void 
		{
			//trace("NomPieceView::cleanup()");
			model.removeZoomEventListener(_onZoom);
			//iconMenu.removeEventListener(MouseEvent.CLICK, renommer);
			//iconDelete.removeEventListener(MouseEvent.CLICK, _delete);
			//bg.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
	}

}