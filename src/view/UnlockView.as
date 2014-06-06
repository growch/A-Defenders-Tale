package view
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
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
		private var _unlocking:Boolean = false;
		private var _restoring:Boolean = false;
		
		public function UnlockView() 
		{
			_mc = new OverlayUnlockMC();
			_mc.x_btn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_unlockMC = _mc.unlock_mc;
			_unlockMC["blocker_mc"].visible = false;
			
			_unlockNotMC = _mc.unlockNot_mc;
			_unlockNotMC["blocker_mc"].visible = false;
			_unlockNotMC.visible = false;
			
			_unlockMC.restore_btn.addEventListener(MouseEvent.CLICK, restoreClick);
			_unlockMC.unlock_btn.addEventListener(MouseEvent.CLICK, unlockClick);
			
			_unlockNotMC.retry_btn.addEventListener(MouseEvent.CLICK, retryClick);
			_unlockNotMC.cover_btn.addEventListener(MouseEvent.CLICK, coverClick);
			
			_unlockMC.text_txt.text = "You’ve survived the Stormy Sea and reached "+ DataModel.ISLAND_SELECTED[0] + 
				". " + DataModel.defenderInfo.defender +	", will you continue your quest and save the realm from the evil Prince Nero?\n\n" +
				"Unlock the full book. For a limited time, only $1.99 USD."
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_unlockMC);
			DataModel.getInstance().setGraphicResolution(_unlockNotMC);
			
			addChild(_mc);
			
			EventController.getInstance().addEventListener(ViewEvent.UNLOCK_PURCHASED, unlockPurchased);
			EventController.getInstance().addEventListener(ViewEvent.UNLOCK_NOT, unlockNot);
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
		
		public function destroy():void {
			EventController.getInstance().removeEventListener(ViewEvent.UNLOCK_PURCHASED, unlockPurchased);
			EventController.getInstance().removeEventListener(ViewEvent.UNLOCK_NOT, unlockNot);
			
			_mc.x_btn.removeEventListener(MouseEvent.CLICK, closeClick);
			
			_unlockMC.restore_btn.removeEventListener(MouseEvent.CLICK, restoreClick);
			_unlockMC.unlock_btn.removeEventListener(MouseEvent.CLICK, unlockClick);
			
			_unlockNotMC.retry_btn.removeEventListener(MouseEvent.CLICK, retryClick);
			_unlockNotMC.cover_btn.removeEventListener(MouseEvent.CLICK, coverClick);
			
			_unlockMC = null;
			_unlockNotMC = null;
			
			removeChild(_mc);
			_mc = null;
		}
	}
}