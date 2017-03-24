package classes.views.accordion 
{
	import classes.commands.SaveCommand;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.services.GetEquipementsXML;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.Info360;
	import classes.views.CommonTextField;
	import classes.views.items.EquipementItem;
	import classes.vo.EquipementVO;
	import fl.containers.ScrollPane;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class AccordionItemPrises extends MovieClip 
	{
		private var container:Sprite;
		private var _scrollpane:ScrollPane;
		private var appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function AccordionItemPrises() 
		{
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
			//g.drawRoundRectComplex(0, 36, 241, 216, 0, 0, 5, 5); 
			g.drawRoundRectComplex(0, 36, 241, 111, 0, 0, 5, 5); 
			g.endFill();
			
			new GetEquipementsXML("Prises", _createItems);
			//_createItems(XMLList(ApplicationModel.instance.VOs.prises.children()));
		}
		
		private function _createItems(e:XMLList):void
		{
			var t:CommonTextField = new CommonTextField("helvet", 0);
			
			if (appmodel.projectType == "fibre") {
				t.width = 234;
				t.setText(AppLabels.getString("accordion_outletSelectONT"));
			} else {
				t.width = 145;
				t.setText(AppLabels.getString("accordion_outletSelectTel"));
			}
			t.y = 6;
			t.x = 5;
			addChild(t);
			
			container = new Sprite();
			addChild(container);
			container.y = 35;
			
			//var liste:XMLList = (e.prise.@type == "fibre");
			
			var i:int = -1;
			var ypos:int;
			for each (var prise:XML in e)
			{
				if (String(prise.@type).substr(0,4) === appmodel.projectType.substr(0,4)) 
				{
					i++;
					//trace(prise.screenLabel, prise.classz, i, prise.thumbImage, prise.@type);
					var vo:EquipementVO = new EquipementVO();
					vo.imagePath = prise.thumbImage;
					vo.name = prise.name;
					vo.screenLabel = prise.screenLabel;
					vo.type = prise.classz;
					vo.infos = prise.infos;
					vo.max = prise.max;
					vo.diaporama360 = prise.diaporama360;
					vo.linkArticleShop = prise.linkArticleShop;
					vo.isOrange = prise.isOrange;
					
					var instance:EquipementItem = new EquipementItem(i, prise.classz, vo);
					container.addChild(instance);
					
					instance.x = 7 + Math.round(i % 2) * (95 + 7);
					instance.y = 2 + Math.floor(i / 2) * (83 + 3);
					if (i == 0) {
						instance.x = 7 + Math.round(i % 2) * (95 + 7);
						instance.y = 2 + Math.floor(i / 2) * (83 + 3);
					} else {
						instance.x = 7 + Math.round((i+1) % 2) * (95 + 7);
						instance.y = 2 + Math.floor((i+1) / 2) * (83 + 3);
					}
					ypos = instance.y + instance.height;
					
					if (appmodel.projectType == "fibre" && i==0) 
					{
						t = new CommonTextField("helvet", 0x333333);
						t.autoSize = "left";
						t.width = 117;
						t.x = 110;
						t.y = container.y -1;
						t.setText(vo.infos);
						addChild(t);
					}
				}
			}
			
			// add scrollbar if needed
			/*if (this.height > 254) 
			{
				_scrollpane = new ScrollPane();
				addChild(_scrollpane);
				_scrollpane.setSize(235, 256);
				_scrollpane.source = container;
				_scrollpane.x = 3;
				_scrollpane.y = 20;
			}*/
			
			var icon:IconGlissezDeposez = new IconGlissezDeposez();
			addChild(icon);
			icon.x = 110;
			icon.y = -20;
			icon.d.htmlText = "<b>" + AppLabels.getString("accordion_dragDrop");
			
			t = new CommonTextField("helvet", 0);
			t.width = 200;
			addChild(t);
			t.setText(AppLabels.getString("accordion_outletRJ45"));
			t.x = 5;
			t.y = container.y + container.height + 5;
			
			var btnI:IconInfo = new IconInfo();
			addChild(btnI);
			btnI.addEventListener(MouseEvent.CLICK, _info, false, 0, true);
			btnI.buttonMode = true;
			btnI.mouseChildren = false;
			btnI.x = t.x + t.textWidth + 10;
			btnI.y = t.y;
			btnI.name = "swf/rj45.swf";
			
			//(parent as ContentItem).effectiveHeight = height
		}
		
		private function _info(e:MouseEvent):void
		{
			trace("_info", e.target.name);
			var diapo:String = e.target.name;
			var popup:Info360 = new Info360(diapo);
			AlertManager.addPopup(popup, Main.instance);
		}
		
		private function clickHandler(e:MouseEvent):void
		{
			var dontshootetage:Boolean = false;
			new SaveCommand(dontshootetage).run(_updateAccordion);
			//_updateAccordion();
		}
		
		private function _updateAccordion(pResult:Object = null):void
		{
			var contentitem:ContentItem = parent as ContentItem;
			var i:int = contentitem.nextid;
			trace("AccordionItemPrises::clickHandler()",  i);
			
			appmodel.currentStep = i//Math.min(appmodel.steps.length -1, nextStep);
		}
		
		private function _removed(e:Event):void
		{
			//if(btnValider && btnValider.stage) btnValider.removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
	}

}