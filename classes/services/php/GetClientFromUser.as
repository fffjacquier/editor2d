package classes.services.php 
{
	import classes.services.GetPHP;
	import classes.utils.AppUtils;
	import classes.vo.ClientVO;
	import classes.vo.VendeurVO;
	import flash.net.Responder;
	
	/**
	 * ...
	 * @author 
	 */
	public class GetClientFromUser extends GetPHP 
	{
		
		public function GetClientFromUser(cb:Function=null) 
		{
			super(cb);
		}

		override public function call(...rest):void
		{
			//AppUtils.TRACE("GetClientFromUser::call() > cvo.id="+cvo.id);
			AppUtils.TRACE("GetClientFromUser::call() > rest[0]="+rest[0]);
			
			if(rest.length > 0){
				_nc.call("Clients.GetClientFromUser", new Responder(onResult, onError), rest[0]);
			}else {
				AppUtils.TRACE("GetClientFromUser::call() > PARAMETRES MANQUANTS :  rest.length="+rest.length+"/1");
				onError(false);
			}
		}

		override protected function onResult(pResult:Object):void
		{
			//AppUtils.TRACE("GetClientFromUser::onResult() " + pResult);
			super.onResult(pResult);
		}
		
		override protected function onError(pResult:Object):void
		{
			AppUtils.TRACE("GetClientFromUser::onError() " + pResult);
			super.onError(pResult);
		}
		
	}

}