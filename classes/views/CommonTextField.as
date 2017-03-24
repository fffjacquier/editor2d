package classes.views
{
	import flash.filters.DropShadowFilter;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * Utilitaire pour créer plus rapidement des <code>TextField</code>
	 */
	public class CommonTextField extends TextField
	{
		private var _ft:TextFormat;
		
		/**
		 * La parti pris de ce raccourci est de créer des textes en autoSize "left", multiline, wordWrap,
		 * non selectable, avec la propriété embedFonts égal à true.
		 * 
		 * @param	fontName Le nom de la police que l'on veut utiliser : "helvet" par défaut,
		 * autres choix possibles : "helvet35", "helvet45", "helvetBold", "helvet65"
		 * @param	color La couleur de texte
		 * @param	size La taille du texte
		 * @param	align La méthode d'alignement as3, "left" par défaut
		 * @param	letterSpacing L'espacement entre les lettres, 0 par défaut
		 * @param	leading L'espace entre les lignes, 0 par défaut
		 */
		public function CommonTextField(fontName:String = "helvet", color:int=0xffffff, size:int=12, 
										align:String = "left", letterSpacing:Number=0, leading:int=0)
		{
			super();
			
			autoSize = TextFieldAutoSize.LEFT;
			multiline = true;
			wordWrap = true;
			selectable = false;
			embedFonts = true;
			antiAliasType = AntiAliasType.ADVANCED;
			
			_ft = new TextFormat(fontName);
			_ft.bold = false;
			
			switch (fontName)
			{
				case "helvet35":
					_ft.font = (new Helvet35Thin() as Font).fontName;
					break;
					
				case "helvet45":
					_ft.font = (new Helvet45() as Font).fontName;
					break;
					
				case "helvet":
					_ft.font = (new Helvet55Reg() as Font).fontName;
					//trace("normal", _ft.font);
					break;
				
				case "helvetBold":
					_ft.font = (new Helvet55Bold() as Font).fontName;
					//trace("bold", _ft.font);
					_ft.bold = true;
					break;
					
				case "helvet65":
					_ft.font = (new Helvet55Reg() as Font).fontName;
					break;
				
				case "verdana":
					_ft.font = (new Verdana() as Font).fontName;
					break;
			}
			
			//_ft.font = font.fontName;
			_ft.color = color;
			_ft.size = size;
			_ft.align = align;
			_ft.letterSpacing = letterSpacing;
			_ft.leading = leading;
			
		}
		
		public function setText(str:String):void
		{
			text = str;
			setTextFormat(_ft);
		}
		
		public function setHtmlText(str:String):void
		{
			//embedFonts = true;
			htmlText = str;
			setTextFormat(_ft);
		}
		
		/**
		 * Permet de passer des éléments du texte en gras
		 * 
		 * @param	str La chaîne de caractères pouvant contenir la balise <b> et </b>
		 */
		public function boldify(str:String):void
		{
			var boldStartNum:int = (str.split("<b>")[0] as String).length;
			if(boldStartNum != str.length) str.replace("<b>", "");
			var boldEndNum:int = (str.split("</b>")[0] as String).length -3;
			if(boldStartNum != str.length) str.replace("</b>", "");
			if (boldStartNum < boldEndNum) {
				var boldFormat:TextFormat = cloneFormat();
				boldFormat.font = (new Helvet55Bold() as Font).fontName;
				boldFormat.bold = true;
				setTextFormat(boldFormat, boldStartNum, boldEndNum);
			}
		}
		
		/**
		 * Utilitaire de récupération du TextFormat associé au champ de texte
		 * 
		 * @return Renvoie le TextFormat associé à ce champ de texte
		 */
		public function cloneFormat():TextFormat
		{
			var f:TextFormat = getTextFormat();
			//f.color = 0xffffff;
			return f;
		}
		
		public function xCenter(w:Number):void
		{
			x = Math.round((w - width) / 2);
		}
		
		public function yCenter(h:Number):void
		{
			y = Math.round((h - height) / 2);
		}
		
		/**
		 * Ajoute un Filtre d'ombre <code>DropShadowFilter</code> au <code>CommonTextField</code>
		 * Les paramètres utilisés sont des variations de ceux de la classe DropShadowFilter - hormis la couleur (0 par défaut) qui a été ici omise
		 * 
		 * @param	distance
		 * @param	angle
		 * @param	alpha
		 * @param	blur
		 * @param	strength
		 */
		public function dropShadow(distance:int = 2, angle:int = 45, alpha:Number = .7, blur:int = 2, strength:int = 2 ):void
		{
			var d:DropShadowFilter = new DropShadowFilter(distance,angle,0,alpha,blur,blur,strength);
			filters = [d];
		}
	}
}