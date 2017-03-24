package classes.views.plan 
{
	import classes.config.Config;
	import classes.controls.CurrentScreenUpdateEvent;
	import classes.model.ApplicationModel;
	import classes.views.CommonTextField;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class EditorNavButton extends Sprite 
	{
		private var _label:String;
		private var _icon:MovieClip;
		private var _tf:CommonTextField;
		private var _appmodel:ApplicationModel = ApplicationModel.instance;
		
		public function EditorNavButton(str:String, mc:Class) 
		{
			_label = str;
			_icon = new mc();
			
			_tf = new CommonTextField("helvet", Config.COLOR_WHITE, 12, "left", 0.5);
			_tf.width = 250;
			_tf.autoSize = TextFieldAutoSize.LEFT;
			addChild(_tf);
			
			// manage the bold part of the string
			var boldStartNum:int = (str.split("<b>")[0] as String).length;
			var newstr:String = str.split("<b>")[1];
			var boldEndNum:int = newstr.length;
			_tf.setText(newstr + str.split("<b>")[2]);			
			if (boldStartNum < boldEndNum) {
				var boldFormat:TextFormat = _tf.cloneFormat();
				boldFormat.font = (new Helvet55Bold() as Font).fontName;
				boldFormat.bold = true;
				_tf.setTextFormat(boldFormat, boldStartNum, boldEndNum);
			}
			_tf.width = _tf.textWidth +20;
		
			// add the idol icon
			addChild(_icon);
			
			// position all
			_tf.y = 30;
			_position();
			
			// hitarea zone
			var r:Rectangle = getBounds(this);
			var g:Graphics = graphics;
			g.lineStyle()
			g.beginFill(0, 0);// bg invisible
			//trace(_label, height);
			g.drawRect(0, 0, _tf.textWidth, 48);
			g.endFill();
			
			buttonMode = true;
			mouseChildren = false;
		}
		
		public function changeScaleIcon(newscale:Number):void
		{
			_icon.scaleX = _icon.scaleY = newscale;
			_position();
		}
		
		private function _position():void
		{
			_icon.y = 15;
			// works because icon coords are not starting at 0,0
			_icon.x = (_tf.textWidth) / 2;
		}
	}

}