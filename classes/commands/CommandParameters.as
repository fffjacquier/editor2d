package classes.commands 
{
	/**
	 * CommandParameters
	 * This class holds parameters for commands
	 */
	public dynamic class CommandParameters 
	{
		public var id:int;
		
		public function CommandParameters(id:int = -1, params:Object=null) 
		{
			this.id = id;
			if (params) {
				for (var attr:String in params) {
					this[attr] = params[attr];
				}
			}
		}
		
		public function get params():Object
		{
			var prm : Object;
			for ( var attr:String in this )
			{
				if (!prm) prm = {}
				prm[attr] = this[attr];
			}
			return prm;
		}	
		
		public function toString():String
		{
			if (params) {
				return params.toString();
			}
			return "no";
		}
	}

}