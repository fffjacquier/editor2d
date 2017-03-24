package classes.views.accordion 
{
	import classes.commands.SaveCommand;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.services.GetEquipementsXML;
	import classes.utils.AppUtils;
	import classes.views.CommonTextField;
	import classes.views.items.EquipementItem;
	import classes.vo.EquipementVO;
	import fl.containers.ScrollPane;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class AccordionItemEquipments extends MovieClip
	{
		private var _scrollpane:ScrollPane;
		private var container:Sprite;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function AccordionItemEquipments() 
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
			g.drawRoundRectComplex(0, 36, 241, 258, 0, 0, 5, 5); 
			g.endFill();
			
			var icon:IconGlissezDeposez = new IconGlissezDeposez();
			icon.d.htmlText = "<b>" + AppLabels.getString("accordion_dragDrop");
			addChild(icon);
			icon.x = 115;
			icon.y = -15;
			
			new GetEquipementsXML("Equipements", _createItems);
			//_createItems(_appmodel.VOs.equipements.children());
		}
		
		private function _createItems(e:XMLList):void
		{
			container = new Sprite();
			addChild(container);
			
			var i:int = -1;
			for each (var equipement:XML in e)
			{
				trace(equipement.screenLabel, String(equipement.@type), String(equipement.name), String(equipement.classz), _appmodel.projectType, (String(equipement.@type).indexOf(_appmodel.projectType.substr(0, 4))), String(equipement.name).indexOf(_appmodel.selectedLivebox));
				if (equipement.@type == undefined 
					|| (equipement.@type != undefined && (String(equipement.@type).indexOf(_appmodel.projectType + ",") != -1) && equipement.classz != "LiveboxItem")
					|| (equipement.@type != undefined && (String(equipement.@type).indexOf(_appmodel.projectType + ",") != -1) && equipement.classz == "LiveboxItem") && String(equipement.name).indexOf(_appmodel.selectedLivebox) != -1)
				{
					i++;
					/*var modes:XMLList = equipement.modeDeConnexion.mode;
					var m:Array = [];
					for each(var labelMode:String in modes)
					{
						//trace(labelMode.toLowerCase());
						m.push(labelMode.toLowerCase());
					}*/
					var vo:EquipementVO = new EquipementVO();
					vo.imagePath = equipement.thumbImage;
					vo.id = parseInt(equipement.id);
					if(equipement.modeDeConnexion != undefined) vo.modesDeConnexionPossibles = equipement.modeDeConnexion.split(",");
					vo.screenLabel = equipement.screenLabel;
					vo.name = equipement.name;
					vo.max = parseInt(equipement.max);
					vo.type = equipement.classz.toString();
					vo.infos = equipement.infos;
					vo.diaporama360 = equipement.diaporama360;
					vo.linkArticleShop = equipement.linkArticleShop;
					vo.nbPortsEthernet = parseInt(equipement.data.nbPortsEthernet);
					vo.isOrange = equipement.isOrange;
					vo.isConnector = AppUtils.stringToBoolean(e.isConnector);
					vo.isTerminal = AppUtils.stringToBoolean(e.isTerminal);
				
					_addEquipementItem(i, equipement.classz, vo);
				}
			}
			
			// add scrollbar if needed
			if (this.height > 254) 
			{
				_scrollpane = new ScrollPane();
				addChild(_scrollpane);
				_scrollpane.setSize(235, 256);
				_scrollpane.source = container;
				_scrollpane.x = 3;
				_scrollpane.y = 8;
			}
			//trace("AccordionEquipementsItem::height", this.height, _scrollpane.height);
			
			(parent as ContentItem).effectiveHeight = 55 + _scrollpane.y + _scrollpane.height;
			
			if(Accordion.instance != null) Accordion.instance.drawBG();
		}
		
		private function _addEquipementItem(i:int, classz:String, vo:EquipementVO):void
		{
			var instance:EquipementItem = new EquipementItem(i, classz, vo);
			container.addChild(instance);
			//check ownership of equipement from clientvo
			/*trace(_appmodel.clientvo.id_livebox);
			trace(_appmodel.clientvo.id_decodeur);*/
			// special case: treat all the liveboxes cases, despite the fact they are not in the xml
			if (classz === "LiveboxItem" && (_appmodel.clientvo.id_livebox == vo.id/* || _appmodel.clientvo.id_livebox == 2 || _appmodel.clientvo.id_livebox == 3*/) ) {
				instance.isOwned = true;
			}
			// here we treat the special case the id decodeur 3 or 4 (usd86 and usd87), which are not in the xml (for the dec usd86)
			if (classz === "DecodeurItem" && (_appmodel.clientvo.id_decodeur == vo.id || _appmodel.clientvo.id_decodeur == 3)) {
				instance.isOwned = true;
			}
			if (i == 0) {
				instance.x = 7 + Math.round(i % 2) * (95 + 7);
				instance.y = 2 + Math.floor(i / 2) * (83 + 3);
			} else {
				//if (/*i == 0*/classz === "LiveboxItem") {
					instance.x = 7 + Math.round((i+1) % 2) * (95 + 7);
					instance.y = 2 + Math.floor((i+1) / 2) * (83 + 3);
				/*} else {
					instance.x = 7 + Math.round((i+2) % 2) * (95 + 7);
					instance.y = 2 + Math.floor((i+2) / 2) * (83 + 3);
				}*/
			}
			if (/*_appmodel.projectType == "fibre" && */classz === "LiveboxItem") 
			{
				var t:CommonTextField = new CommonTextField("helvet", 0x333333, 11);
				t.autoSize = "left";
				t.width = 111;
				t.x = 110;
				t.y = instance.y -1; 
				t.setText(vo.infos);
				container.addChild(t);
			}
		}
		
		private function clickHandler(e:MouseEvent):void
		{
			//trace("clickHandler", e.target);
			new SaveCommand().run(_updateAccordion);
		}
		
		private function _updateAccordion():void
		{
			_appmodel.screen = ApplicationModel.SCREEN_RECAP;
		}
		
		private function _removed(e:Event):void
		{
			//if(btnValider) btnValider.removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}

}