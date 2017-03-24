package classes.vo 
{
	import classes.config.Config;
	import classes.views.plan.Grid;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	public class Shapes
	{
		private static var _self:Shapes;
		
		public static function get instance() : Shapes 
		{
			if ( _self == null ) _self = new Shapes () ;        		
			return _self ;
		}
		
		public var blocsMaison:Dictionary;
		public var cloisons:Dictionary;
		public var dependances:Dictionary;
		public var balconerys:Dictionary;
		public var jardins:Dictionary;
		public var pieces:Dictionary;
		
		public function Shapes() 
		{
			
		}
		
		public function update(longueur:Number=NaN, largeur:Number=NaN):void
		{
			var shape:ShapeVO;
			var i:int;
			
			//-----------blocs maison -------------
			
			blocsMaison = new Dictionary(false);
			i = -1;
			/*
			w500cm = 285.74999640000004 pixels
			300cm = 157.4803169446339 px
			*/
			var w:Number;
			var h:Number;
			
			//GAP taille pixels équivalente à  10 cm assigné en dur dans Grid
			//m mesure pixel equivalente à un mètre
			var m:Number = Grid.GAP * 10;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = IconDefaultShape;
			
			//var p:Point = new Point();
			
			var p:Point = new Point(m * 2, m * .5);
			//w = Measure.metricToPixel(500);
			//h = Measure.metricToPixel(300);
			longueur = Math.min(longueur, Config.LIMIT_LONG_SURFACE);
			largeur = Math.min(largeur, Config.LIMIT_LARG_SURFACE);
			
			if (isNaN(longueur)) w = 8 * m;
			else w = longueur * m;
			if (isNaN(largeur)) h = 5 * m;
			else h = largeur * m;
			shape.points = [p, new Point(p.x + w, p.y), new Point(p.x + w, p.y + h), new Point(p.x, p.y +h)];
			blocsMaison[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = IconSurfaceLShape;
			//p = new Point(m * 2, m);
			/*w = 8 * m;
			h = 6 * m;*/
			shape.points = [p, new Point(p.x + w/2, p.y), new Point(p.x + w/2, p.y + h/3), new Point(p.x + w, p.y + h/3), new Point(p.x + w, p.y + h), new Point(p.x, p.y + h)];
			blocsMaison[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconSurfaceLShape2;
			shape.points = [new Point(p.x, p.y + h/3), new Point(p.x + w/2, p.y + h/3), new Point(p.x + w/2, p.y), new Point(p.x + w, p.y), new Point(p.x + w, p.y + h), new Point(p.x, p.y + h)];
			blocsMaison[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconSurfaceLShape3;
			shape.points = [p, new Point(p.x + w, p.y), new Point(p.x + w, p.y + h), new Point(p.x + w/2, p.y + h), new Point(p.x + w/2, p.y + h*2/3), new Point(p.x, p.y + h*2/3)];
			blocsMaison[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconSurfaceLShape4;
			shape.points = [p, new Point(p.x + w, p.y), new Point(p.x + w, p.y + h*2/3), new Point(p.x + w/2, p.y + h*2/3), new Point(p.x + w/2, p.y + h), new Point(p.x, p.y + h)];
			blocsMaison[i] = shape;
			
			/*shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconSurfaceUShape;
			shape.points = [p, new Point(p.x + w/3, p.y), new Point(p.x + w/3, p.y + h/2), new Point(p.x + (w*2/3), p.y + h/2), new Point(p.x + (w*2/3), p.y), new Point(p.x + w, p.y), new Point(p.x + w, p.y + h), new Point(p.x, p.y + h)];
			blocsMaison[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconSurfaceUShape2;
			shape.points = [p, new Point(p.x + w, p.y), new Point(p.x + w, p.y + h), new Point(p.x, p.y + h), new Point(p.x, p.y + (h*2/3)), new Point(p.x + w/2, p.y + (h*2/3)), new Point(p.x + w/2, p.y + (h/3)), new Point(p.x, p.y + (h/3))];
			blocsMaison[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconSurfaceUShape3;
			shape.points = [p, new Point(p.x + w, p.y), new Point(p.x + w, p.y + h), new Point(p.x + (w*2/3), p.y + h), new Point(p.x+ (w*2/3), p.y + (h*2/3)), new Point(p.x + (w/3), p.y + (h*2/3)), new Point(p.x + (w/3), p.y + (h)), new Point(p.x, p.y + (h))];
			blocsMaison[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconSurfaceUShape4;
			shape.points = [p, new Point(p.x + w, p.y), new Point(p.x + w, p.y + h/3), new Point(p.x + w*2/3, p.y + h/3), new Point(p.x + w*2/3, p.y + (h*2/3)), new Point(p.x + w, p.y + (h*2/3)), new Point(p.x + w, p.y + h), new Point(p.x, p.y + h)];
			blocsMaison[i] = shape;*/
			
			//------------ pieces --------------			
			pieces = new Dictionary(false);
			//i = -1;
			i=-1;
			w = m*2;  // 200cm  
			// forme carrée, fermée
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = IconRoom;
			shape.points = [new Point(-w/2, -w/2), new Point(w/2, -w/2), new Point(w/2, w/2), new Point(-w/2, w/2)];
			pieces[i] = shape;
			w = m*2;  // 150cm
			h = m*2;  // 300cm
			// forme en T, fermée (balcons)
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = IconRoom;
			p=new Point(-m, -m);
			//shape.points = [new Point(-w/2, -h/2), new Point(w/2, -h/2), new Point(w/2, h/2), new Point(-w/2, h/2)];//rectangle 
			shape.points = [p, new Point(p.x + w, p.y), new Point(p.x + w, p.y + h*.5), new Point(p.x + w/2, p.y + h*.5), new Point(p.x + w/2, p.y + h), new Point(p.x, p.y + h)];
			
			pieces[i] = shape;
			
			
			//------------ cloisons --------------			
			cloisons = new Dictionary(false);
			i = -1;
			w = m;  // 30cm  
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconCloisonH;
			shape.points = [new Point(-w, 0), new Point(w, 0)];
			cloisons[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconCloisonV;
			shape.points = [new Point(0, -w), new Point(0, w)];
			cloisons[i] = shape;
			
			/*shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconCloisonD;
			shape.points = [new Point(-w, -w), new Point(w, w)];
			cloisons[i] = shape;*/
			
			w = m * 2;
			
			/*shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconCloison3Points;
			shape.points = [new Point(0, w), new Point(0, 0), new Point(w, 0)];
			cloisons[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconCloison3Points;
			shape.points = [new Point(-w, 0), new Point(0, 0), new Point( 0, -w)];
			cloisons[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconCloisonU;
			shape.points = [new Point(-w/2, -w), new Point(-w/2, 0), new Point(w/2, 0), new Point(w/2,-w)];
			cloisons[i] = shape;
			
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = DraggableIconCloisonU2;
			shape.points = [new Point(-w, -w/2), new Point(0, -w/2), new Point(0, w/2), new Point(-w,w/2)];
			cloisons[i] = shape;*/
			
			
			
			//------------ dependance --------------
			dependances = new Dictionary(false);
			i = -1;
			w = m;  //100 cm
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = IconDependance;
			shape.points = [new Point(-w, w), new Point(w, w), new Point(w, -w), new Point(-w, -w)];
			dependances[i] = shape;
			
			//------------ balcon --------------
			balconerys = new Dictionary(false);
			i = -1;
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = IconBalcon;
			shape.points = [new Point(-w, w), new Point(w, w), new Point(w, -w), new Point(-w, -w)];
			balconerys[i] = shape;
			
			//------------ jardin --------------
			jardins = new Dictionary(false);
			i = -1;
			shape = new ShapeVO();
			shape.id = ++i;
			shape.classz = IconJardin;
			shape.points = [new Point(-w, w), new Point(w, w), new Point(w, -w), new Point(-w, -w)];
			jardins[i] = shape;
		}
		
		
	}

}