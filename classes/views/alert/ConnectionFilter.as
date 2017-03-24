package classes.views.alert 
{
	import classes.config.Config;
	import classes.config.ModesDeConnexion;
	import classes.resources.AppLabels;
	import classes.utils.ArrayUtils;
	import classes.views.Btn;
	import classes.views.equipements.EquipementView;
	import classes.views.menus.MenuContainer;
	import flash.events.MouseEvent;
	
	/**
	 * Cette classe affiche le popup de Connexion générique qui permet de filtrer le type de connexion choisi, 
	 * soit Ethernet soit Wi-Fi.
	 * 
	 * Les équipements ne possédant pas l'option Wi-Fi ne passent pas par cet écran et arrivent directement à 
	 * <code>ConnectionEthernet</code>. Les équipements qui ne possèdent pas l'option Ethernet ne passent pas
	 * par cet écran non plus et arrivent directement à <code>ConnectionWifi</code>.
	 * 
	 * La validation de ce filtre a pour conséquence le chargement soit du popup Ethernet soit du popup Wifi, mais ne connecte
	 * pas les équipements.
	 */
	public class ConnectionFilter extends AlertConnection 
	{
		
		public function ConnectionFilter(eq:EquipementView) 
		{
			super(eq);
		}
		
		override protected function _addTitle():void
		{
			super._addTitle();
			_title.setText("connecter");
		}
		
		override protected function _addChoiceModeConnection():void
		{
			if (ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.ETHERNET) ) {
				_addRadioButton("connecter en Ethernet (filaire)", ModesDeConnexion.ETHERNET);
				//_nexty += 12
				_addText(AppLabels.getString("connections_filterTextEthernet"), "helvet", 12, Config.COLOR_DARK, 35, 460);
			}
			_nexty += 8
			if (ArrayUtils.contains(_vo.modesDeConnexionPossibles, ModesDeConnexion.WIFI) ) {
				_addRadioButton("connecter en Wi-Fi (sans fil)", ModesDeConnexion.WIFI);
				//_nexty += 12
				_addText(AppLabels.getString("connections_filterTextWifi"), "helvet", 12, Config.COLOR_DARK, 35, 460);
			}
		}
		
		override protected function _addButtons():void
		{
			_btnValidate = new Btn(0, AppLabels.getString("buttons_validateAndContinue"), null, 158, 0xffffff, 12, 30, Btn.GRADIENT_ORANGE);
			_itemsContainer.addChild(_btnValidate);
			_btnValidate.y = _itemsContainer.height +16;
			_btnValidate.x = (WIDTH - 158 - 20);
			_btnValidate.alpha = .3;
			
			super._addButtons();
		}
		
		override protected function _clickHandler(e:MouseEvent):void
		{
			super._clickHandler(e);
			
			_btnValidate.alpha = 1;
			_btnValidate.addEventListener(MouseEvent.CLICK, _valider, false, 0, true);
		}
		
		override protected function _valider(e:MouseEvent):void
		{
			//trace("valider connectionfilter");
			
			var poup:AlertConnection;
			if (_selectedConnexion === ModesDeConnexion.ETHERNET) 
			{
				poup = new ConnectionEthernet(_eqView);
			} else  {
				poup = new ConnectionWifi(_eqView);
			}
			AlertManager.addPopup(poup, Main.instance);
			poup.x = MenuContainer.instance.x - 560;
			poup.y = 109;
		}
		
		private function _removeListeners():void
		{
			_btnValidate.removeEventListener(MouseEvent.CLICK, _valider);
			_btnCancel.removeEventListener(MouseEvent.CLICK, _cancel);
		}
		
		override protected function _cancel(e:MouseEvent):void
		{
			_removeListeners()
			super._cancel(e);
		}
	}

}