package view.map
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	import view.IPageView;
	
	public class MapCapitolView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _darkness:MovieClip;
		
		
		public function MapCapitolView(mc:MovieClip)
		{
			_mc = mc;
			_darkness = _mc.darkness_mc;
			_darkness.stop();
//			_darkness.visible = false;
			
			init();
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		protected function pageOn(event:ViewEvent):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			if (!DataModel.ipad1) {
				_darkness.play();
			}
//			_darkness.visible = true;
		}
		
		private function init():void
		{
			
//			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
//		protected function enterFrameLoop(event:Event):void
//		{
//		}
		
		public function destroy():void {
//			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_darkness = null;
			_mc = null;
		}
		
		public function showCapitol():void
		{
			_darkness.visible = false;
		}
	}
}