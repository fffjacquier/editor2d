package classes.vo 
{
	/**
	 * les valeurs à connaitre pour intersection entre un equipement (terminal) et un connector 
	 */
	public class IntersectionVO 
	{
		// le nombre de murs traversés
		public var numWalls:int;
		// le nombre de plafonds traversés
		public var numCeilings:int;
		// le nombre de murs porteurs traversés
		public var numBearingWalls:int;
		public var pertes:int;
		
		public function IntersectionVO() 
		{
		}
		
	}

}