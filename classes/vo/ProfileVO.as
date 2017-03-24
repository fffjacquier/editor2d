package classes.vo 
{
	import classes.model.ApplicationModel;
	import classes.utils.AppUtils;
	
	dynamic public class ProfileVO 
	{
		/*public var identification_acces:String = "0";
		public var recherche_acces:String = "0";
		public var inscription_acces:String = "0";
		public var inscription_creer:String = "0";
		public var inscription_modifier:String = "0";
		public var plan_acces:String = "0";
		public var plan_creer:String = "0";
		public var plan_sols_modifier:String = "0";*/
		
		public function ProfileVO() 
		{
		}
		public function setProfile(str:String):void
		{
			//AppUtils.TRACE("ProfileVO::setProfile() >> str = " + str);
			if (str.length > 0) {
				//var tmp_str:String = str.substr(1);
				//AppUtils.TRACE("ProfileVO::setProfile() >> tmp_str = " + tmp_str);
				//tmp_str = tmp_str.substr(0,tmp_str.length-1);
				//AppUtils.TRACE("ProfileVO::setProfile() >> tmp_str = " + tmp_str);
				//tmp_str = tmp_str.substr( -1);
				var tmp:Array = str.substr(1, str.length - 2).split("#");
				for (var i:int = 0; i < tmp.length; i++) 
				{
					var data:Array = tmp[i].split(":");
					var key:String = data[0];
					var val:String = data[1];
					this[key] = val;
				}
				AppUtils.TRACE("ProfileVO::setProfile() >> tmp = " + tmp);
			}
		}
		
		public function get acces_identification():Boolean
		{
			return Boolean(parseInt(this['identification_acces']));
		}
		
		public function get acces_recherche():Boolean
		{
			return Boolean(parseInt(this['recherche_acces']));
		}
		
		public function get acces_notesvendeur():Boolean
		{
			return Boolean(parseInt(this['synthese_note_afficher']));
		}
		
		public function get acces_btnprint():Boolean
		{
			return Boolean(parseInt(this['synthese_btn_imprimer']));
		}
		
		public function get acces_btnmail():Boolean
		{
			//trace("acces_btnmail", this['synthese_btn_email'], parseInt(this['synthese_btn_email']), Boolean(parseInt(this['synthese_btn_email'])))
			return Boolean(parseInt(this['synthese_btn_email']));
		}
		
		public function get eligibility_mandatory():Boolean
		{
			return Boolean(parseInt(this['inscription_eligibilite_obligatoire']));
		}	
		
		public function get user_profile():String
		{
			return String(this['type_user']);
		}
	}
}