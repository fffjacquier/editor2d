package classes.views.accordion 
{
	import classes.config.Config;
	import classes.controls.CurrentStepUpdateEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.ObjectUtils;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.EquipementsLayer;
	import classes.views.Toolbar;
	import classes.views.equipements.EquipementView;
	import classes.views.equipements.PriseView;
	import classes.views.items.EquipementItem;
	import classes.views.plan.Editor2D;
	import classes.views.plan.EditorZoom;
	import classes.views.plan.FiberLiner;
	import classes.views.plan.Floor;
	import classes.vo.EquipementVO;
	
	import com.warmforestflash.drawing.DottedLine;
	
	import fl.containers.ScrollPane;
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class AccordionFiberArrival extends MovieClip
	{
		private const _HEIGHT:int = 200;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _scrollpane:ScrollPane;
		private var _container:Sprite;
		
		//public var btnValider:BtnValiderTerminer;
		public var btnDessin:Btn;
		public var btnStopDessin:Btn;
		
		private static var _instance:AccordionFiberArrival;
		public static function get instance():AccordionFiberArrival
		{
			return _instance;
		}
		
		public function AccordionFiberArrival() 
		{
			_instance = this;
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0xe5e5e5);
			g.drawRoundRectComplex(0, 36, 241, _HEIGHT, 0, 0, 5, 5); 
			g.endFill();
			
			//new GetEquipementsXML("Meubles", _createItems);
			_createItemContent();
			_appmodel.addCurrentStepUpdateListener(_onStepUdate);
		}
		
		private function _createItemContent():void
		{
			var xpos:int = 5;
			var ypos:int = 1;
			
			// if no surface or no livebox or no prise 
			if (_model.currentBlocMaison == null || EquipementsLayer.getLivebox() == null || EquipementsLayer.getEquipements(PriseView) == 0) {
				//display a text
				var t:CommonTextField = new CommonTextField("helvet", 0);
				t.width = 180;
				t.setText(AppLabels.getString("accordion_fiberArrivalError"));
				addChild(t);
				t.x = xpos;
				t.y = ypos;
				return;
			}
			
			///////////////////////////////////////////////////
			var blocPorte:Sprite = new Sprite();
			addChild(blocPorte);
			
			t = new CommonTextField("helvet", 0);
			t.width = 234;
			t.setText(AppLabels.getString("accordion_fiberArrivalInfo"));
			blocPorte.addChild(t);
			t.y = ypos;
			t.x = xpos;
			
			var vo:EquipementVO = new EquipementVO();
			vo.max = 3;
			vo.imagePath = "images_x400/porte.png";
			vo.name = "MainDoor";
			vo.infos = AppLabels.getString("accordion_fiberArrivalFact");
			vo.screenLabel = AppLabels.getString("accordion_mainDoor");
			vo.type = "MainDoorItem";
			vo.isOrange = "false";
			vo.diaporama360 = "null";
			vo.linkArticleShop = "null";
			
			var instance:EquipementItem = new EquipementItem(0, vo.type, vo);
			instance.isOwned = true;
			blocPorte.addChild(instance);
			
			var icon:IconGlissezDeposez = new IconGlissezDeposez();
			icon.d.htmlText = "<b>" + AppLabels.getString("accordion_dragDrop");
			blocPorte.addChild(icon);
			icon.x = 110;
			icon.y = instance.y + 20;
			
			t = new CommonTextField("helvet", 0x333333, 11);
			t.autoSize = "left";
			t.width = 111;
			t.x = 112;
			t.y = icon.y + 22;
			t.setText(vo.infos);
			blocPorte.addChild(t);
			
			instance.x = 7// + Math.round(0 % 2) * (95 + 7);
			instance.y = 22// + Math.floor(0 / 2) * (83 + 3);			
			///////////////////////////////////////////////////
			
			t = new CommonTextField("helvet", 0);
			t.width = 234;
			t.setHtmlText(AppLabels.getString("accordion_traceFiberWire"));
			addChild(t);
			t.y = ypos;
			t.x = xpos;
			ypos += t.height;
			
			btnDessin = new Btn(0x333333, "commencer le dessin du tracé", IconCrayon);
			btnDessin.name = "btnDessin";
			addChild(btnDessin);
			btnDessin.x = (Config.TOOLBAR_WIDTH - btnDessin.width-10)/2;
			btnDessin.y = ypos + 5;
			ypos += 45;
			btnDessin.addEventListener(MouseEvent.CLICK, _startDrawing, false, 0, true);
			btnDessin.buttonMode = true;
			
			t = new CommonTextField("helvet", Config.COLOR_DARK, 10);
			t.width = Config.TOOLBAR_WIDTH - 20;
			t.setText("Reliez la Livebox à la prise optique");
			addChild(t);
			t.y = btnDessin.y + btnDessin.height;
			t.x = (Config.TOOLBAR_WIDTH -20 - t.textWidth)/2;
			
			btnStopDessin = new Btn(Config.COLOR_GREY, "terminer le tracé", IconCrayonBarre);//labels["buttons"]["end"]
			addChild(btnStopDessin);
			btnStopDessin.x = (Config.TOOLBAR_WIDTH - btnStopDessin.width)/2;
			btnStopDessin.y = ypos;
			btnStopDessin.buttonMode = false;
			t = new CommonTextField("helvet", Config.COLOR_DARK, 10);
			t.setText("Reposez le crayon");
			addChild(t);
			t.y = btnStopDessin.y + btnStopDessin.height;
			t.x = (Config.TOOLBAR_WIDTH - t.textWidth) / 2;
			
			var line:DottedLine = new DottedLine(231, 1.4, Config.COLOR_GREY, 1, 1.15, 2.30);
			addChild(line);
			line.x = xpos;
			line.y = ypos + 48;
			
			blocPorte.y = t.y + 30;
			
			(parent as ContentItem).effectiveHeight = 55 + _HEIGHT;
			
			Accordion.instance.drawBG();
		}
		
		public function update():void
		{
			while (numChildren > 0) {
				removeChildAt(0);
			}
			_createItemContent();
		}
		
		public function _onStepUdate(e:CurrentStepUpdateEvent):void
		{
			if(e.step == ApplicationModel.STEP_FIBER && !_model.isDrawStep)
			{
				openLiveBoxFloor();
			}
		}
		
		private var _fiberLiner:FiberLiner;
		
		private function _startDrawing(e:MouseEvent):void
		{
			if(_fiberLiner)
			{
				_fiberLiner.stopLiner();
			}
			
			
			//on ouvre la livebox au click ds 'litem de  l'accordéon plutot que dans dessiner
			//if(!FiberLineEntity.instance)
			/*{
				openLiveBoxFloor();
			}*/
			
			if(!_model.currentBlocMaison.fiberLineContainer)
			{
				_model.currentBlocMaison.createFiberLineContainer();
			}
			_fiberLiner = new FiberLiner(_model.currentBlocMaison.fiberLineContainer);
			btnDessin.removeEventListener(MouseEvent.CLICK, _startDrawing);
			btnStopDessin.addEventListener(MouseEvent.CLICK, _stopDrawing, false, 0, true);
			Main.instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, _onClickOnStage);
			btnDessin.buttonMode = false;
			btnStopDessin.buttonMode = true;
		}
		
		private function _stopDrawing(e:MouseEvent=null):void
		{
			Main.instance.stage.removeEventListener(MouseEvent.MOUSE_DOWN, _onClickOnStage);
			if(_fiberLiner) _fiberLiner.stopLiner();
			_fiberLiner = null;
			btnDessin.addEventListener(MouseEvent.CLICK, _startDrawing, false, 0, true);
			btnStopDessin.removeEventListener(MouseEvent.CLICK, _stopDrawing);
			btnDessin.buttonMode = true;
			btnStopDessin.buttonMode = false;
		}
		
		public function openLiveBoxFloor():void
		{
			var livebox:EquipementView =  EquipementsLayer.getLivebox();
			if(!livebox) return;
			var floor:Floor = _model.getFloorById(livebox.floorId);
			if(!floor) return;
			_model.currentFloor = floor;
			// FJ comment 06/07
			//EditorZoom.instance.restoreEditorDefaultPosition();
		}
		
		
		private function _onClickOnStage(e:MouseEvent):void
		{
			if(!ObjectUtils.isChildOf(e.target as DisplayObject, Editor2D.instance)
				|| (ObjectUtils.isChildOf(e.target as DisplayObject, this) 
					&& (e.target == btnDessin)))
			{ 
				_stopDrawing();
			}
		}
		
		public function clear():void
		{
			if(!_fiberLiner) return;
			_fiberLiner.stopLiner();
			_fiberLiner = null;
		}
		
		private function _removed(e:Event):void
		{
			_appmodel.removeCurrentStepUpdateListener(_onStepUdate);
			if (btnDessin) btnDessin.removeEventListener(MouseEvent.CLICK, _startDrawing);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}

}