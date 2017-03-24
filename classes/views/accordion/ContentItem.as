package classes.views.accordion 
{
	import classes.commands.SaveCommand;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.vo.AccordionItemVO;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ContentItem extends MovieClip 
	{
		private static var MAX_HEIGHT:int = Accordion.OPEN_ITEM_HEIGHT;
		private var _accordionItem:AccordionItem;
		private var _itemVO:AccordionItemVO;
		private var item:MovieClip;
		private var appmodel:ApplicationModel = ApplicationModel.instance;
		public var effectiveHeight:int = Accordion.OPEN_ITEM_HEIGHT;
		
		public function ContentItem(accordionItem:AccordionItem, itemVO:AccordionItemVO) 
		{
			super();
			
			_accordionItem = accordionItem;
			_itemVO = itemVO;
			
			//trace("ContentItem:: ", this.classz);
			if (stage) _added();
			else addEventListener(Event.ADDED_TO_STAGE, _added);
			
		}
		
		private function _added(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			if (_itemVO.classz == null) {
				return;
			}
			
			item =  new _itemVO.classz();
			addChild(item);
			
			if (item is AccordionItemSurface) {
				// set variables
				(item as AccordionItemSurface).dd.d.htmlText = "<b>" + AppLabels.getString("accordion_dragDrop");
				(item as AccordionItemSurface).room.htmlText = "<b>" + AppLabels.getString("accordion_room");
				(item as AccordionItemSurface).wall.htmlText = "<b>" + AppLabels.getString("accordion_wallAnd");
				(item as AccordionItemSurface).balcony.htmlText = "<b>" + AppLabels.getString("accordion_balconies");
				(item as AccordionItemSurface).spaces.htmlText = "<b>" + AppLabels.getString("accordion_nameSpaces");
				(item as AccordionItemSurface).the_rect.text = AppLabels.getString("accordion_rectangle");
				(item as AccordionItemSurface).the_free_shape.text = AppLabels.getString("accordion_freeShape");
			}
			if (item is AccordionFiberArrival)
			{
				(item as AccordionFiberArrival).update();
			}
			if (item is AccordionItemEquipments) {
				effectiveHeight = 318;
			}
			if (item is AccordionItemPrises) {
				effectiveHeight = 171;
			}
		}
		
		private function _onClickValider(e:MouseEvent):void
		{
			var dontshootetage:Boolean = false;
			new SaveCommand(dontshootetage).run(_updateAccordion);
		}
		
		private function _updateAccordion(pResult:Object = null):void
		{
			var i:int = nextid;
			
			appmodel.currentStep = i//Math.min(appmodel.steps.length -1, nextStep);
		}
		
		private function _removed(e:Event):void
		{
			//if(_btnValider) _btnValider.removeEventListener(MouseEvent.CLICK, _onClickValider);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		public function get id():int
		{
			return _itemVO.id;
		}
		
		public function get nextid():int
		{
			return _itemVO.id +1;
		}
		
	}

}