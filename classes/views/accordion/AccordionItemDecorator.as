package classes.views.accordion 
{
	import classes.commands.SaveCommand;
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.GeomUtils;
	import classes.views.menus.MenuContainer;
	import classes.views.menus.MenuRenderer;
	import classes.views.plan.EditorContainer;
	import classes.views.plan.Floor;
	import classes.views.tooltip.Tooltip;
	import classes.vo.AccordionItemVO;
	import flash.geom.Point;	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Regular;	
	import flash.events.MouseEvent;
	
	public class AccordionItemDecorator extends AccordionItem 
	{
		private var _accordion: Accordion = Accordion.instance;
		private var _contentItem:ContentItem;
		private var _itemVO:AccordionItemVO;
		private var _tweensArr:Array = new Array();
		public var id:int;
		public var nextid:int;
		
		private var _tooltip:Tooltip;
		
		public function AccordionItemDecorator(vo:AccordionItemVO, i:int) 
		{
			super();
			id = i;
			nextid = i + 1;
			_itemVO = vo;
			label.embedFonts = true;
			setText();
			
			/*if(_itemVO.classz == null) {
				// disabled
			} else {*/
				enable();
			/*}*/
		}
		
		public function open(slide:Boolean = true):void
		{
			//trace("AccordionItemDecorator::open()", id, _itemVO.id);
			if (isOpen) return;
			
			_accordion.closeSelected();
			_accordion.selectedItem = this;
			gotoAndStop(2);
			setText();
			
			if (!_contentItem) _contentItem = new ContentItem(this, _itemVO);
			
			//on clique dans arrivée de la fibre, on ouvre l'étage de la livebox
			
			
			if (!_contentItem.stage) {
				addChild(_contentItem);
				if (slide)
				{
					_contentItem.y = 0;
					//TweenMax.to(_contentItem, .4, { y: Accordion.CLOSED_ITEM_HEIGHT } ); 
					// fix for a tween sometimes uncompleted 
					//new Tween(_contentItem, "y", Regular.easeOut, 0, Accordion.CLOSED_ITEM_HEIGHT, .4, true);
					_tweensArr.push(new Tween(_contentItem, "y", Regular.easeOut, 0, Accordion.CLOSED_ITEM_HEIGHT, .4, true));
					(_tweensArr[_tweensArr.length - 1] as Tween).addEventListener(TweenEvent.MOTION_FINISH, _tweenComplete, false, 0, true);
     			}
				else
				{
					_contentItem.y = Accordion.CLOSED_ITEM_HEIGHT;
				}				
			}
			if(Accordion.instance) Accordion.instance.adapt();
			_disable();
		}
		
		private function _tweenComplete(e:TweenEvent):void
		{
			_tweensArr = [];
		}
		
		public function close():void 
		{
			gotoAndStop(1);
			setText();
			
			if (_contentItem && _contentItem.stage) {
				removeChild(_contentItem);
				_contentItem = null;
			}
			_accordion.adapt();
			enable();
		}
		
		public function cleanup():void
		{
			_disable();
		}
		
		public function get isOpen():Boolean
		{
			return (_contentItem && _contentItem.stage);
		}
		
		public function get effective_height():int
		{
			return isOpen ?  _contentItem.effectiveHeight : Accordion.CLOSED_ITEM_HEIGHT;
		}
		
		public function get bg_height():int
		{
			return isOpen ? Math.min(effective_height/*height + 30*/, Accordion.OPEN_ITEM_HEIGHT) : Accordion.CLOSED_ITEM_HEIGHT;
		}
		
		public function enable():void
		{
			if (_itemVO.classz != null) {
				addEventListener(MouseEvent.CLICK, onClick, false, 0, true); 
			} else {
				addEventListener(MouseEvent.ROLL_OVER, _onRoll, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, _onRollOut, false, 0, true);
			}
			
			bg.buttonMode = true;
			if (label) label.mouseEnabled = false;
		}
		
		private function _onRoll(e:MouseEvent):void
		{
			if (EditorContainer.instance == null) return;
			
			_tooltip = new Tooltip(Main.instance, AppLabels.getString("accordion_soon"));
			_tooltip.x = GeomUtils.localToGlobal(new Point(mouseX, mouseY), this).x;
			_tooltip.y = GeomUtils.localToGlobal(new Point(mouseX, mouseY), this).y;
			Main.instance.addChild(_tooltip);
		}
		
		private function _onRollOut(e:MouseEvent):void
		{
			if (_tooltip && _tooltip.stage) _tooltip.remove();
		}
		
		private function onClick(e:MouseEvent):void
		{
			//AppUtils.TRACE("Click accordion " + _itemVO.id);
			//if (_itemVO.classz  == null) return;
			
			var menu:MenuContainer = MenuContainer.instance;
			if (menu && menu.stage) {
				menu.closeMenu();
			}
			
			var dontshootetage:Boolean = false;
			new SaveCommand(dontshootetage).run((_itemVO.classz  == null) ? function():void{} : _saveCallback);
			/*switch (_itemVO.classz)
			{
				case AccordionItemSurface :
					if(EditorModelLocator.instance.currentBlocMaison) EditorModelLocator.instance.currentBlocMaison.unlock();
					break;
				default :
					if(EditorModelLocator.instance.currentBlocMaison) EditorModelLocator.instance.currentBlocMaison.lock();
					break;
			}*/
		}
		
		private function _saveCallback(pResult:Object = null):void
		{
			ApplicationModel.instance.currentStep = _itemVO.id;
			
		}
		
		private function _disable():void
		{
			removeEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function setText():void
		{
			if (label) label.htmlText = "<b>" + _itemVO.label +"</b>";
			//label.mouseEnabled = false;
		}
		
	}

}