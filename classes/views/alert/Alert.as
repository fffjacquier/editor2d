package classes.views.alert
{
	import classes.config.Config;
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	import classes.views.CommonTextField;
	import classes.vo.Shapes;
	import com.warmforestflash.drawing.DottedLine;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	/**
	 * Classe de base des popups d'alerte
	 * 
	 * Contient les éléments communs aux popups - fond, titre et bouton fermer
	 */
	public class Alert extends Sprite
	{
		public var bg:Sprite;
		protected var alertText:String;
		protected var color:Number;
		protected var callBack:Function;
		protected var params:Object;
		protected var title:CommonTextField;
		protected var closeButton:BoutonFermerMenus;
		protected var closeBool:Boolean;// used when closing a YesAlert opened above an other Alert
		
		/**
		 * Constructeur d'Alertes
		 * 
		 * @param text Le texte à afficher
		 * @param func La fonction de callback
		 * @param color La couleur de fond du popup
		 * @param params Un objet de paramètres, null par defaut
		 * @param bool Valeur booléenne qui force la valeur de closeBool si deux fenêtres sont ouvertes l'une par dessus l'autre
		 */
		public function Alert(text:String, func:Function = null, color:Number=NaN, params:* =null, bool:Boolean=true)
		{
			super();
			alertText = text.split("*").join(String.fromCharCode(13));			
			callBack = func;
			this.color = isNaN(color) ? Config.ALERT_COLOR_BG : color;
			this.params = params;
			closeBool = bool;

			if (stage) _init();
			else addEventListener(Event.ADDED_TO_STAGE, _init);
		}		
        
		private function _init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, _init);	
			
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			setBackground();
			stage.addEventListener(Event.RESIZE, _onResize);
		}
		
		protected function setBackground():void
		{
			bg = new Sprite();
			draw();		
			addChild(bg);
			
			gradientify();
			
			closeButton = new BoutonFermerMenus();
			closeButton.x = bg.width / 2 - closeButton.width / 2;
			closeButton.y = bg.height - closeButton.height - 20;
			addChild(closeButton);
			
			if(closeBool) x = Config.EDITOR_WIDTH / 2 - width / 2;// + 36;
			if(closeBool) y = Config.EDITOR_HEIGHT / 2  - height / 2 + 6;
			closeButton.addEventListener(MouseEvent.CLICK, close, false, 0, true);
			setTexts();
		}	
		
		protected function draw():void
		{
			var g:Graphics = bg.graphics;
			//g.lineStyle(4, Config.ALERT_COLOR_STROKE);
			g.clear();
			g.lineStyle(1, 0xcccccc, .4);
			//g.beginFill(color);
			g.beginFill(0);
			var c:int = 7;
			g.drawRoundRect(0, 0, Config.ALERT_WIDTH,Config.ALERT_HEIGHT,c);
			g.endFill();
		}
		
		protected function gradientify():void
		{
			var s:Shape = new Shape();
			addChild(s);
			var g:Graphics = s.graphics;
			g.lineStyle();  
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0x8b8b8b, 0x565656, 0x3b3b3b, 0];
			var alphas:Array = [1, 1, 1, 1];
			var ratios:Array = [0, 155, 170, 255];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(10, 15, Math.PI / 2, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			g.drawRoundRect(1, 1, Config.ALERT_WIDTH-1, Config.ALERT_HEIGHT-1, 7);
		}
		
		protected function setTexts(ypos:int=NaN):void
		{
			addDotsLine(ypos);
			
			title = new CommonTextField("helvetBold");	
			//title.dropShadow();			
			title.multiline = true;
			title.wordWrap = true;
			title.width = 318//bg.width - 37;			
			title.setText(alertText);
			title.y = ypos + 9;
			title.x = ( Config.ALERT_WIDTH - title.textWidth ) /2
			addChild(title);
		}	
		
		protected function addDotsLine(posy:int):void
		{
			var s:DottedLine = new DottedLine(315, 1, Config.COLOR_LIGHT_GREY, 1, 1.3, 2);
			addChild(s);
			s.x = (Config.ALERT_WIDTH - 315 )/2;
			s.y = posy;
		}
		
		protected function _onResize(e:Event=null):void
		{
			x = (ApplicationModel.instance.maskSize.width - Config.ALERT_WIDTH) / 2;
			y = (Config.FLASH_HEIGHT - Config.ALERT_HEIGHT) / 2;
		}
		
		protected function close(e:MouseEvent = null):void
		{
			//AlertManager.removePopup();
			AlertManager.removeUpperPopup();
		}		
		
		private function _removed(e:Event):void
		{
			closeButton.removeEventListener(MouseEvent.CLICK, close);
			stage.removeEventListener(Event.RESIZE, _onResize);
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
	}
}