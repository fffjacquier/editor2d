package classes.views.plan 
{
	import classes.config.Config;
	import classes.controls.History;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.HelpPopup;
	import classes.views.Background;
	import classes.views.menus.MenuContainer;
	import classes.views.menus.MenuFactory;
	import classes.views.Navigator;
	import classes.views.Toolbar;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * EditorContainer est un singleton, un getter public statique réfère à son instance. Il contient l'editeur2d, la toolbar et le navigator
	 */
	public class EditorContainer extends Sprite 
	{
		private var _am:ApplicationModel = ApplicationModel.instance;
		private var _editorMask:Sprite;
		private var _editor:Editor2D;
		private var _toolbar:Toolbar;
		
		private static var _instance:EditorContainer;
		public static function get instance():EditorContainer
		{
			return _instance;
		}
		
		/**
		 * EditorContainer,  singleton qui contient l'editeur2d, la toolbar et le navigator
		 * Cette classe gère la dimension du masque de l'editeur en fonction de la taille du navigateur et au resize.
		 * C'est ici qu'il faudrait intervenir pour éventuellment recentrer l'éditeur en fonction de la taille de la fenêtre du navigateur, 
		 * pour recentrer le bloc maison qui est fixe dans l'éditeur. 
		 * Nous parlons bien de la position par défaut de l"éditeur, sous le masque qui lui ne bouge pas, mais se redimentionne uniquement
		 */
		public function EditorContainer() 
		{
			if (_instance == null) _instance = this;
			else throw new Error("EditorContainer should be instantiate only once");
			
			x = 14;
			y = 78;
			
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		public function get editorMask():Sprite
		{
			return _editorMask;
		}
		
		public function get maskHeight():int
		{
			//trace("EditorContainer::maskHeight", editorMask.height);
			return _editorMask.height;
		}
		
		public function get maskWidth():int
		{
			//trace("EditorContainer::maskWidth", editorMask.height);
			return _editorMask.width;
		}
		
		private function _added(e:Event):void
		{
			//trace("EditorContainer::_added()");
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			_editorMask = new Sprite();
			addChild(_editorMask);
			
			_editor = new Editor2D();
			addChild(_editor);
			_editor.x = /*_editorMask.x =*/ Config.TOOLBAR_WIDTH;
			_editor.y = 34;
			_setMaskSizes();
			
			_toolbar = new Toolbar();
			addChild(_toolbar);
			//_toolbar.x = _model.maskSize.width - Config.TOOLBAR_WIDTH - 10;
			_toolbar.x = 0;
			_toolbar.y = 34;
			
			var navigator:Navigator = new Navigator();
			addChild(navigator);
			navigator.y = 34;
			
			//stage.addEventListener(Event.RESIZE, _onResize);
			_am.addResizeMaskUpdateListener(_onResize);
			
			// si appmodel.projectvo.id == -1 
			//		pas de data -> nouveau plan
			// else: loadxml from projetvo.xml_plan
			AppUtils.TRACE("projetvo:"+ _am.projetvo.toString());
			if (_am.projetvo.id === -1) 
			{
				if (_am.plantype != null) {
					Editor2D.instance.createFromXML(_am.plantype);
				} else if (_am.projetvo.xml_plan != null) {// cas des plans sauvegardés desquels on repart
					Editor2D.instance.createFromXML(_am.projetvo.xml_plan);
				} else {
					_editor.addFirstFloor();
				}
				//trace("EditorContainer PROJECTTYPE:", _model.projectType);
				
				History.initialized = true;
			} else {
				if (_am.projetvo != null && _am.projetvo.xml_plan != null) {
					_am.projectType = _am.projetvo.ref_type_projet;
					//AppUtils.TRACE("EditorContainer::" + _model.projectType+"$");
					if (_am.projetvo.ref_type_projet == "") _am.projectType = null;
					if(_am.projectType != null) _am.notifyProjectType();
					Editor2D.instance.createFromXML(_am.projetvo.xml_plan);
				}
				else {
					trace("projetvo null");
					AppUtils.TRACE("PBM du plan_xml");
				}
			}
			//trace("_model.projectType", _model.projectType);
			var menu:MenuContainer = MenuContainer.instance;
			trace("EditorContainer::_added() menu", menu)
			if (menu == null) {
				addChild(new MenuContainer()/*menu*/);
				
			} else {
				// needs to be betterified
				menu.alpha = 1;
				menu.visible = true;
				addChild(menu);
			}
			menu = MenuContainer.instance;
			var floor:Floor = EditorModelLocator.instance.currentFloor;
			if (floor && floor.id == 0) menu.update(floor, MenuFactory.createMenu(floor, EditorContainer.instance), "floor");
			
			// si 1er plan, afficher aide
			AppUtils.TRACE("1er plan ? " +_am.listProjectsCopy + " "+ _am.clientvo.liste_id_projet +" "+ _am.projetvo.id);
			if (_am.listProjectsCopy == 0) 
			{
				var popup:HelpPopup = new HelpPopup();
				AlertManager.addPopup(popup, Main.instance);
				popup.x = Background.instance.masq.width/2 - popup.width/2;
			}
		}
		
		private function _setMaskSizes():void
		{
			_editorMask.graphics.clear();
			_editorMask.graphics.beginFill(0);
			var largeur:int = _am.maskSize.width -30 - Config.TOOLBAR_WIDTH;
			var hauteur:int = _am.maskSize.height - 122;
			//AppUtils.TRACE("EditorContainer::_setMaskSizes() "+largeur+" "+ hauteur);
			
			//_editorMask.graphics.drawRoundRect(0, 0, largeur, hauteur, 15, 15);
			//_editorMask.x = Config.TOOLBAR_WIDTH;
			_editorMask.graphics.drawRoundRect(Config.TOOLBAR_WIDTH, 34, largeur, hauteur, 15, 15);
			_editor.mask = _editorMask;
			Config.EDITOR_WIDTH = _editorMask.width;
			Config.EDITOR_HEIGHT = _editorMask.height;
			if (EditorZoom.instance) EditorZoom.instance.onResize();
			
		}
		
		private function _onResize(e:Event):void
		{
			_editor.mask = null;
			//_toolbar.x = _model.maskSize.width - Config.TOOLBAR_WIDTH - 14;
			//_editor
			_setMaskSizes();
		}
		
		private function _removed(e:Event):void
		{
			trace("EditorContainer::_removed()");
			
			_instance = null;
			//stage.removeEventListener(Event.RESIZE, _onResize);
			_am.removeResizeMaskUpdateListener(_onResize);
			//EditorModelLocator.instance.reset();
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
	}

}