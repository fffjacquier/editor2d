package classes.views 
{
	import classes.controls.History;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.services.GetEquipementsXML;
	import classes.views.plan.EditorContainer;
	import classes.views.plan.EditorNav;
	import flash.events.Event;
	
	/**
	 * Classe ScreenEditor affiche le container de l'editeur <code>EditorContainer</code> et la navigation de l'éditeur 
	 * <code>EditorNav</code>
	 * 
	 * @see classes.views.plan.EditorContainer
	 * @see classes.views.plan.EditorNav
	 */
	public class ScreenEditor extends Screen 
	{
		public function ScreenEditor() 
		{
			screen = ApplicationModel.SCREEN_EDITOR;
			super();
		}
		
		override protected function _added(e:Event):void
		{
			super._added(e);
			//loads VOs
			new GetEquipementsXML("All", _init);
		}
		
		private function _init(e:XMLList):void
		{
			var editorContainer:EditorContainer = new EditorContainer();
			addChild(editorContainer);
			
			var nav:EditorNav = new EditorNav();
			addChild(nav);
			
			// notifier l'appli que le bouton enregistrer devient actif
			//ApplicationModel.instance.notifySaveStateUpdate(true);
		}
		
		override protected function cleanup():void
		{
			History.initialized = false;
			EditorModelLocator.instance.reset();
			super.cleanup();
		}
		
	}

}