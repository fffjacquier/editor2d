package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.AppUtils;
	import classes.views.equipements.EquipementView;
	import classes.views.plan.Editor2D;
	import flash.external.ExternalInterface;
	
	public class SaveCommand extends Command implements ICommand 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		private var _callback:Function;
		private var _shoot:Boolean;
		private var _labelProjet:String;
		
		public function SaveCommand(dontshootetage:Boolean = true, labelProjet:String = "") 
		{
			_shoot = dontshootetage;
			_labelProjet = labelProjet;
			doNotify = false;
			super();
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			//commenté suite à demande EH 29/11/2012
			//history.clearHistory();
			
			_callback = callback;
			
			if (_model.editorVO != null) { 
				_model.editorVO.title = _appmodel.projectLabel;
				_appmodel.projetvo.xml_plan = _model.editorVO.toXML();
			} else {
				_appmodel.projetvo.xml_plan.title = _appmodel.projectLabel;
			}
			
			AppUtils.TRACE("SaveCommand::run() "+_appmodel.projectLabel );
			//trace("SaveCommand::run() "+_appmodel.projectLabel );
			
			_appmodel.projetvo.note_memo = _appmodel.memos;
			_appmodel.projetvo.note_vendeur = _appmodel.notes;
			if (_appmodel.listeDeCourses != null) {
				var courses:String = (_appmodel.listeDeCourses.length === 0) ? "" : "#";
				for (var i:int = 0; i < _appmodel.listeDeCourses.length; i++) {
					var equipement:EquipementView = _appmodel.listeDeCourses[i] as EquipementView;
					var type:String = equipement.vo.type.toLowerCase();
					courses += type.substr(0, type.length -4);
					if (equipement.vo.id) {
						courses += "_"+equipement.vo.id + "#";
					} else {
						courses += "#";
					}
				}
				_appmodel.projetvo.liste_courses = courses;
			} else {
				_appmodel.projetvo.liste_courses = "";
			}
			_appmodel.projetvo.nom = _appmodel.projectLabel;
			
			trace("SaveCommand::run()");
			trace("============================");
			if (_model.editorVO != null) { 
				trace(_model.editorVO.toXML());
				//var r:RegExp = />(\t|\n|\s{2,})</gim;
				//var xmlasStr:String = String(_model.editorVO.toXML()).replace(r, "><");
				//trace("SaveCommand xml2String >", xmlasStr);
			}else {
				trace("_model.editorVO null")
			}
			trace("============================");
			AppUtils.TRACE("SaveCommand nom projet:"+ApplicationModel.instance.projetvo.nom);
			
			if (_shoot && Editor2D.instance) Editor2D.instance.shootEtages(_save);
			else _save();
		}
		
		private function _save():void
		{
			// if in a browser, save with php
			if (ExternalInterface.available) {
				_appmodel.projetvo.saveDb(_callback);
				_appmodel.notifySaveStateUpdate(false);
			}
			else {
				//TEMPORAIRE
				if (_callback != null) _callback();
			}
		}
		
		override public function undo():void 
		{
		}		
	}
}