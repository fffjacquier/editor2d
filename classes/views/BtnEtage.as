package classes.views 
{
	import classes.commands.AddNewFloorCommand;
	import classes.controls.ChangeFloorEvent;
	import classes.controls.DeleteFloorEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.YesAlert;
	import classes.views.menus.MenuContainer;
	import classes.views.menus.MenuFactory;
	import classes.views.plan.Editor2D;
	import classes.views.plan.EditorContainer;
	import classes.views.plan.EditorNav;
	import classes.views.plan.Floor;
	import classes.views.plan.Floors;
	import fl.transitions.easing.Strong;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * La classe <code>BtnEtage</code> crée et gère l'état des boutons des étages
	 * 
	 * <p>Trois états sont possibles : 
	 * <ul>
	 * 		<li>inactive, l'étage n'a pas été créé encore ou a été supprimé</li>
	 * 		<li>active, l'étage a été ajouté mais n'est pas l'étage affiché</li>
	 * 		<li>selected, l'étage a été ajouté et c'est l'étage affiché</li>
	 * </ul>
	 * </p>
	 * 
	 * <p>Cette classe écoute le changement d'étage (event <code>ChangeFloorEvent</code>) et la suppression des étages 
	 * (event <code>DeleteFloorEvent</code>)</p>
	 * 
	 */
	public class BtnEtage extends Sprite 
	{
		//data
		private var _etageLabel:String;
		private var _state:String;
		private var _id:int;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _selectedColor:ColorTransform;
		private var _notSelectedColor:ColorTransform;
		private var _DEFAULT_HEIGHT:int = 25;
		private var _tweenColor:Tween;
		private var _tweenHeight:Tween;
		/**
		 * Valeur d'un bouton d'étage inactif, non encore cliqué
		 */
		public static var STATE_INACTIVE:String = "inactive";
		/**
		 * Valeur d'un bouton d'étage actif, cliqué mais pas l'étage sélectionné
		 */
		public static var STATE_ACTIVE:String = "active";
		/**
		 * Valeur d'un bouton d'étage sélectionné, cliqué et étage en cours d'affichage
		 */
		public static var STATE_SELECTED:String = "selected";
		/**
		 * Correspond à son étage (<code>Floor</code>) de référence
		 */
		public var floor:Floor;
		//views
		private var _t:CommonTextField;
		private var _bg:Sprite;
		
		/**
		 * Permet de créer un bouton d'étage avec son libellé, son numéro d'étage et son état par défaut.
		 * 
		 * @param	etage Le label de l'étage
		 * @param	id L'id de l'étage -1 pour le sous sol, 0 pour le RDC, 1, 2, 3 pour les étages. Pas d'autres valeurs possibles.
		 * @param	state Quel est son état (state) souhaité à la création
		 */
		public function BtnEtage(etage:String, id:int, state:String = "inactive") 
		{
			_etageLabel = etage;
			_id = id;
			//trace("btn etage " + _id);
			_state = state;
			_selectedColor = new ColorTransform();
			_notSelectedColor = new ColorTransform();
			_notSelectedColor.color = 0;
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			_bg = new Sprite();
			addChild(_bg);
			buttonMode = true;
			
			_t = new CommonTextField("helvetBold", 0x999999);
			addChild(_t);
			if (_etageLabel === AppLabels.getString("editor_level0")) {
				_t.width = 111;
			} else {
				_t.width = 84;
			}
			_t.x = 1;
			_t.y = 5;
			_t.mouseEnabled = false;
			
			// dessiner la forme avec le dégradé clair d'abord
			var g:Graphics = _bg.graphics;
			g.lineStyle();
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xe5e5e5, 0xffffff];
			var alphas:Array = [1, 1];
			var ratios:Array = [60, 216];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(15, _DEFAULT_HEIGHT, - Math.PI / 2);
			var spreadMethod:String = SpreadMethod.PAD;
			g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
			g.drawRoundRectComplex(0, 0, _t.width, _DEFAULT_HEIGHT, 0, 0, 5, 5);
			g.endFill();
			
			// figer le scale9grid
			var offset:int = 15;
			_bg.scale9Grid = new Rectangle(offset, offset/2, _t.width -offset * 2, _DEFAULT_HEIGHT - offset);
			
			changeState(_state);
			
			addEventListener(MouseEvent.CLICK, _action, false, 0, true);
			_model.addFloorChangeListener(_onChangeFloor);
			_model.addFloorDeletionListener(_onDeleteFloor);
			//trace("BtnEtage::added()", _etageLabel);
		}
		
		private function _onDeleteFloor(e:DeleteFloorEvent):void
		{
			if(e.floor.id == _id) changeState(STATE_INACTIVE);
		}
		
		public function changeState(state:String):void
		{
			//if (_bg.numChildren > 0) _bg.removeChildAt(0);

			switch(state) {
				case STATE_INACTIVE:
					inactiveState();
					break;
				case STATE_ACTIVE:
					activeState();
					break;
				case STATE_SELECTED:
					selectedState();
					if (floor == null) floor = _model.currentFloor;
					break;
			}
		}		
		
		private function inactiveState():void
		{			
			var f:TextFormat = _t.cloneFormat();
			f.align = TextFormatAlign.CENTER;
			f.color = 0xeaeaea;
			_t.alpha = .5;
			_setText();
			_t.setTextFormat(f);
			
			_state = STATE_INACTIVE;
			_doTweenColor();
		}
		
		private function activeState():void
		{
			var f:TextFormat = _t.cloneFormat();
			f.align = TextFormatAlign.CENTER;
			f.color = 0xffffff;
			_t.alpha = 1;
			_setText();
			_t.setTextFormat(f);
			
			_state = STATE_ACTIVE;
			_doTweenColor();
		}
		
		private function selectedState():void
		{
			var f:TextFormat = _t.cloneFormat();
			f.align = TextFormatAlign.CENTER;
			f.color = 0x333333;
			_t.alpha = 1;
			_setText();
			_t.setTextFormat(f);
			
			_state = STATE_SELECTED;
			_doTweenColor();
			/*trace(floor);*/
		}
		
		private function _doTweenColor():void
		{
			_tweenColor = new Tween(_bg, "", Strong.easeOut, 0, 1, 16);
			_tweenColor.addEventListener(TweenEvent.MOTION_CHANGE, _tweenColorTransform, false, 0, true);
		}
		
		private function _tweenColorTransform(e:TweenEvent):void
		{
			//trace("_tweenColorTransform", _state)
			if (_state === STATE_INACTIVE) {
				_bg.transform.colorTransform = AppUtils.interpolateColor(_selectedColor, _notSelectedColor, _tweenColor.position);
			} else if(_state === STATE_ACTIVE) {
				_bg.transform.colorTransform = AppUtils.interpolateColor(_selectedColor, _notSelectedColor, _tweenColor.position);
			} else if(_state === STATE_SELECTED) {
				_bg.transform.colorTransform = AppUtils.interpolateColor(_notSelectedColor, _selectedColor, _tweenColor.position);
			}
		}
		
		private function _setText():void
		{
			_t.setText(_etageLabel);
		}
		
		private function _action(e:MouseEvent):void
		{
			/*trace("========================");
			trace("BtnEtage::_click", _id, e.currentTarget, _state, floor.id, floor.isFirstTime);
			trace("========================");*/
			
			var menu:MenuContainer = MenuContainer.instance;
			if (menu && menu.stage) {
				menu.closeMenu();
			}
			var floors:Floors = Editor2D.instance.floors;
			//check if there's a surface in ground 0
			/*var ground0:Floor = _model.getFloorById(0) as Floor;
			if(!ground0.blocMaison)
			{
				var popup:YesAlert = new YesAlert("Veuillez créer une surface au rez-de-chaussée avant de construire un nouvel étage", true, true);
				AlertManager.addPopup(popup, Main.instance);
				AppUtils.appCenter(popup);
				return;
			}*/
			
			// check if there's is no floor missing under the asked floor
			var UpfloorsCount:int = Editor2D.instance.hasUnderground ? floors.length -1 : floors.length;
			if(_id != -1) 
			{
				if(UpfloorsCount < _id)
				{
					var arr:Array = ["", AppLabels.getString("messages_floorError1"), AppLabels.getString("messages_floorError2")];
					var popup:YesAlert = new YesAlert(AppLabels.getString("messages_floors"), arr[UpfloorsCount], true);
					AlertManager.addPopup(popup, Main.instance);
					//AppUtils.appCenter(popup);
					return;
				}
			}
			
			// check popup warning changement étage
			/*if (!Navigator.firstTimeEtage) {
				Navigator.firstTimeEtage = true;
				
				popup = new YesAlert("vous venez de créer un niveau. Nous avons installé une surface identique au rez-de-chaussée.\nVous pouvez la modifier et/ou continuer votre installation...", true, true);
				AlertManager.addPopup(popup, Main.instance);
				AppUtils.appCenter(popup);
			}*/
			
			// on ramene le zoom à 100%
			//EditorZoom.instance.restoreEditorDefaultPosition();
			
			//on pourrait mettre cette action dans floor a l'ecoute du changment d'étage pour qu'elle ait vraiment lieu chaque fois qu'on change d'étage
			//si on veut. dans ce cas il faudra enlever la fonction dans le menu de fibre (ds l'accordéeon)
			
			if (_state === STATE_INACTIVE) {
				// createFloor && change floor
				changeState(STATE_ACTIVE);
				new AddNewFloorCommand(_etageLabel, _id).run(/*_setFloor*/);
				
				ApplicationModel.instance.screen = ApplicationModel.SCREEN_EDITOR;
				_model.isDrawStep = true;
				_model.notifyModeUpdate();
				EditorNav.instance.manageAlphaBtnsEditor();
			} else {
				_model.currentFloor = floor;
			}	
			//--------  menu steps -----
			if (floor.blocMaison == null)
			{  
				ApplicationModel.instance.currentStep = ApplicationModel.STEP_SURFACE;
				
			} else { 
				if (_model.isDrawStep) {
					ApplicationModel.instance.currentStep = 0
				} else {
					ApplicationModel.instance.currentStep = 1
				}
				//ApplicationModel.instance.currentStep = (floor.hasEquipements()) ? ApplicationModel.STEP_EQUIPEMENTS : ApplicationModel.STEP_SURFACE;
			}
			menu.update(floor, MenuFactory.createMenu(floor, EditorContainer.instance), "floor");
		}
		
		private function _setFloor():void
		{
			if (_model.currentFloor.id === _id) {
				changeState(STATE_ACTIVE);
				floor = _model.currentFloor;
				floor.isFirstTime = false;
			}
		}
		
		private function _onChangeFloor(e:ChangeFloorEvent):void
		{
			//trace("BtnEtage"+ _id +"::_onChangeFloor", e.floor.id, _state);
			if (e.floor == null) return;
			_setFloor();
			
			if (e.floor.id === _id) {
				changeState(STATE_SELECTED);
				//trace("BtnEtage::_onChangeFloor after", _id, _state, "currentfloor:", e.floor.id);
			} else {
				if (_state === STATE_SELECTED) {
					changeState(STATE_ACTIVE);
					//trace("BtnEtage::_onChangeFloor after", _id, _state, "currentfloor:", e.floor.id);
				}
			}
		}
		
		private function _removed(e:Event):void
		{
			//trace("BtnEtage::_removed", _id);
			_model.removeFloorChangeListener(_onChangeFloor);
			_model.removeFloorDeletionListener(_onDeleteFloor);
			removeEventListener(MouseEvent.CLICK, _action);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}

}