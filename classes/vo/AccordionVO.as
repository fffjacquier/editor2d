package classes.vo 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.views.accordion.AccordionItemEquipments;
	import classes.views.accordion.AccordionItemPrises;
	import classes.views.accordion.AccordionFiberArrival;
	
	public class AccordionVO 
	{
		public var items:Array;/* Array of AccordionItemVO*/
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _editormodel:EditorModelLocator = EditorModelLocator.instance;
		
		public function AccordionVO() 
		{
			//trace("AccordionVO", _editormodel.isDrawStep);
			items = [];
			if (_editormodel.isDrawStep) {
				items.push(new AccordionItemVO(AppLabels.getString("accordion_rooms"), AccordionItemSurface as Class, items.length));
				/*items.push(new AccordionItemVO(AppLabels.getString("accordion_openings"), null, items.length));
				items.push(new AccordionItemVO(AppLabels.getString("accordion_furniture"), null, items.length));
				items.push(new AccordionItemVO(AppLabels.getString("accordion_deco"), null, items.length));*/
			} else {
				items.push(new AccordionItemVO(AppLabels.getString("accordion_outletsTitle"), AccordionItemPrises as Class, items.length));
				items.push(new AccordionItemVO(AppLabels.getString("accordion_equipmentsTitle"), AccordionItemEquipments as Class, items.length));
				if (_appmodel.projectType === "fibre") {
					items.push(new AccordionItemVO(AppLabels.getString("accordion_fiberArrivalTitle"), AccordionFiberArrival as Class, items.length));
				}
			}
		}
		
	}

}