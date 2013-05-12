package view
{
	
	import control.EventController;
	import control.GoViralService;
	
	import events.ViewEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import model.DataModel;
	
	public class EmergencySignInSelectView extends MovieClip
	{
		private var _mc:MovieClip;
		private var _closeBtn:MovieClip;
		private var _facebookBtn:MovieClip;
		private var _submitBtn:MovieClip;
		private var _nameTF:TextField; 
		
		public function EmergencySignInSelectView(mc:MovieClip)
		{
			_mc = mc;
			super();
			init();
		}
		
		private function init() : void {
			_closeBtn = _mc.getChildByName("x_btn") as MovieClip;
			_closeBtn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_facebookBtn = _mc.getChildByName("facebook_btn") as MovieClip;
			_facebookBtn.addEventListener(MouseEvent.CLICK, facebookClick);
			
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
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.LOGIN_FACEBOOK));	
		}
		
		private function closeClick(e:MouseEvent) : void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_EMERGENCY_OVERLAY));
		}
		
		public function destroy():void
		{
			_closeBtn.removeEventListener(MouseEvent.CLICK, closeClick);
			_facebookBtn.removeEventListener(MouseEvent.CLICK, facebookClick);
			_nameTF.removeEventListener(FocusEvent.FOCUS_OUT, capFirst); 
			_submitBtn.removeEventListener(MouseEvent.CLICK, submitClick);
		}
	}
}