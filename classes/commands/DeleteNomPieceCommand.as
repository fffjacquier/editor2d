package classes.commands 
{
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.views.NomPieceView;
	
	public class DeleteNomPieceCommand extends Command implements ICommand 
	{
		private var _nomPiece:NomPieceView;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		
		public function DeleteNomPieceCommand(nomPiece:NomPieceView) 
		{
			_nomPiece = nomPiece;
		}
		
		/* INTERFACE classes.commands.ICommand */
		
		override public function run(callback:Function = null):void 
		{
			trace("DeleteNomPieceCommand::run()", _nomPiece);
			_model.currentFloor.removeLabel(_nomPiece);
			
			ApplicationModel.instance.notifySaveStateUpdate(true);
			history.pushInHistory(this);
		}
		
		override public function undo():void 
		{
			trace("DeleteNomPieceCommand::undo()", _nomPiece);
			_model.currentFloor.addLabel(_nomPiece);
			
		}
		
	}

}