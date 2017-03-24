package classes.config 
{
	import classes.resources.AppLabels;
	import classes.vo.Texture;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	/**
	 * La classe Config contient des données du projet relatives aux couleurs, tailles et autres données par 
	 * défaut comme les plans types ou les chemins vers l'amfphp ou l'url du dossier xml.
	 */
	public class Config 
	{		
		public static var FLASH_WIDTH:int = 1000;
		public static var FLASH_HEIGHT:int = 580;
		
		public static var MASK_BG_WIDTH_MIN:int = 1000;
		public static var MASK_BG_WIDTH_MAX:int = 1350;
		public static var MASK_BG_HEIGHT_MAX:int = 700;
		public static var MASK_BG_HEIGHT_MIN:int = 580;
		
		public static var RESOLUTION_WIDTH_MAX:int = 1920;
		public static var RESOLUTION_WIDTH_MIN:int = 1024;		
		public static var RESOLUTION_HEIGHT_MAX:int = 1004;
		public static var RESOLUTION_HEIGHT_MIN:int = 580;
		
		public static var EDITOR_WIDTH:int = 720;
		public static var EDITOR_HEIGHT:int = 458;
		//public static var ZONE_ACTIVE_MOUSE:Rectangle;
		
		public static var EPAISSEUR_MURS_EXTERNES:int = 4;
		public static var EPAISSEUR_CLOISONS:int = 2;
		
		public static var LIMIT_LONG_SURFACE:int = 30;//en m
		public static var LIMIT_LARG_SURFACE:int = 20;//en m
		
		public static var HAUTEUR_PIECE:Number = 2.6;//en m
		public static var DISTANCE_PRECO_LIVEPLUG:Number = 3.5;//en m
		public static var DISTANCE_ETHERNET:int = 2;//en m
		public static var DISTANCE_WIFI:int = 15;//en m
		public static var DISTANCE_WIFIDUO_MIN:int = 1;//en m
		public static var DISTANCE_WIFIDUO_MAX:int = 25;//en m
		
		public static var COLOR_DARK:Number = 0x333333;
		public static var COLOR_ORANGE:Number = 0xff6600;
		public static var COLOR_GREEN:Number = 0x99CC00;
		public static var COLOR_YELLOW:Number = 0xffcc00;
		public static var COLOR_GREY:Number = 0x666666;
		public static var COLOR_LIGHT_GREY:Number = 0xcccccc;
		public static var COLOR_WHITE:Number = 0xffffff;
		public static var COLOR_RED:Number = 0xff0000;
		public static var COLOR_FIBERLINE:Number = COLOR_YELLOW;//COLOR_WHITE;
		public static var COLOR_GRID_BACKGROUND:Number = 0x2A3035;//COLOR_WHITE;
		public static var COLOR_WIFI_GREEN:Number = 0x33cc00;
		public static var COLOR_WIFI_ORANGE:Number = COLOR_ORANGE;
		public static var COLOR_WIFI_YELLOW:Number = COLOR_YELLOW;
		public static var COLOR_WIFI_RED:Number = COLOR_RED;
		
		public static var COLOR_GREEN_CONNECT_LINE:Number = 0x33CC00;
		public static var COLOR_ORANGE_CONNECT_LINE:Number = 0xff9900;
		
		public static var COLOR_LABEL_PIECE:Number = 0x999999;
		
		public static var COLOR_SURFACE_MAISON:Number = 0xffffff;
		public static var COLOR_SURFACE_JARDIN:Number = 0x99cc00;
		public static var COLOR_SURFACE_BALCONERY:Number = COLOR_GREEN;
		public static var COLOR_SURFACE_DEPENDANCE:Number = 0xcccccc;
		public static var COLOR_SURFACE_PIECE:Number = 0x000000;
		
		public static var TEXTURES_SURFACE:Array =	[new Texture(COLOR_SURFACE_MAISON, .5), new Texture(COLOR_SURFACE_PIECE, .1),
													 new Texture(COLOR_SURFACE_BALCONERY, .4), new Texture(COLOR_YELLOW/*0xffff33*/, .4),
													 /*new Texture(0x000000, .6), */new Texture(0xff55ff, .3),
													 new Texture(0xff0000, .3),  new Texture(0x5555ee, .3),
													 new Texture(0x66ffff, .3),new Texture(0xabcdef, .3)];
		
		public static var COLOR_MURS:Number = 0x333333;
		public static var COLOR_POINTS_EXTERNES_INSIDE:Number = 0xff6600;
		public static var COLOR_POINTS_EXTERNES_OUTSIDE:Number = 0x333333;
		public static var COLOR_POINTS_PIECES:Number = 0xdddddd;
		public static var COLOR_POINTS_CLOISONS:Number = 0xcccccc;
		public static var COLOR_POINTS_EXTERIEURS_JARDIN:Number = 0x99cc00;
		public static var COLOR_POINTS_EXTERIEURS_BALCONERY:Number = COLOR_GREEN;
		public static var COLOR_POINTS_EXTERIEURS_DEPENDANCE:Number = 0xcccccc;
		public static var COLOR_ORTHO_SEGMENT:Number = COLOR_YELLOW;
		
		public static var COLOR_BG_EDITOR:Number = 0xe5e5e5;
		
		public static var COLOR_CONNEXION_NULL:Number = 0xcccccc;
		public static var COLOR_CONNEXION_WIFI:Number = 0xd00050;
		public static var COLOR_CONNEXION_FIBRE:Number = 0xff9900;
		public static var COLOR_CONNEXION_ETHERNET:Number = 0xcccccc;/*0x339999;*/
		public static var COLOR_CONNEXION_DECT:Number = 0x215fac;
		public static var COLOR_CONNEXION_AUTRES:Number = 0x999999;
		public static var COLOR_CONNEXION_LIVEBOX:Number = 0x333333;
		
		public static var ALERT_COLOR_STROKE:Number = 0xff6600;
		public static var ALERT_COLOR_BG:Number = 0x333333;
		public static var ALERT_WIDTH:int = 401;
		public static var ALERT_WIDTH2:int = 218;
		public static var ALERT_HEIGHT:int = 209//179;
		public static var ALERT_HEIGHT2:int = 135;
		
		public static var TOOLBAR_WIDTH:int = 251;
		public static var TOOLBAR_HEIGHT:int = 439;
		
		public static var ROOT_URL:String = "";
		public static var RESOURCES_FOLDER:String = "swf/";
		public static var XML_URL:String = ""//"xml/";
		public static var AMF_URL:String = "_amfphp_19_maisonconnectee_/gateway.php";
		
		/**
		 * Deprecated
		 * Savoir si on est sur le serveur de test : on vérifie sur l'url contient le mot "test"
		 * 
		 * @return Renvoie true si serveur de test, false dans les autres cas.
		 */
		public static function isTest():Boolean
		{
			if (!ExternalInterface.available) return true;
			
			var pageURL:String = ExternalInterface.call("eval", "window.location.href") as String;
			if(pageURL) {
				var index:int = (pageURL).indexOf("test");
				return (index >= 0);
			}
			return false;
		}
		
		/* Optimisation possible
		 * 
		 * D'autres endroits du code utilisent un code similaire. Forcer l'appel à cette fonction pour ceux-là
		 * 
		 */
		/**
		 * Centralise le nommage des types de projets. Les clés utilisées sont celles des types de projet
		 * 
		 * @return renvoie un Dictionary avec les clés utilisées dans le code et les valeurs à afficher correspondantes
		 */
		public static function getProjectTypes():Dictionary
		{
			var d:Dictionary = new Dictionary(true);
			d["fibre"] = AppLabels.getString("common_fiber");
			d["adsl"] = AppLabels.getString("common_adsl");
			d["adslSat"] = AppLabels.getString("common_adslSat");
			d["adsl2tv"] = AppLabels.getString("common_adsl2Dec");
			return d;
		}
		
		/**
		 * Plan type studio
		 * 
		 * @return Renvoie le XML du plan type studio
		 */
		public static function f2():XML
		{
			var xx:XML = <maison>
  <title><![CDATA[Studio]]></title>
  <floors>
    <floor id="0" index="0" plancher="béton">
      <name><![CDATA[rez-de-chaussée]]></name>
      <blocs>
        <bloc type="blocMaison" classz="[class MainEntity]" positionx="104.95" positiony="52.45" mursPorteurs="" coeffMurs="10,10,10,10,10,10" surfaceType="free">
          <points>
            <point x="105" y="26.25" id="0"/>
            <point x="314.95" y="26.25" id="1"/>
            <point x="314.95" y="115.5" id="2"/>
            <point x="524.95" y="115.5" id="3"/>
            <point x="524.95" y="288.75" id="4"/>
            <point x="105" y="288.75" id="5"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3" alphaSurface="0.3" colorSurface="6750207">
          <points>
            <point x="105" y="183.75" id="0"/>
            <point x="209.98687796308928" y="183.75" id="1"/>
            <point x="209.98687796308928" y="288.75" id="2"/>
            <point x="105" y="288.75" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
      </blocs>
      <labels>
        <label x="216" y="293" text="salle de bain"/>
        <label x="466.85" y="274.3" text="salon"/>
        <label x="244" y="136" text="cuisine"/>
      </labels>
    </floor>
  </floors>
</maison>;
			return xx;
		}
		
		/**
		 * Plan type appartement f4
		 * 
		 * @return Renvoie le XML du plan type appartement f4
		 */
		public static function f4():XML
		{
			var xx:XML = <maison>
  <title><![CDATA[Nommez le projet]]></title>
  <floors>
    <floor id="0" index="0" plancher="béton">
      <name><![CDATA[rez-de-chaussée]]></name>
      <blocs>
        <bloc type="blocMaison" classz="[class MainEntity]" positionx="104.95" positiony="54.2" mursPorteurs="" coeffMurs="10,10,10,10,10,10,10,10" surfaceType="free">
          <points>
            <point x="10.5" y="140" id="0"/>
            <point x="173.25" y="140" id="1"/>
            <point x="173.25" y="-22.75" id="2"/>
            <point x="561.7" y="-22.75" id="3"/>
            <point x="561.7" y="192.5" id="4"/>
            <point x="398.95" y="192.5" id="5"/>
            <point x="398.95" y="386.7" id="6"/>
            <point x="10.5" y="386.7" id="7"/>
          </points>
          <cloisons>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="10.5" y="213.5" id="0"/>
              <point x="131.25" y="213.5" id="1"/>
            </cloison>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="252" y="166.25" id="0"/>
              <point x="356.95" y="166.25" id="1"/>
            </cloison>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="173.25" y="45.5" id="0"/>
              <point x="356.95" y="45.5" id="1"/>
            </cloison>
          </cloisons>
          <equipements/>
        </bloc>
        <bloc type="blocBalcony" classz="[class BalconyEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="">
          <points>
            <point x="398.95" y="192.5" id="0"/>
            <point x="561.7" y="192.5" id="1"/>
            <point x="561.7" y="386.7" id="2"/>
            <point x="398.95" y="386.7" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3" alphaSurface="0.3" colorSurface="6750207">
          <points>
            <point x="356.95" y="-22.75" id="0"/>
            <point x="561.7" y="-22.75" id="1"/>
            <point x="561.7" y="82.25" id="2"/>
            <point x="356.95" y="82.25" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3" alphaSurface="0.3" colorSurface="6750207">
          <points>
            <point x="356.95" y="82.25" id="0"/>
            <point x="561.7" y="82.25" id="1"/>
            <point x="561.7" y="192.5" id="2"/>
            <point x="356.95" y="192.5" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
      </blocs>
      <labels>
        <label x="174" y="226" text="Cuisine"/>
        <label x="210" y="345" text="Séjour"/>
        <label x="315" y="147" text="Entrée"/>
        <label x="350" y="61" text="SdB"/>
        <label x="527" y="191" text="Chambre1"/>
        <label x="525" y="89" text="Chambre2"/>
      </labels>
    </floor>
  </floors>
</maison>/*<maison>
  <title><![CDATA[Appartement T3]]></title>
  <floors>
    <floor id="0" index="0" plancher="béton">
      <name><![CDATA[rez-de-chaussée]]></name>
      <blocs>
        <bloc type="blocMaison" classz="[class MainEntity]" positionx="103.4" positiony="52.55" mursPorteurs="" coeffMurs="10,10,10,10,10,10,10,10" surfaceType="free">
          <points>
            <point x="48.8" y="-68.25" id="0"/>
            <point x="411" y="-68.25" id="1"/>
            <point x="411" y="162.65" id="2"/>
            <point x="274.55" y="162.65" id="3"/>
            <point x="274.55" y="367.35" id="4"/>
            <point x="-98.2" y="367.35" id="5"/>
            <point x="-98.2" y="110.15" id="6"/>
            <point x="48.8" y="110.15" id="7"/>
          </points>
          <cloisons>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="-98.2" y="183.65" id="0"/>
              <point x="17.3" y="183.65" id="1"/>
            </cloison>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="106.55" y="131.15" id="0"/>
              <point x="211.55" y="131.15" id="1"/>
            </cloison>
            <cloison mursPorteurs="" coeffMurs="3">
              <point x="48.8" y="-0.1" id="0"/>
              <point x="211.55" y="-0.1" id="1"/>
            </cloison>
          </cloisons>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,10,3,3" alphaSurface="0.3" colorSurface="6750207">
          <points>
            <point x="211.55" y="41.9" id="0"/>
            <point x="411" y="41.9" id="1"/>
            <point x="411" y="162.65" id="2"/>
            <point x="211.55" y="162.65" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocBalcony" classz="[class BalconyEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="">
          <points>
            <point x="274.55" y="162.65" id="0"/>
            <point x="411" y="162.65" id="1"/>
            <point x="409.4659090909093" y="367.35" id="2"/>
            <point x="274.55" y="367.35" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3" alphaSurface="0.3" colorSurface="6750207">
          <points>
            <point x="211.55" y="-68.25" id="0"/>
            <point x="411" y="-68.25" id="1"/>
            <point x="411" y="42" id="2"/>
            <point x="211.55" y="42" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
      </blocs>
      <labels>
        <label x="391" y="137" text="Chambre1"/>
        <label x="376" y="32" text="Chambre2"/>
        <label x="190" y="17" text="SdB"/>
        <label x="51.9" y="196.75" text="Cuisine"/>
        <label x="106.9" y="319.75" text="Séjour"/>
        <label x="412.95" y="320.95" text="Terrasse"/>
        <label x="167" y="103" text="Entrée"/>
      </labels>
    </floor>
  </floors>
</maison>*/;
			return xx;
		}
		
		/**
		 * Plan type maison f4
		 * 
		 * @return Renvoie le XML du plan type maison f4
		 */
		public static function mf4():XML
		{
			var xx:XML = <maison>
  <title><![CDATA[Maison 2 niveaux & sous sol]]></title>
  <floors>
    <floor id="0" index="1" plancher="béton">
      <name><![CDATA[rez-de-chaussée]]></name>
      <blocs>
        <bloc type="blocMaison" classz="[class MainEntity]" positionx="104.95" positiony="52.45" mursPorteurs="" coeffMurs="10,10,10,10,10,10" surfaceType="free">
          <points>
            <point x="0" y="26.25" id="0"/>
            <point x="524.95" y="26.25" id="1"/>
            <point x="524.95" y="372.7" id="2"/>
            <point x="294" y="372.7" id="3"/>
            <point x="294" y="446.2" id="4"/>
            <point x="0" y="446.2" id="5"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3" alphaSurface="0.5" colorSurface="16777215">
          <points>
            <point x="0" y="315" id="0"/>
            <point x="294" y="315" id="1"/>
            <point x="294" y="446.2" id="2"/>
            <point x="0" y="446.2" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3" alphaSurface="0.3" colorSurface="6750207">
          <points>
            <point x="320.2" y="26.25" id="0"/>
            <point x="524.95" y="26.25" id="1"/>
            <point x="524.95" y="236.25" id="2"/>
            <point x="320.2" y="236.25" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3" alphaSurface="0.5" colorSurface="16777215">
          <points>
            <point x="393.7" y="236.25" id="0"/>
            <point x="524.95" y="236.25" id="1"/>
            <point x="524.95" y="372.7" id="2"/>
            <point x="393.7" y="372.7" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
      </blocs>
      <labels>
        <label x="432" y="358" text="Entrée"/>
        <label x="491" y="180" text="Chambre1"/>
        <label x="550" y="350" text="SdB"/>
        <label x="208" y="440" text="Cuisine"/>
        <label x="228" y="194" text="Séjour"/>
        <label x="419" y="446" text="jardin"/>
        <label x="229" y="51" text="jardin"/>
      </labels>
    </floor>
    <floor id="-1" index="0" plancher="béton">
      <name><![CDATA[sous-sol]]></name>
      <blocs>
        <bloc type="blocMaison" classz="[class MainEntity]" positionx="104.95" positiony="52.45" mursPorteurs="" coeffMurs="10,10,10,10,10,10" surfaceType="free">
          <points>
            <point x="0" y="26.25" id="0"/>
            <point x="472.45" y="26.25" id="1"/>
            <point x="472.45" y="262.5" id="2"/>
            <point x="294" y="262.5" id="3"/>
            <point x="294" y="446.2" id="4"/>
            <point x="0" y="446.2" id="5"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="0" y="26.25" id="0"/>
            <point x="294" y="26.25" id="1"/>
            <point x="294" y="446.2" id="2"/>
            <point x="0" y="446.2" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
      </blocs>
      <labels>
        <label x="228" y="236" text="garage"/>
        <label x="466" y="235" text="Cave"/>
      </labels>
    </floor>
    <floor id="1" index="2" plancher="béton">
      <name><![CDATA[1er étage]]></name>
      <blocs>
        <bloc type="blocMaison" classz="[class MainEntity]" positionx="104.95" positiony="52.45" mursPorteurs="" coeffMurs="10,10,10,10,10,10" surfaceType="free">
          <points>
            <point x="0" y="26.25" id="0"/>
            <point x="325.45" y="26.25" id="1"/>
            <point x="325.45" y="372.7" id="2"/>
            <point x="294" y="372.7" id="3"/>
            <point x="294" y="446.2" id="4"/>
            <point x="0" y="446.2" id="5"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3" alphaSurface="0.3" colorSurface="6750207">
          <points>
            <point x="0" y="26.25" id="0"/>
            <point x="278.25" y="26.25" id="1"/>
            <point x="278.25" y="183.75" id="2"/>
            <point x="0" y="183.75" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3,3,3" alphaSurface="0.3" colorSurface="6750207" surfaceType="free">
          <points>
            <point x="0" y="283.5" id="0"/>
            <point x="325.45" y="283.5" id="1"/>
            <point x="325.45" y="372.7" id="2"/>
            <point x="294" y="372.7" id="3"/>
            <point x="294" y="446.2" id="4"/>
            <point x="0" y="446.2" id="5"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
        <bloc type="blocPiece" classz="[class RoomEntity]" positionx="0" positiony="0" mursPorteurs="" coeffMurs="3,3,3,3">
          <points>
            <point x="0" y="183.75" id="0"/>
            <point x="215.25" y="183.75" id="1"/>
            <point x="215.25" y="283.5" id="2"/>
            <point x="0" y="283.5" id="3"/>
          </points>
          <cloisons/>
          <equipements/>
        </bloc>
      </blocs>
      <labels>
        <label x="207" y="424" text="Chambre2"/>
        <label x="198" y="157" text="Chambre3"/>
        <label x="379" y="151" text="escalier"/>
        <label x="158" y="264" text="SdB"/>
      </labels>
    </floor>
  </floors>
</maison>;
			return xx;
		}
	}

}