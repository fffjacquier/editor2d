package classes.views.synthese 
{
	import classes.config.Config;
	import classes.views.CommonTextField;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	
	public class TabBtn extends Sprite 
	{
		private var _tf:CommonTextField;
		private var _color:Number = 0xe5e5e5;
		private var _colorOrange:Number = Config.COLOR_ORANGE;
		private var _str:String;
		private var _paddingOff:int = 5;
		private var _paddingOn:int = 10;
		private var _bg_h:int = 34 /*la hauteur de la couleur de fond*/
		
		public function TabBtn(label:String) 
		{
			_str = label;
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		public function set text(label:String):void
		{
			_tf.setText(label);
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			_draw();
		}
		
		private function _draw():void
		{
			_tf = new CommonTextField("helvet45", Config.COLOR_WHITE, 20);
			_tf.wordWrap = false;
			_tf.multiline = false;
			_tf.setText(_str);
			addChild(_tf);
			_tf.x = _paddingOff;
			_tf.y = (_bg_h - _tf.textHeight);
			
			deselected();
			
			_addListeners();
		}
		
		public function selected():void
		{
			// change text format
			if (_tf && _tf.stage) removeChild(_tf);
			
			_tf = new CommonTextField("helvet45", (name == "end") ? Config.COLOR_WHITE : Config.COLOR_DARK, 30);
			_tf.wordWrap = false;
			_tf.multiline = false;
			_tf.setText(_str);
			addChild(_tf);
			_tf.x = _paddingOn;
			_tf.y = -8
			
			// change background			
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill((name == "end") ? _colorOrange : _color);
			g.drawRoundRectComplex(0, -12, _tf.width + 2*_paddingOn, _bg_h+12, 8, 8, 0, 0);
			g.endFill();
		}
		public function deselected():void
		{
			var tf:TextFormat = _tf.cloneFormat();
			tf.color = Config.COLOR_WHITE;
			tf.size = 20;
			_tf.setText(_str);
			_tf.setTextFormat(tf);
			_tf.x = _paddingOff;
			_tf.y = 0;
			
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill((name == "end") ? _colorOrange : _color, (name == "end") ? .69 : .2);
			g.drawRoundRectComplex(0, 0, _tf.width + 2*_paddingOff, _bg_h, 8, 8, 0, 0);
			g.endFill();
		}
		
		private function _addListeners():void
		{
			buttonMode = true;
			mouseChildren = false;
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		private function _removeListeners():void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		private function _removed(e:Event):void
		{
			_removeListeners();
		}
		
	}

}