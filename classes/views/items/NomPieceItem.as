package classes.views.items 
{
	import classes.commands.AddNomPieceCommand;
	import classes.utils.GeomUtils;
	import classes.views.NomPieceView;
	import classes.views.plan.Bloc;
	import flash.geom.Point;
	
	public class NomPieceItem extends DraggableItem
	{
		public function NomPieceItem() 
		{
			type = "nom";
			super(0, type);
		}
		
		override protected function executeAction():void
		{
			super.executeAction();
			if (isOverMenu) return;
			
			var bloc:Bloc = isOverBloc();
			
			/*trace("NomPieceItem::_executeAction() BLOC : " + bloc);
			trace("NomPieceItem::_executeAction() type : " + type)*/
			
			var p:Point = GeomUtils.localToEditor(new Point(mouseX, mouseY), this);
			
			var nomPiece:NomPieceView = new NomPieceView();
			nomPiece.x = p.x;
			nomPiece.y = p.y;
			new AddNomPieceCommand(nomPiece).run();
		}
		
	}

}