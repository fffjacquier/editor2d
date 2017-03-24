package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.NomPieceView;
	
	public class AddNomPieceCommand extends Command implements ICommand 
	{
		private var _nomPiece:NomPieceView;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		public function AddNomPieceCommand(nomPiece:NomPieceView) 
		{
			_nomPiece = nomPiece;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("AddNomPieceCommand::run()", _nomPiece);
			_model.currentFloor.addLabel(_nomPiece);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			trace("AddNomPieceCommand::undo()", _nomPiece);
			_model.currentFloor.removeLabel(_nomPiece);
			
		}
		
	}

}