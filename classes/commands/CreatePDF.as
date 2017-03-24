package classes.commands
{	
	import classes.config.Config;
	import classes.controls.LegendeLoadedEvent;
	import classes.model.ApplicationModel;
	import classes.model.EditorModelLocator;
	import classes.resources.AppLabels;
	import classes.services.LoadBinary;
	import classes.services.mailPDF;
	import classes.utils.AppUtils;
	import classes.utils.MapDict;
	import classes.utils.PNGEncoderSekvens;
	import classes.utils.StringUtils;
	import classes.views.CommonTextField;
	import classes.views.items.ItemListeCourse;
	import classes.views.items.ItemListePDF;
	import classes.vo.EquipementVO;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.display.*;
	import org.alivepdf.fonts.CodePage;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.EmbeddedFont;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.images.ColorSpace;
	import org.alivepdf.layout.*;
	import org.alivepdf.pdf.*;
	import org.alivepdf.saving.*;

	public class CreatePDF
	{
		private var _editorModel:EditorModelLocator = EditorModelLocator.instance;
		private var _appModel:ApplicationModel = ApplicationModel.instance;
		private var _resizeLeft:Resize = new Resize(Mode.NONE, Position.LEFT);
		private var _resizeCenter:Resize = new Resize(Mode.NONE, Position.CENTERED);
		private var _resizeFit:Resize = new Resize(Mode.FIT_TO_PAGE, Position.CENTERED);
		private var _pdf:*; //-- type : PDF ou mailPDF;
		private var _printButton:Sprite;
		private var _margin:int = 6;		
		private var _helvet35:EmbeddedFont;
		private var _helvet55:EmbeddedFont;
		private var _helvet55Bold:EmbeddedFont;
		private var _verdana:EmbeddedFont;		
		private var _etagesCount:int;
		private var _nombrePages:int;
		private var _numeroPage:int = 1;
		private var _count:int = 0;
		private var _nomProjet:String;
		private var _xml:XML;
		private var _php:String;
		private var _email:String;
		private var _legendesListe:Array;
		private var _legendesLoaded:int;
		
		public function CreatePDF(file:String, email:String = null, pCallback:Function = null) 
		{
			_php = file;
			_email = email;
			
			_xml = _appModel.projetvo.xml_plan;
			_etagesCount = _xml.floors.floor.length();
			_nomProjet = (_appModel.projetvo.nom == AppLabels.getString("editor_nameTheProject")) ? "" : _appModel.projectLabel/*projetvo.nom*/;
			_countNbPages();
			
			if(_php == "mailPDF"){
				_pdf = new mailPDF(pCallback, Orientation.PORTRAIT, Unit.MM);
			}else {
				_pdf = new PDF(Orientation.PORTRAIT, Unit.MM);
			}
			_pdf.setDisplayMode(Display.REAL, Layout.SINGLE_PAGE);
			_pdf.setMargins(_margin+4, _margin, _margin, 0);
			
			new LoadBinary("fonts/HelvN35.TTF" , _handleHelvet35);
			
			//_addFirstPage();  //cette action dans _handleVerdanaPS
		}
		
		private function _countNbPages():void 
		{
			// on a tjs premiere page, derniere page,
			_nombrePages = 2;
			var etages:int
			// plus une page par étage si cet étage contient des equipements
			if (_etagesCount > 0) {
				for (var i:int = 0; i < _etagesCount; i++) 
				{
					if (_xml.floors.floor[i].blocs.bloc.equipements.equipement.length() > 0) {
						etages++;
					}
				}
				_nombrePages += etages;
			}
			// plus une page de légendes
			if (etages > 0) _nombrePages++;
			
			// plus mémo s'il y a mémo
			if (_appModel.memos != "") _nombrePages++;
			trace("_nombrePages:",_nombrePages);
		}
		
		private function _addFirstPage():void
		{
			_pdf.addPage();
			
			//titre
			_pdf.textStyle (new RGBColor(0xff6600));
			_pdf.setFont(_helvet35);
			_pdf.setFontSize (40);
			_pdf.addCell(200, 20, AppLabels.getString("pdf_title"), 0, 0, Align.CENTER);
			
			//data projet
			_pdf.textStyle ( new RGBColor( 0x333333) );
			_pdf.setXY( _pdf.getMargins().left, 185 );
			var font:CoreFont = new CoreFont ( FontFamily.HELVETICA_BOLD );
			_pdf.setFont( font );
			_pdf.writeText ( 20, _nomProjet);
			_pdf.newLine(6);
			font = new CoreFont ( FontFamily.HELVETICA );
			_pdf.setFont( font );
			_pdf.writeText ( 20, _getProjetTypeLabel());
			
			// perso
			_pdf.setFont(_helvet55);			
			_pdf.textStyle ( new RGBColor (Config.COLOR_GREY) );
			_pdf.newLine(20);
			var nom:String = _appModel.clientvo.nom;
			var prenom:String = _appModel.clientvo.prenom;
			var nomprenom:String;
			if (nom != null && prenom != null) {
				nomprenom = StringUtils.capitalize(prenom) + " " + StringUtils.capitalize(nom);
			} else {
				if (prenom == null && nom == null) nomprenom = "";
				else if (prenom == null) nomprenom = StringUtils.capitalize(nom);
				else if (nom == null) nomprenom = StringUtils.capitalize(prenom);
				else nomprenom = "";
			}
			//if(nomprenom != "") {
				_pdf.writeText(20, nomprenom);
				_pdf.newLine(6);
			//}
			_pdf.writeText(20, _appModel.clientvo.adresse || "");
			_pdf.newLine(6);
			_pdf.writeText(20, _appModel.clientvo.cp || " ");
			_pdf.writeText(20, _appModel.clientvo.ville || "");
			_pdf.newLine(10);
			_pdf.writeText(20, _appModel.clientvo.telephone_fixe || "");
			_pdf.newLine(6);
			_pdf.writeText(20, _appModel.clientvo.telephone_mobile || "");
			_pdf.newLine(6);
			_pdf.writeText(20, _appModel.clientvo.email || "");
			
			_writeFooter();
			
			//image
			new LoadBinary("images/fond_PDF.jpg", _onFirstPageImageLoaded);
		}
		
		private function _getProjetTypeLabel():String
		{
			var str:String;
			if(_appModel.projetvo.ref_type_projet == "fibre") str = AppLabels.getString("editor_projectFibre");
			else if(_appModel.projetvo.ref_type_projet == "adsl") str = AppLabels.getString("editor_projectADSL");
			else if(_appModel.projetvo.ref_type_projet == "adslSat") str = AppLabels.getString("editor_projectADSLSat");
			else if (_appModel.projetvo.ref_type_projet == "adsl2tv") str = AppLabels.getString("editor_projectADSL2dec");
			else str = AppLabels.getString("pdf_project");
			return str;
		}
		
		private function _onFirstPageImageLoaded(byteArray:ByteArray):void
		{						
		  _pdf.addImageStream(byteArray, ColorSpace.DEVICE_RGB, _resizeLeft, 25, 30);
		  //_addEtages();
		  _addRecapTextPage();
		}
		
		private function _addEtages():void
		{
			trace("pdf _addEtages", _etagesCount);
			if (_etagesCount == 0)
			{
				// si aucun étage encore créé, on crée la page suivante
				_addMemo();
				return;
			}
			_count = 0;
			_addEtage();
		}
		
		private function _addEtage():void
		{
			trace("pdf add etage " + _count, _appModel.pdfCapturesArr.length );
			
			// we need for floor which index attribute is equal to _count
			if (_xml.floors.floor.(@index == _count).blocs.bloc.equipements.equipement.length() > 0) {
			//if (_xml.floors.floor[_count].blocs.bloc.equipements.equipement.length() > 0) {
			
				_pdf.addPage();
				
				var bmd:BitmapData = _appModel.pdfCapturesArr[_count];
				var x:int; 	var y:int; var width:int; var height:int;
				var ratio:Number = bmd.height / bmd.width;
				if (ratio >= ((297 - 50) / 210) )
				{
					height = 220;
					width = height / ratio;
					x = (210 - width) / 2 - _margin;
					y = 20 + ((297 - 50) - height) / 2;
					width = 0;
				}
				else 
				{
					width = 180;
					height = width / ratio;
					x = (210 - width) / 2 - 4;
					y = 20 + ((297 - 50) - height) / 2;
					height = 0;
				}
				
				var pngEncoder:PNGEncoderSekvens = new PNGEncoderSekvens();
				var byteArray:ByteArray = pngEncoder.encode(bmd);
				//_pdf.setXY(100, 200);
				_pdf.addImageStream(byteArray, ColorSpace.DEVICE_RGB, null ,x, y, width, height);
				
				var e:EtagePDF = new EtagePDF();
				var etageXML:XMLList = _xml.floors.floor.(@index == _count);
				//trace(etageXML);
				//trace("@mdc", etageXML.blocs.bloc.equipements.equipement.@mdc.length(), etageXML.blocs.bloc.equipements.equipement.@mdc);
				
				var a:Array=[], z:String;
				for (z in etageXML.blocs.bloc.equipements.equipement.@mdc) {
					a[z] = etageXML.blocs.bloc.equipements.equipement.@mdc[z];
				}
				var ss:String = String(a);
				//trace("ss=", ss);
				
				e.label.htmlText = "<b>" + etageXML.name.toString();
				_addSprite(e, 0, 22);
				
				_numeroPage++;
				_writeFooter("etage");
				_writeHeader();
				
				// checks if ethernets, wifi,  fibre
				//var isEthernet:Boolean = (ss == "ethernet") || (ss === "ethernet-liveplug") || (ss === "wifiextender-ethernet");
				var isEthernet:Boolean = (ss.indexOf("ethernet-liveplug") != -1) || (ss.indexOf("wifiextender-ethernet") != -1) || (ss.indexOf(",ethernet,") != -1 || ss.indexOf(",duo-ethernet,") != -1 || ss == ",ethernet");
				//trace("isEthernet", isEthernet);
				var isFibre:Boolean = (ss.indexOf("kitfibre") != -1);
				//trace("isFibre", isFibre);
				//var isDect:Boolean = (ss.indexOf("usb") != -1);
				ss = ss.replace("wifiextender", "extender");
				var isWifi:Boolean = (ss.indexOf("wifi") != -1);
				//trace("isWifi", isWifi);
				
				var fiberArrivalList:XMLList = etageXML.blocs.bloc.fiberLine;
				var fiberArrivalBool:Boolean = (fiberArrivalList.toString().length != 0);
				
				//if none do not display info
				if (!isEthernet && !isWifi /*&& !isDect && !isFibre*/) {
					
				} else {
					_pdf.setFont(_helvet55);			
					_pdf.textStyle ( new RGBColor (Config.COLOR_GREY) );
					var posy:int = _pdf.getMargins().bottom - 38;
					_pdf.setXY(_pdf.getMargins().left, posy);
					_pdf.writeText(4, AppLabels.getString("pdf_connectionsLegend"));
					
					var posx:int = _pdf.getX();
					var initialx:int = posx;
					if (isEthernet) {
						var bulle:MovieClip = new PDFEthernet();
						AppUtils.changeColor(Config.COLOR_GREEN_CONNECT_LINE, MovieClip(bulle.getChildAt(0)).getChildAt(0));
						_addSprite(bulle, posx, posy - 8);
						posx += 35;
					}
					if (isWifi) {
						bulle = new PDFWifi();
						AppUtils.changeColor(Config.COLOR_GREEN_CONNECT_LINE, MovieClip(bulle.getChildAt(0)).getChildAt(0));
						_addSprite(bulle, posx, posy - 8);
						posx += 30;
					}
					if (isFibre) {
						_addSprite(new PDFFibre(), posx, posy - 8);
						posx += 30;
					}/*
					if (isDect) {
						_addSprite(new PDFDect(), posx, posy - 8);
						posx += 30;
					}*/
					if (fiberArrivalBool) {
						_addSprite(new PDFFiberArrival(), initialx, posy);
					}
				}
			}
			
			_count ++;
			
			if (_count < _etagesCount)
			{
				_addEtage();
			}
			else
			{
				if(_xml.floors.floor.blocs.bloc.equipements.equipement.length() > 0)
					_addLegendes();
				else 
					_addMemo();
			}
			
		}
		
		private function _addLegendes():void
		{
			_pdf.addPage();
			_numeroPage++;
			_writeFooter("liste");
			_writeHeader();
			
			//texte legende
			_pdf.setFont(_helvet55);			
			_pdf.textStyle ( new RGBColor (Config.COLOR_GREY) );
			var posy:int = _pdf.getMargins().top + 30;
			_pdf.setXY(_pdf.getMargins().left, posy);
			_pdf.writeText(4, AppLabels.getString("pdf_equipmentsLegend"));
			_pdf.newLine(5);
			
			var equipements:XMLList = _xml.floors.floor.blocs.bloc.equipements.equipement.(@type != "MainDoorItem");
			var nbEq:int = equipements.length();
			var mapEq:MapDict = new MapDict();
			var a:Array = [], z:String;
			for (z in equipements) {
				var vo:EquipementVO = _appModel.getVOFromXML(equipements[z].@vo);
				trace("-->equipement xml::", vo.name, vo.screenLabel)
				a[z] = { "nom": vo.name, "label": vo.screenLabel, "image": vo.imagePath, "type": equipements[z].@type};	
			}
			
			_legendesListe = [];
			var i:int = -1;
			// do this first, for the order
			// if there is livebox or decodeur in equipements, push them in liste
			if (_hasItem(a, "LiveboxItem") !== -1) _legendesListe.push(a[_hasItem(a, "LiveboxItem")]);
			if (_hasItem(a, "DecodeurItem") !== -1) _legendesListe.push(a[_hasItem(a, "DecodeurItem")]);
			
			// do that now to treat the cases of paires and solo
			//trace("count liveplug", _countItem(a, "LivePlugItem", "Liveplug HD+"));
			if (_countItem(a, "LivePlugItem", AppLabels.getString("check_liveplugHD")) !== -1) {
				_legendesListe.push(a[_countItem(a, "LivePlugItem", AppLabels.getString("check_liveplugHD"))]);
			}
			//trace("count wfe", _countItem(a, "WifiExtenderItem", "Wi-Fi Ext "));
			//trace("count wfe", _countItem(a, "WifiExtenderItem", "Wi-Fi Ext"));
			/*if (_countItem(a, "WifiExtenderItem", "Wi-Fi Ext 2") !== -1) {
				liste.push(a[_countItem(a, "WifiExtenderItem", "Wi-Fi Ext 2")]);
			}*/
			if (_countItem(a, "WifiExtenderItem", AppLabels.getString("check_wfe")) !== -1) {//FJ string left 25/07
				_legendesListe.push(a[_countItem(a, "WifiExtenderItem", AppLabels.getString("check_wfe"))]);
			}
			
			// le reste...
            while (++i < a.length) {
				if (_hasItem(_legendesListe, a[i].type) === -1) {
					trace("\thas", a[i].type, a[i].nom, a[i].label);
					_legendesListe.push(a[i]);
				}
			}
			
			// load ALL elementS from the liste
			// when loaded pop the _legendeListe array
			// when _legendeListe is empty, _addSprite and go to memo
			_appModel.addLegendesLoadedListener(_onLegendesLoaded);
			
			for (i = 0; i < _legendesListe.length; i++) {
				trace("---"+_legendesListe[i].type, _legendesListe[i].nom+"---" );
				var sprite:* = _legendesListe[i].image;
				//_addSprite(new ItemListePDF(_legendesListe[i].label, _legendesListe[i].type, sprite), xpos, ypos);
				(new ItemListePDF(_legendesListe[i].label, _legendesListe[i].type, sprite, i)/*, xpos, ypos*/);
			}
			
		} 
		
		private function _onLegendesLoaded(e:LegendeLoadedEvent):void
		{
			var xpos:int = 6 + Math.round((e.num) % 2) * (90);
			var ypos:int = 35 + Math.floor((e.num) / 2) * (25);
			_addSprite(e.item, xpos, ypos);
			/*var pngEncoder:PNGEncoderSekvens = new PNGEncoderSekvens();
			var byteArray:ByteArray = pngEncoder.encode(e.item);
			_pdf.addImageStream(byteArray, ColorSpace.DEVICE_RGB, _resizeLeft, xpos, ypos);*/
			_legendesLoaded++;
			//trace("CreatePDF::_onLegendesLoaded()", e.num, _legendesLoaded, _legendesListe.length);
			if (_legendesLoaded == _legendesListe.length) {
				_addMemo();
			}
		}
		
		private function _countItem(inArray:Array, type:String, nom:String=""):int
		{
			if (nom == "") return _hasItem(inArray, type);
			
			var i:int = -1;
            var item:*;
             
            while (++i < inArray.length) {
                item = inArray[i];
				trace("_countItem()", item["type"], type, item["nom"], nom, i);
                if (item["type"] == type && item["nom"] == nom)
					return i;
			}
             
            return -1;
		}
		
		private function _hasItem(inArray:Array, type:String):int 
		{
            var i:int = -1;
            var item:*;
             
            while (++i < inArray.length) {
                item = inArray[i];
               // trace(item.type, type, i);
                if (item["type"] == type)
						return i;
			}
             
            return -1;
        }
		
		private function _addMemo():void
		{
			//trace("memo");
			if (_appModel.memos == "") 
			{
				// si mémo vide  on crée la page suivante
				//_addRecapTextPage();
				_setPDFReady();
				return;
			}
			
			_pdf.addPage();
			_numeroPage++;
			_writeFooter("memo");
			_writeHeader();
			
			//titre memo			
			_pdf.textStyle (new RGBColor(0x333333));
			_pdf.setFont(_helvet35);
			_pdf.setFontSize (30);
			_pdf.setXY(_pdf.getMargins().left + 10, 60);
			_pdf.addCell(400, 15, AppLabels.getString("check_yourMemos"));
			
			// texte memo
			var font:CoreFont = new CoreFont ( FontFamily.HELVETICA_BOLD );
			_pdf.setFont( font );
			_pdf.setXY(_pdf.getMargins().left + 10, 80);
			var str:String = StringUtils.replace(_appModel.memos, "\r", "\n");
			str.replace("\r\n", "\n");
			var memo:Array =  str.split("\n");
			for (var i:int = 0; i < memo.length; i++) {
				//_pdf.addText(memo[i], _pdf.getMargins().left + 10, 90 + i * 5);
				
				//_pdf.writeText(6, memo[i]);
				_pdf.addMultiCell(_pdf.getMargins().right - 45, 6, memo[i], 0);
				
				_pdf.setXY(_pdf.getMargins().left + 10, _pdf.getY());
			}
			//_pdf.writeFlashHtmlText(20, _appModel.memos);
			
			_pdf.lineStyle(new RGBColor(0xcccccc), 0.1, 0);
			_pdf.moveTo(10 , 65);
			_pdf.drawRoundRect(new Rectangle(_pdf.getMargins().left + 5, 75, _pdf.getMargins().right - 34, 120), 10);
			_pdf.end();
			
			//_addRecapTextPage();
			_setPDFReady();
		}
	
		private function _addRecapTextPage():void
		{
			//trace("recap page");
			_pdf.addPage();
			_numeroPage++;
			_writeFooter("last");
			_writeHeader();
			
			var ypos:int = 40;
			var xpos:int = 20;
			//trace("Civ.", _appModel.clientvo.id_civilite, _appModel.clientvo.nom);
			if(_appModel.clientvo.nom != null) {
				_pdf.textStyle(new RGBColor(0x333333));
				var font:CoreFont = new CoreFont ( FontFamily.HELVETICA_BOLD );
				_pdf.setFont( font );
				_pdf.setXY( xpos, ypos);
				var civ:String;
				if (_appModel.clientvo.id_civilite == 1) civ = AppLabels.getString("common_miss");
				else if(_appModel.clientvo.id_civilite == 2) civ = AppLabels.getString("common_madam");
				else if (_appModel.clientvo.id_civilite == 3) civ = AppLabels.getString("common_mister");
				else civ = AppLabels.getString("common_noCiv");
				var nom:String = StringUtils.capitalize(_appModel.clientvo.nom);
				_pdf.writeText(5, civ + " " + nom +",");
				ypos = 50;
			}
			
			_pdf.textStyle ( new RGBColor( 0xff6600) );
			//_pdf.setFont(new CoreFont(new Helvet45().fontName));
			_pdf.setFont(_helvet55);
			_pdf.setXY(xpos, ypos);
			ypos = 60;
			if (_appModel.profilevo.user_profile == "VENDEUR") {
				_pdf.addMultiCell (190, 10, AppLabels.getString("pdf_happy"));
			} else {
				_pdf.addMultiCell (190, 10, AppLabels.getString("pdf_happy2"));
			}

			// add text message
			_pdf.textStyle ( new RGBColor (0x333333) );
			//_pdf.setFont(new CoreFont(new Verdana().fontName), 12);
			_pdf.setFont(_helvet55);
			_pdf.setXY(20, ypos);
			ypos = 70;			
			if (_appModel.listeDeCoursesSynthese != null && _appModel.listeDeCoursesSynthese.length > 0) 
			{
				_pdf.addMultiCell(190, 5, AppLabels.getString("pdf_bodyText"), 0, 'L'); 
				_pdf.setXY(xpos, ypos + 10);
				
				var keys:Array = _appModel.listeDeCoursesSynthese.getValues();
				keys.sortOn("ordre");
				var listeLength:int = keys.length;
				for (var i:int = 0; i < listeLength; i++) {
					_pdf.writeText(5, "- " + (keys[i] as ItemListeCourse).getLabel() + "\n" );
					_pdf.setX(xpos);
				}
			}
			
			_pdf.setXY(xpos, ypos +20 + listeLength*5);
			//_pdf.addMultiCell(190, 5, "La réalisation de votre projet de 'maison connectée' pourrait nécessiter une évolution\nde votre offre Orange actuelle. Les tarifs et les conditions de nos offres figurent\nsur notre site orange.fr." ); 
			//_pdf.setXY(xpos, ypos + 40 + listeLength*5);
			
			if (_appModel.profilevo.user_profile == "VENDEUR") {
				_pdf.addMultiCell(190, 5, AppLabels.getString("pdf_signature1") ); 
				_pdf.setXY(xpos, ypos + 30 + listeLength*5);
			}
			if (_appModel.profilevo.user_profile == "VENDEUR") _pdf.addMultiCell(190, 5, AppLabels.getString("pdf_signature2") ); 
			else _pdf.addMultiCell(180, 5, AppLabels.getString("pdf_signature2b")); 
			_pdf.setXY(xpos, ypos + 40 + listeLength*5);
			_pdf.addMultiCell(190, 5, AppLabels.getString("pdf_signature3"));
			_pdf.setXY(xpos, ypos + 45 + listeLength*5);
			_pdf.addMultiCell(190, 5, AppLabels.getString("pdf_signature4") ); 
			_pdf.setXY(xpos, ypos + 55 + listeLength*5);
			_pdf.addMultiCell(190, 5, AppLabels.getString("pdf_note1") ); 
			
			_addEtages();
			
		}
		
		private function _setPDFReady():void
		{
			_appModel.notifyPDFReady();
			
			if (ExternalInterface.available) {
				if (_php == "mailPDF") {
					_pdf.saveAndMail(_php + '.php', AppLabels.getString("pdf_pdfName") + _appModel.projetvo.id + ".pdf", _email);
				}else {
					_pdf.save(Method.REMOTE, _php + '.php', Download.ATTACHMENT, AppLabels.getString("pdf_pdfName") + _appModel.projetvo.id + ".pdf");
				}
			} else {
				var fileRef:FileReference = new FileReference();
				fileRef.save(_pdf.save(Method.LOCAL) as ByteArray, AppLabels.getString("pdf_pdfName")+_appModel.projetvo.id+".pdf");
			}
		}
		//------------ TITRE ---------------------
		
		private function _writeHeader():void
		{
			_pdf.textStyle(new RGBColor(Config.COLOR_GREY));
			_pdf.setFont(_helvet55, 10);
			_pdf.addText("" + (_numeroPage) +" / "+_nombrePages, _pdf.getMargins().right - 10, _pdf.getMargins().top + 10);
			
			_pdf.textStyle (new RGBColor(0xff6600));
			_pdf.setFont(_helvet35);
			_pdf.setFontSize (30);
			_pdf.addCell(400, 15, AppLabels.getString("pdf_title"));
			
			//nom projet
			_pdf.textStyle ( new RGBColor( 0x333333) );
			_pdf.setXY( _pdf.getMargins().left, 15 );
			var font:CoreFont = new CoreFont ( FontFamily.HELVETICA_BOLD );
			_pdf.setFont( font );
			_pdf.writeText ( 15, _nomProjet);
			
			//draw line
			_pdf.lineStyle(new RGBColor(0xcccccc), .01, 0);
			_pdf.moveTo(_pdf.getMargins().left, 35);
			_pdf.lineTo(_pdf.getMargins().right, 35);
			_pdf.end();//without this line, no line shows up
			//_pdf.addImage(e, null, _pdf.getMargins().left, _pdf.getMargins().top+ 110, pixelsToInch(e.width), pixelsToInch(e.height));
		}
		
		private function _writeFooter(page:String = ""):void
		{
			//add logo
			var logo:Logo = new Logo();
			//trace(273, _pdf.getMargins().bottom);
			if(page == "" || page == "last") _addSprite(logo, 180, 273);
			
			if (page === "etage") {
				_pdf.textStyle ( new RGBColor (0x333333) );
				_pdf.setFont(_helvet55, 8);
				_pdf.addText(AppLabels.getString("pdf_plan"), _pdf.getMargins().left, _pdf.getMargins().bottom - 22);
			} else if (page === "memo" || page === "") {
				
			} else if (page === "liste") {
				_pdf.textStyle ( new RGBColor (0x333333) );
				_pdf.setFont(_helvet55, 8);
				_pdf.addText(AppLabels.getString("pdf_photos"), _pdf.getMargins().left, _pdf.getMargins().bottom - 22);
				_pdf.addText(AppLabels.getString("pdf_condition1"), _pdf.getMargins().left, _pdf.getMargins().bottom - 19);
			} else if (page === "last") {
				_pdf.textStyle ( new RGBColor (0x333333) );
				_pdf.setFont(_helvet55, 8);
				_pdf.addText(AppLabels.getString("pdf_legal1"),_pdf.getMargins().left, _pdf.getMargins().bottom - 22);
				_pdf.addText(AppLabels.getString("pdf_legal2"), _pdf.getMargins().left, _pdf.getMargins().bottom - 19);
				_pdf.addText(AppLabels.getString("pdf_legal3"), _pdf.getMargins().left, _pdf.getMargins().bottom - 16);
				_pdf.addText(AppLabels.getString("pdf_boutiques"), _pdf.getMargins().left, _pdf.getMargins().bottom - 10);
			}
			
			if(page != "") {
				// draw line
				_pdf.lineStyle(new RGBColor(0xcccccc), .05, .5);
				_pdf.moveTo(_pdf.getMargins().left - _margin -4, _pdf.getMargins().bottom - 25);
				_pdf.lineTo(_pdf.getMargins().right + _margin, _pdf.getMargins().bottom -25);
				_pdf.end();//without this line, no line shows up
			}
			
			// num de dossier
			_pdf.textStyle ( new RGBColor (Config.COLOR_GREY) );
			_pdf.setFont(_helvet55, 10);
			_pdf.addText("n° " + _appModel.projetvo.id, _pdf.getMargins().left, _pdf.getMargins().bottom - 5 );
		}
		
		//methode pour ajouter un Sprite si on veut pouvoir faire ça a sa façon
		// mais on peut utiliser aussi_pdf.addImage qui ajoute aussi un sprite (à sa façon) 
		private function _addSprite(sp:Sprite, xx:int, yy:int, tomtom:Boolean = false):void
		{
			var bmd:BitmapData;
			bmd = new BitmapData(sp.width + 3, sp.height +3, false, 0xffffff);
			bmd.draw(sp, null, null, null, null, true);
			var pngEncoder:PNGEncoderSekvens = new PNGEncoderSekvens();
			var byteArray:ByteArray = pngEncoder.encode(bmd);
			_pdf.addImageStream(byteArray, ColorSpace.DEVICE_RGB, _resizeLeft, xx, yy);
		}
		
        protected function pixelsToInch(param1:int) : Number
        {
            return param1 / 72;
        }
		
		// ---------------  FONTS  --------------------
		
		private var _fontByte:ByteArray;
		private function _handleHelvet35(fontByte:ByteArray):void
		{
			_fontByte = fontByte;
			new LoadBinary("fonts/Helvn35.afm" , _handleHelvet35PS);
		}
		
		private function _handleHelvet35PS(fontByte:ByteArray):void
		{
			_helvet35 = new EmbeddedFont(_fontByte, fontByte, CodePage.CP1252 );
			new LoadBinary("fonts/HelvN55.TTF" , _handleVerdana);
		}
		
		//insérer ici autres polices s'il le faut, de la même façon
		
		private function _handleVerdana(fontByte:ByteArray):void
		{
			_fontByte = fontByte;
			new LoadBinary("fonts/Helvn55.afm" , _handleVerdanaPS);
		}
		
		private function _handleVerdanaPS(fontByte:ByteArray):void
		{
			_helvet55 = new EmbeddedFont(_fontByte, fontByte, CodePage.CP1252 )
			_addFirstPage();
		}
	}
}