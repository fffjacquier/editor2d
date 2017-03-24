package classes.vo
{
	import flash.display.Graphics;

	public class Texture
	{
		public var color:int;
		public var alfa:Number;
		public var texturePath:String;
		
		public function Texture(texture:*, alfa:Number)
		{
			if(texture is String)
			{
				texturePath = texture;
				//création du bltmapData à utiliser pour le bitmapFill
			}
			else
			{
				color = texture;
				//trace("texture creee couleur : " + color);
			}
			this.alfa = alfa;
			//trace("texture creee alfa : " + alfa);
		}
		
		public function get isColor():Boolean
		{
			return (texturePath == null);
		}
		
		public function equals(texture:Texture):Boolean
		{
			if (alfa != texture.alfa) return false;
			if (!texturePath && (color != texture.color)) return false;
			if (texturePath && (texturePath != texture.texturePath)) return false;
			return true;
		}
		
		public function copy(texture:Texture):void
		{
			alfa = texture.alfa;
			texturePath = texture.texturePath;
			color = texture.color;
		}	
		
		public function clone():Texture
		{
			if(isColor) return new Texture(color, alfa);
			else return new Texture(texturePath, alfa);
		}	
	}
}
