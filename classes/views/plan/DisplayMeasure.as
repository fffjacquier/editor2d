package classes.views.plan 
{
	import classes.config.Config;
	import classes.model.EditorModelLocator;
	import classes.utils.Measure;
	import classes.vo.PointVO;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	
	/**
	 * DisplayMeasure, classe étendant Sprite, indiquant les mesures des murs du plan.
	 */
	public class DisplayMeasure extends Sprite 
	{
		private var _model:EditorModelLocator = EditorModelLocator.instance;
		private var t:TextField;
		private var _segment:Segment
		private var _inputMeasure:Number;
		private var _prevMeasure:Number;
		private var _measure:Number;
		private var ft:TextFormat;
		public var unit:String = Measure.METERS;
		private var p1:PointVO;
		private var p2:PointVO;
		public var isAssociated:Boolean = false;
		private var _w:int;
		
		/**
		 * DisplayMeasure, classe étendant Sprite, indiquant les mesures des murs du plan.
		 * <p>Elle peut afficher la mesure d'un mur, ou les mesures du mur entrecoupé de cloisons ou pièces.</p>
		 * @param segment le segment dont elle affiche la mesure.
		 * @param p1 Optionnel, pour afficher la mesure entre 2 points du segment 
		 * dont au moins l'un est un point associé et non pas une extrémité.
		 * @param p2 Optionnel, pour afficher la mesure entre 2 points du segment 
		 * dont au moins l'un est un point associé et non pas une extrémité.
		 */
		public function  DisplayMeasure (segment:Segment, p1:PointVO=null, p2:PointVO=null) 
		{
			_segment = segment;
			if (p1)
			{
				//mesure partielle // entre points associés
				this.p1 = p1;
				this.p2 = p2;
				isAssociated = true;
			}
			else
			{
				//mesure d'un segment entier 
				this.p1 = segment.p1;
				this.p2 = segment.p2;
			}
			
			t = new TextField();
			//t.autoSize = TextFieldAutoSize.LEFT;
			t.width = 60;
			t.height = 20;
			t.embedFonts = true;
			t.selectable = false;
			
			ft = new TextFormat();
			ft.font = (new Verdana() as Font).fontName;
			//ft.font = (new Helvet55Bold() as Font).fontName
			ft.color = Config.COLOR_MURS;
			ft.size = 12;
			ft.align = TextFormatAlign.CENTER;
			
			addChild(t);
			t.setTextFormat(ft);
			
			//si on veut pouvoir entrer les mesures 
			//addEventListener(MouseEvent.CLICK, _onClick);
			addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
		
		private function _onClick(e:MouseEvent):void
		{
			//trace("_onClick");
			_prevMeasure = _measure;
			t.selectable = true;
			t.type = TextFieldType.INPUT;
			t.restrict = "0-9";
			t.maxChars = 4;
			t.setSelection(0, t.text.length);
		
			if(t.text.indexOf(unitShort) != -1) t.text = t.text.substr(0, - unitShort.length);
			t.setTextFormat(ft);
			stage.focus = t;
			t.addEventListener(Event.CHANGE, _onChange);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			removeEventListener(MouseEvent.CLICK, _onClick);
			Editor2D.instance.addEventListener(MouseEvent.MOUSE_DOWN, _onFocusOut);
		}
		
		private function _onChange(e:Event):void
		{
			//trace("_onChange");
			// 2 chiffres apres virgule si metres  TODO si on doit afficher des metres
			_inputMeasure = int(t.text);
			t.setTextFormat(ft);
			trace("_onChange", t.text, _inputMeasure);
		}
		
		private  function _onFocusOut(e:MouseEvent=null):void
		{
			if (e && (e.target == this || e.target == t)) return;
			//t.removeEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);
			//t.removeEventListener(FocusEvent.FOCUS_IN, _onFocus);
			
			
			Editor2D.instance.removeEventListener(MouseEvent.MOUSE_DOWN, _onFocusOut);
			t.maxChars = 6;
			t.selectable = false;
			t.type = TextFieldType.DYNAMIC;
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			t.removeEventListener(FocusEvent.FOCUS_OUT, _onFocusOut);
			t.removeEventListener(Event.CHANGE, _onChange);
			addEventListener(MouseEvent.CLICK, _onClick);
			
			if (_inputMeasure < 10 || isNaN(_inputMeasure)) 
			{
				//on réintroduit la donnée précédente 
				_inputMeasure = _prevMeasure;
				t.text = getIntString(_measure) + unitShort;
				t.setTextFormat(ft);
				return;
			}
			//var p1:PointVO = _segment.p1;
			//var p2:PointVO = _segment.p2;
			
			//calcul du ratio proportionnellement aux longueurs en pixel, plus précis
			var prevDist:Number = Point.distance(p1, p2);
			//on calcule la longeur en pixels attendue en fonction de la mesure entrée par le user 
			var newDist:Number = Measure.metricToPixel(_inputMeasure) * _model.currentScale;
			//trace("newDist en pixels", newDist);
			
			//p1 et p2 locked
			if (p1.isLocked && p2.isLocked) return;
			
			var offset:Number = (newDist - prevDist);
			//var offset:Number = (_inputMeasure - _measure) /// 2;
			
			if (!p1.isLocked && !p2.isLocked) offset /= 2;
			var ratio:Number = offset / prevDist;
			//var ratio:Number = offset / _measure;
			if (p1.isLocked) {
				var point2:Point = Point.interpolate(p2, p1, 1 + ratio);
				p2.setPointPosition(point2);
				_model.notifyPointMove([p2]);
			} else if (p2.isLocked) {
				var point1:Point = Point.interpolate(p2, p1, - ratio);
				p1.setPointPosition(point1);
				_model.notifyPointMove([p1]);
			} else {
				point1 = Point.interpolate(p2, p1, - ratio);
				point2 = Point.interpolate(p2, p1, 1 + ratio);
				p1.setPointPosition(point1);
				p2.setPointPosition(point2);
				_model.notifyPointMove([p2, p1]);
			}
			
			//calcul du ratio proportionnellement aux mesures, moins précis
			//var offset:Number = (_inputMeasure - _measure) /// 2;
			//var ratio:Number = offset / _measure;
			
		}
		
		private function _onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode != Keyboard.ENTER) return;
			if (_inputMeasure < 10 || isNaN(_inputMeasure)) 
			{
				//diplayMeasure se remettra à la donnée précédente automatiquement
				//car les points n'ont pas bougé. 
				var p1:PointVO = _segment.p1;
				var p2:PointVO = _segment.p2;
				_model.notifyPointMove([p1, p2]);
				return;
			}
			_onFocusOut();
		}
		
		public function  get measure():Number
		{
			return Math.round(_measure * 100) / 100;
		}
		
		public function  get unitShort():String
		{
			return Measure.getUnitShort(unit);
		}
		
		public function  get segment():Segment
		{
			return _segment;
		}
		
		public function update():void
		{
			//if (t == null) return;
			
			var distp1p2:Number = Point.distance(p1, p2);// Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2))  //;
			
			distp1p2 /= _model.currentScale;
			
			//_measure = NumberUtils.format(Measure.pixelToMetric(unit, distp1p2));
			_measure = Measure.pixelToMetric(distp1p2, unit);
			//trace("_measure" + _measure)
			t.text = getIntString(_measure) + unitShort;
			t.y = -t.textHeight/2 ;
			t.setTextFormat(ft);
			
			_draw();
			var middle:Point = Point.interpolate(p2, p1, .5);
			x = middle.x - _w / 2;
			y = middle.y;
			if (_segment.isInHome)
			{
				var p:Point = Point.polar(22, _segment.perpendicularAngle);
				x += p.x;
				y += p.y;
				//if(!_segment.isHorizontal) rotation = _segment.degreeAngle %180;
			}			
		}
		
		private function _draw():void
		{
			graphics.clear();
			graphics.lineStyle(.25, Config.COLOR_LIGHT_GREY);
			graphics.beginFill(0xffffff, .9);
			_w = t.textWidth +8;
			var h:int = t.textHeight+6
			graphics.drawRect(-2, -h/2, _w, h);
			graphics.endFill();
			t.x = (_w - t.width) / 2;
			t.y = - t.height / 2;
		}
		
		public function getIntString(value:Number):String
		{
			var val:Number = Math.round(value * 100) / 100;
			if (val == int(val)) return String(val);
			var str:String  = String(val);
			var arr:Array = str.split(".");
			if((arr[1] as String).length == 2)  return String(val);
			arr[1] += "0";
			return arr.join(",");
			//return String(Math.round(value));
		}
		
		public function selfRemove():void
		{
			measuresContainer.removeDisplayMeasure(this);
		}
		
		public function selfAdd():void
		{
			measuresContainer.addDisplayMeasure(this);
		}
		
		public function get isOff():Boolean
		{
			if (!_segment.isInCurrentFloor) return true;
			if (_segment.doesStickToSegment()) return true;
			if (isAssociated) return false;
			if (!_segment.hasAssociatedPoints) return false;
			return true;
		}
		
		public function get measuresContainer():MeasuresContainer
		{
			return _segment.measuresContainer;
		}
		
		public  function cleanup(e:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanup);
		}
	}

}