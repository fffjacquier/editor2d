package classes.views 
{
	import classes.config.Config;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	/**
	 * Extension de la classe Btn qui va gérer l'affichage d'un contour.
	 */
	public class BtnHeader extends Btn 
	{
		/**
		 * <p>Voir la classe <code>Btn</code> pour tous les détails</p>
		 * 
		 * @param	bgcolor
		 * @param	texte
		 * @param	mc
		 * @param	largeur
		 * @param	textcolor
		 * @param	textsize
		 * @param	hauteur
		 * @param	gradient
		 * @param	bold
		 * @param	specialRound
		 */
		public function BtnHeader(bgcolor:Number, texte:String, mc:Class = null, largeur:int = 116, 
							textcolor:Number = 0xffffff, textsize:int = 12, hauteur:int = 24, gradient:Array = null, bold:Boolean = true, specialRound:Boolean = false ) 
		{
			super(bgcolor, texte, mc, largeur, textcolor, textsize, hauteur, gradient, bold, specialRound);
		}
		
		override public function disable():void
		{
			removeEventListener(MouseEvent.ROLL_OVER, _over);
			removeEventListener(MouseEvent.ROLL_OUT, _out);
			enabled = false;
			alpha = .5;
		}
		
		override public function enable():void
		{
			if (!hasEventListener(MouseEvent.ROLL_OVER)) {
				addEventListener(MouseEvent.ROLL_OVER, _over);
				addEventListener(MouseEvent.ROLL_OUT, _out);
			}
			enabled = true;
			alpha = 1;
		}
		
		override protected function _drawUI(nextx:int):void
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1.5, Config.COLOR_WHITE, 0.25);			
			if (_bgcolor == -1) g.beginFill(0, 0);
			else g.beginFill(_bgcolor);
			g.drawRoundRect(0, 0, nextx, _h, 8);
			
			_realwidth = nextx;
			g.endFill();
		}
		
		override protected function _addListeners():void
		{
			super._addListeners();
			
			// ajoute comportements de survol
			addEventListener(MouseEvent.ROLL_OVER, _over);
			addEventListener(MouseEvent.ROLL_OUT, _out);
		}
		
		override protected function _removeListeners():void
		{
			super._removeListeners();
			
			// enleve comportements de survol
			removeEventListener(MouseEvent.ROLL_OVER, _over);
			removeEventListener(MouseEvent.ROLL_OUT, _out);
		}
		
		private function _over(e:MouseEvent):void
		{
			changeColor(Config.COLOR_ORANGE);
		}
		
		private function _out(e:MouseEvent):void
		{
			changeColor( -1);
		}
		
	}

}