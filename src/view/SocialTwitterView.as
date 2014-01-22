package view
{
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import control.EventController;
	import control.Twitter;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	public class SocialTwitterView extends MovieClip
	{
		private var _mc:MovieClip;
		private var _closeBtn:MovieClip;
		private var _noTwitterMC:MovieClip;
		private var _retryBtn:MovieClip;
		private var _twitter:Twitter;
		private var _screenNameTxt:TextField;
		
		public function SocialTwitterView(mc:MovieClip)
		{
			_mc = mc;
//			super();
			init();
		}
		
		private function init() : void {
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc);
			
			_closeBtn = _mc.getChildByName("x_btn") as MovieClip;
			_closeBtn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_noTwitterMC = _mc.noTwitter_mc;
			_retryBtn = _noTwitterMC.cta_btn;
			_retryBtn.addEventListener(MouseEvent.CLICK, retryClick);
			
			_noTwitterMC.visible = false;
		}
		
		public function twitterDisabled():void {
			_noTwitterMC.visible = true;
		}

		
		protected function retryClick(event:MouseEvent):void
		{
			trace("retryClick trying TWITTER AGAIN...twitterAvailable: "+DataModel.getTwitter().twitterAvailable());
			if (DataModel.getTwitter().twitterAvailable()) {
				DataModel.getTwitter().getUserName();
				DataModel.getTwitter().getFollowers();
			}
			
		}
		
		private function closeClick(e:MouseEvent) : void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_TWITTER_OVERLAY));
		}
		
		public function destroy():void
		{
			_retryBtn.removeEventListener(MouseEvent.CLICK, retryClick);
				
			if (_twitter) {
				_twitter.destroy();
				_twitter = null;
			}	
		}
	}
}