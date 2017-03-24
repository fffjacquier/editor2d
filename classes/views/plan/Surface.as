package classes.views.plan 
{
	import classes.commands.DeleteSurfaceCommand;
	import classes.config.Config;
	import classes.controls.PointMoveEvent;
	import classes.controls.UpdatePointsVOEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.utils.Measure;
	import classes.utils.ObjectUtils;
	import classes.views.CommonTextField;
	import classes.views.menus.MenuFactory;
	import classes.views.menus.MenuItemRenderer;
	import classes.views.menus.MenuRenderer;
	import classes.vo.PointVO;
	import classes.vo.Texture;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	
	public class Surface extends Sprite 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var _obj2D:Object2D;
		private var _tf:CommonTextField;
		private var _bg:Sprite;
		private var _texture:Texture;
		
		public static var TYPE_FREE:String = "free";
		public static var TYPE_SQUARE:String = "square";
		
		public function Surface(obj:Object2D) 
		{
			_obj2D = obj;
		
			if(stage) _onAdded();
			else addEventListener(Event.ADDED_TO_STAGE, _onAdded);
		}
		
		private function _onAdded(e:Event=null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, _clean);
			_bg = new Sprite();
			addChild(_bg);
			_tf = new CommonTextField("verdana", 0x000000, 12, "center");
			MeasuresContainer.addSurfaceMeasure(_tf);
			addChild(_tf);
			_tf.visible = false;
			mouseChildren = false;
			if(bloc.texture) texture = bloc.texture;
			else texture = defaultTexture;
			
			_onPointMove();
			_model.addPointMoveListener(_onPointMove);
			_model.addPointsVOUpdateListener(_onPointVOUpdate);
			//blendMode = BlendMode.SCREEN;
		}
		
		private function get _pointsVO():Array
		{
			return obj2D.pointsVOArr;
		}
		
		private function _onPointVOUpdate(e:UpdatePointsVOEvent = null):void
		{
			_redraw();
		}
		
		private function _onPointMove(e:PointMoveEvent=null):void
		{
			_redraw();
		}
		
		private function _redraw():void
		{
			var p:Array = _obj2D.pointsVOArr;
			var g:Graphics = _bg.graphics;
			g.clear();
			//g.lineStyle(5, Config.COLOR_MURS);
			var po:PointVO = p[0] as PointVO;
			g.moveTo(po.x, po.y);
			//trace("redraw " + ObjectUtils.getClassName(_obj2D));
			
			if(_texture.isColor)
			{
				g.beginFill(_texture.color, _texture.alfa);
			}
			else
			{
				//g.beginBitmapFill(...);
			}
			for (var i:int = 1; i < p.length; i++) {
				po = _obj2D.getPointVOAt(i);
				g.lineTo(po.x, po.y);
			}
			//trou simple de surface
			//var bounds:Rectangle = this.getBounds(this);
			//g.drawCircle(bounds.x+30, bounds.y + 30, 10);
			//creer des  pieces trous sans surface  
			//en redraw ici detecter les pieces trou et les redessiner ici 
			g.endFill();
			updateSurface();
		}
		
		private function get defaultTexture():Texture
		{
			var color:int;
			var alfa:Number;
			
			switch(ObjectUtils.getClassName(_obj2D))
			{
				case "MainEntity" :
					color = Config.COLOR_SURFACE_MAISON;
					alfa = .6;
					break;
				case "DependanceEntity" :
					color = Config.COLOR_SURFACE_DEPENDANCE;
					alfa = 1;
					break;
				case "GardenEntity" :
					color = Config.COLOR_SURFACE_JARDIN;
					alfa = .5;
					break;
				case "BalconyEntity" :
					color = Config.COLOR_SURFACE_BALCONERY;
					alfa = .4;
					break;					
				case "RoomEntity" :
					color = Config.COLOR_SURFACE_PIECE;
					alfa = .1;
					break;
				default:
					color = Config.COLOR_SURFACE_MAISON;
					alfa = .1;
			}
			return (new Texture(color, alfa));
		}
		
		public function get hasDefaultTexture():Boolean
		{
			return (_texture.equals(defaultTexture));
		}
		
		public function set texture(newTexture:Texture):void
		{
			if(!_texture) _texture = newTexture.clone();
			else _texture.copy(newTexture);
				
			bloc.setTexture(newTexture);
			_redraw();
		}
		
		public function get texture():Texture
		{
			return _texture;
		}
		
		
	//	protected var menu:MenuRenderer;
		
		public function onClickOnSurface(e:MouseEvent=null):void
		{
			//trace("Surface::onClickOnSurface()", ObjectUtils.getClass(_obj2D), _model.isDrawStep,ApplicationModel.instance.currentStep, ApplicationModel.STEP_SURFACE);
			if (!_model.isDrawStep) return;
			if (ApplicationModel.instance.currentStep != ApplicationModel.STEP_SURFACE) return;
			
			var menu:MenuRenderer = MenuFactory.createMenu(this, EditorContainer.instance);
		}
		
		public function get isMainSurface():Boolean
		{
			return (obj2D is MainEntity);
		}
		
		private function _clean(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, _clean);
			
			_model.removePointMoveListener(_onPointMove);
			_model.removePointsVOUpdateListener(_onPointVOUpdate);
			MeasuresContainer.removeSurfaceMeasure(_tf);
			//removeEventListener(MouseEvent.MOUSE_UP, onClickMainSurface);
		}
		
		// ------ public methods ------------
		
		public function get obj2D():Object2D
		{
			return _obj2D;
		}
		
		public function get bloc():Bloc
		{
			return _obj2D.bloc;
		}
		
		
		public function deleteSurface():void
		{
			MenuItemRenderer.DOCLOSE = true;
			new DeleteSurfaceCommand(_obj2D.bloc).run();
		}
		
		private var _bitmap:Bitmap;
		public function updateSurface():void
		{
			//if (_tf.stage) removeChild(_tf);
			// if (_bitmap && _bitmap.stage) removeChild(_bitmap);
			var bounds:Rectangle = _bg.getBounds(this);
			if (bounds.width <= 0 || bounds.height <= 0)
			{
				_tf.text = "";
				return;
			}
			
			var s:Number = surfaceIfSquare;
		    if (s > 0) 
			{
				_setText(s, bounds);
				return;
			}
			
			
			//trace(bounds);
			var matrix:Matrix = new Matrix();
			matrix.translate( -bounds.x, -bounds.y);
			if(bounds.width<1 || bounds.height<1)  return;
			var bmdDraw:BitmapData = new BitmapData(bounds.width, bounds.height, false, 0xff0000);
			bmdDraw.draw(_bg, matrix, null, null, null, true);
			var pt:Point = new Point(0, 0);
            var rect:Rectangle = new Rectangle(0, 0, bounds.width, bounds.height);
			
		    var s1:int = bmdDraw.threshold(bmdDraw, rect, pt, "!=", 0xff0000, 0x000000, 0xffffff)
		 	var boundsSurface:Number = s1 * Measure.realSize(1) * Measure.realSize(1);
			_setText(boundsSurface, bounds);
			
			/*_bitmap = new Bitmap(bmdDraw);
			_bitmap.x = bounds.x;
			_bitmap.y = bounds.y;
			addChild(_bitmap);*/
		}
		
		private function _setText(s:Number, bounds:Rectangle):void
		{
			s = Math.round(s * 100) / 100;
			var str:String  = String(s);
			var arr:Array = str.split(".");
			if (arr[1])
			{
			   if((arr[1] as String).length == 1) arr[1] += "0";
				str = arr.join(",");
			}
			// FJ patch 03/07/12 -- demande d'ajouter un fond afin de rendre le texte lisible si fond de couleur proche du texte
			_tf.background = true;
			_tf.backgroundColor = 0xffffff;
			_tf.autoSize = TextFieldAutoSize.CENTER
			// fin du patch
			_tf.setText(str + Measure.getUnitShort(Measure.METERS) + "²");
			_tf.x = bounds.x + bounds.width / 2 - _tf.width / 2;
			_tf.y = bounds.y + bounds.height / 2 - _tf.height / 2;			
			addChild(_tf);
		}
		
		public function get bg():Sprite
		{
			return _bg;
		}
		
		public function displaySurfaceSize(doShow:Boolean):void
		{
			if (!doShow)
			{
				_tf.setText("");
				if (_tf.stage) removeChild(_tf);
			}
			else
			{
				if (!_tf.stage) addChild(_tf);
			}
		}
		
		public function get surfaceIfSquare():Number
		{
			if (_pointsVO.length != 4) return 0;
			if (obj2D.segmentsArr.length != 4) return 0;
			
			var segment0:Segment = obj2D.segmentsArr[0] as Segment;
			var segment1:Segment = obj2D.segmentsArr[1] as Segment;
			var segment2:Segment = obj2D.segmentsArr[2] as Segment;
			var segment3:Segment = obj2D.segmentsArr[3] as Segment;
			var s:Number = segment0.metricSize * segment1.metricSize;
			/*if (segment0.isVertical && segment2.isVertical && segment0.metricSize == segment2.metricSize)   return s;
			if (segment1.isVertical && segment3.isVertical && segment1.metricSize == segment3.metricSize)   return s;
			if (segment0.isHorizontal && segment2.isHorizontal && segment0.metricSize == segment2.metricSize)   return s;
			if (segment1.isHorizontal && segment3.isHorizontal && segment1.metricSize == segment3.metricSize)   return s;*/
			if (segment0.isOrtho && segment1.isOrtho && segment2.isOrtho && segment3.isOrtho) return s;
			return 0;
		}
		
		
	}

}