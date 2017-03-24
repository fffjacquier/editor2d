package classes.views.plan
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.controls.HomeResizeEvent;
	import classes.controls.ZoomEvent;
	import classes.model.EditorModelLocator;
	import classes.utils.GeomUtils;
	import classes.vo.ConnectionVO;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * Classe étendant Sprite, tracé des connexions entre différents équipements.
	 */
	public class ConnectionLine extends Sprite
	{
		
		private var _connection:ConnectionVO;
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _innerLine:Sprite;
		
		/**
		 * <p>Tracé des connexions entre équipements, de design différent selon les types de connection.</p>
		 * <p>Un changement de couleur indique si la connexion est optimale ou non, vert si optimale, orange sinon.</p> 
		 * @param _connection VO renseignant sur la connexion
		 */
		public function ConnectionLine(connection:ConnectionVO)
		{
			super();
			_connection = connection;
		}
		
		public function draw():void
		{
			//trace("connection draw");
			if(!stage)_model.currentConnectionsLayer.addChild(this);
			clearGraphics();
			
			var X:Number = 0;
			var g:Graphics = graphics;
			
			//on check l'intégrité de la connexion et change la couleur en fonction 
			var color:int =  _connection.isAcceptable ? Config.COLOR_GREEN_CONNECT_LINE : Config.COLOR_ORANGE_CONNECT_LINE;
			
			g.clear();
			if(type == ModesDeConnexion.ETHERNET)
			{
				g.lineStyle(2, color);
				g.moveTo(p1.x, p1.y);
				g.lineTo(p2.x, p2.y);
			}
			else if(type == ModesDeConnexion.CPL)
			{
				//tracé d'une sinusoide
				_innerLine = new Sprite();
				addChild(_innerLine);
				_innerLine.x = p1.x;
				_innerLine.y = p1.y;
				g = _innerLine.graphics;
				g.lineStyle(2, color);
				g.moveTo(0,0);			
				while (X <= Point.distance(p1, p2)) 
				{
					g.lineTo(X, Math.sin(X*.7) * 1)
					X+=.1;
				}
				_innerLine.rotation = GeomUtils.getDegreeAngle(p1, p2);
			}
			else if(type == ModesDeConnexion.WIFI)
			{
				//tracé d'une ligne pointillée
				_innerLine = new Sprite();
				addChild(_innerLine);
				_innerLine.x = p1.x;
				_innerLine.y = p1.y;
				g = _innerLine.graphics;
				//g.lineStyle(1, color, 1, false, LineScaleMode.NONE);
				g.beginFill(color);
				while (X <= Point.distance(p1, p2)) 
				{
					//g.moveTo(X,0);
					//g.lineTo(X + 6, 0)
					g.drawRect(X, -2, 6, 2);
					X+=12;
				}
				
				_innerLine.rotation = GeomUtils.getDegreeAngle(p1, p2);
				/*var ratio:Number = 0;
				var p:Point;
				while (ratio <= 1)
				{
					p = Point.interpolate(p1, p2, ratio);
					g.moveTo(p.x, p.y);
					ratio+=0.01;
					p = Point.interpolate(p1, p2, ratio);
					g.lineTo(p.x, p.y);
					ratio+=0.01;
				}*/				
			}
			_model.addZoomEventListener(_onZoom);
			_model.addHomeResizeEventListener(_onHomeResize);
		}
		
		private function _onZoom(e:ZoomEvent):void
		{
			clearGraphics();
		}
		
		private function _onHomeResize(e:HomeResizeEvent):void
		{
			clearGraphics();
		}	
		
		public function clear():void
		{
			//trace("connection clear");
			clearGraphics();
			if(!stage) return;
			_model.removeZoomEventListener(_onZoom);
			_model.removeHomeResizeEventListener(_onHomeResize);
			 parent.removeChild(this);
		}
		
		public function clearGraphics():void
		{
			graphics.clear();
			if(_innerLine)
			{
				if(_innerLine.stage) removeChild(_innerLine);
				_innerLine = null;
			}
		}
			
		
			
		public function get p1():Point
		{
			return _connection.p1;
		}
		
		public function get p2():Point
		{
			return _connection.p2;
		}
		
		public function get type():String
		{
			return _connection.type;
		}
		
	}
}