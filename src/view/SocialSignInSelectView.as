package view
{
	
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	public class SocialSignInSelectView extends MovieClip
	{
		private var _mc:MovieClip;
		private var _closeBtn:MovieClip;
		private var _facebookBtn:MovieClip;
		private var _twitterBtn:MovieClip;
		private var _submitBtn:MovieClip;
		private var _nameTF:TextField; 
		
		public function SocialSignInSelectView(mc:MovieClip)
		{
			_mc = mc;
//			super();
			init();
		}
		
		private function init() : void {
			_closeBtn = _mc.getChildByName("x_btn") as MovieClip;
			_closeBtn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_facebookBtn = _mc.getChildByName("facebook_btn") as MovieClip;
			_facebookBtn.addEventListener(MouseEvent.CLICK, facebookClick);

			_twitterBtn = _mc.getChildByName("twitter_btn") as MovieClip;
			_twitterBtn.addEventListener(MouseEvent.CLICK, twitterClick);
			
			_nameTF = _mc.getChildByName("name_txt") as TextField;
			_nameTF.maxChars = 100;
			_nameTF.addEventListener(FocusEvent.FOCUS_OUT, capFirst); 
			
			_submitBtn = _mc.getChildByName("submit_btn") as MovieClip;
			_submitBtn.addEventListener(MouseEvent.CLICK, submitClick);
		}
		
		protected function submitClick(event:MouseEvent):void
		{
			if (_nameTF.text != "") {
				var fullName:Array = _nameTF.text.split(" ");
				var firstName:String = fullName[0];
				
				DataModel.defenderInfo.contact = firstName; 
				DataModel.SOCIAL_CONNECTED = false;
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CONTACT_SELECTED));
			}
		}
		
		protected function capFirst(event:FocusEvent):void
		{
			var thisTF:TextField = event.target as TextField;
			var str:String = thisTF.text;
			var firstChar:String = str.substr(0, 1);
			var restOfString:String = str.substr(1, str.length);
			thisTF.text = firstChar.toUpperCase()+restOfString.toLowerCase();
		}
		
		protected function facebookClick(event:MouseEvent):void
		{
			DataModel.SOCIAL_CONNECTED = true;
			DataModel.SOCIAL_PLATFROM = DataModel.SOCIAL_FACEBOOK;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.LOGIN_FACEBOOK));	
		}
		
		protected function twitterClick(event:MouseEvent):void
		{
			DataModel.SOCIAL_CONNECTED = true;
			DataModel.SOCIAL_PLATFROM = DataModel.SOCIAL_TWITTER;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.LOGIN_TWITTER));	
		}
		
		private function closeClick(e:MouseEvent) : void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_EMERGENCY_OVERLAY));
		}
		
		public function destroy():void
		{
			_closeBtn.removeEventListener(MouseEvent.CLICK, closeClick);
			_facebookBtn.removeEventListener(MouseEvent.CLICK, facebookClick);
			_twitterBtn.removeEventListener(MouseEvent.CLICK, twitterClick);
			_nameTF.removeEventListener(FocusEvent.FOCUS_OUT, capFirst); 
			_submitBtn.removeEventListener(MouseEvent.CLICK, submitClick);
		}
	}
}