package classes.views.plan
{
	import classes.config.Config;
	import classes.controls.ZoomEndEvent;
	import classes.controls.ZoomEvent;
	import classes.model.EditorModelLocator;
	import classes.utils.Measure;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	* Grid est la grille de l'éditeur, elle permet une aimantation mathématique et non pas réellement physique des divers objetsdu plan.
	*/
	public class Grid extends Sprite
	{
		private static var _UNSCALED_GAP:Number; // le gap en scale 1 calculé en fonction d'une donnée metrique
		private static var _GAP:Number; // gap scalé  qui sera utlisé par les fonctions de self draw et d'aimantation
		public static const LINE_THICKNESS:Number = .1;
		public static const LINE_ALPHA:Number = .14;//.5;
		public static const LINE_COLOR:Number = 0xffffff;// 0x4C5254;// 0x999999;
		public static var OFF_LIMT:Number;
		public var WIDTH:int;
		public var HEIGHT:int;
		private var _scale:Number = 1;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		private static var _instance:Grid;
		public static function get instance():Grid
		{
			return _instance;
		}
		
		/**
		 * Grid est la grille de l'éditeur, elle permet une aimantation mathématique et non pas réellement physique des divers objets du plan.
		 * <p>C'est un singleton. Les lignes composant la grille sont tracées avec un lineStyle en LineScaleMode.NONE, aussi Grid peut il être rescalé sans déformation des lignes.</p>
		 * <p>Lors du zoom, le paramètre poublic GAP est lui aussi modifié pour donner en temps réel la distance en pixels entre 2 lignes. Cette valeur permet d'aimanter les objets sur la grille grâca aux fonctions 
		 * magnetPoint, magnetPointX et magnetPointY de GeomUtils</p>
		 * 
		 * @see classes.utils.GeomUtils
		 */
		public function Grid()
		{
			_instance = this;
			
			//gap existe uniquement en setter pour donner la veleur en pixel de la grille d'origine
			//GAP lui en getter uniquement valeur utilisée par les divers éléments de l'application
			
			//on initie le gap à 10 cm, ce qui nous settera _gap en pixels par calcul
			UNSCALED_GAP = 10;
			
			if(stage) _onAdded();
			else addEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _onAdded(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			
			_drawGrid();
			_model.addZoomEventListener(_onZoom);
			//_model.addZoomEndEventListener(_onZoomEnd);
		}
		
		public static function get MAGNETISM():Number
		{
			return 1.5;//1.5 is rather strong,  1 is medium, the more the stronger
		}
		
		public static function get GAP():Number
		{
			return _GAP;
		}
		
		public static function get UNSCALED_GAP():Number
		{
			return _UNSCALED_GAP;
		}
		
		public static function set UNSCALED_GAP(measure:Number):void
		{
			_UNSCALED_GAP = Measure.metricToPixel(measure);
			_GAP = _UNSCALED_GAP * EditorModelLocator.instance.currentScale;
		}
		
		private function _onZoomEnd(e:ZoomEndEvent):void
		{
			_scale = _model.currentScale;
			_GAP = _UNSCALED_GAP * _scale;
			//drawGrid();
		}
		
		private function _onZoom(e:ZoomEvent):void
		{
			_scale = _model.currentScale;
			_GAP = _UNSCALED_GAP * _scale;
			
		
			scaleX = _scale;
			scaleY = _scale;
		
			/*
			var n:int = 100//Math.ceil(500 / GAP);
			OFF_LIMT = n * GAP;
			WIDTH = OFF_LIMT * 2 + Config.EDITOR_WIDTH * _scale;
			HEIGHT = OFF_LIMT * 2 + Config.EDITOR_HEIGHT * _scale;
			
			graphics.clear();
			
			//draw Editor graphics  grey  
			var g:Graphics = Editor2D.instance.graphics;
			g.clear();
			g.beginFill(0xaaaaaa, .5);
			g.drawRect( -OFF_LIMT, -OFF_LIMT, WIDTH, HEIGHT);*/
			
		}
		
		private  function _drawGrid():void
		{
			//trace("drawGrid " + GAP);
			var n:int = 400//Math.ceil(500 / GAP);
			OFF_LIMT = n * _UNSCALED_GAP;// GAP;
			WIDTH = OFF_LIMT * 2 + Config.EDITOR_WIDTH//* _scale;
			HEIGHT = OFF_LIMT * 2 + Config.EDITOR_HEIGHT// * _scale;
			
			graphics.clear();
			
			//draw Editor graphics  grey  
			var g:Graphics = graphics;//Editor2D.instance.graphics;
			g.clear();
			g.beginFill(Config.COLOR_GRID_BACKGROUND, .8);
			g.drawRect( -OFF_LIMT, -OFF_LIMT, WIDTH, HEIGHT);
			
			//draw grid
			
			var k:int;
			var iter:int = Math.ceil(WIDTH / GAP);// - 1;
			var pos:Number;
			
			// vertical lines
			for (k =  5; k < iter; k+=5) {
				pos = k * GAP - OFF_LIMT ;
				//graphics.lineStyle( LINE_THICKNESS, k == n ? 0xff0000 : LINE_COLOR, 1, false, LineScaleMode.NONE);
				graphics.lineStyle( LINE_THICKNESS, LINE_COLOR, LINE_ALPHA, false, LineScaleMode.NONE);
				//trace(k + " :vertical: " + n);
				graphics.moveTo(pos, - OFF_LIMT);
				graphics.lineTo(pos, HEIGHT - OFF_LIMT );
			}
			
			iter = Math.ceil(HEIGHT / GAP);// - 1;
			// horizontal lines
			for (k =  5; k < iter; k+=5) {
				pos = k * GAP - OFF_LIMT ;
				//graphics.lineStyle( LINE_THICKNESS, k == n ? 0xff0000 : LINE_COLOR, 1, false, LineScaleMode.NONE);
				//trace(k + " :horizontal: " + n);
				graphics.lineStyle( LINE_THICKNESS, LINE_COLOR, LINE_ALPHA, false, LineScaleMode.NONE);
				graphics.moveTo(- OFF_LIMT, pos);
				graphics.lineTo(WIDTH - OFF_LIMT, pos);
			}
		}
	}
}