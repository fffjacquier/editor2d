package classes.views.menus 
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.views.alert.AlertConnection;
	import classes.views.alert.AlertManager;
	import classes.views.alert.ConnectionEthernet;
	import classes.views.alert.ConnectionWifi;
	import classes.views.Btn;
	import classes.views.CommonTextField;
	import classes.views.equipements.EquipementView;
	import classes.vo.ConnectionVO;
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	
	/**
	 * La classe ConnexionInfo est l'encart qui s'affiche sur le menu d'un équipement lorsqu'une connexion est établie.
	 * 
	 * Test à la ligne. Point barre
	 * <p>Elle établit les différentes informations relatives à la connexion.</p>
	 */
	public class ConnexionInfo extends Sprite 
	{
		private var _X:int = 2;
		private var _eq:EquipementView;
		private var _appModel:ApplicationModel = ApplicationModel.instance;
		private var btnDisco:Btn;
		private var btnMod:Btn;
		private var warning:Sprite;
		private static var _instance:ConnexionInfo;
		public static function get instance():ConnexionInfo
		{
			return _instance;
		}
		
		public function ConnexionInfo(e:EquipementView) 
		{
			_instance = this;
			_eq = e;
			addEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _added(e:Event):void
		{
			//bg
			var g:Graphics = graphics;
			g.lineStyle();  
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0x8b8b8b, 0x565656, 0x3b3b3b];
			var alphas:Array = [1, 1, 1];
			var ratios:Array = [0, 200, 245];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(189, 15, Math.PI / 2, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
			
			//title
			var t:CommonTextField = new CommonTextField("helvet", Config.COLOR_WHITE, 20);
			addChild(t);
			t.width = 185;
			if (_eq.selectedConnexion != null) t.setText(AppLabels.getString("editor_connected"));
			if(_eq.type === "LivephoneItem" || _eq.type === "TelephoneItem")  t.setText(AppLabels.getString("editor_plugged"));
			else t.setText(AppLabels.getString("editor_equiptsConnected"));
			t.x = _X;
			t.y = _X;
			var ypos:int = t.y + t.textHeight + 5;
			
			var tConn:CommonTextField = new CommonTextField();
			addChild(tConn);
			tConn.width = 180;
				
			if (_eq.vo.type === "TelephoneItem") 
			{
				tConn.width = 165;
				tConn.setText(AppLabels.getString("editor_msgPhone"));
				tConn.x = 10;
				tConn.y = ypos;
				ypos += tConn.height +10;
				
				var ImageClass:Class = getDefinitionByName("Convertisseur") as Class;
				var bmp:Bitmap = new Bitmap(new ImageClass(NaN,NaN));
				addChild(bmp);
				bmp.scaleX = bmp.scaleY = .5;
				bmp.y = ypos -20;
				ypos = bmp.y + 100;
			} 
			else if (_eq.vo.type === "LivephoneItem") 
			{
				ImageClass = getDefinitionByName("AntenneDECT") as Class;
				bmp = new Bitmap(new ImageClass(NaN, NaN));
				addChild(bmp);
				bmp.scaleX = bmp.scaleY = .4;
				bmp.y = ypos -30;
				ypos = bmp.y + 100;
				
				tConn.setText(AppLabels.getString("editor_dectAntenna"));
				tConn.x = 15;
				tConn.y = ypos;
				ypos += tConn.height +10;
			} 
			else {
			
				//if (_eq.selectedConnexion != null) {
				if(_eq.isTerminal && _eq.connection != null) {
					//icon + actual connexion
					var connIcon:MovieClip = new BulleEthernet();
					addChild(connIcon);
					connIcon.x = _X;
					connIcon.y = ypos;
					
					tConn.setText("en "+ ModesDeConnexion.getConnexionLabel(_eq.selectedConnexion));
					tConn.x = 25;
					tConn.y = ypos;
					ypos += tConn.height +10;
					
					if (_eq.connection && !_eq.connection.isAcceptable) {
						warning = new Sprite();
						addChild(warning);
						var ggg:Graphics = warning.graphics;
						ggg.clear();
						ggg.lineStyle();
						ggg.beginFill(Config.COLOR_ORANGE_CONNECT_LINE);
						warning.x = 25;
						warning.y = ypos;
						var tt:CommonTextField = new CommonTextField("helvetBold");
						tt.width = 148;
						warning.addChild(tt);
						tt.x = 5;
						tt.y = 3;
						tt.setText(AppLabels.getString("editor_checkConnection"))
						ggg.drawRoundRect(0, 0, 153, 3 + tt.textHeight + 5, 10);
						ggg.endFill();
						ypos += tt.textHeight + 20;
					}
					
					// buttons
					btnMod = new Btn(Config.COLOR_ORANGE, AppLabels.getString("buttons_modify"), null, 65, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_ORANGE);
					addChild(btnMod);
					btnMod.x = 25;
					btnMod.y = ypos;
					btnMod.addEventListener(MouseEvent.CLICK, _modify, false, 0, true);
					
					btnDisco = new Btn(Config.COLOR_ORANGE, AppLabels.getString("buttons_disconnect"), null, 65, Config.COLOR_WHITE, 12, 24, Btn.GRADIENT_DARK);
					addChild(btnDisco);
					btnDisco.x = 25 + btnMod.width + 3;
					btnDisco.y = ypos;
					btnDisco.addEventListener(MouseEvent.CLICK, _disconnect, false, 0, true);
					
					ypos += 30;
					
					// legendes des traits
					var isEthernet:Boolean = false;
					var isWifi:Boolean = false;
					var isCpl:Boolean = false;
					
					var cvo:ConnectionVO = _eq.connection;
					if(cvo){
						if (cvo.type == ModesDeConnexion.ETHERNET) {
							isEthernet = true;
						} else if (cvo.type == ModesDeConnexion.WIFI) {
							isWifi = true;
						} else if (cvo.type == ModesDeConnexion.CPL) {
							isCpl = true;
						}
						
						// les connexions parents
						var pcvo:ConnectionVO = cvo.parentConnection;
						if (pcvo) {
							//trace("connexion 2", pcvo.type);
							if (pcvo.type == ModesDeConnexion.ETHERNET) {
								isEthernet = true;
							} else if (pcvo.type == ModesDeConnexion.WIFI) {
								isWifi = true;
							} else if (pcvo.type == ModesDeConnexion.CPL) {
								isCpl = true;
							}
							var ppcvo:ConnectionVO = pcvo.parentConnection;
							if (ppcvo && ppcvo.parentConnection) {
								if (ppcvo.type == ModesDeConnexion.ETHERNET) {
									isEthernet = true;
								} else if (ppcvo.type == ModesDeConnexion.WIFI) {
									isWifi = true;
								} else if (ppcvo.type == ModesDeConnexion.CPL) {
									isCpl = true;
								}
								//trace("connexion 3", ppcvo.parentConnection.type);
							}
						}
						//trace(isEthernet, isWifi, isCpl);
						if (isEthernet) {
							_drawLegend(ModesDeConnexion.ETHERNET, ypos, AppLabels.getString("check_ethernetWire"));
							ypos += 15;
						}
						if (isWifi) {
							_drawLegend(ModesDeConnexion.WIFI, ypos, AppLabels.getString("editor_wifi"));
							ypos += 15;
						}
						if (isCpl) {
							_drawLegend(ModesDeConnexion.CPL, ypos, ModesDeConnexion.CPL.toUpperCase());
							ypos += 15;
						}
					}
					
					if (_eq.connection) trace("CI:connection  isAcceptable:",_eq.connection.isAcceptable);
					var color:Number = (_eq.connection && !_eq.connection.isAcceptable) ? Config.COLOR_ORANGE_CONNECT_LINE : Config.COLOR_GREEN_CONNECT_LINE;
					var gg:Graphics = connIcon.graphics;
					gg.clear();
					gg.lineStyle();
					gg.beginFill(color);
					gg.drawCircle(9, 9, 9);
					gg.endFill();
					
				} else {
					//list the equipements directly connected to this
					var s:String = "";
					var a:Array = _appModel.connectionsCollection.getDirectConnections(_eq);
					for (var i:int = 0; i < a.length; i++) 
					{
						var connexionVO:ConnectionVO = a[i] as ConnectionVO;
						var other:EquipementView = connexionVO.getOther(_eq);
						s += "- " + other.vo.screenLabel + "\n";
					}
					tConn.setText(s);
					tConn.x = _X;
					tConn.y = ypos;
					ypos += tConn.textHeight;
				}
			}
			// legend for connexion strokes
			
			g.drawRoundRect(0, 0, 189, ypos +5, 8);
			g.endFill();
			
			removeEventListener(Event.ADDED_TO_STAGE, _added);
		}
		
		private function _drawLegend(connectionType:String, ypos:int, lable:String=null):void
		{
			var s:Sprite = new Sprite();
			addChild(s);
			s.y = ypos;
			s.x = 5;
			var c:Number = Config.COLOR_WHITE;
			var g:Graphics = s.graphics;
			g.clear();
            g.lineStyle(1, c, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE);
            if (connectionType == ModesDeConnexion.ETHERNET) {
				g.moveTo(0, 12);
				g.lineTo(22, 12);
			} else if (connectionType == ModesDeConnexion.WIFI) {
				g.lineStyle();
				g.moveTo(0, 12);
				g.beginFill(c);
				var X:int;
				while (X < 23) 
				{
					g.drawRect(X, 11, 4, 1);
					X+=6;
				}
			} else if (connectionType == ModesDeConnexion.CPL) {
				g.lineStyle(1, c);
				g.moveTo(0, 12);
				var Xx:Number = 12;
				var p1:Point = new Point(0, 12);
				var p2:Point = new Point(22, 12);
				while (Xx <= Point.distance(p1, p2)) 
				{
					//trace("Xx", Xx, Math.sin(Xx)*2);
					g.lineTo(Xx, 12 + Math.sin(Xx)*1.5)
					Xx += .1;
				}
			}
			g.endFill();
			var t:CommonTextField = new CommonTextField("helvetBold", Config.COLOR_WHITE, 11, "left", -0.5);
			t.width = 145;
			t.setText(AppLabels.getString("editor_connection") +" " + lable);
			s.addChild(t);
			t.x = 25;
		}
		
		public function update():void
		{
			if (_eq.selectedConnexion != null) {
				if (btnDisco && btnDisco.stage) removeChild(btnDisco);
				if (btnMod && btnMod.stage) removeChild(btnMod);
				if (warning && warning.stage) removeChild(warning);
				
				var g:Graphics = graphics;
				g.clear();
				g.lineStyle();  
				var fillType:String = GradientType.LINEAR;
				var colors:Array = [0x8b8b8b, 0x565656, 0x3b3b3b];
				var alphas:Array = [1, 1, 1];
				var ratios:Array = [0, 200, 245];
				var matr:Matrix = new Matrix();
				matr.createGradientBox(189, 15, Math.PI / 2, 0, 0);
				var spreadMethod:String = SpreadMethod.PAD;
				g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
				var ypos:int = 75;
				g.drawRoundRect(0, 0, 189, ypos +5, 8);
				g.endFill();
			}
		}
		
		private function _modify(e:MouseEvent):void
		{
			//trace(_eq.connection, _eq.selectedConnexion);
			var poup:AlertConnection;
			if(!_eq.connection)
			{
				trace("erreur il devrait y avoir une connection");
				return;
			}
			
			if (_eq.connection.type === "ethernet") 
			{
				poup = new ConnectionEthernet(_eq);
			} 
			else if (_eq.connection.type === "wifi") 
			{
				poup = new ConnectionWifi(_eq);
			}
			
			//var poup:AlertConnection = new AlertConnection(eq);
			AlertManager.addPopup(poup, Main.instance);
			poup.x = MenuContainer.instance.x - 560;
			poup.y = 109;
		}
		
		private function _disconnect(e:MouseEvent):void
		{
			var connection:ConnectionVO = _appModel.connectionsCollection.getProvidingConnection(_eq);
			if (connection) connection.remove(/*true, false*/);
			_appModel.notifySaveStateUpdate(true);
		}
		
	}

}