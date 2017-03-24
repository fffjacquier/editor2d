package classes.views 
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.HelpPopup;
	import classes.views.Background;
	import classes.views.CommonTextField;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	/**
	 * La classe ProjectType correspond à l'écart de choix de type de projet pour lequel le user va choisir 
	 * ses équipements
	 * 
	 * <p>4 différents types de projets existent :
	 * <ul>
	 * 		<li>projet de type Fibre</li>
	 * 		<li>projet de type ADSL</li>
	 * 		<li>projet de type ADSL Satellite</li>
	 * 		<li>projet de type ADSL avec deux décodeurs</li>
	 * </ul>
	 * </p>
	 * 
	 * <p> Deux états sont possibles pour cette vue : 
	 * <ul>
	 * 		<li>ouvert, l'utilisateur n'a pas encore choisi de type de projet, et on propose tous les choix en tenant compte 
	 * aussi de ce qu'il a saisi lors de l'inscription comme éligibilité (on coche alors par défaut ce type)</li>
	 * 		<li>fermé, l'utilisateur a dééjà choisi un type de projet, et on l'affiche</li>
	 * </ul>
	 * </p>
	 */
	public class ProjectType extends Sprite
	{
		private var _title:CommonTextField;
		private var _subt:CommonTextField;
		private var st:CommonTextField;
		
		private var _liveboxChoice:LiveboxChoice;
		
		private var xpos:int;
		private var group:RadioButtonGroup;
		private var _selection:String;
		private var myFont:Font; 
 		private var tf1:TextFormat;
 		private var tf2:TextFormat;
 		private var _errTF:CommonTextField;
		private var _btnValid:Btn;
		private var rb1:RadioButton;
		private var rb2:RadioButton;
		private var rb3:RadioButton;
		private var rb4:RadioButton;
		private var d:Dictionary;
		
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function ProjectType() 
		{
			d = new Dictionary(true);
			d["fibre"] = AppLabels.getString("common_fiber");
			d["adsl"] = AppLabels.getString("common_adsl");
			d["adslSat"] = AppLabels.getString("common_adslSat");
			d["adsl2tv"] = AppLabels.getString("common_adsl2Dec");
			
			xpos = 4;
			
			_liveboxChoice = new LiveboxChoice();
			addChild(_liveboxChoice);
			_liveboxChoice.y = 5;
			
			_title = new CommonTextField("helvetBold", Config.COLOR_WHITE, 14);
			_title.width = 220;
			_title.autoSize = "left";
			addChild(_title);
			_title.setText("t");
			_title.x = xpos;
			_title.y = _liveboxChoice.y + _liveboxChoice.height + 15;
			
			_subt = new CommonTextField("helvet", Config.COLOR_LIGHT_GREY);
			_subt.width = 218;
			addChild(_subt);
			_subt.setText("c");
			_subt.x = xpos;
			_subt.y = _title.y + _title.textHeight;
			
			addEventListener(Event.REMOVED_FROM_STAGE, _remove);
			
			myFont = new Helvet55Bold(); 
 			tf1 = new TextFormat();
			tf1.font = myFont.fontName; 
			tf1.bold = true;
			tf1.color = Config.COLOR_WHITE; 
			tf1.size = 12; 
			
 			tf2 = new TextFormat();
			tf2.font = myFont.fontName; 
			tf2.bold = true;
			tf2.color = Config.COLOR_ORANGE; 
			tf2.size = 12;
			//AppUtils.TRACE("ProjectType "+_appmodel.projectType);
			if (_appmodel.projectType == null) {
				_stateOpen();
				
				// afficher aide install
				var popup:HelpPopup = new HelpPopup();
				AlertManager.addPopup(popup, Main.instance);
				popup.x = Background.instance.masq.width/2 - popup.width/2;
			} else {
				_stateClose();
			}
		}
		
		private function _stateOpen():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0, .4);
			
			_title.setText(AppLabels.getString("messages_installType"));
			st = new CommonTextField("helvet", 0xffffff, 10);
			st.width = 220
			st.setText(AppLabels.getString("messages_changingTypeWarning"));
			addChild(st);
			st.x = 4;
			st.y = _title.y + _title.textHeight;
			_subt.setText(AppLabels.getString("common_choose"));			
			_subt.y = st.y + st.textHeight;
			
			var isfibre:Boolean = (_appmodel.clientvo.id_test_eligibilite == 3);
			var isadsl:Boolean = (_appmodel.clientvo.id_test_eligibilite == 5 || _appmodel.clientvo.id_test_eligibilite == 4);
			var isadsl2tv:Boolean = (_appmodel.clientvo.id_test_eligibilite == 6);
			var issat:Boolean = (_appmodel.clientvo.id_test_eligibilite == 7);
			//trace(isfibre, isadsl, isadsl2tv, issat);
			
			// add radio buttons
			group = new RadioButtonGroup("offre");
			group.addEventListener(MouseEvent.CLICK, _clickHandler);
			
			var ypos:int = _subt.y + _subt.height +5;//50;
			//trace(ypos, subt.y + subt.height, subt.y + subt.textHeight);
			var esp:int = 8;
			
			rb1 = new RadioButton();
			rb1.label = d["fibre"];
			rb1.value = "fibre";
			rb1.setStyle("embedFonts", true);
			rb1.setStyle("bold", true);
			rb1.setStyle("textFormat", isfibre ? tf2 : tf1);
			rb1.setSize(200,19);
			addChild(rb1);
			rb1.x = xpos;
			rb1.y = ypos;
			rb1.buttonMode = true;
			ypos = rb1.y + rb1.height + esp;
			rb1.group = group;
			AppUtils.setButton(rb1);
			if (isfibre)
			{
				_setProjectType(rb1.value.toString());
				rb1.selected = true;
			};
			AppUtils.radioButtonHack(rb1);
			
			rb2 = new RadioButton();
			rb2.label = d["adsl"];
			rb2.value = "adsl";
			rb2.setStyle("embedFonts", true);
			rb2.setStyle("bold", true);
			rb2.setStyle("textFormat", isadsl ? tf2 : tf1); 
			rb2.setSize(200,19);
			addChild(rb2);
			rb2.x = xpos;
			rb2.y = ypos;
			ypos = rb2.y + rb2.height +esp;
			rb2.group = group;
			AppUtils.setButton(rb2);
			if (isadsl)
			{
				_setProjectType(rb2.value.toString());
				rb2.selected = true;
			};
			AppUtils.radioButtonHack(rb2);
			
			rb3 = new RadioButton();
			rb3.label = d["adslSat"];
			rb3.value = "adslSat";
			rb3.setStyle("embedFonts", true);
			rb3.setStyle("bold", true);
			rb3.setStyle("textFormat", issat ? tf2 : tf1); 
			rb3.setSize(200,19);
			addChild(rb3);
			rb3.x = xpos;
			rb3.y = ypos;
			ypos = rb3.y + rb3.height +esp;
			rb3.group = group;
			AppUtils.setButton(rb3);
			if (issat){
				_setProjectType(rb3.value.toString());
				rb3.selected = true;
			};
			AppUtils.radioButtonHack(rb3);
			
			rb4 = new RadioButton();
			rb4.label = d["adsl2tv"];
			rb4.value = "adsl2tv";
			rb4.setStyle("embedFonts", true);
			rb4.setStyle("bold", true);
			rb4.setStyle("textFormat", isadsl2tv ? tf2 : tf1); 
			rb4.setSize(225,19);
			addChild(rb4);
			rb4.x = xpos;
			rb4.y = ypos;
			ypos = rb4.y + rb4.height +esp;
			rb4.group = group;
			AppUtils.setButton(rb4);
			if (isadsl2tv)
			{
				_setProjectType(rb4.value.toString());
				rb4.selected = true;
			};
			AppUtils.radioButtonHack(rb4);
			
			_errTF = new CommonTextField("helvetBold", 0xffcc00);
			_errTF.width = 160;
			addChild(_errTF);
			_errTF.x = xpos;
			_errTF.y = ypos;
			
			_btnValid = new Btn(0, AppLabels.getString("buttons_validate"), null, 68, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_ORANGE);
			addChild(_btnValid);
			_btnValid.x = 160;
			_btnValid.y = ypos;
			_btnValid.addEventListener(MouseEvent.CLICK, _onClickStart);
			//addEventListener(Event.ADDED_TO_STAGE, _added);
			
			g.drawRoundRect(0, 0, Config.TOOLBAR_WIDTH -10, 444, 9);
			g.endFill();
			
			Toolbar.instance.position();
		}
		
		private function _cleanStateOpen():void
		{
			_removeButton();
			if (_liveboxChoice && _liveboxChoice.stage) removeChild(_liveboxChoice);
			if (_errTF && _errTF.stage) removeChild(_errTF);
			if (rb1 && rb1.stage) removeChild(rb1);
			if (rb2 && rb2.stage) removeChild(rb2);
			if (rb3 && rb3.stage) removeChild(rb3);
			if (rb4 && rb4.stage) removeChild(rb4);
		}
		
		private function _removeButton():void
		{
			if (_btnValid && _btnValid.stage) {
				_btnValid.removeEventListener(MouseEvent.CLICK, _onClickStart);
				//_btnValid.removeEventListener(MouseEvent.CLICK, _goOpenState);
				removeChild(_btnValid);
			}
		}
		
		private function _stateClose():void
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(0, .4);
			
			_title.setText(d[_appmodel.projectType]+"\n"+AppLabels.getString("messages_with") + _appmodel.selectedLivebox)//AppLabels.getString("messages_installType"));
			if (st && st.stage) removeChild(st);
			_subt.setText(AppLabels.getString("messages_typeChosen2"));
			_subt.y = 5//_title.y + _title.textHeight;
			_title.y = _subt.y + _subt.textHeight + 5;
			
			/*rb1 = new RadioButton();
			rb1.label = d[_appmodel.projectType];
			//rb1.value = _appmodel.projectType;
			rb1.setStyle("embedFonts", true);
			rb1.setStyle("bold", true);
			rb1.setStyle("textFormat", tf1);
			rb1.setSize(200,19);
			addChild(rb1);
			rb1.x = xpos;
			rb1.y = 50;
			rb1.selected = true;
			AppUtils.radioButtonHack(rb1);*/
			
			/*_btnValid = new Btn(0, AppLabels.getString("buttons_modify"), null, 70, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_DARK);
			addChild(_btnValid);
			_btnValid.x = 160;
			_btnValid.y = 45;
			_btnValid.addEventListener(MouseEvent.CLICK, _goOpenState);*/

			g.drawRoundRect(0, 0, Config.TOOLBAR_WIDTH -10, 75, 9);
			g.endFill();
			
			_appmodel.notifyProjectType();
		}
		
		private function _cleanStateClose():void
		{
			_removeButton();
			if (rb1 && rb1.stage) removeChild(rb1);
		}
		
		private function _goOpenState(e:MouseEvent):void
		{
			_cleanStateClose();
			_stateOpen();
		}
		
		/*private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			stage.addEventListener(Event.RESIZE, _onResize);
			_onResize();
		}*/
		
		/*private function _onResize(e:Event = null):void
		{
			x = Background.instance.masq.width / 2 - width / 2;
			y = (Background.instance.masq.height / 2) - height / 2;
			//trace(y, _flvpb.height, Background.instance.masq.height);
		}*/
		
		private function _setProjectType(val:String):void
		{
			_selection = val;
		}
		
		private function _clickHandler(e:MouseEvent):void
		{
			_setProjectType(e.target.selection.value);
			var selectedRadioButton:RadioButton = (e.target.selection as RadioButton);
			
			rb1.setStyle("textFormat", tf1);
			rb2.setStyle("textFormat", tf1);
			rb3.setStyle("textFormat", tf1);
			rb4.setStyle("textFormat", tf1);
			
			selectedRadioButton.setStyle("textFormat", tf2);
			_errTF.setText("");
		}
		
		private function _onClickStart(e:MouseEvent):void
		{
			if (_selection != null) {
				ApplicationModel.instance.projetvo.ref_type_projet = _selection;
				ApplicationModel.instance.projectType = _selection;
				_appmodel.notifyProjectType();
				_cleanStateOpen();
				_stateClose();
			} else {
				_errTF.setText(AppLabels.getString("messages_selectProjectType"));
			}
		}
		
		public function getHeight():int
		{
			if (_appmodel.projectType != null) return 75;
			return 204;
		}
		
		private function _remove(e:Event):void
		{
			//stage.removeEventListener(Event.RESIZE, _onResize);
			if(group) group.removeEventListener(MouseEvent.CLICK, _clickHandler);
			if(_btnValid) _btnValid.removeEventListener(MouseEvent.CLICK, _onClickStart);
			removeEventListener(Event.REMOVED_FROM_STAGE, _remove);
		}
	}

}