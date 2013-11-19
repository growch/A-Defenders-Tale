package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import assets.NoInternetMC;
	
	import control.EventController;
	
	import events.ViewEvent;

	public class NoInternetView extends MovieClip
	{
		private var _mc:NoInternetMC;
		
		public function NoInternetView() 
		{
			_mc = new NoInternetMC();
			_mc.x_btn.addEventListener(MouseEvent.CLICK, closeClick);
			
			addChild(_mc);
		}
		
		protected function closeClick(event:MouseEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_OVERLAY));
		}
		
		public function destroy():void {
			_mc.x_btn.removeEventListener(MouseEvent.CLICK, closeClick);
			removeChild(_mc);
			
		}
	}
}