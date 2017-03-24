package classes.views
{
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	import classes.vo.ClientVO;
	import classes.vo.ProjetVO;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	
	/**
	 * <code>LigneResultatClient</code> est appelé par ScreenRecherche
	 * 
	 * C'est la classe correspondant à une ligne de résultat de la recherche.
	 * 
	 * <p>Etend la classe RechercheLigne qui est dans editeur.swf</p>
	 * 
	 */
	public class LigneResultatClient extends RechercheLigne
	{
		public var id:int;
		public var vo:ClientVO;
		public var btn:Btn;
		
		public function LigneResultatClient()
		{
			//AppUtils.TRACE("LigneResultatClient::CONSTRUCT");
		}
		
		//-- Affecte a l'appmodel l'id client et le VO et affiche le formulaire d'inscription client
		public function modifierClient():void
		{
			//-- Copie les valeurs dans le VO de l'Appmodel
			vo.modifierInscriptionClient();
		}
		
		//-- Affecte a l'appmodel l'id client et le VO
		public function setAsCurrentClient(pTemp:String = ""):void
		{
			//-- Copie les valeurs dans le VO de l'Appmodel
			ApplicationModel.instance.clientvo = vo;
			
			AppUtils.TRACE("LigneResultatClient::setAsCurrentClient("+pTemp+") > id=" + ApplicationModel.instance.clientvo.id + "/ name=" + ApplicationModel.instance.clientvo.nom);
			
			//-- Affiche l'editeur
			ApplicationModel.instance.screen = ApplicationModel.SCREEN_HOME;
			//ApplicationModel.instance.projetvo.duree_utilisation = getTimer();
			//ApplicationModel.instance.projetvo.durationBetween2Savings = getTimer();
		}
		
		//-- Affecte a l'appmodel l'id projet, l'id client et le VO
		public function setAsCurrentProjet(pIdProjet:int):void
		{				
			//AppUtils.TRACE("LigneResultatClient::setAsCurrentProjet("+pIdProjet+") ?> currentProjetId=" + ApplicationModel.instance.projetvo.id);
			
			//-- Charge le projet
			if (ExternalInterface.available)
			{
				//AppUtils.TRACE("LigneResultatClient::setAsCurrentProjet LoadProjet(_projetResult).call(" + pIdProjet + ")> ");
				//new LoadProjet(_projetResult).call(pIdProjet);
				ApplicationModel.instance.projetvo.loadDb(pIdProjet, _projetResult);
			}
			else
			{
				//-- Affecte le numero de projet
				//-- TEMPORAIRE
				var pvo:ProjetVO = new ProjetVO();
				
				pvo.id = 22;
				//pvo.id_agence = 1;
				pvo.duree_creation = 15;//secs
				pvo.duree_utilisation = 15;
				pvo.nom = "Mon projet automatique";
				pvo.id_type_logement = 2;
				pvo.ref_type_projet = "adsl";
				pvo.xml_plan = new XML('<maison><title><![CDATA[Mon projet test]]></title><floors><floor><name><![CDATA[Niveau 0]]></name><blocs><bloc type="blocMaison" classz="[class MainEntity]" positionx="0" positiony="0"><points><point x="146.98162914832497" y="73.49081457416248"/><point x="558.5" y="73.468370851675"/><point x="558.5" y="242.5"/><point x="338.05" y="242.5"/><point x="338.0459271291876" y="389.4775562775125"/><point x="146.97755627751258" y="389.5"/></points><cloisons><cloison><point x="146.98044935646453" y="165.02945696275108"/><point x="558.5" y="164.9977754148111"/></cloison></cloisons></bloc><bloc type="blocJardin" classz="[class GardenEntity]" positionx="614.15" positiony="71.8"><points><point x="-511.3" y="332.35"/><point x="76.65" y="332.35"/><point x="76.65" y="-35.1"/><point x="-511.3" y="-35.1"/></points><cloisons/></bloc><bloc type="blocBalcon" classz="[class BalconEntity]" positionx="597" positiony="110"><points><point x="-38.5" y="132.5"/><point x="49.7" y="132.5"/><point x="51.45459271291876" y="-36.74540728708125"/><point x="-38.5" y="-36.55"/></points><cloisons/></bloc></blocs></floor><floor><name><![CDATA[1er]]></name><blocs><bloc type="blocMaison" classz="[class MainEntity]" positionx="0" positiony="0"><points><point x="146.98162914832497" y="73.49081457416248"/><point x="558.5" y="73.468370851675"/><point x="558.5" y="242.5"/><point x="338.05" y="242.5"/><point x="338.0459271291876" y="389.4775562775125"/><point x="146.97755627751258" y="389.5"/></points><cloisons><cloison><point x="298.0170180280347" y="73.48257728369404"/><point x="465.96972618440884" y="242.5"/></cloison></cloisons></bloc></blocs></floor><floor><name><![CDATA[2eme]]></name><blocs><bloc type="blocMaison" classz="[class MainEntity]" positionx="0" positiony="0"><points><point x="146.98162914832497" y="73.49081457416248"/><point x="558.5" y="73.468370851675"/><point x="558.5" y="242.5"/><point x="338.05" y="242.5"/><point x="338.0459271291876" y="389.4775562775125"/><point x="146.97755627751258" y="389.5"/></points><cloisons><cloison><point x="280.0240789913736" y="73.48355859718835"/><point x="280.8499354371867" y="389.48427476764886"/></cloison></cloisons></bloc></blocs></floor></floors>');
				
				ApplicationModel.instance.projetvo = pvo;
				
				AppUtils.TRACE("LigneResultatClient::setAsCurrentProjet() TEMP > id=" + ApplicationModel.instance.projetvo.id + "/ name=" + ApplicationModel.instance.projetvo.nom);
				
				//-- Affecte le client (et affiche l'editeur)
				setAsCurrentClient("setAsCurrentProject");
			}
		}
		
		private function _projetResult():void
		{
			//AppUtils.TRACE("LigneResultatClient::setAsCurrentProjet()::_projetResult() > id=" + ApplicationModel.instance.projetvo.id + "/ name=" + ApplicationModel.instance.projetvo.nom);
			AppUtils.TRACE("LigneResultatClient::setAsCurrentProjet()::_projetResult() > \n" + ApplicationModel.instance.projetvo);
			
			//-- Affecte le client (et affiche l'editeur)
			setAsCurrentClient();
		}
	}
}