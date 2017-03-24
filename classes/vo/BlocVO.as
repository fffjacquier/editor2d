package classes.vo 
{
	import classes.views.plan.BalconyEntity;
	import classes.views.plan.DependanceEntity;
	import classes.views.plan.GardenEntity;
	import classes.views.plan.MainEntity;
	import classes.views.plan.Object2D;
	import classes.views.plan.RoomEntity;
	
	/**
	 * A blocVO has four possible types: 
	 * - Maison
	 * - Dépendance
	 * - Balcon
	 * - Jardin
	 * 
	 */
	public class BlocVO 
	{
		public static const BLOC_MAISON:String = "blocMaison";
		public static const BLOC_DEPENDANCE:String = "blocDependance";
		public static const BLOC_JARDIN:String = "blocJardin";
		public static const BLOC_BALCONY:String = "blocBalcony";
		public static const BLOC_ROOM:String = "blocPiece";
		public static const BLOC_CLOISON:String = "blocCloison";
		
		public var type:String;
		public var obj2D:Object2D;
		
		public function BlocVO() 
		{
		}
		
		public function isMaison():Boolean
		{
			return (obj2D is MainEntity);
		}
		
		public function isDependance():Boolean
		{
			return (obj2D is DependanceEntity);
		}
		
		public function isRoom():Boolean
		{
			return (obj2D is RoomEntity);
		}
		
		public function isBalcony():Boolean
		{
			return (obj2D is BalconyEntity);
		}
		
		public function isGarden():Boolean
		{
			return (obj2D is GardenEntity);
		}
	}
}