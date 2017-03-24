package classes.services 
{
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	import com.hurlant.util.Base64;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	import org.alivepdf.events.ProcessingEvent;
	import org.alivepdf.pdf.PDF;

	/**
	 * Cette classe étend la classe Alivepdf PDF
	 * Le but initial était de ne pas modifier la lib originale
	 * 
	 * Cette classe permet de générer le pdf et de l'envoyer par mail à l'utilisateur.
	 */
	public class mailPDF extends PDF 
	{
		private var _callback:Function = null;
		
		public function mailPDF(pCallback:Function, orientation:String = 'Portrait', unit:String = 'Mm') 
		{
			_callback = pCallback;
		}
		
		/**
		 * Envoie le pdf par mail
		 * 
		 * @param url Le nom du fichier php à appeler
		 * @param fileName Le nom du fichier pdf à générer (voir dans les labels_fr.xml)
		 * @param email L'adresse email du destinataire du mail
		 */
		public function saveAndMail(url:String = '', fileName:String = 'generated.pdf', email:String = ''):void
		{
			AppUtils.TRACE("PDF::saveAndMail("+url+", "+fileName+", "+email+")");
			dispatcher.dispatchEvent(new ProcessingEvent(ProcessingEvent.STARTED));
			var started:Number = getTimer();
			finish();
			dispatcher.dispatchEvent(new ProcessingEvent(ProcessingEvent.COMPLETE, getTimer() - started));
			buffer.position = 0;
			
			//-- Envoi du pdf
			var myRequest:URLRequest = new URLRequest(url);
			myRequest.method = URLRequestMethod.POST;
			
			var myVars:URLVariables = new URLVariables();			
			myVars.name = fileName;
			myVars.email = email;
			myVars.pdf = com.hurlant.util.Base64.encodeByteArray(buffer);
			myVars.size = myVars.pdf.length;
			myVars.profile = (ApplicationModel.instance.profilevo.user_profile == "VENDEUR") ? "vendeur" : "";
			
			myRequest.data = myVars;
			
			var myLoader:URLLoader = new URLLoader();
			myLoader.addEventListener(Event.COMPLETE, saveAndMailResult);
			myLoader.addEventListener(IOErrorEvent.IO_ERROR, saveAndMailError);
			
			AppUtils.TRACE("buffer.length = "+buffer.length + " / myVars.pdf.length = " + myVars.pdf.length + " / myVars.size = " + myVars.size);
			
			myLoader.load(myRequest);
		}
		
		private function saveAndMailResult(evt:Event):void
		{
			//AppUtils.TRACE("PDF::saveAndMail()::saveAndMailResult() > evt=" + evt.target.data);
			evt.target.removeEventListener(Event.COMPLETE, saveAndMailResult);
			evt.target.removeEventListener(IOErrorEvent.IO_ERROR, saveAndMailError);
			if (_callback != null) {
				_callback(evt);
			}
		}
		
		private function saveAndMailError(evt:IOErrorEvent):void
		{
			//AppUtils.TRACE("PDF::saveAndMail()::saveAndMailError() > evt=" + evt.target.data);
			evt.target.removeEventListener(Event.COMPLETE, saveAndMailResult);
			evt.target.removeEventListener(IOErrorEvent.IO_ERROR, saveAndMailError);
			if (_callback != null) {
				_callback(evt);
			}
		}	
	}

}