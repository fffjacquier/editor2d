package classes.commands 
{
	
	public interface ICommand 
	{
		function run(callback:Function = null):void;
		function undo():void;
	}
	
}