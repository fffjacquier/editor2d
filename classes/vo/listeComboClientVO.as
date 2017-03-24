package classes.vo
{
	import classes.views.plan.IntersectionPoint;
	import classes.vo.listeBoxVO
	import fl.data.DataProvider;
	import classes.utils.AppUtils;
	
	public class listeComboClientVO
	{
		private var tabCombos:Array = new Array();
		//= Array(["test_eligibilite", "votre éligibilité"], ["orange_forfait_internet", "votre accès"], ["livebox", "votre livebox"], ["decodeur", "votre décodeur"], null, ["autre_operateur_internet", "votre fournisseur d'accès"], ["autre_operateur_mobile", "votre opérateur mobile"], ["autre_operateur_fixe", "votre opérateur fixe"]);
		
		public function listeComboClientVO()
		{
			//AppUtils.TRACE("listeComboClientVO() > Creation > "+this);
		}
		
		public function addListeBoxVo(pVo:listeBoxVO):void
		{
			//tabCombos.push(pVo);
			tabCombos[pVo.ref] = pVo;
			//AppUtils.TRACE("listeComboClientVO::addListeBoxVo("+pVo.ref+") > "+tabCombos[pVo.ref]);
		}
		
		public function getListeBoxVo(pRef:String):listeBoxVO
		{
			/*var lBox:listeBoxVO;
			for  (var i:int = 0; i< tabCombos.length; i++)
			{
				lBox = tabCombos[i];
				if(lBox.ref == pRef) return lBox;
			}
			return null;*/
			return tabCombos[pRef];
		}
		public function getListeBoxDp(pRef:String):DataProvider
		{
			//AppUtils.TRACE("listeComboClientVO::getListeBoxDp("+pRef+")");
			return tabCombos[pRef].dp;
		}
		
		public function getListeBoxLabel(pRef:String, pData:int):String
		{
			if (tabCombos[pRef] == null)
				return null;			
			
			var dp:DataProvider = tabCombos[pRef].dp;
			var item:Object;
			for (var i:int = 0; i < dp.length; i++)
			{
				item = dp.getItemAt(i);
				if (item.data == pData) {
					//trace(pRef, pData, item.label);
					return item.label;
				}
			}
			return null;			
		}
		
		public function toString():String
		{
			var strRetour:String = "";
			for (var key:Object in tabCombos) 
			{
				strRetour += "> "+tabCombos[key]+"\n";
			}
			if (strRetour == ""){
				strRetour = "listeComboClientVO[ VIDE !]";
			}else{
				strRetour = "listeComboClientVO[\n" + strRetour + "]";
			}
			return strRetour;
		}
	}
}