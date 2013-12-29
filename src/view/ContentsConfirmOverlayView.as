package view
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import assets.OverlayContentsPanelMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;

	public class ContentsConfirmOverlayView extends MovieClip
	{
		private var _mc:OverlayContentsPanelMC;
		private var _decisionObject:Object;
		
		public function ContentsConfirmOverlayView(decisionObject:Object) 
		{
			_decisionObject = decisionObject;
			
			_mc = new OverlayContentsPanelMC();
			_mc.x_btn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_mc.cancel_btn.addEventListener(MouseEvent.CLICK, closeClick);
			_mc.continue_btn.addEventListener(MouseEvent.CLICK, continueClick);
			
			addChild(_mc);
		}
		
		protected function closeClick(event:MouseEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_OVERLAY));
		}
		
		protected function continueClick(event:MouseEvent):void
		{
//			trace("continueClick");
//			DataModel.getInstance().contentsPageSelected = false; 
			_decisionObject.overwriteHistory = true;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_OVERLAY));
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, _decisionObject));
		}
		
		public function destroy():void {
			_mc.x_btn.removeEventListener(MouseEvent.CLICK, closeClick);
			_mc.cancel_btn.removeEventListener(MouseEvent.CLICK, closeClick);
			_mc.continue_btn.removeEventListener(MouseEvent.CLICK, continueClick);
			removeChild(_mc);
			_mc = null;
		}
	}
}