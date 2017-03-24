package classes.views.plan 
{
	import classes.model.EditorModelLocator;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	/**
	 * Classe étendant Sprite ajoutée dans les blocs et contenant les cloisons du plan.
	 */
	public class Cloisons extends Sprite 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		public var cloisonsArr:Array = new Array();
		
		
		/**
		 * Classe étendant Sprite ajoutée dans les blocs et contenant les cloisons du plan, CloisonEntity.
		 * <p>Ces classes ont des méthodes permettant d'ajouter ou supprimer des cloisons.</p>
		 */
		public function Cloisons() 
		{
			super();
		}
		
		public function addCloison(cloison:CloisonEntity, murPorteurs:Array=null, coeffMurs:Array = null):void
		{
			addChild(cloison);
			cloisonsArr.push(cloison);
			if (murPorteurs != null && murPorteurs.length > 0) {
				var len:int = murPorteurs.length;
				for (var k:int = 0; k < len; k ++) {
					var index:int = murPorteurs[k];
					(cloison.segmentsArr[index] as Segment).setMurPorteur();
				}
			}
			if (coeffMurs != null && coeffMurs.length > 0) {
				len = coeffMurs.length;
				for (k = 0; k < len; k++) {
					(cloison.segmentsArr[k] as Segment).setMurCoeff(coeffMurs[k]);
				}
			}
		}
		
		public function removeCloison(cloison:CloisonEntity):void
		{
			removeChild(cloison);
			var index:int = cloisonsArr.indexOf(cloison);
			cloisonsArr.splice(index, 1);
		}
		
		public function get bloc():Bloc
		{
			return parent as Bloc;
		}
		
		public function getHitCloison(p:Point, exceptedCloison:CloisonEntity):CloisonEntity
		{
			for (var i:int=0; i < cloisonsArr.length; i++)
			{
				var cloison:CloisonEntity = cloisonsArr[i];
				if ((cloison != exceptedCloison )  && cloison.hitTestPoint(p.x, p.y, true))
				{
					return cloison;
				}
			}
			return null;
		}
		
		/**
		 * Quand les Cloisons restent toujours en position (0,0) dans le bloc. 
		 * quand le bloc se déplace, les points des cloisons se déplacent d'autant.
		 */
		public function moveWidthPiece(dep:Point):void
		{
			for (var i:int=0; i < cloisonsArr.length; i++)
			{
				var cloison:CloisonEntity = cloisonsArr[i];
				cloison.moveWidthPiece(dep);
			}
		}
		
		/**
		 * Glue les points de toutes ses cloisons sur les murs ou angle de la maison ou des pièces qui la contiennent.
		 */
		public function attachPoints():void
		{
			for (var i:int=0; i < cloisonsArr.length; i++)
			{
				var cloison:CloisonEntity = cloisonsArr[i];
				setTimeout(cloison.testAndAttachPoints,100);//2aout
			}
		}
		
	}

}