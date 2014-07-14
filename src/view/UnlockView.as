package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import assets.OverlayUnlockMC;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.DataModel;

	public class UnlockView extends MovieClip
	{
		private var _mc:OverlayUnlockMC;
		private var _unlockMC:MovieClip;
		private var _unlockNotMC:MovieClip;
		private var _unlockKickMC:MovieClip;
		private var _unlocking:Boolean = false;
		private var _restoring:Boolean = false;
		private var _kickTimer:Timer;
		private var _kickTimerID:uint;
		
		public function UnlockView() 
		{
			_mc = new OverlayUnlockMC();
			_mc.x_btn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_unlockMC = _mc.unlock_mc;
			_unlockMC["blocker_mc"].visible = false;
			
			_unlockNotMC = _mc.unlockNot_mc;
			_unlockNotMC["blocker_mc"].visible = false;
			_unlockNotMC.visible = false;
			
			_unlockKickMC = _mc.kickstarter_mc;
			_unlockKickMC["blocker_mc"].visible = false;
			_unlockKickMC.visible = false;
			_unlockKickMC.unlock_btn.addEventListener(MouseEvent.CLICK, submitClick);
			_unlockKickMC.code_txt.addEventListener(FocusEvent.FOCUS_IN, textFocusIn);
			
			_unlockMC.restore_btn.addEventListener(MouseEvent.CLICK, restoreClick);
			_unlockMC.unlock_btn.addEventListener(MouseEvent.CLICK, unlockClick);
			_unlockMC.your_btn.addEventListener(MouseEvent.MOUSE_DOWN, unlockKickActivate);
			_unlockMC.your_btn.addEventListener(MouseEvent.MOUSE_UP, unlockKickDeActivate);
			
			_unlockNotMC.retry_btn.addEventListener(MouseEvent.CLICK, retryClick);
			_unlockNotMC.cover_btn.addEventListener(MouseEvent.CLICK, coverClick);
			
			_unlockMC.text_txt.text = "Will you continue your quest and defeat the evil Pince Nero? " + 
				DataModel.defenderInfo.defender +	", you're this realm's only hope.\n\n" +
				"Unlock the full book. For a limited time, only $1.99 USD."
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_unlockMC);
			DataModel.getInstance().setGraphicResolution(_unlockNotMC);
			
			addChild(_mc);
			
			EventController.getInstance().addEventListener(ViewEvent.UNLOCK_PURCHASED, unlockPurchased);
			EventController.getInstance().addEventListener(ViewEvent.UNLOCK_NOT, unlockNot);
			
			DataModel.getInstance().trackEvent("application", "show UNLOCK at: "+ DataModel.CURRENT_PAGE_ID);
//			trace( "show UNLOCK at: "+ DataModel.CURRENT_PAGE_ID);
			
		}
		
		protected function unlockNot(event:ViewEvent):void
		{
			_unlockMC.visible = false
			_unlockNotMC["blocker_mc"].visible = false;
			_unlockNotMC.visible = true;
		}
		
		protected function unlockPurchased(event:ViewEvent):void
		{
			DataModel.getInstance().unlockBook();
			closeOverlay();
		}
		
		protected function retryClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			if (!DataModel.getInstance().networkConnection()) return;
			
			_unlockNotMC["blocker_mc"].visible = true;
			
			if (_unlocking) {
				DataModel.getStoreKit().purchaseUnlock();
			} else {
				DataModel.getStoreKit().restoreTransactions();
			}
			
		}
		
		protected function coverClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_OVERLAY));
			
			var tempObj:Object = new Object();
			tempObj.id = "TitleScreenView";
			EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.RESTART_BOOK));
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		protected function restoreClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			if (!DataModel.getInstance().networkConnection()) return;
			
			_unlocking = false;
			_restoring = true;
			
			_unlockMC["blocker_mc"].visible = true;
			
			if (!DataModel.getStoreKit().supported) {
				//				lil' hacky so as to not get stuck behind paywall on desktop
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.UNLOCK_PURCHASED));
				return;
			}
			
			DataModel.getStoreKit().restoreTransactions();
			
		}
		
		protected function closeClick(event:MouseEvent):void
		{
			closeOverlay();
		}
		
		private function closeOverlay():void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_OVERLAY));
		}
		
		protected function unlockClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			if (!DataModel.getInstance().networkConnection()) return;
			
			_unlocking = true;
			_restoring = false;
			
			_unlockMC["blocker_mc"].visible = false;
			
