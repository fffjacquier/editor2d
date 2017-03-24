package classes.views.accordion 
{
	import classes.config.Config;
	import classes.controls.CurrentStepUpdateEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.AppUtils;
	import classes.views.Toolbar;
	import classes.vo.AccordionItemVO;
	import classes.vo.AccordionVO;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	public class Accordion extends Sprite 
	{
		public static var OPEN_ITEM_HEIGHT:int = 365;//275;
		public static var WIDTH:int = Config.TOOLBAR_WIDTH;
		public static var CLOSED_ITEM_HEIGHT:int = 24;
		
		private var _itemsContainer:Sprite;
		private var vo:AccordionVO;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		public var selectedItem:AccordionItem;
		
		private static var _instance:Accordion;
		public static function get instance():Accordion
		{
			return _instance;
		}
		
		public function Accordion()
		{
			if (_instance == null) {
				_instance = this;
				
				addEventListener(Event.ADDED_TO_STAGE, _added);
			}
		}
		
		private function _added(e:Event = null):void
		{
			trace("Accordion::_added", _instance);
			
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
		
			_itemsContainer = new Sprite();		
			addChild(_itemsContainer);
			
			_addAccordion();
		}
		
		private function _addAccordion(e:Event=null):void
		{
			update();
			
			/*if (_model.isDrawStep)*/ _appmodel.currentStep = 0;
			
			to(0);
			_appmodel.addCurrentStepUpdateListener(_onCurrentStepUpdate);
		}
		
		public function update():void
		{
			this.vo = new AccordionVO();
			cleanup();
			_appmodel.steps = vo.items;
			for  (var i:int = 0; i < vo.items.length; i++)
			{
				var itemVO:AccordionItemVO = vo.items[i] as AccordionItemVO;
			 	var accordionItem:AccordionItemDecorator = new AccordionItemDecorator(itemVO, i);
			 	_itemsContainer.addChild(accordionItem);
			}
			adapt();
		}
		
		public function to(i:int):void
		{
			if (i >= _itemsContainer.numChildren) return;
			
			var accordionItem:AccordionItemDecorator = _itemsContainer.getChildAt(i) as AccordionItemDecorator;
			if(i == ApplicationModel.STEP_FIBER && AccordionFiberArrival.instance) AccordionFiberArrival.instance.openLiveBoxFloor();
			setTimeout(accordionItem.open, 100, true);
		}
		
		public function adapt(/*e:Event = null*/):void
		{
			var a:AccordionItemDecorator = _itemsContainer.getChildAt(0) as AccordionItemDecorator;
			a.y = 4;
			for (var i:int = 1; i < _itemsContainer.numChildren; i++)
			{
			 	var accordionItem:AccordionItemDecorator = _itemsContainer.getChildAt(i) as AccordionItemDecorator;
			 	var prevItem:AccordionItemDecorator = _itemsContainer.getChildAt(i-1) as AccordionItemDecorator;
			 	accordionItem.y = prevItem.y + prevItem.bg_height + 4;	
			}
			var g:Graphics = _itemsContainer.graphics;
			g.clear()
			g.lineStyle();
			g.beginFill(0, .3);
			var the_height:Number = (_itemsContainer.numChildren == 1) ? _itemsContainer.height + 30 : _itemsContainer.height + 10;
			g.drawRoundRect( -5, 0, 251, the_height, 15);
			g.endFill();
		}
		
		public function drawBG():void
		{
			var g:Graphics = _itemsContainer.graphics;
			g.clear()
			g.lineStyle();
			g.beginFill(0, .3);
			var h:int;
			for (var i:int = 0; i < _itemsContainer.numChildren; i++)
			{
			 	var accordionItem:AccordionItemDecorator = _itemsContainer.getChildAt(i) as AccordionItemDecorator;
				h += accordionItem.effective_height;
				//trace(i, accordionItem.effective_height);
			}
			//trace(h);
			g.drawRoundRect( -5, 0, 251, h + 10, 15);
			//trace("adapt", _appmodel.currentStep, _itemsContainer.height);
			g.endFill();
		}
		
		public function closeSelected():void
		{
			if(!selectedItem) return;
			selectedItem.close();
		}
		
		public function cleanup():void
		{
			//trace("Accordion::cleanup");
			while (_itemsContainer.numChildren >0)
			{
				var accordionItem:AccordionItemDecorator = _itemsContainer.getChildAt(0) as AccordionItemDecorator;
				accordionItem.cleanup();
				_itemsContainer.removeChild(accordionItem);
			}
		}
		
		private function _onCurrentStepUpdate(e:CurrentStepUpdateEvent):void
		{
			//AppUtils.TRACE("Accordion::_onCurrentStepUpdate()"+ e.step);
			//trace("Accordion::_onCurrentStepUpdate()"+ e.step);
			to(e.step);
		}
		
		private function _removed(e:Event):void
		{
			//trace("Accordion::_removed");
			_appmodel.removeCurrentStepUpdateListener(_onCurrentStepUpdate);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
			_instance = null;
			_appmodel.currentStep = -1;
		}
	}

}