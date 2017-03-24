package classes.views.items 
{
	import classes.commands.AddEquipementCommand;
	import classes.config.Config;
	import classes.controls.UpdateEquipementViewEvent;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.utils.GeomUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.Info360;
	import classes.views.CommonTextField;
	import classes.views.equipements.*;
	import classes.views.EquipementsLayer;
	import classes.views.menus.MenuFactory;
	import classes.views.menus.MenuRenderer;
	import classes.views.plan.Bloc;
	import classes.views.plan.EditorContainer;
	import classes.vo.EquipementVO;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * La classe EquipementItem est la classe des objets équipements présents dans l'accordion ou liste déroulante de 
	 * l'éditeur.
	 * 
	 * <p>Un EquipementItem devient un EquipementView lors du drag and drop sur l'éditeur</p>
	 */
	public class EquipementItem extends DraggableItem 
	{
		private var _btnInfo:IconInfo;
		private var _imageContainer:Sprite;
		private var _image:String;
		private var _label:String;
		private var _equipementView:EquipementView;
		private var _newEquipement:EquipementView;
		private var _maxExemplaire:Sprite;
		private var _vo:EquipementVO;
		private static var count:int = 0;
		public var isOwned:Boolean = false;
		
		/**
		 * Crée un objet EquipementItem avec une image, un label, un texte éventuel sur le nombre maximal d'occurences qu'il 
		 * est possible d'ajouter dans un projet, dessine le fond  et le contour et ajoute le bouton i d'information 
		 * qui peut ou non être présent et qui correspond au diaporama 360 de l'équipement
		 * 
		 * @param	pid L'id de l'item
		 * @param	ptype Le type d'équipement (utilisé lors de la transfo EquipementItem en EquipementView
		 * @param	pvo
		 */
		public function EquipementItem(pid:int, ptype:String, pvo:EquipementVO ) 
		{
			super(pid, ptype);
			_vo = pvo;
			//trace("EquipementItem", _vo.toString());
			_image = pvo.imagePath;
			_label = pvo.screenLabel;
			
			if (ptype != "LivePlugItem" && ptype != "WifiExtenderItem") {
				_addMax();
			}
			
			//load image or class
			_imageContainer = new Sprite();
			var g:Graphics = _imageContainer.graphics;
			g.lineStyle(1, Config.COLOR_LIGHT_GREY);
			g.beginFill(0xffffff, 1);
			if (ptype == "LivePlugItem" || ptype == "WifiExtenderItem")
				g.drawRoundRect(0, 0, 67, 64, 15);
			else 
				g.drawRoundRect(0, 0, 95, 83, 15);
			g.endFill();
			addChild(_imageContainer);
			if (_image != "")
			{
				var u:Loader = new Loader();
				u.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImageComplete);
				u.load(new URLRequest(_image));
			}
			
			// add btn info
			if(_vo.diaporama360 !== "null") {
				_btnInfo = new IconInfo();
				addChild(_btnInfo);
				_btnInfo.x = _imageContainer.width - _btnInfo.width -3;
				_btnInfo.y = 3;
				_btnInfo.addEventListener(MouseEvent.CLICK, _info, false, 0, true);
			}
			appmodel.addUpdateEquipementListener(_onUpdateEquipement);
		}
		
		private function _info(e:MouseEvent):void
		{
			//trace("_info", type);
			var popup:Info360 = new Info360(_vo.diaporama360);
			if (type === "WifiExtenderItem" || type === "LivePlugItem") {
				AlertManager.addSecondPopup(popup, Main.instance );
			} else {
				AlertManager.addPopup(popup, Main.instance);
			}
		}
		
		private function _onImageComplete(e:Event):void
		{
			//trace("EquipementItem::_onImageComplete");
			var u:Loader = e.currentTarget.loader as Loader;
			u.removeEventListener(Event.COMPLETE, _onImageComplete);
			
			var bitmap:Bitmap = e.currentTarget.content as Bitmap;
			bitmap.smoothing = true;
			bitmap.scaleX = .25
			bitmap.scaleY = .25
			
			u.x = (_imageContainer.width - bitmap.width) / 2;
			u.y = (_imageContainer.height - bitmap.height) / 2;
			_imageContainer.addChild(u);
			
			// add Text
			var t:CommonTextField = new CommonTextField("helvetBold", 0x333333, 9);
			var tf:TextFormat = t.cloneFormat();
			tf.align = TextFormatAlign.CENTER;
			t.width = (type == "LivePlugItem" || type == "WifiExtenderItem") ? 62 : 95;
			t.setText(_label);
			t.setTextFormat(tf);
			t.y = _imageContainer.height - t.textHeight - 4;
			_imageContainer.addChild(t);
			
			getMax();
		}
		
		override protected function move(e:MouseEvent=null):void
		{
			var bloc:Bloc = isOverBloc();
			var p:Point = GeomUtils.localToGlobal(new Point(mouseX, mouseY), this);
			//trace(p.x, p.y, EditorContainer.instance.editorMask.getBounds(ghost))
			if (bloc == null && (EditorContainer.instance.editorMask.getBounds(ghost).containsPoint(new Point(ghost.mouseX, ghost.mouseY))))
			{
				bloc = _model.currentBlocMaison;
			}
			var mousePos :Point = new Point(EditorContainer.instance.mouseX, EditorContainer.instance.mouseY);
			if (bloc) 
			{
				if(ghost && ghost.stage) EditorContainer.instance.removeChild(ghost);
				if (!_equipementView)
				{
					if (type == "PriseItem") _equipementView = new PriseView(_vo);
					else if (type == "LiveboxItem") _equipementView = new LiveboxView(_vo);
					else if (type == "DecodeurItem") _equipementView = new DecodeurView(_vo);
					else if (type == "HomeLibraryItem") _equipementView = new HomeLibraryView(_vo);
					else if (type == "LivephoneItem") _equipementView = new LivePhoneView(_vo);
					else if (type == "LiveradioItem") _equipementView = new LiveradioCubeView(_vo);
					else if (type == "ImprimanteItem") _equipementView = new ImprimanteView(_vo);
					else if (type == "TabletteItem") _equipementView = new TabletteView(_vo);
					else if (type == "OrdinateurItem") _equipementView = new OrdinateurView(_vo);
					else if (type == "ConsoleJeuItem") _equipementView = new ConsoleJeuView(_vo);
					else if (type == "SmartphoneItem") _equipementView = new SmartphoneView(_vo);
					else if (type == "SqueezeBoxItem") _equipementView = new SqueezeBoxView(_vo);
					else if (type == "TelephoneItem") _equipementView = new TelephoneView(_vo);
					else if (type == "LivePlugItem") _equipementView = new LiveplugView(_vo);
					else if (type == "WifiExtenderItem") _equipementView = new WifiExtenderView(_vo);
					else if (type == "WifiDuoItem") _equipementView = new WifiDuoView(_vo);
					else if (type == "TeleItem") _equipementView = new TeleView(_vo);
					else if (type == "SwitchItem") _equipementView = new SwitchView(_vo); // rajouté mais inutile ici
					else if (type == "MainDoorItem") {
						_equipementView = new MainDoorView(_vo);
					}
					
					_equipementView.id = this.id;
					
					EditorContainer.instance.addChild(_equipementView);
					_equipementView.draw(Config.COLOR_SURFACE_JARDIN);
				}
				_equipementView.x = mousePos.x //+ _equipementView.width / 2;
				_equipementView.y = mousePos.y //+ _equipementView.height / 2;
					
			}
			else
			{
				if (ghost && !ghost.stage) {
					EditorContainer.instance.addChild(ghost);
					if(_cursor && !_cursor.stage) ghost.addChild(_cursor);
				}
				
				if (_equipementView && _equipementView.stage) EditorContainer.instance.removeChild(_equipementView);
				_equipementView = null;
				ghost.x = mousePos.x - ghost.width / 2;
				ghost.y = mousePos.y - ghost.height / 2;
				
			}
			
		}
		
		override protected function createGhost():void
		{
			var klass:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
			//trace("EquipementItem::klass=", klass);
			//trace("EquipementItem::id=", id);
			//trace("EquipementItem::type=", type);
			
			//if ((EquipementsLayer.getEquipements(AppUtils.getClassView(type)) >= _vo.max)) return;
			
			//ghost = new klass(id, klass, _image);
			// we have to take a shoot
			var bmd:BitmapData = new BitmapData(_imageContainer.width, _imageContainer.height, true, 0xffffff);
			bmd.draw(_imageContainer);
			ghost = new Sprite();
			var bitmap:Bitmap = new Bitmap(bmd);
			bitmap.smoothing = true;
			ghost.addChild(bitmap);
			
			_cursor.x = ghost.width / 2;
			_cursor.y = ghost.height / 2;
			
			EditorContainer.instance.addChild(ghost);
			if (!_cursor.stage) ghost.addChild(_cursor);
			
		}
		
		// lame :(
		private function _onUpdateEquipement(e:UpdateEquipementViewEvent):void
		{
			//trace("updateEquipement", e.action, e.item, type);
			if (type === "LiveboxItem" && e.item.type === type) 
			{
				getMax();
				return;
			}
			if (type === "PriseItem" && e.item.type === type && appmodel.projectType === "fibre") 
			{
				getMax(); 
				return;
			}
			if (type === "DecodeurItem" && e.item.type === type) 
			{
				getMax();
				return;
			} else {
				getMax();
			}
		}
		
		public function getMax():void
		{
			if (/*type == "PriseItem" ||*/ type == "LivePlugItem" || type == "WifiExtenderItem") return;
			//trace("getMax()", _vo.name, EquipementsLayer.getEquipements(AppUtils.getClassView(type)), _vo.max);
			if (type === "DecodeurItem") {
				var nbDecodeursPoses:int = EquipementsLayer.getEquipements(AppUtils.getClassView(type));
				//trace("nb de décodeurs deja posés", nbDecodeursPoses);
				var nbMax:int;
				if (appmodel.projectType === "adsl"/* || appmodel.projectType === "adslSat"*/) {//FJ 15/06/2012 : 2 decodeurs sur adslSat
					nbMax = 1;
				} else {
					nbMax = 2;
				}
				//_imageContainer.visible = true;
				if (nbDecodeursPoses >= nbMax) {
					removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
					_imageContainer.visible = false;
				} else {
					addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
					_imageContainer.visible = true;
				}
				return;
			}
			// FJ patch 03/07 
			// il faudrait recoder les views, en enlevant toutes les déclinaisons et vérifiant les points d'impact (1j et demi environ)
			if (type === "OrdinateurItem") {
				//ordinateur ou ordinateur fixe
				if (EquipementsLayer.getEquipements(AppUtils.getClassView(type), _vo.name) >= _vo.max) {
					removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
					_imageContainer.visible = false;
				} else {
					addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
					_imageContainer.visible = true;
				}
				return;
			}// fin du patch
			if (EquipementsLayer.getEquipements(AppUtils.getClassView(type)) >= _vo.max) {
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_imageContainer.visible = false;
			} else {
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				_imageContainer.visible = true;
			}
		}
		
		private function _addMax():void
		{
			_maxExemplaire = new Sprite();
			addChild(_maxExemplaire);
			var g:Graphics = _maxExemplaire.graphics;
			g.clear();
			g.lineStyle(1, Config.COLOR_LIGHT_GREY, .6);
			g.beginFill(0xffffff, .6);
			g.drawRoundRect(0, 0, 95, 83, 15);
			g.endFill();
			
			var maxEx:MaxExemplaire = new MaxExemplaire();
			var txt:String = (_vo.type == "MainDoorItem") ? AppLabels.getString("accordion_mainDoor") : type.substr(0, type.length - 4);
			var str:String = (_vo.max > 1) ? " " + AppLabels.getString("accordion_exs") + " " + txt + " " + AppLabels.getString("accordion_placeds") : " " + AppLabels.getString("accordion_ex") + " " + txt + " " + AppLabels.getString("accordion_placed");
			maxEx.label.text = _vo.max + str;
			if (type === "DecodeurItem") {
				maxEx.label.text = AppLabels.getString("accordion_noMoreAllowed");
			}
			_maxExemplaire.addChild(maxEx);
			_maxExemplaire.mouseChildren = false;
			_maxExemplaire.buttonMode = false;
			_maxExemplaire.useHandCursor = false;
		}
		
		override protected function executeAction():void
		{
			if(ghost && ghost.stage) EditorContainer.instance.removeChild(ghost);
			
			if (isOverMenu) {
				if (_equipementView && _equipementView.stage) EditorContainer.instance.removeChild(_equipementView);
				_equipementView = null;
				return;
			}
			
			var bloc:Bloc = isOverBloc();
			
			/*trace("EquipementItem::_executeAction() BLOC : " + bloc);
			trace("EquipementItem::_executeAction() type : " + type)*/
			
			// check if there is a surface
			/*if (_model.currentBlocMaison == null) {
				var popup:YesAlert = new YesAlert("vous devez tout d'abord poser une surface...");
				AlertManager.addPopup(popup, Main.instance, false, true);
				AppUtils.appCenter(popup);
				_equipementView = null;
				appmodel.currentStep = ApplicationModel.STEP_SURFACE;
				return;
			}*/
			
			// check if there is a livebox
			/*if (type !== "PriseItem" && type !== "LiveboxItem" && EquipementsLayer.getLivebox() == null) {
				popup = new YesAlert("vous devez tout d'abord placer votre Livebox...");
				AlertManager.addPopup(popup, Main.instance, false, true);
				AppUtils.appCenter(popup);
				EditorContainer.instance.removeChild(_equipementView);
				_equipementView = null;
				appmodel.currentStep = ApplicationModel.STEP_EQUIPEMENTS
				return;
			}*/
			
			if (bloc == null) {
				//getMax();
				bloc = _model.currentBlocMaison;
			}
			
			var mousePos :Point = new Point(bloc.equipements.mouseX, bloc.equipements.mouseY);
			var p:Point = mousePos;
			
			if (_equipementView)
			{
				//_equipementView.draw();
				_equipementView.x = p.x;
				_equipementView.y = p.y;
				if (type === "TelephoneItem") {
					_equipementView.setConnexion("telephone");
				} else if (type === "LivephoneItem") {
					_equipementView.setConnexion("usb");
				} /*else if (type === "TabletteItem") {
					_equipementView.setConnexion("wifi");
				} else if (type === "SmartphoneItem") {
					_equipementView.setConnexion("wifi");
				}*/
				new AddEquipementCommand(bloc, _equipementView).run();
				var menu:MenuRenderer = MenuFactory.createMenu(_equipementView, EditorContainer.instance);
				//_newEquipement = _equipementView;
				_equipementView = null;
			}
		}
		
		private function _shouldAskPossession(type:String):Boolean
		{
			if (type == "LiveboxItem") {
				if (appmodel.clientvo.id_livebox == 2 || appmodel.clientvo.id_livebox == 3 || appmodel.clientvo.id_livebox == 4) {
					return false;
				}
				else {
					return true;
				}
			} else if (type == "DecodeurItem") {
				if (appmodel.clientvo.id_decodeur == 2 || appmodel.clientvo.id_decodeur == 3 || appmodel.clientvo.id_decodeur == 4) {
					return false;
				}
				else {
					return true;
				}
			} else {
				if(type == "MainDoorItem") return false
				else return true;
			}
		}
		
		override protected function isOverBloc():Bloc
		{
			var p:Point = GeomUtils.localToLocal(new Point(mouseX, mouseY), this, Main.instance);
			var i:int;
			var blocs:Array; 
			var bloc:Bloc;
			if (_model.currentBlocMaison == null) return null;
			if (_model.currentMaisonPieces == null) return null;
			
			blocs = _model.currentMaisonPieces.piecesArr;
			for (i = blocs.length-1; i >=0 ; i--)
			{
				bloc = blocs[i];
				
				if (bloc.hitTestPoint(p.x, p.y, true))
				{
					//trace("DraggableItem::isOver ", bloc.type);
				    return bloc;
				}
			}
			
			blocs = _model.currentFloor.blocs;
			for (i = 0; i < blocs.length ; i++)
			{
				bloc = blocs[i];
				
				if (bloc.hitTestPoint(p.x, p.y, true))
				{
					//trace("DraggableItem::isOver ", bloc.type);
				    return bloc;
				}
			}
			return null;
		}
		
		override protected function _removed(e:Event):void
		{
			//trace("EquipementItem::_removed");
			//appmodel.removeUpdateEquipementListener(_onUpdateEquipement);
			super._removed(e);
		}
	}

}