package classes.views.menus 
{
	import classes.commands.CommandParameters;
	import classes.vo.EquipementVO;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * La classe MenuItem contient les informations du menu
	 */
	public class MenuItem 
	{
		public var label:String;
		public var icon:MovieClip;
		public var labelUnique:String;
		public var command:*/*Class or Function*/;
		public var commandParameters:CommandParameters;
		public var vo:EquipementVO;
		public var needInfo:int = 0//Math.random() * 2;
		
		/**
		* Crée une occurence de MenuItem
		* 
		* @param label Label localisé
		* @param icon L'icône qui doit s'afficher à gauche du label
		* @param labelUnique Un label unique pour ce menu
		* @param command La commande à lancer lorsqu'on clique sur ce menu
		*/
		public function MenuItem(label:String, icon:MovieClip=null, labelUnique:String=null, commandClass:*/*Class or Function*/=null, cmdParams:CommandParameters=null) 
		{
			this.label = label;
			this.icon = icon;
			this.labelUnique = labelUnique;
			this.command = commandClass;
			this.commandParameters = cmdParams;
		}
		
	}

}