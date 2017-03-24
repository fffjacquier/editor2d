package classes.error 
{
	public class AbstractError extends Error
	{
		
		public function AbstractError(methodName:String='', id:int=0)
		{
			super("abstract method error called:" + methodName, id);
		}
	}

}