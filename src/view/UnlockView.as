package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import assets.OverlayUnlockMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;

	public class UnlockView extends MovieClip
	{
		private var _mc:OverlayUnlockMC;
//		private var _decisionObject:Object;
		
		public function UnlockView() 
		{
			_mc = new OverlayUnlockMC();
			_mc.x_btn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_mc.return_btn.addEventListener(MouseEvent.CLICK, returnClick);
			_mc.unlock_btn.addEventListener(MouseEvent.CLICK, unlockClick);
			
			_mc.text_txt.text = "You’ve survived the Stormy Sea and reached "+ DataModel.ISLAND_SELECTED[0] + 
				". " + DataModel.defenderInfo.defender +	", will you continue your quest and save the realm from the evil Prince Nero?\n\n" +
				"Unlock the full book for $3.99."
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.text_mc);
			
			addChild(_mc);
			
			EventController.getInstance().addEventListener(ViewEvent.UNLOCK_PURCHASED, unlockPurchased);
		}
		
		protected function unlockPurchased(event:Event):void
		{
			closeOverlay();
		}
		
		protected function returnClick(event:MouseEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_OVERLAY));
			
			var tempObj:Object = new Object();
			tempObj.id = "TitleScreenView";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
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
			DataModel.storeKitService.purchaseUnlock();
		}
		
		public function destroy():void {
			_mc.x_btn.removeEventListener(MouseEvent.CLICK, closeClick);
			_mc.return_btn.addEventListener(MouseEvent.CLICK, returnClick);
			_mc.unlock_btn.removeEventListener(MouseEvent.CLICK, unlockClick);
			removeChild(_mc);
			_mc = null;
		}
	}
}