package classes.utils
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.views.equipements.*;
	import fl.controls.RadioButton;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	
	public class AppUtils
	{
		public function AppUtils()
		{
		}
		
		public static function TRACE(str:*):void
		{
			if (ExternalInterface.available) {
				ExternalInterface.call("console.log", String(str));
			}
			//trace(String(str));
		}	

		public static function stringToBoolean(str:String):Boolean
		{
			return (str.toLowerCase() == "true" || str.toLowerCase() == "1");
		}
		
		public static function displayDistance(d:Number):String
		{
			var str:String;
			if (d > 0 && d <= 1.5) {
				str = "0" + AppLabels.getString("common_to") + "2" + AppLabels.getString("editor_metersShortcut");
			} else if (d > 1.5 && d <= 2.5) {
				str = Math.floor(d) + AppLabels.getString("common_to") + Math.floor(d+2) + AppLabels.getString("editor_metersShortcut");
			} else if (d > 2.5 && d <= 3.5) {
				str = Math.floor(d) + AppLabels.getString("common_to") + Math.floor(d+2) + AppLabels.getString("editor_metersShortcut");
			} else if (d > 3.5 && d <= 4.5) {
				str = Math.floor(d) + AppLabels.getString("common_to") + Math.floor(d+2) + AppLabels.getString("editor_metersShortcut");
			} else if (d > 4.5 && d <= 5.5) {
				str = Math.floor(d) + AppLabels.getString("common_to") + Math.floor(d+2) + AppLabels.getString("editor_metersShortcut");
			} else if (d > 5.5 && d <= 6.5) {
				str = Math.floor(d) + AppLabels.getString("common_to") + Math.floor(d+2) + AppLabels.getString("editor_metersShortcut");
			} else {
				str = AppLabels.getString("common_beyond") + "7" +AppLabels.getString("editor_metersShortcut");
			}
			return str;
		}
		
		public static function appSetPos(displayObject:DisplayObject, align:String, x:int, y:int=-1000):void
		{
			if(y!= -1000) displayObject.y = y;
			if(align == "center")
			{
				appXCenter(displayObject);
				return;
			}
			if(align == "left")
			{
				displayObject.x = x;
				return;
			}
			if(align == "right")
			{
				displayObject.x = Config.EDITOR_WIDTH - displayObject.width - x;
			}
		}
		
		public static function appCenter(displayObject:DisplayObject):void
		{
			//model.maskSize.width, model.maskSize.height
			/*displayObject.x = (Config.FLASH_WIDTH - displayObject.width) / 2;
			displayObject.y = (Config.FLASH_HEIGHT - displayObject.height) / 2;*/
			displayObject.x = (ApplicationModel.instance.maskSize.width - displayObject.width) / 2;
			/*if (displayObject.x == 0) {
				displayObject.x = (Config.FLASH_WIDTH - displayObject.width) / 2;
			}*/
			displayObject.y = (Config.FLASH_HEIGHT - displayObject.height) / 2;
		}
		
		public static function appXCenter(displayObject:DisplayObject):void
		{
			//var ww:int = EditorContainer.instance.maskWidth;
			displayObject.x = (ApplicationModel.instance.maskSize.width - displayObject.width) / 2;
		}
		
		//centre par rapport à son contenant
		public static function insideXCenter(displayObject:DisplayObject, container:DisplayObject):void
		{
			displayObject.x = (container.width - displayObject.width) / 2;
		}
		
		//centre par rapport à son contenant
		public static function insideYCenter(displayObject:DisplayObject, container:DisplayObject):void
		{
			displayObject.y = (container.height - displayObject.height) / 2;
		}
		
		//centre par rapport à son contenant
		public static function insideCenter(displayObject:DisplayObject, container:DisplayObject):void
		{
			insideXCenter(displayObject, container);
			insideYCenter(displayObject, container);
		}
		
		//centre en x par rapport à un autre displayObject ds le même container
		public static function sideXCenter(displayObject:DisplayObject, referent:DisplayObject):void
		{
			displayObject.x = referent.x + (referent.width - displayObject.width) / 2;
		}
		
		//centre en y par rapport à un autre displayObject ds le même container
		public static function sideYCenter(displayObject:DisplayObject, referent:DisplayObject):void
		{
			displayObject.y = referent.y + (referent.height - displayObject.height) / 2;
		}
		
		//centre par rapport à une largeur
		public static function XCenter(displayObject:DisplayObject, w:int):void
		{
			displayObject.x =(w - displayObject.width) / 2;
		}
		
		//centre par rapport à une largeur
		public static function YCenter(displayObject:DisplayObject, h:int):void
		{
			displayObject.y =(h - displayObject.height) / 2;
		}
		
		/*public static function isInActiveZone(x:Number, y:Number):Boolean
		{
			return Config.EDITOR_ZONE.contains(x, y);
		}*/
		
		/* not used */
		public static function getDefinition(loaderInfo:LoaderInfo, className:String):Class
		{
			return loaderInfo.applicationDomain.getDefinition( className ) as Class;
			
			throw new ReferenceError( "ReferenceError: Error #1065: Variable " + className + " is not defined." );
		}
		
		public static function changeColor(color:int, displayObject:DisplayObject):void
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			displayObject.transform.colorTransform = ct;
		}
		
		// function to transition from one colorTransform to another
		// to be used to twin color's clips or objects with TweenEvent.MOTION_CHANGE
		public static function interpolateColor(start:ColorTransform, end:ColorTransform, t:Number):ColorTransform 
		{
			var result:ColorTransform = new ColorTransform();
			result.redMultiplier = start.redMultiplier + (end.redMultiplier - start.redMultiplier)*t;
			result.greenMultiplier = start.greenMultiplier + (end.greenMultiplier - start.greenMultiplier)*t;
			result.blueMultiplier = start.blueMultiplier + (end.blueMultiplier - start.blueMultiplier)*t;
			result.alphaMultiplier = start.alphaMultiplier + (end.alphaMultiplier - start.alphaMultiplier)*t;
			result.redOffset = start.redOffset + (end.redOffset - start.redOffset)*t;
			result.greenOffset = start.greenOffset + (end.greenOffset - start.greenOffset)*t;
			result.blueOffset = start.blueOffset + (end.blueOffset - start.blueOffset)*t;
			result.alphaOffset = start.alphaOffset + (end.alphaOffset - start.alphaOffset)*t;
			return result;
		}
		
		public static function getClassView(type:String):Class
		{
			var klass:Class;
			if (type == "PriseItem") klass = PriseView;
			else if (type == "LiveboxItem") klass = LiveboxView;
			else if (type == "DecodeurItem") klass = DecodeurView;
			else if (type == "HomeLibraryItem") klass = HomeLibraryView;
			else if (type == "LivephoneItem") klass = LivePhoneView;
			else if (type == "LiveradioItem") klass = LiveradioCubeView;
			else if (type == "ImprimanteItem") klass = ImprimanteView;
			else if (type == "TabletteItem") klass = TabletteView;
			else if (type == "OrdinateurItem") klass = OrdinateurView;
			else if (type == "ConsoleJeuItem") klass = ConsoleJeuView;
			else if (type == "SmartphoneItem") klass = SmartphoneView;
			else if (type == "SqueezeBoxItem") klass = SqueezeBoxView;
			else if (type == "TelephoneItem") klass = TelephoneView;
			else if (type == "LivePlugItem") klass = LiveplugView;
			else if (type == "WifiExtenderItem") klass = WifiExtenderView;
			else if (type == "WifiDuoItem") klass = WifiDuoView;
			else if (type == "TeleItem") klass = TeleView;
			else if (type == "SwitchItem") klass = SwitchView;
			else klass = MainDoorView;
			return klass;
		}
		
		/**
		 * Hack to remove blue stroke on first focus and add the right skin
		 * 
		 * @param	rb le bouton radio ciblé
		 */
		public static function radioButtonHack(rb:RadioButton):void
		{
			rb.setStyle("upIcon", RadioButtonSkinBaseSmall);
			rb.setStyle("overIcon", RadioButtonSkinBaseSmall);
			rb.setStyle("downIcon", RadioButtonSkinSelectedSmall);
			rb.setStyle("disabledIcon", RadioButtonSkinBaseSmall);
			rb.setStyle("selectedUpIcon", RadioButtonSkinSelectedSmall);
			rb.setStyle("selectedOverIcon", RadioButtonSkinSelectedSmall);
			rb.setStyle("selectedDownIcon", RadioButtonSkinSelectedSmall);
			rb.setStyle("selectedDisabledIcon", RadioButtonSkinSelectedSmall);
			rb.setStyle("focusRectSkin", new Sprite());
		}
		
		public static function setButton(rb:RadioButton):void
		{
			rb.buttonMode = true;
			rb.useHandCursor = true;
			rb.mouseChildren = false;
		}
		
		public static  function setVisibleChildrenOf(s:Sprite, bVisible:Boolean):void
		{
			if (s != null) {
				var l:int = s.numChildren;
				for (var i:int = 0; i < l; i++)
				{
					s.getChildAt(i).visible = bVisible;
					//trace("_setVisibleChildrenOf", id, s, s.getChildAt(i), bVisible);
				}
			}
		}
	}
}