//			TESTING!!!! so JOY can test without paying
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.UNLOCK_PURCHASED));
//			return;
			
			if (!DataModel.getStoreKit().supported) {
//				lil' hacky so as to not get stuck behind paywall on desktop
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.UNLOCK_PURCHASED));
				return;
			}
			
			DataModel.getStoreKit().purchaseUnlock();
		}
		
		private function unlockKickActivate(e:MouseEvent):void {
			if (_kickTimer) {
				_kickTimer.stop();
			} else {
				_kickTimer = new Timer(5000, 1);
				_kickTimer.addEventListener(TimerEvent.TIMER_COMPLETE, unlockKickstarter);
			}
			_kickTimer.start();
		}
		
		private function unlockKickDeActivate(e:MouseEvent):void {
			_kickTimer.stop();
		}
		
		protected function unlockKickstarter(event:TimerEvent):void
		{
			_kickTimer.stop();
			_unlockKickMC.visible = true;
		}
		
		private function submitClick(e:MouseEvent):void {
			if (!DataModel.getInstance().networkConnection()) return;
			
			if (_unlockKickMC.code_txt.text == "") {
				_unlockKickMC.code_txt.text = "ENTER UNLOCK CODE";
			} else {
				processUnlock();
			}
		}
		
		private function processUnlock():void {
			_unlockKickMC["blocker_mc"].visible = true;
			
			var phpVars:URLVariables = new URLVariables(); 

			var phpFileRequest:URLRequest = new URLRequest("http://www.2ndstringproductions.com/dev/adt/scripts/unlock_user.php");
			phpFileRequest.method = URLRequestMethod.POST;
			phpFileRequest.data = phpVars;
			
			var phpLoader:URLLoader = new URLLoader();
			phpLoader.dataFormat = URLLoaderDataFormat.TEXT;   
			phpLoader.addEventListener(Event.COMPLETE, showUnlockResult);
			
			phpVars.password = _unlockKickMC.code_txt.text;
			
			phpLoader.load(phpFileRequest);
		}
		
		protected function showUnlockResult(event:Event):void
		{
//			trace("showUnlockResult: " + event.target.data.systemResult);
			_unlockKickMC["blocker_mc"].visible = false;
			
			var variables:URLVariables = new URLVariables(event.target.data);
//			trace("showUnlockResult: " + variables.systemResult);
			if (variables.systemResult == "unlocked") {
				DataModel.getInstance().unlockBook();
				closeOverlay();
			} else if (variables.systemResult == "unlockedAlready") {
				_unlockKickMC.code_txt.text = "UNLOCK CODE USED";
			} else {
				_unlockKickMC.code_txt.text = "ERROR UNLOCKING";
			}
		}
		
		private function textFocusIn(event:FocusEvent) : void {
			//cuz of AIR bug with input text shifting down on input
			var thisTF:TextField = event.target as TextField;
//			thisTF.defaultTextFormat = _tfm;
//			thisTF.y -= 10;
			thisTF.text = "";
		}
		
		public function destroy():void {
			EventController.getInstance().removeEventListener(ViewEvent.UNLOCK_PURCHASED, unlockPurchased);
			EventController.getInstance().removeEventListener(ViewEvent.UNLOCK_NOT, unlockNot);
			
			_mc.x_btn.removeEventListener(MouseEvent.CLICK, closeClick);
			
			_unlockMC.restore_btn.removeEventListener(MouseEvent.CLICK, restoreClick);
			_unlockMC.unlock_btn.removeEventListener(MouseEvent.CLICK, unlockClick);
			
			_unlockNotMC.retry_btn.removeEventListener(MouseEvent.CLICK, retryClick);
			_unlockNotMC.cover_btn.removeEventListener(MouseEvent.CLICK, coverClick);
			
			_unlockMC.your_btn.removeEventListener(MouseEvent.MOUSE_DOWN, unlockKickActivate);
			_unlockMC.your_btn.removeEventListener(MouseEvent.MOUSE_UP, unlockKickDeActivate);
			
			_unlockKickMC.unlock_btn.removeEventListener(MouseEvent.CLICK, submitClick);
			_unlockKickMC.code_txt.removeEventListener(FocusEvent.FOCUS_IN, textFocusIn);
			
			_unlockMC = null;
			_unlockNotMC = null;
			_unlockKickMC = null;
			
			if (_kickTimer) {
				_kickTimer.stop();
				_kickTimer = null;	
			}
			
			removeChild(_mc);
			_mc = null;
		}
	}
}