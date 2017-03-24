package classes.views.plan 
{
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.views.alert.AlertManager;
	import classes.views.alert.YesNoAlert;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Pieces extends Sprite 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		public var piecesArr:Array = new Array();
		
		public function Pieces() 
		{
		}
		
		public function addBloc(bloc:Bloc, murPorteurs:Array=null, coeffMurs:Array = null):void
		{
			addChild(bloc);
			piecesArr.push(bloc);
			if (murPorteurs != null && murPorteurs.length > 0) {
				var len:int = murPorteurs.length;
				for (var k:int = 0; k < len; k ++) {
					var index:int = murPorteurs[k];
					(bloc.obj2D.segmentsArr[index] as Segment).setMurPorteur();
				}
			}
			if (coeffMurs != null && coeffMurs.length > 0) {
				len = coeffMurs.length;
				for (k = 0; k < len; k++) {
					(bloc.obj2D.segmentsArr[k] as Segment).setMurCoeff(coeffMurs[k]);
				}
			}
		}
		
		public function removeBloc(bloc:Bloc):void
		{
			if (bloc.isPiece && bloc.equipements.numChildren > 0) {
				var s:String = (bloc.equipements.numChildren == 1) ? AppLabels.getString("messages_warningRemoveEquipment") : AppLabels.getString("messages_warningRemoveEquipments");
				var popup:YesNoAlert = new YesNoAlert(AppLabels.getString("messages_warning"), s, _doRemoveBloc, function():void{}, NaN, bloc);
				AlertManager.addPopup(popup, Main.instance);
				//AppUtils.appCenter(popup);
				return;
			}
			
			_doRemoveBloc(bloc);
		}
		
		private function _doRemoveBloc(bloc:Bloc):void
		{
			removeChild(bloc);
			var index:int = piecesArr.indexOf(bloc);
			piecesArr.splice(index, 1);
			// below added on 08/02/2012 11:06 FJ
			// xml not up to date otherwise
			//17juillet le pb est là. la pièce s'enlevait 2 fois. Le bug fixé par les lignes ci-dessous est maintenant fixé dans DeleteSurfacecommand. ligne 37 -> y aller par recherche sur mot clef "17jullet" 
			//index = _model.currentFloor.blocs.indexOf(bloc);
			//_model.currentFloor.blocs.splice(index, 1);
		}
		
		public function get bloc():Bloc
		{
			return parent as Bloc;
		}
		
		public function get mainEntity():MainEntity
		{
			if (!bloc) return null;
			return bloc.obj2D as MainEntity;
		}
		
		public function getHitPiece(p:Point):PieceEntity
		{
			for (var i:int=0; i < piecesArr.length; i++)
			{
				var piece:PieceEntity = piecesArr[i].obj2D;
				if (piece.hitTestPoint(p.x, p.y, true))
				{
					return piece;
				}
			}
			return null;
		}
		
		public function hidePieces():void
		{
			for (var i:int=0; i < piecesArr.length; i++)
			{
				var piece:Bloc = piecesArr[i] as Bloc;
				piece.hideAll();
			}
		}
		
		public function showPieces():void
		{
			for (var i:int=0; i < piecesArr.length; i++)
			{
				var piece:Bloc = piecesArr[i] as Bloc;
				piece.showAll();
			}
		}
		
	}

}