package classes.views.alert 
{
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	
	/**
	 * La classe AlertSauvegarde affiche le message de sauvegarde pendant la sauvegarde du projet
	 */
	public class AlertSauvegarde extends Sprite 
	{
		/**
		 * Permet d'afficher un message pendant la sauvegarde
		 * 
		 * @param	texte Le texte à afficher
		 */
		public function AlertSauvegarde(texte:String = null) 
		{
			if(texte == null) texte = AppLabels.getString("messages_savingProcess")
			var g:Graphics = graphics;
			g.lineStyle();
			g.beginFill(0xffffff);
			g.drawRoundRect(0, 0, 580, 240, 8);
			
			var t:CommonTextField = new CommonTextField("helvetBold", 0x333333);
			t.width = 545;
			t.x = 20;
			t.y = 190;
			
			t.setText(texte);
			addChild(t);
			
			dropShadow();
		}
		
		public function dropShadow(distance:int = 0, angle:int = 45, alpha:Number = 1, blur:int = 20, strength:Number = .5 ):void
		{
			var d:DropShadowFilter = new DropShadowFilter(distance,angle,0,alpha,blur,blur,strength);
			filters = [d];
		}
		
	}

}