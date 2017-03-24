package classes.views 
{
	import classes.config.Config;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	/**
	 * Classe générique pour la création de boutons.
	 * 
	 * <p>La class <code>Btn</code> permet de créer un bouton avec des fonds transparents, unis ou en dégradés prédéfinis.
	 *  Les couleurs sont modifiables, ainsi que le libellé, les 4 ou 2 bords arrondis et la présence optionnelle d'une icône.</p>
	 * 
	 */
	public class Btn extends MovieClip 
	{
		public static var GRADIENT_ORANGE:Array = [0x983D01, 0xFF6600, 0xFF9900, 0xFFCC00, Config.COLOR_WHITE];
		public static var GRADIENT_DARK:Array = [0x121212, 0x585858, 0x696969, 0x9a9a9a, 0xd0d0d0];
		protected var _h:int = 24;
		protected var _realwidth:int;
		protected var _bgcolor:Number;/*-1 for no bg, any other value else, could be not taken in account if there is a gradient Array value provided*/
		protected var _gradient:Array;
		protected var _icon:MovieClip;
		protected var _textcolor:Number;
		protected var _tf:CommonTextField;
		private var _isBold:Boolean;
		private var _isSpecialRound:Boolean;
		private var _textsize:int;
		private var _str:String;
		private var _w:int;
		
		/**
		 * Permet de créer un nouveau bouton
		 * 
		 * @param	bgcolor la couleur de fond du bouton; valeur -1 : la couleur de fond est transparente (alpha 0);
		 * si le parametre <code>gradient</code> est non null, cette valeur n'est pas prise en compte
		 * @param	texte Le texte du bouton
		 * @param	mc Le MovieClip ou icône qui peut ou non figurer à gauche du texte
		 * @param	largeur La largeur du fond du bouton. A utiliser si on souhaite une taille spécifique; si la taille du texte 
		 * est plus grande que la largeur, c'est la taille du texte <code>texte.textWidth + 10</code> qui est pris en compte.
		 * @param	textcolor La couleur du texte
		 * @param	textsize La taille du texte
		 * @param	hauteur La hauteur du fond du bouton
		 * @param	gradient  Valeur null par défaut; il faut passer un Array de couleurs, le ratio de dégradés et les alphas sont en dur dans le code.
		 * @param 	bold La valeur Booléenne, par défaut égal à true 
		 * @param 	specialRound  Certains boutons sont arrondis des 4 côtés, d'autres que de deux
		 * 
		 * @example L'exemple suivant crée un nouveau <code>Btn</code> avec icône et dégradé
		 * <listing version="3.0">
		 *	var btn:Btn = new Btn(Config.COLOR_ORANGE, AppLabels.getString("buttons_connect"), IconBtnConnect, 188, 0xffffff, 18, 31, Btn.GRADIENT_ORANGE)
		 * 	addChild(btn);
		 *	</listing>
		 */
		public function Btn(bgcolor:Number, texte:String, mc:Class = null, largeur:int = 116, 
							textcolor:Number = 0xffffff, textsize:int = 12, hauteur:int = 24, gradient:Array = null, bold:Boolean = true, specialRound:Boolean = false ) 
		{
			_bgcolor = bgcolor;
			_textcolor = textcolor;
			_gradient = gradient;
			_textsize = textsize;
			_isBold = bold;
			_isSpecialRound = specialRound;
			_str = texte;
			_w = largeur;
			_h = hauteur;
			if (mc != null) {
				_icon = new mc();
			}
			
			addEventListener(Event.ADDED_TO_STAGE, _added, false, 1);
		}
		
		public function disable():void
		{
		}
		
		public function enable():void
		{
		}
		
		public function alterAfter(func:Function):void 
		{
			if (stage) func();
			else {
				addEventListener(Event.ADDED_TO_STAGE, func, false, 0, false);
			}
		}
		
		public function get icon():MovieClip
		{
			return _icon;
		}
		
		public function setText(label:String):void
		{
			_tf.setText(label);
		}
		
		public function get the_text():CommonTextField
		{
			return _tf;
		}
		
		public function changeColor(pColor:int):void
		{
			_bgcolor = pColor;
			_draw();
		}
		
		private function _added(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _added);
			
			_draw();
		}
		
		protected function _draw():void
		{
			//var nextx:int = _drawIcon();
			var nextx:int = 10;
			
			if (_icon != null) {
				addChild(_icon);
				_icon.x = nextx + _icon.width/2;
				nextx += _icon.width + 5;
				_icon.y = _h/2;
			} 
			
			var fontStr:String = _isBold ? "helvetBold" : "helvet";
			if(_tf && _tf.stage) {} else {
				_tf = new CommonTextField(fontStr, _textcolor, _textsize);
				_tf.wordWrap = false;
				_tf.multiline = false;
				_tf.setText(_str);
				addChild(_tf);
				_tf.x = nextx;
			}
			
			var ypos:int;
			if (_h > 24) {
				if (_textsize > 12) {
					ypos = (_h - 22) / 2;
				} else {
					ypos = (_h - _tf.textHeight) / 2;
				}
			}
			else {
				ypos = 3;
			}
			_tf.y = ypos;
			nextx +=  _tf.textWidth + 10;
			if (nextx < _w) {
				nextx = _w;
			}
			// si pas d'icone on centre le texte
			if (_icon == null) _tf.x = (nextx - _tf.width) / 2;
			
			_drawUI(nextx);
			
			_checkListeners();
		}
		
		protected function _drawUI(nextx:int):void
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			if (_gradient == null) {
				if (_bgcolor == -1) g.beginFill(0, 0);
				else g.beginFill(_bgcolor);
			} else {
				var fillType:String = GradientType.LINEAR;
				var colors:Array = _gradient;
				var alphas:Array = [1, 1, 1, 1, 1];
				var ratios:Array = [0, 26, 161, 212, 255];
				var matr:Matrix = new Matrix();
				matr.createGradientBox(nextx, _h, - Math.PI / 2);
				var spreadMethod:String = SpreadMethod.PAD;
				g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod); 
			}
			if (_isSpecialRound) g.drawRoundRectComplex(0, 0, nextx, _h, 8, 8, 0, 0);
			else g.drawRoundRect(0, 0, nextx, _h, 8);
			_realwidth = nextx;
			g.endFill();
		}
		
		protected function _checkListeners():void
		{
			if(!hasEventListener(Event.REMOVED_FROM_STAGE)) _addListeners();
		}
		
		protected function _addListeners():void
		{
			buttonMode = true;
			mouseChildren = false;
			addEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		protected function _removeListeners():void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, _removed);
		}
		
		private function _removed(e:Event):void
		{
			_removeListeners();
		}
	}

}