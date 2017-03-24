package classes.views.menus 
{
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.utils.ObjectUtils;
	import classes.views.equipements.ConsoleJeuView;
	import classes.views.equipements.DecodeurView;
	import classes.views.equipements.HomeLibraryView;
	import classes.views.equipements.ImprimanteView;
	import classes.views.equipements.LiveboxView;
	import classes.views.equipements.LivePhoneView;
	import classes.views.equipements.LiveradioCubeView;
	import classes.views.equipements.MainDoorView;
	import classes.views.equipements.OrdinateurView;
	import classes.views.equipements.PriseView;
	import classes.views.equipements.SmartphoneView;
	import classes.views.equipements.SqueezeBoxView;
	import classes.views.equipements.TabletteView;
	import classes.views.equipements.TelephoneView;
	import classes.views.equipements.TeleView;
	import classes.views.NomPieceView;
	import classes.views.plan.CloisonEntity;
	import classes.views.plan.Editor2D;
	import classes.views.plan.FiberLineEntity;
	import classes.views.plan.Floor;
	import classes.views.plan.Object2D;
	import classes.views.plan.PointView;
	import classes.views.plan.Segment;
	import classes.views.plan.Surface;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	
	/**
	 * La classe MenuFactory s'occupe de créer une partie des menus des objets du plan
	 * 
	 */
	public class MenuFactory 
	{
		private static var items:Array;
		
		/**
		 * C
		 */
		public function MenuFactory() 
		{
		}
		
		/**
		 * L'appel à cette fonction créer les menus pour les différents objets du plan: les étages, les points, les segments, 
		 * les cloisons, les surfaces, les noms des pièces (étiquettes <code>NomPieceView</code>) et les équipements
		 * 
		 * @param	displayObj Le type d'objet qui appelle la création du menu
		 * @param	menuContainer L'endroit dans lequel le MenuContainer doit s'afficher
		 * @return Renvoie un MenuRenderer 
		 */
		public static function createMenu(displayObj:DisplayObject, menuContainer:DisplayObjectContainer):MenuRenderer
		{
			var className:String = ObjectUtils.getClassName(displayObj);
			var menus:Array = new Array();
			var type:String;
			var icon:MovieClip;
			
			switch (className)
			{
				case "Floor" :
					var floor:Floor = displayObj as Floor;
					type = "floor";
					break;
				
				case "PointView" :
					var pointView:PointView = displayObj as PointView;
					if (pointView.isLocked) 
						menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_unlockPoint"), new IconUnLock(), "unlockPoint", pointView.unLockPoint)));
					else
						menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_lockPoint"), new IconLock(), "lockPoint", pointView.lockPoint)));
					
					if (pointView.obj2D.surface)
					{
						if (pointView.obj2D.length > 3)
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_deletePoint"), new IconDelete(), "deletePoint", pointView.removePoint)));
					}
					else
					{
						if (pointView.obj2D.length > 2)
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_deletePoint"), new IconDelete(), "deletePoint", pointView.removePoint)));
					}
					type = "point";
					break;
				
				case "Segment" : 
					var segment:Segment =  displayObj as Segment;
					var obj2D:Object2D = segment.obj2D
					switch(ObjectUtils.getClassName(obj2D))
					{
						case "RoomEntity" :
							if(!obj2D.isSquare)
							{
								menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addAngle"), new IconAjouterAngle(), "insertOnePoint", segment.insertOnePoint)));
								menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addDecroche"), new IconAjouterDecroche(), "insertTwoPoints", segment.insertTwoPoints)));
							}
							
							icon = new IconMurPorteur();
							if (!segment.murPorteur) {
								icon.gotoAndStop(2);
							}
							menus.push(new MenuIconChangeRenderer(new MenuItem(AppLabels.getString("editor_bearingWall"), icon, "murPorteur", segment.menuMurPorteur)));
							break;
						case "BalconyEntity" :
							if(!obj2D.isSquare)
							{
								menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addAngle"), new IconAjouterAngle(), "insertOnePoint", segment.insertOnePoint)));
								menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addDecroche"), new IconAjouterDecroche(), "insertTwoPoints", segment.insertTwoPoints)));
							}
							break;
						case "MainEntity" :
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addAngle"), new IconAjouterAngle(), "insertOnePoint", segment.insertOnePoint)));
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addDecroche"), new IconAjouterDecroche(), "insertTwoPoints", segment.insertTwoPoints)));
							break;
						case "FiberLineEntity":
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addAngle"), new IconAjouterAngle(), "insertOnePoint", segment.insertOnePoint)));
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addDecroche"), new IconAjouterDecroche(), "insertTwoPoints", segment.insertTwoPoints)));
							var fiber:FiberLineEntity = obj2D as FiberLineEntity;
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_deleteFiberLine"), new IconDelete(), "deleteFiberLine", fiber.removeFiberLine)));
							break;
						case "CloisonEntity" :
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_addAngle"), new IconAjouterAngle(), "insertOnePoint", segment.insertOnePoint)));
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_duplicateBulkhead"), new IconDupliquer(), "duplicateCloison", segment.duplicateCloison)));
							icon = new IconMurPorteur();
							if (!segment.murPorteur) {
								//AppUtils.changeColor(Config.COLOR_LIGHT_GREY, icon);
								icon.gotoAndStop(2);
							}
							menus.push(new MenuIconChangeRenderer(new MenuItem(AppLabels.getString("editor_bearingWall"), icon, "murPorteur", segment.menuMurPorteur)));	
							var cloison:CloisonEntity = obj2D as CloisonEntity;
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_deleteBulkhead"), new IconDelete(), "deleteCloison", cloison.removeCloison)));
							break;
					}
					type = "cloison";
					break;
					
				case "Surface" :
					var surface:Surface = displayObj as Surface;
					menus.push(new MenuEditColorRenderer(surface.bloc, new MenuItem("null")));
					if(!surface.obj2D.isSquare)
					{
						if (surface.obj2D.isLocked) 
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_unlockPoints"), new IconUnLock(), "unlockAllPoints", surface.obj2D.unlock)));
						else
							menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_lockPoints"), new IconLock(), "lockAllPoints", surface.obj2D.lock)));
					}
					else
					{
						menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_modifyFreeShape"), new IconConvertToFreeType(), "changeSurfaceType", surface.bloc.changeSurfaceType)));
						
					}
					var label:String;
					var objClassName:String = ObjectUtils.getClassName(surface.obj2D);
					switch(objClassName) {
						case "MainEntity" :
							label = AppLabels.getString("editor_deleteSurface");
							type = "surface";
							break;
						/*case "DependanceEntity" :
							label = "supprimez la dépendance";
							type = "piece";
							break;
						case "GardenEntity" :
							label = "supprimez le jardin";
							type = "piece";
							break;*/
						case "BalconyEntity" :
							label = AppLabels.getString("editor_deleteBalcony");
							type = "balcon";
							break;
						case "RoomEntity" :
							label = AppLabels.getString("editor_deleteRoom");
							type = "piece";
							break;
						default :
							label = AppLabels.getString("editor_deleteSurface");
							type = "surface";
					}
					
					/*if (objClassName == "MainEntity" || objClassName == "PieceEntity")
					{
						menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_enlargeSurface"), new IconAgrandir(), "agrandir", Editor2D.instance.agrandir)));
						menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_reduceSurface"), new IconReduire(), "reduire", Editor2D.instance.reduire)));
					}
					if (objClassName == "MainEntity")
					{
						menus.push(new MenuSurfaceRenderer(new MenuItem("test"), false));
						menus.push(new MenuSurfaceRenderer(new MenuItem("test"), true));
					}*/
					
					if (objClassName != "MainEntity")
					{
						menus.push(new MenuIconRenderer(new MenuItem(label, new IconDelete(), "deletePoint", surface.deleteSurface)));
					}
					
					break;
					
				case "NomPieceView":
					var obj:* = displayObj as NomPieceView;
					label = AppLabels.getString("editor_delete");
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_rename"), new IconRenommer(), "renommerObj", obj.renommer)));
					menus.push(new MenuIconRenderer(new MenuItem(label, new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "piecelabel";
					break;
				case "PriseView":
					obj = displayObj as PriseView;
					label = AppLabels.getString("editor_delete");
					menus.push(new MenuIconRenderer(new MenuItem(label, new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "SwitchView":
				case "LiveplugView":
				case "WifiExtenderView":
				case "WifiDuoView":
					obj = displayObj;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					type = "equipement";
					break;
				case "MainDoorView":
					obj = displayObj as MainDoorView;
					label = AppLabels.getString("editor_delete");
					menus.push(new MenuIconRenderer(new MenuItem(label, new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
					
				case "LiveboxView":					
					var livebox:LiveboxView = displayObj as LiveboxView;
					// s'il y a un étage supérieur
					if (EditorModelLocator.instance.getFloorById(livebox.floorId + 1) != null) {
						menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_levelUp"), new IconUpFloor(), "moveLB", livebox.changeLevelUp)));
					}
					// s'il y a un étage inférieur
					if (EditorModelLocator.instance.getFloorById(livebox.floorId - 1) != null) {
						menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_levelDown"), new IconDnFloor(), "moveLB", livebox.changeLevelDn)));
					}
					//menus.push(new MenuPossessionRenderer(livebox, new MenuItem("possession")));
					//menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", livebox.deleteObj)));
					type = "equipement";
					break;
				
				case "TeleView":
					obj = displayObj as TeleView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "DecodeurView":
					obj = displayObj as DecodeurView;					
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					//menus.push(new MenuIconRenderer(new MenuItem("tourner vers la droite", new IconRotateRight(), "rotateRight", obj.rotateRight)));
					//menus.push(new MenuIconRenderer(new MenuItem("tourner vers la gauche", new IconRotateLeft(), "rotateLeft", obj.rotateLeft)));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "ConsoleJeuView":
					obj = displayObj as ConsoleJeuView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "HomeLibraryView":
					obj = displayObj as HomeLibraryView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "ImprimanteView":
					obj = displayObj as ImprimanteView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "LivePhoneView":
					obj = displayObj as LivePhoneView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "LiveradioCubeView":
					obj = displayObj as LiveradioCubeView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "OrdinateurView":
					obj = displayObj as OrdinateurView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "SmartphoneView":
					obj = displayObj as SmartphoneView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "SqueezeBoxView":
					obj = displayObj as SqueezeBoxView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "TabletteView":
					obj = displayObj as TabletteView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
				case "TelephoneView":
					obj = displayObj as TelephoneView;
					//menus.push(new MenuPossessionRenderer(obj, new MenuItem("possession")));
					menus.push(new MenuIconRenderer(new MenuItem(AppLabels.getString("editor_delete"), new IconDelete(), "deleteObj", obj.deleteObj)));
					type = "equipement";
					break;
			}
			//if(menus.length == 0) return null;
			var menu:MenuRenderer = MenuRenderer.instance;
			menu = new MenuRenderer(menus, menuContainer);
			MenuContainer.instance.update(displayObj, menu, type);
			return menu;
		}
	}
}