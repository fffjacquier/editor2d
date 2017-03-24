package classes.views.plan 
{
	import classes.commands.ClearAllCommand;
	import classes.components.ScrollBar;
	import classes.config.Config;
	import classes.controls.History;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.YesNoAlert;
	import classes.views.Navigator;
	import classes.views.tooltip.Tooltip;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	/**
	 * EditorZoom est un Sprite. Il contient
	 * <ul>
	 * <li>la scrollBar permettant de zoomer l'éditeur.</li>
	 * <li>les 4 boutons permettant le déplacement du plan, blocsDeplacement.</li>
	 * <li>le bouton permettant d'annuler la dernière action, _btnAnnulerAction </li>
	 * <li>le bouton permettant de revenir à l'échalle et à la position en x et y de l'éditeur par défaut, _moveBack</li>
	 * </ul>
	 * Il est dans le Sprite <code>Navigator.as,</code> avec l'échelle, <code>Echelle.as</code>.
	 */
	public class EditorZoom extends Sprite 
	{
		private var _step:int = 3;
		private var _moveBack:EditorZoomBackToInitial;
		private var _sb:ScrollBar;
		private var _blocBoutons:Sprite;
		private var blocsDeplacement:Sprite;
		private var _btnAnnulerAction:BtnAnnulerAction;
		private var _btnEffacer:BtnEffacerTout;
		
		private var _editor:Editor2D = Editor2D.instance;
		private var _echelle:Echelle;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _history:History = History.instance;
		
		private static var _instance:EditorZoom;
		public static function get instance():EditorZoom
		{
			return _instance;
		}
		
		/**
		 * EditorZoom est un singleton, un getter public statique réfère à son instance.
		 * 
		 */
		public function EditorZoom(echelle:Echelle) 
		{
			_echelle = echelle;
			if (_instance == null) _instance = this;
			else throw new Error("EditorZoom should be instantiate only once");
			
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			x = Config.TOOLBAR_WIDTH;
			
			var bottom:int = EditorContainer.instance.maskHeight// -50;
			
			/*var g:Graphics = graphics;
			g.lineStyle();
			g.beginFill(0xe5e5e5, .7);
			g.drawRoundRectComplex(0, 0, 78, bottom, 10, 0, 10, 0);*/
			
			_blocBoutons = new Sprite();
			addChild(_blocBoutons);
			
			blocsDeplacement = new Sprite();
			addChild(blocsDeplacement);
			var g:Graphics = blocsDeplacement.graphics;
			g.lineStyle();
			g.beginFill(0, .3);
			g.drawRoundRect(0, 0, 62, 62, 10);
			
			var moveUp:MovieClip = new EditorZoomMoveUp();
			blocsDeplacement.addChild(moveUp);
			moveUp.x = 20;
			moveUp.y = 3;
			
			var moveRight:MovieClip = new EditorZoomMoveRight();
			blocsDeplacement.addChild(moveRight);
			moveRight.x = 37;
			moveRight.y = 20;
			
			var moveDown:MovieClip = new EditorZoomMoveDown();
			blocsDeplacement.addChild(moveDown);
			moveDown.x = 20;
			moveDown.y = 37;
			
			var moveLeft:MovieClip = new EditorZoomMoveLeft();
			blocsDeplacement.addChild(moveLeft);
			moveLeft.x = 3;
			moveLeft.y = 20;
			blocsDeplacement.x = 6;
			blocsDeplacement.y = bottom - 6 -blocsDeplacement.height;
			
			_btnAnnulerAction = new BtnAnnulerAction()
			_blocBoutons.addChild(_btnAnnulerAction);
			_btnAnnulerAction.enabled = false;
			_model.addHistoryListener(_onHistoryUpdate);
			_onHistoryUpdate();
			_btnAnnulerAction.buttonMode = true;
			_btnAnnulerAction.mouseChildren = false;
			_btnAnnulerAction.addEventListener(MouseEvent.CLICK, _cancel);
			_btnAnnulerAction.addEventListener(MouseEvent.ROLL_OVER, _over);
			_btnAnnulerAction.addEventListener(MouseEvent.ROLL_OUT, _out);
			
			_btnEffacer = new BtnEffacerTout()
			_blocBoutons.addChild(_btnEffacer);
			_btnEffacer.y = _btnAnnulerAction.y + _btnAnnulerAction.height + 6;
			_btnEffacer.buttonMode = true;
			_btnEffacer.addEventListener(MouseEvent.CLICK, _effacerTout);
			_btnEffacer.addEventListener(MouseEvent.ROLL_OVER, _over);
			_btnEffacer.addEventListener(MouseEvent.ROLL_OUT, _out);
			
			_moveBack = new EditorZoomBackToInitial();
			addChild(_moveBack);
			_moveBack.x = 6;
			_moveBack.y = 80;
			
			_sb = new ScrollBar(Editor2D.instance, ScrollBarZoomAssets);
			addChild(_sb);
			_sb.x = 12;
			_sb.y = _moveBack.y + _moveBack.height + 14;
			
			_blocBoutons.x = 9;
			_blocBoutons.y = bottom -10 - _blocBoutons.height;
			
			blocsDeplacement.x = 9;
			blocsDeplacement.y = _sb.y + _sb.height + 10;
			
			moveUp.buttonMode = true;
			moveUp.mouseChildren = false;
			moveRight.buttonMode = true;
			moveRight.mouseChildren = false;
			moveDown.buttonMode = true;
			moveDown.mouseChildren = false;
			moveLeft.buttonMode = true;
			moveLeft.mouseChildren = false;
			_moveBack.buttonMode = true;
			_moveBack.mouseChildren = false;
			
			_moveBack.addEventListener(MouseEvent.ROLL_OVER, _over);
			_moveBack.addEventListener(MouseEvent.ROLL_OUT, _out);
			
			addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown, true);
			addEventListener(MouseEvent.MOUSE_UP, _stopMoving, true);
			addEventListener(MouseEvent.MOUSE_OUT, _stopMoving, true);
			
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			onResize();
		}
		
		private function _cancel(e:MouseEvent):void
		{
			if (_tooltip && _tooltip.stage) _tooltip.remove();
			if (ApplicationModel.instance.screen == ApplicationModel.SCREEN_EDITOR) {
				_history.popHistory();
				EditorModelLocator.instance.notifyUndoMovePointListener();
			}
		}
		
		private function _onHistoryUpdate(e:Event = null):void
		{
			if (_history.length > 0) {
				_enableBtn();
			} else {
				_disableBtn();
			}
		}
		
		private function _disableBtn():void
		{
			_btnAnnulerAction.enabled = false;
			_btnAnnulerAction.alpha = .3;
			//_btnAnnulerAction.buttonMode = false;
			//_btnAnnulerAction.mouseChildren = false;
		}
		private function _enableBtn():void
		{
			_btnAnnulerAction.enabled = true;
			_btnAnnulerAction.alpha = 1;
			//_btnAnnulerAction.buttonMode = true;
			//_btnAnnulerAction.mouseChildren = false;
		}
		
		private function _effacerTout(e:MouseEvent):void
		{
			var popup:YesNoAlert = new YesNoAlert(AppLabels.getString("alert_eraseAll"), AppLabels.getString("alert_confirmEraseAll"), _doClearAll);
			AlertManager.addPopup(popup, Main.instance);
			//AppUtils.appCenter(popup);
		}
		
		private function _doClearAll():void
		{
			new ClearAllCommand().run();
		}
		
		private var _p:Point;
		private function _onMouseDown(e:MouseEvent):void
		{
			if (e.target is EditorZoomBackToInitial) 
			{
				/*_model.currentScale = _model.defaultScale;
				//setter le x et y en 0 apres le scale car Editor2D change de position en fonction du scale 
				//pour se recentrer sur le point enregistré en tant que centre du zoom
				_editor.x = Config.TOOLBAR_WIDTH;
				_editor.y = 0;
				setTimeout(_model.notifyZoomEndEvent, 200);*/
				restoreEditorDefaultPosition();
			}
			else
			{
				//Grid.instance.graphics.clear();
				_p = new Point();
				if (e.target is EditorZoomMoveUp) {
					_p.y = + _step//*Grid.GAP;
				} else if (e.target is EditorZoomMoveRight) {
					_p.x =  - _step//*Grid.GAP;
				} else if (e.target is EditorZoomMoveDown) {
					_p.y = - _step//*Grid.GAP;
				} else if (e.target is EditorZoomMoveLeft) {
					_p.x = + _step//*Grid.GAP;
				}
				addEventListener(Event.ENTER_FRAME, _move, false, 0, true);
			}
		}
		
		public function restoreEditorDefaultPosition():void
		{
			_model.currentScale = _model.defaultScale;
			//setter le x et y en 0 apres le scale car Editor2D change de position en fonction du scale 
			//pour se recentrer sur le point enregistré en tant que centre du zoom
			_editor.x = Config.TOOLBAR_WIDTH;
			_editor.y = 0;
			setTimeout(_model.notifyZoomEndEvent, 200);
		}
		
		private function _stopMoving(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, _move);
			_p = null;
		}
		
		private function _move(e:Event):void
		{
			_editor.x += _p.x;
			_editor.y += _p.y;
		}
		
		private var _tooltip:Tooltip;
		private function _over(e:MouseEvent):void
		{
			if (!_btnAnnulerAction.enabled && e.target == _btnAnnulerAction) return;
			//trace("over")
			var message:String;
			var mc:MovieClip = e.target as MovieClip;
			if (mc.bg) {
				if (e.target == _btnEffacer) AppUtils.changeColor(0xff0000, mc.bg);
				else AppUtils.changeColor(0xff6600, mc.bg);
			}
			switch(e.target) {
				case _btnEffacer:
					message = AppLabels.getString("buttons_eraseAll");
					break;
				case _btnAnnulerAction:
					message = AppLabels.getString("buttons_cancelLastAction");
					break;
				default:
					message = AppLabels.getString("buttons_backTo100");
			}
			_tooltip = new Tooltip(Main.instance, message);
			Main.instance.addChild(_tooltip);
		}
		
		private function _out(e:MouseEvent=null):void
		{
			if (!_btnAnnulerAction.enabled && e.target == _btnAnnulerAction) return;
			//trace("out")
			if (_tooltip && _tooltip.stage) _tooltip.remove();
			if (e.target.bg) AppUtils.changeColor(0x666666, e.target.bg);
		}
		
		public function onResize(e:Event=null):void
		{
			var bottom:int = EditorContainer.instance.maskHeight;
			var right:int = EditorContainer.instance.maskWidth;
			//trace("EditorZoom::onResize()", bottom, right);
			
			/*var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0xe5e5e5, .7);
			g.drawRoundRectComplex(0, 0, 78, bottom, 10, 0, 10, 0);
			g.endFill();*/
			
			_blocBoutons.x = EditorContainer.instance.maskWidth - _blocBoutons.width;
			_blocBoutons.y = bottom - _blocBoutons.height;
			
			blocsDeplacement.y = bottom - 6 -blocsDeplacement.height;
			_echelle._onEditorMaskResize();
			Navigator.instance.updateGradient();
		}
		
		private function removeListeners(e:Event= null):void
		{
			_moveBack.removeEventListener(MouseEvent.ROLL_OVER, _over);
			_moveBack.removeEventListener(MouseEvent.ROLL_OUT, _out);
			_model.removeHistoryListener(_onHistoryUpdate);
			
			removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown, true);
			removeEventListener(MouseEvent.MOUSE_UP, _stopMoving, true);
			removeEventListener(MouseEvent.MOUSE_OUT, _stopMoving, true);
			if (hasEventListener(Event.ENTER_FRAME)) removeEventListener(Event.ENTER_FRAME, _move);
			
			removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
			_instance = null;
		}
	}

}