package classes.views 
{
	/**
	 * Réutilisation du code Btn pour afficher un btn mais qui sera non cliquable
	 */
	public class BtnDisabled extends Btn 
	{
		
		public function BtnDisabled(bgcolor:Number, texte:String, mc:Class=null, largeur:int=116, textcolor:Number=0xffffff, textsize:int=12, hauteur:int=24, gradient:Array=null, bold:Boolean=true, specialRound:Boolean=false) 
		{
			super(bgcolor, texte, mc, largeur, textcolor, textsize, hauteur, gradient, bold, specialRound);
			enabled = false;
		}
		
		override protected function _checkListeners():void
		{
			enabled = false;
			buttonMode = false;
			mouseChildren = false;
		}
	}

}