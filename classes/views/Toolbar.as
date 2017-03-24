package classes.views 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.AppUtils;
	import classes.views.accordion.Accordion;
	import classes.views.tooltip.Tooltip;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * La classe Toolbar permet d'afficher l'accordion et si on est sur la partie Installez les équipements  
	 * affiche l'encart sur le type de projet <code>ProjectType</code>
	 */
	public class Toolbar extends Sprite 
	{
		private var tooltip:Tooltip;
		private var _accordion:Accordion;
		private var bg:MovieClip;
		private var p:ProjectType;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		private static var _instance:Toolbar;
		public static function get instance():Toolbar
		{
			return _instance;
		}
		
		public function Toolbar() 
		{
			if (_instance == null) _instance = this;
			else throw new Error("error Toolbar");
			if (stage) _added();
			else addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event=null):void
		{
			if(hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			_model.addModeUpdateListener(_onModeUpdate);
			_onModeUpdate();
		}
		
		private function _onModeUpdate(e:Event=null):void
		{
			//AppUtils.TRACE("Toolbar::_onModeUpdate() "+ _model.isDrawStep+" "+ _appmodel.projectType);
			removeAccordion();
			_removeProjectType();
			if (_model.isDrawStep) 
			{
				addAccordion();
			} 
			else {
				_addProjectType();
				if (_appmodel.projectType != null) {
					_appmodel.removeProjectTypeListener(_onProjectType);
					_onProjectType();
				}
			}
		}
		
		public function addAccordion():void
		{
			//trace("Toolbar::addAccordion");
			_accordion = new Accordion();
			_accordion.name = "acc"
			if (_accordion.stage == null) {
				addChild(_accordion);
			} else {
				_accordion.update();
			}
		}
		
		public function removeAccordion():void
		{
			//if (_accordion && _accordion.stage) removeChild(_accordion);
			if (_accordion && _accordion.stage) {
				var toBeRemove:DisplayObject = getChildByName("acc");
				toBeRemove.parent.removeChild(toBeRemove);
			}
		}
		
		private function _addProjectType():void
		{
			p = new ProjectType();
			addChild(p);
			
			_appmodel.addProjectTypeListener(_onProjectType);
		}
		
		private function _removeProjectType():void
		{
			if (p && p.stage) {
				removeChild(p);
				_appmodel.removeProjectTypeListener(_onProjectType);
			}
		}
		
		private function _onProjectType(e:Event=null):void
		{
			AppUtils.TRACE("_onProjectType");
			removeAccordion();
			addAccordion();
			position();
		}
		
		public function position():void
		{
			if (_accordion && _accordion.stage) {
				if (p && p.stage) _accordion.y = p.y + p.getHeight() + 2;
				else {
					_accordion.y = 0;
					_accordion.update();
				}
			}
		}
		
		private function _removed(e:Event):void
		{
			trace("Toolbar::_removed");
			_model.removeModeUpdateListener(_onModeUpdate);
			_appmodel.removeProjectTypeListener(_onProjectType);
			_instance = null;
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}

}