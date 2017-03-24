package classes.views 
{
	import classes.config.Config;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.views.plan.Echelle;
	import classes.views.plan.EditorContainer;
	import classes.views.plan.EditorZoom;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	/**
	 * Navigator contient l'outil de zoom de l'editeur, les boutons étages et une échelle de mesure du plan
	 */
	public class Navigator extends Sprite 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private static var _self:Navigator;		
		private var _comboContent:Sprite;
		private var _isComboVisible:Boolean = false;
		protected var btnSousSol:BtnEtage;
		protected var btnRDC:BtnEtage;
		protected var btnEtage1:BtnEtage;
		protected var btnEtage2:BtnEtage;
		protected var btnEtage3:BtnEtage;
		protected var gradient:Shape;
		
		public static function get instance():Navigator
		{
			return _self;
		}
		
		public function Navigator() 
		{
			if (_self == null) _self = this;
				
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
			
			//trace("Navigator::added");
			
			var echelle:Echelle = new Echelle();
			addChild(echelle);
			
			var editorZoom:EditorZoom = new EditorZoom(echelle);
			addChild(editorZoom);
			
			btnSousSol = new BtnEtage(AppLabels.getString("editor_levelbelow"), -1);
			addChild(btnSousSol);
			btnSousSol.x = Config.TOOLBAR_WIDTH + 10;
			btnSousSol.y = 0//- btnSousSol.height;
			
			btnRDC = new BtnEtage(AppLabels.getString("editor_level0"), 0, BtnEtage.STATE_SELECTED );
			addChild(btnRDC);
			btnRDC.x = btnSousSol.x + btnSousSol.width +2;
			btnRDC.y = btnSousSol.y;
			btnRDC.floor = _model.currentFloor;
			
			btnEtage1 = new BtnEtage(AppLabels.getString("editor_level1"), 1);
			addChild(btnEtage1);
			btnEtage1.x = btnRDC.x + btnRDC.width +2;
			btnEtage1.y = btnRDC.y;
			
			btnEtage2 = new BtnEtage(AppLabels.getString("editor_level2"), 2);
			addChild(btnEtage2);
			btnEtage2.x = btnEtage1.x + btnEtage1.width +2;
			btnEtage2.y = btnEtage1.y;
			
			btnEtage3 = new BtnEtage(AppLabels.getString("editor_level3"), 3);
			addChild(btnEtage3);
			btnEtage3.x = btnEtage2.x + btnEtage2.width +2;
			btnEtage3.y = btnEtage2.y;
			
			updateGradient();
		}
		
		public function updateGradient():void
		{
			if(gradient == null) gradient = new Shape();
			/*if (gradient.stage == null) */addChild(gradient);
			
			var g:Graphics = gradient.graphics;
			g.clear();
			g.lineStyle();  
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xffffff, 0xffffff];
			var alphas:Array = [.69, 0];
			var ratios:Array = [0, 255];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(15, 10, Math.PI / 2, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
			g.drawRoundRectComplex(Config.TOOLBAR_WIDTH, 0, EditorContainer.instance.maskWidth, 10, 10, 10, 0, 0);
		}
		
		private function _removed(e:Event):void
		{
			//trace("Navigator::_removed");
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
	}
}