package view.map
{
	import flash.display.MovieClip;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import view.IPageView;
	
	public class MapCatteryView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _ripples:MovieClip;
		private var _stone:MovieClip;
		
		public function MapCatteryView(mc:MovieClip)
		{
			_mc = mc;
			
			init();
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		protected function pageOn(event:ViewEvent):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			_ripples.visible = true;
			_ripples.play();
		}
		
		private function init():void
		{
			_ripples = _mc.ripples_mc;
			_ripples.stop();
			_ripples.visible = false;
			
			_stone = _mc.name_mc.stone_mc;
			_stone.visible = false;
			
		}
		
		public function showStone():void {
			_stone.visible = true;
		}
		
		public function destroy():void {
			_stone = null;
			_ripples = null;
			_mc = null;
		}
	}
}