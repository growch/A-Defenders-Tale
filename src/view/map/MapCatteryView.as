package view.map
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import view.IPageView;
	
	public class MapCatteryView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		
		public function MapCatteryView(mc:MovieClip)
		{
			_mc = mc;
			init();
		}
		
		private function init():void
		{
//			_mc.ripples_mc.stop();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		
		protected function enterFrameLoop(event:Event):void
		{
		}
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_mc = null;
		}
	}
}