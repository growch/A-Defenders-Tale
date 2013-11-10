package view
{
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import control.EventController;
	import control.TwitterAccess;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	public class SocialTwitterView extends MovieClip
	{
		private var _mc:MovieClip;
		private var _closeBtn:MovieClip;
		private var _signInBtn:MovieClip;
		private var _signInMC:MovieClip;
		private var _noTwitterMC:MovieClip;
		private var _retryBtn:MovieClip;
		private var _twitterAccess:TwitterAccess;
		private var _screenNameTxt:TextField;
		
		public function SocialTwitterView(mc:MovieClip)
		{
			_mc = mc;
//			super();
			init();
		}
		
		private function init() : void {
			_closeBtn = _mc.getChildByName("x_btn") as MovieClip;
			_closeBtn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_signInMC = _mc.singIn_mc;
			_signInBtn = _signInMC.cta_btn;
			_signInBtn.addEventListener(MouseEvent.CLICK, signInClick);
			
			_screenNameTxt = _signInMC.screenName_txt as TextField;
			
			_noTwitterMC = _mc.noTwitter_mc;
			_retryBtn = _noTwitterMC.cta_btn;
			_retryBtn.addEventListener(MouseEvent.CLICK, retryClick);
			
			_noTwitterMC.visible = false;
		}
		
		public function loginTwitter():void {
			_signInMC.visible = true;
			_noTwitterMC.visible = false;
		}
		
		public function twitterDisabled():void {
			_noTwitterMC.visible = true;
			_signInMC.visible = false;
		}

		
		protected function retryClick(event:MouseEvent):void
		{
			trace("retryClick trying TWITTER AGAIN...twitterAvailable: "+DataModel.getGoViral().twitterAvailable());
			if (DataModel.getGoViral().twitterAvailable()) {
				loginTwitter();
			}
			
		}
		
		protected function signInClick(event:MouseEvent):void
		{
			if (!_twitterAccess) {
				if (_screenNameTxt.text != "") {
					_twitterAccess = new TwitterAccess(_screenNameTxt.text);
				}
			}
		}

		
		private function closeClick(e:MouseEvent) : void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_TWITTER_OVERLAY));
		}
		
		public function destroy():void
		{
			_closeBtn.removeEventListener(MouseEvent.CLICK, closeClick);
			_signInBtn.removeEventListener(MouseEvent.CLICK, signInClick)
			_retryBtn.removeEventListener(MouseEvent.CLICK, retryClick);
				
			if (_twitterAccess) {
				_twitterAccess.destroy();
				_twitterAccess = null;
			}	
		}
	}
}