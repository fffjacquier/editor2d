package classes.utils
{
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	
	/**
	 * This class contains some functions for dealing with form elements.
	 *
	 */
	public final class FormUtils
	{
		//-----------------------------------------------------------------------
		//-- Validation elements
		//-----------------------------------------------------------------------
		
		/**
		 * Check wether email is valid or not
		 * @param pEmailStr an email string
		 */
		public static function isValidMail_basic(pEmailStr:String):Boolean
		{
			var validEmailRegExp:RegExp = /([a-z0-9._-]+)@([a-z0-9.-]+)\.([a-z]{2,4})/;
			return validEmailRegExp.test(pEmailStr);
		}
		
		public static function isValidMail(pEmailStr:String):Boolean
		{
			var validEmailRegExp:RegExp = /^[0-9a-zA-Z][-._a-zA-Z0-9]*@([0-9a-zA-Z][-._0-9a-zA-Z]*\.)+[a-zA-Z]{2,4}$/;
			return validEmailRegExp.test(pEmailStr);
		}
		
		public static function isValidPhone(pPhoneStr:String):Boolean {
			var validPhoneRegExp:RegExp = /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,3})|(\(?\d{2,3}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/i;
			trace("isValidPhone(" + pPhoneStr + ") > " + validPhoneRegExp.test(pPhoneStr));
			return validPhoneRegExp.test(pPhoneStr);
		}
		
		//-----------------------------------------------------------------------
		//-- Change elements states, styles...
		//-----------------------------------------------------------------------
		
		public static function radioButtonReset(pRadioButtonGroup:RadioButtonGroup):void
		{
			if (pRadioButtonGroup.selection != null)
			{
				var tmpBtn:RadioButton = new RadioButton();
				pRadioButtonGroup.addRadioButton(tmpBtn);
				tmpBtn.selected = true;
				pRadioButtonGroup.removeRadioButton(tmpBtn);
				tmpBtn = null;
				pRadioButtonGroup.selectedData = null;
				pRadioButtonGroup.selection = null;
			}
		}
		
		public static function radioButtonReset_byName(pRadioButtonGroupName:String):void
		{
			radioButtonReset(RadioButtonGroup.getGroup(pRadioButtonGroupName));
		}
	
	}
}