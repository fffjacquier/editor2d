package classes.views.alert 
{
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import flash.display.Sprite;
	
	/**
	 * La classe AlertSave permet d'afficher le message de chargement
	 */
	public class AlertSave extends Sprite 
	{
		/**
		 * La classe AlertSave permet d'afficher le message de chargement
		 */
		public function AlertSave(texte:String = null) 
		{	
			if (texte == null) texte = AppLabels.getString("messages_loadingProcess");
			var l:Loading = new Loading();
			addChild(l);
			
			var t:CommonTextField = new CommonTextField("helvetBold");
			t.width = 545;
			
			t.x = l.width + 10;
			//t.y = l.height / 2;
			
			t.setText(texte);
			addChild(t);
		}
		
	}

}