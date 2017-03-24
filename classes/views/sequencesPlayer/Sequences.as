package classes.views.sequencesPlayer 
{
	import classes.config.Config;
	import classes.services.Load;
	import classes.utils.AppUtils;
	import classes.views.alert.AlertManager;
	import classes.views.alert.AlertSave;
	import classes.views.CommonTextField;
	import classes.vo.VideoVO;
	import fl.transitions.easing.Regular;
	import fl.transitions.Tween;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * FJ / VC
	 */
	public class Sequences extends MovieClip 
	{
		private var _label:String;
		private var _connection:String;
		private var _videosArr:Array;
		private var _loader:Loader;
		
		private var _sequenceCurrent:int;
		private var _sequencesNb:int;
		
		private var _tfTitre1:CommonTextField;
		private var _tfTitre2:CommonTextField;
		private var _posXNavDefaut:Number = 210.5;
		private var _posYNavDefaut:Number = -104;
		private var _espacementYBtns:Number = 5;
		private var _textColorOn:Number = 0xFF6600;
		private var _textColorOff:Number = 0x333333;
		private var _animDurationDefault:Number = 1.5;
		private var _animTypeDefault:String = "easeOutCubic";
		private var _animBtnDuration:Number = 0.5;
		
		public var _mcConteneurSequences:Sprite;
		public var targetedClip:MovieClip;
		public var globalContainer:Sprite;
		
		public function Sequences(videosArr:Array, label:String, connection:String)
		{
			//trace("Sequences constructor", videosArr.length, label, connection);
			
			_label = label;
			_connection = (connection == "null") ? "" : connection;
			_videosArr = videosArr;
			_sequencesNb = _videosArr.length;
			
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			_init();
		}
		
		private function _init():void
		{
			var g:Graphics = graphics;
			g.lineStyle(1, Config.COLOR_LIGHT_GREY);
			g.beginFill(0xffffff);
			g.drawRect( -5, 0, 905, 460);
			
			//-- variable pour le player video, permet de dire qu'on est dans une séquence, pas une anim autonome
			if (GlobalVarContainer.vars.root == undefined)
			{
				GlobalVarContainer.vars.root = this;
			}
			trace("Sequences GlobalVarContainer.vars.root", GlobalVarContainer.vars.root)
			
			//-- Pref du lecteur de sequences
			if (GlobalVarContainer.vars.sequencesAutoplay == undefined)
			{
				GlobalVarContainer.vars.sequencesAutoplay = true;
			}
			
			//FJ GlobalVarContainer.vars.son_sequences ou sequencesSon??
			if (GlobalVarContainer.vars.sequencesSon == undefined)
			{
				GlobalVarContainer.vars.sequencesSon = true;
			}
			
			if (GlobalVarContainer.vars.son_sequences == undefined)
			{
				GlobalVarContainer.vars.son_sequences = true;
			}
			
			
			//-- créer le masque, le container, les deux champs de textes et les boutons séquences
			
			//-- on stocke tout dans un container global
			//-- ca nous permet de garder le code parent.parent.parent.action_next dans les séquences SequenceElt des swf loadés
			//-- bad practice!! ca nous limite bcp d'avoir trois parent mais le changer implique de changer tout le projet as3 MaisonConnectéeInternet, besoin d'un peu de temps
			//-- on pourrait changer avec un Sequences.instance.action_next(), à voir.
			//FJ pbm corrigé avec le enterframe qui gère les enchainements
			
			globalContainer = new Sprite();
			addChild(globalContainer).name = "sequences";
			
			_mcConteneurSequences = new Sprite();
			globalContainer.addChild(_mcConteneurSequences);
			_mcConteneurSequences.x = 2;
			_mcConteneurSequences.y = 10;
			
			var maskk:Sprite = new Sprite()
			g = maskk.graphics;
			g.lineStyle();
			g.beginFill(0);
			g.drawRect(2, 10, 640, 406);
			g.endFill()
			addChild(maskk)
			_mcConteneurSequences.mask = maskk;
			
			_tfTitre1 = new CommonTextField("helvet35", Config.COLOR_DARK, 35);
			_tfTitre1.width = 250;
			_tfTitre1.autoSize = "left";
			addChild(_tfTitre1);
			_tfTitre1.setText(_label);
			_tfTitre1.x = 645;
			//_tfTitre1.y = 0;
			
			_tfTitre2 = new CommonTextField("helvet35", Config.COLOR_LIGHT_GREY, 16);
			_tfTitre2.width = 250;
			_tfTitre2.autoSize = "left";
			addChild(_tfTitre2);
			_tfTitre2.setText(_connection);
			_tfTitre2.x = _tfTitre1.x;
			_tfTitre2.y = _tfTitre1.y + _tfTitre1.height;
			
			_addLabels();
		}
		
		protected function _addLabels():void
		{
			var posX:Number = 650;
			var posY:Number = _tfTitre2.y + 66;
			for (var k:int = 0; k < _sequencesNb; k++) {
				//trace((_videosArr[k] as VideoVO).label);
				var btnSeq:MovieClip = new btn_sequence_e();
				var text_desc:TextField = btnSeq.txt_titre as TextField;
				text_desc.width = 190;
				text_desc.autoSize = TextFieldAutoSize.LEFT;
				text_desc.multiline = true;
				text_desc.wordWrap = true;
				text_desc.text = (_videosArr[k] as VideoVO).label;
				text_desc.textColor = _textColorOff;
				btnSeq.id = k;
				btnSeq.name = "btn_" + String(k);
				//AppUtils.TRACE("btnSeq.name = " + btnSeq.name)
				btnSeq.x = posX;
				btnSeq.y = posY;
				posY += btnSeq.height + _espacementYBtns;
				//btnSeq.x0 = btnSeq.x;
				
				addChild(btnSeq);
				
				//-- Ajout des ecouteurs
				btnSeq.addEventListener(MouseEvent.CLICK, _clicBoutonSeq);
				btnSeq.addEventListener(MouseEvent.MOUSE_OVER, _overBoutonSeq);
				btnSeq.addEventListener(MouseEvent.MOUSE_OUT, _outBoutonSeq);
				btnSeq.mouseChildren = false;
				btnSeq.buttonMode = true;
			}
			
			_loadSequence(_sequenceCurrent);
		}
		
		//-------------------------------------------------
		//-- Actions des boutons des sequences...
		//-------------------------------------------------
		
		private function _clicBoutonSeq(pEvt:MouseEvent):void
		{
			pEvt.currentTarget.enabled = false;
			if (pEvt.currentTarget.id != _sequenceCurrent)
			{
				_loadSequence(pEvt.currentTarget.id);
			}
		}
		
		private function _overBoutonSeq(pEvt:MouseEvent):void
		{
			if (pEvt.currentTarget.id != _sequenceCurrent)
			{
				(pEvt.currentTarget.txt_titre as TextField).textColor = _textColorOn;
				//Tweener.addTween(pEvt.currentTarget, {x: pEvt.currentTarget.x0 + 10, time: _animBtnDuration, transition: _animBtnType});
			}
		}
		
		private function _outBoutonSeq(pEvt:MouseEvent):void
		{
			if (pEvt.currentTarget.id != _sequenceCurrent)
			{
				(pEvt.currentTarget.txt_titre as TextField).textColor = _textColorOff;
				//Tweener.addTween(pEvt.currentTarget, {x: pEvt.currentTarget.x0, time: _animBtnDuration, transition: _animBtnType});
			}
		}
		
		private function _enableButtons():void
		{
			var monBtn:MovieClip;
			for (var i:int = 0; i < _sequencesNb; i++)
			{
				monBtn = getChildByName("btn_" + i) as MovieClip;
				monBtn.enabled = true;
				monBtn.addEventListener(MouseEvent.CLICK, _clicBoutonSeq);
			}
		}
		
		private function _disableButtons():void
		{
			var monBtn:MovieClip;
			for (var i:int = 0; i < _sequencesNb; i++)
			{
				monBtn = getChildByName("btn_" + i) as MovieClip;
				monBtn.enabled = false;
				monBtn.removeEventListener(MouseEvent.CLICK, _clicBoutonSeq);
			}
		}
		
		private function _loadSequence(pIdSeq:int):void
		{
			_sequenceCurrent = pIdSeq;
			//trace("_loadSequence", _sequenceCurrent);
			
			//-- Positionne les boutons
			var monBtn:MovieClip;
			for (var i:int = 0; i < _sequencesNb; i++)
			{
				monBtn = getChildByName("btn_" + i) as MovieClip;
				
				if (i == pIdSeq)
				{
					//AppUtils.TRACE("Sequences::_loadSequence(" + pIdSeq + ") > btn_" + i);
					monBtn.enabled = false;
					monBtn.txt_titre.textColor = _textColorOn;
					//Tweener.addTween(monBtn, {x: monBtn.x0 + 10, time: _animBtnDuration, transition: _animBtnType});
					new Tween(monBtn, "x", Regular.easeInOut, monBtn.x, 660, _animBtnDuration, true);
				}
				else
				{
					monBtn.enabled = true;
					monBtn.txt_titre.textColor = _textColorOff;
					//Tweener.addTween(monBtn, {x: monBtn.x0, time: _animBtnDuration, transition: _animBtnType});
					new Tween(monBtn, "x", Regular.easeInOut, monBtn.x, 650, _animBtnDuration, true);
				}
			}
			
			//-- Empeche le clic sur les boutons tant que video pas loadée
			/*_disableButtons();
			var loading:AlertSave = new AlertSave();
			AlertManager.addSecondPopup(loading, Main.instance);
			AppUtils.appCenter(loading);*/
			
			//-- Cache le conteneur
			//_mcConteneurSequences.alpha = 0;
			
			//-- Supprime les sequences dedans
			_removeChildren();
			
			//-- Affiche le loader
			//_mcLoader.visible = true;
			
			//-- Charge l'objet dans le conteneur
			//new LoadSwf(this, (_videosArr[_sequenceCurrent] as VideoVO).src, _afterLoadAction);
			
			var context:LoaderContext = new LoaderContext();
			//context.parameters = { };
			context.checkPolicyFile = true;
			_loader = new Loader();			
			//_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
			//_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onIOError);
			//_loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, _onError);
			var url:URLRequest = new URLRequest((_videosArr[_sequenceCurrent] as VideoVO).src);
			AppUtils.TRACE("_loadSequence() " + url.url);
			_loader.load(url, context);
			_loader.contentLoaderInfo.addEventListener(Event.INIT, _onLoadInit);
			
			/*if(!_loader.stage) *///_mcConteneurSequences.addChild(_loader);
		}
		
		private function _onError(e:ErrorEvent):void
		{
			AppUtils.TRACE("Sequences::_onError() "+ e);
		}
		
		private function _onIOError(e:IOErrorEvent):void
		{
			AppUtils.TRACE("Sequences::_onIOError() "+ e);
		}
		
		private function _onLoadProgress(e:ProgressEvent):void
		{
			AppUtils.TRACE("Sequences::_onLoadProgress() "+ e);
		}
		
		private function _onLoadInit(e:Event):void
		{
			//_mcConteneurSequences.addEventListener(Event.ENTER_FRAME, _catchFrames);
			var loaderinfo:LoaderInfo = LoaderInfo(e.currentTarget);
			var content:* = loaderinfo.content;
			if(!(content is MovieClip)) return;
			
			var mc:MovieClip = content as MovieClip;
			//mc["initExt"](_context);
			_afterLoadAction(mc);
		}
		
		private function _afterLoadAction(pMc:MovieClip):void
		{
			//trace("_afterLoadAction(" + pMc + ")");
			//_mcLoader.visible = false;
			AppUtils.TRACE("Sequences::_afterLoadAction() _loader " + _loader + " " + _sequenceCurrent);
			targetedClip = pMc;
			_mcConteneurSequences.addChild(pMc);
			
			//-- Reprogramme le clic sur les boutons 
			//_enableButtons();
			//AlertManager.removeSecondPopup();
			
			if (_loader != null) {
				//_loader.unloadAndStop();
				_loader.contentLoaderInfo.removeEventListener(Event.INIT, _onLoadInit);
				//_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
				//_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError);
				//_loader.contentLoaderInfo.removeEventListener(ErrorEvent.ERROR, _onError);
				_loader = null;
			}
			
			//-- Masque le loader
			//_mcLoader.visible = false;
			
			//-- watch frames of loaded swf
			_mcConteneurSequences.addEventListener(Event.ENTER_FRAME, _catchFrames);
		}
		
		private function _catchFrames(e:Event):void
		{
			//AppUtils.TRACE("_catchFrames "+ e.target.getChildAt(0).getChildAt(0).getChildAt(0).name)
			var mc:MovieClip = e.target.getChildAt(0).getChildAt(0) as MovieClip;
			//trace("_catchFrames", mc.currentFrame, mc.totalFrames)
			if (mc.currentFrame >= mc.totalFrames-1) {
				action_next();
			}
		}
		
		//-- Action à lancer à la fin de l'animation swf
		public function action_next():void
		{
			//trace("action_next");
			_mcConteneurSequences.removeEventListener(Event.ENTER_FRAME, _catchFrames);
			_sequenceCurrent++;
			if (_sequenceCurrent < _sequencesNb)
			{
				_loadSequence(_sequenceCurrent);
			} //
		}
		
		private function _removeChildren():void
		{	
			SoundMixer.stopAll();
			
			// stop the current swf
			if (targetedClip != null) {
				(targetedClip.getChildAt(0) as MovieClip).stop();
			}
			
			if (_mcConteneurSequences.hasEventListener(Event.ENTER_FRAME)) {
				_mcConteneurSequences.removeEventListener(Event.ENTER_FRAME, _catchFrames);
			}
			if (_loader) {
				//_mcConteneurSequences.removeChild(_loader);
				_loader.close();
				_loader.unloadAndStop(true);
				_loader.unload();
				_loader.contentLoaderInfo.removeEventListener(Event.INIT, _onLoadInit);
				_loader = null;
			}
			
			//AppUtils.TRACE("_removeChildren _mcConteneurSequences numchildren=" + _mcConteneurSequences.numChildren);
			while (_mcConteneurSequences.numChildren > 0)
			{
				//AppUtils.TRACE("conteneur SUPPRIME objet N°" + _mcConteneurSequences.numChildren + " = " + _mcConteneurSequences.getChildAt(0));
				_mcConteneurSequences.removeChildAt(0);
			}
		}
		
		private function _getNextVideo():String
		{
			return _videosArr[_sequenceCurrent].src;
		}
		
		private function _removed(e:Event):void
		{
			if (_loader) {
				_loader.unloadAndStop();
				//_loader.close();
				_loader.contentLoaderInfo.removeEventListener(Event.INIT, _onLoadInit);
				//_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _onLoadProgress);
				//_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError);
				//_loader.contentLoaderInfo.removeEventListener(ErrorEvent.ERROR, _onError);
				_loader = null;
			}
			SoundMixer.stopAll();
			_removeChildren();
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}

}