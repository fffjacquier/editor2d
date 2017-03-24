package classes.views.items 
{
	import classes.model.ApplicationModel;
	import classes.resources.AppLabels;
	import classes.views.CommonTextField;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * La classe ListeItemPDF correspond aux légendes figurant dans le PDF des équipements présents sur le plan 
	 */
	public class ItemListePDF extends Sprite 
	{
		private var _mc:DisplayObject;
		private var _num:int;
		private var _l:Loader;
		
		/**
		 * Créer la légende de l'équipement 
		 * 
		 * @param	pname Le nom de l'équipement (son label)
		 * @param	type Le type d'équipement ("LiveboxItem", "DecodeurItem" ...)
		 * @param	mc Le chemin de l'image de l'équipement à afficher
		 * @param	i le numéro d'ordre de l'équipement dans la liste des légendes
		 */
		public function ItemListePDF(pname:String, type:String, mc:*, i:int) 
		{
			//add picto
			/*_mc = mc as DisplayObject;
			addChild(new mc());*/
			_num = i;
			_l = new Loader();
			_l.contentLoaderInfo.addEventListener(Event.COMPLETE, _onImageLoaded);
			//var imgUrl:String = "images/PDF" + mc.split("/")[1];
			_l.load(new URLRequest(mc as String));
			
			// add text
			var t:CommonTextField = new CommonTextField("helvet", 0x333333, 14 );
			t.autoSize = "left";
			t.width = 170;
			addChild(t);
			var str:String;
			if (type == "LivePlugItem") {
				str = AppLabels.getString("check_liveplugHD");
			} else if (type === "WifiExtenderItem") {
				str = AppLabels.getString("check_wfe");
			} else {
				str = pname;
			}
			trace("---nom=", type, str);
			t.setText(str);
			t.x = 70;
			t.y = 24 - t.textHeight / 2;
		}
		
		private function _onImageLoaded(e:Event):void
		{
			var content:Bitmap = e.currentTarget.content as Bitmap;
			content.scaleX = content.scaleY = .175;
			content.smoothing = true;
			
			/*var bmpData:BitmapData = new BitmapData(90, 78);
			var matrix:Matrix = new Matrix();
			matrix.scale(.175, .175);
			bmpData.draw(content.bitmapData, matrix, null, null, null, true);*/
			
			addChild(content);
			
			//--- envoie une notification que cet item est bien chargé
			ApplicationModel.instance.notifyLegendesLoaded(_num, this);
			//ApplicationModel.instance.notifyLegendesLoaded(_num, bmpData);
		}
		
	}

}