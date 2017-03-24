package classes.views.menus 
{
	import classes.controls.DeleteConnectionEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.equipements.EquipementView;
	import classes.views.plan.EditorContainer;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * La classe MenuContainer contient les menus, le background du menu et le bouton fermer de chaque élement du plan
	 * 
	 * <p>Contient un header et un body</p>
	 */
	public class MenuContainer extends Sprite
	{
		private var _btnClose:BtnCloseMenu;
		private var _isOpen:Boolean = true;
		private var _masq:Sprite;
		private var _bg:Sprite;
		public var content:Sprite;
		public var bec:Sprite;
		private var _container:Sprite;
		private var _body:MenuRenderer;
		private var _WIDTH:int = 201;
		private var _HEIGHT:int = 100;
		private var _openPos:int;
		private var _closePos:int;
		private var t:Tween;
		private var t2:Tween;
		private var _obj:DisplayObject;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function MenuContainer() 
		{
			_instance = this;
			
			addEventListener(Event.ADDED, _addElements);
		}
		
		private static var _instance:MenuContainer;
		public static function get instance():MenuContainer
		{
			return _instance;
		}
		
		private function _addElements(e:Event):void
		{
			//trace("MenuContainer::_added()");
			removeEventListener(Event.ADDED, _addElements);
			
			_masq = new Sprite();
			_masq.graphics.beginFill(0);
			_masq.graphics.drawRect( -40, -20, _WIDTH + 60, 500);
			
			_btnClose = new BtnCloseMenu();
			addChild(_btnClose);
			_btnClose.x = -30
			_btnClose.y = 20
			_btnClose.buttonMode = true;
			_btnClose.addEventListener(MouseEvent.CLICK, _onClick, false, 0, true);
			
			_container = new Sprite();
			addChild(_container);
			
			_bg = new Sprite();
			_container.addChild(_bg);
			var g:Graphics = _bg.graphics;
			g.lineStyle(1, 0xd2d2d2, .4);  
			g.beginFill(0);
			g.drawRoundRect(0, 0, _WIDTH, _HEIGHT, 8);
			g.endFill();
			var offset:int = 15;
			_bg.scale9Grid = new Rectangle(offset, offset, _WIDTH -offset*2, _HEIGHT -offset*2);
			
			_addGradient();
			
			_addBec();
			
			content = new Sprite();
			_container.addChild(content);
			
			_appmodel.addConnectPopupOpenListener(_onConnectPopupOpen);
			//_appmodel.addConnectPopupCloseListener(_onConnectPopupClose);
			_appmodel.addDeleteConnectionListener(_onDeleteConnection);
			
			_dropShadow()
			
			_onResize();
			stage.addEventListener(Event.RESIZE, _onResize, false, 0, true);
		}
		
		private function _onConnectPopupOpen(e:Event):void
		{
			if(_body && _body.stage) content.removeChild(_body);
			var tbg:Tween = new Tween(_bg, "height", Regular.easeOut, _bg.height, content.getBounds(content).height, .2, true);
		}
			
		/*private function _onConnectPopupClose(e:Event):void
		{
		}*/
		
		private function _onDeleteConnection(e:DeleteConnectionEvent):void
		{
			if (e.connection.receiverIs(_obj as EquipementView)) {
				MenuFactory.createMenu(_obj, EditorContainer.instance);
			}
		}
		
		private function _addGradient():void
		{
			var gradient:Shape = new Shape();
			_container.addChild(gradient);
			var g:Graphics = gradient.graphics;
			g.lineStyle();  
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0x8b8b8b, 0x565656, 0x3b3b3b];
			var alphas:Array = [1, 1, 1];
			var ratios:Array = [0, 200, 245];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(_WIDTH, 15, Math.PI / 2, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
			g.drawRect(1, 1, _WIDTH - 1, 15);
		}
		
		private function _addBec():void
		{
			bec = new Sprite();
			_container.addChild(bec);
			bec.x = 1
			bec.y = 72;
			
			// draw bec
			var g:Graphics = bec.graphics;
			g.lineStyle();
			g.beginFill(0);
			var displace:int = 16;
			g.lineTo(-displace, displace);
			g.lineTo( 0, displace);
			g.lineTo(0, 0);
		}
		
		private function _onResize(e:Event=null):void
		{
			if (EditorContainer.instance) {
				var r:Rectangle = EditorContainer.instance.editorMask.getBounds(EditorContainer.instance);
				var rightLimitPos:int = r.x + r.width;
				_openPos = rightLimitPos - width + 50;
				_closePos = rightLimitPos +20;
				
				x = (_isOpen) ? _openPos : _closePos -20;
				if (_masq) _masq.x = _openPos -10;
			}
		}
		
		/**
		 * Permet de mettre à jour l'affichage du menu 
		 * 
		 * @param	obj L'objet sur lequel l'utilisateur a cliqué
		 * @param	menu Le MenuRenderer à appeler
		 * @param	type Le type d'objet concerné par le menu
		 */
		public function update(obj:DisplayObject=null , menu:MenuRenderer = null, type:String=null):void
		{
			_obj = obj;
			visible = true;
			
			y = -20
			
			if (t) t.stop();
			
			t = new Tween (this, "alpha", Regular.easeOut, alpha, 1, .1, true);
			
			if(_body && _body.stage) content.removeChild(_body);
			
			/*trace("MenuContainer", menu, menu.stage);
			if (menu.stage == null) {
				return;
			}*/
			
			if(menu) _body = menu; 
			/*else return;*/
			
			// header
			var header:MenuHeaderRenderer = MenuHeaderRenderer.instance
			if (header == null) {
				header = new MenuHeaderRenderer();
				content.addChild(header);
			}
			header.update(type, obj);
			
			// create new menu and set alpha to zero
			content.addChild(_body);
			_body.y = header.y + header.getHeight();
			
			content.graphics.clear();
			content.graphics.beginFill(0, 0);
			var r:Rectangle = content.getBounds(content);
			content.graphics.drawRect(0, 0, 10, r.height);
			//trace("MenuContainer::update", r.height, content.height);
			
			_body.alpha = 0;
			
			t = new Tween(_bg, "height", Regular.easeOut, _bg.height, _body.y + _body.H, .2, true);
			t.addEventListener(TweenEvent.MOTION_FINISH, _onMotionFinish, false, 0, true);
		}
		
		private function _onMotionFinish(e:TweenEvent):void
		{
			t2 = new Tween(_body, "alpha", Regular.easeOut, 0, 1, .4, true);
			//trace("MenuContainer::_OnMotionFinish", _body.alpha, _body.numChildren);
		}
		
		private function _onClick(e:MouseEvent):void
		{
			if (_isOpen) _close()
			else _open();
		}
		
		private function _close():void
		{
			//trace("_close", parent);
			parent.addChild(_masq);
			_masq.x = x -10;
			_masq.y = y;
			mask = _masq;
			
			_isOpen = false;
			t = new Tween(this, "x", Regular.easeOut, x, _closePos - 20, .3, true);
			
			t.addEventListener(TweenEvent.MOTION_FINISH, function ():void { _container.visible = false; new Tween(_btnClose.arrow, "rotationY", Regular.easeOut, _btnClose.arrow.rotationY, _btnClose.arrow.rotationY + 180, .2, true);}, false, 0, true);
		}
		
		private function _open():void
		{
			_isOpen = true;
			_container.visible = true;
			t = new Tween(this, "x", Regular.easeOut, x, _openPos, .3, true);
			t.addEventListener(TweenEvent.MOTION_FINISH, _callbackMotion, false, 0, true);
		}
		
		private function _callbackMotion(e:TweenEvent):void
		{
			//trace("_callbackMotion", parent, _masq, _masq.parent);
			mask = null;
			_masq.parent.removeChild(_masq); 
			t = new Tween(_btnClose.arrow, "rotationY", Regular.easeOut, _btnClose.arrow.rotationY, _btnClose.arrow.rotationY + 180, .2, true);
		}
		
		/**
		 * Permet de fermer l'instance de MenuContainer. L'instance est rendue invisible mais elle reste présente
		 */
		public function closeMenu():void
		{
			//trace("closeMenu")
			var menu:MenuContainer = MenuContainer.instance;
			if (menu && menu.stage) {
				var rome:DisplayObject = MenuContainer.instance.getChildByName("rome");
				if(rome != null) MenuContainer.instance.removeChild(rome);
			}
			
			//alpha fade
			if(t) t.stop();
			t = new Tween (this, "alpha", Regular.easeOut, 1, 0, .4, true);
			t.addEventListener(TweenEvent.MOTION_FINISH, function():void { visible = false; }, false, 0, true);
			//EditorContainer.instance.removeChild(this)
		}
		
		private function _dropShadow(distance:int = 0, angle:int = 45, alpha:Number = .7, blur:int = 10, strength:int = 1 ):void
		{
			var d:DropShadowFilter = new DropShadowFilter(distance,angle,0,alpha,blur,blur,strength);
			_container.filters = [d];
		}
	}

}