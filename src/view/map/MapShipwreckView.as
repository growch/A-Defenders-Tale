package view.map
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import view.IPageView;
	
	public class MapShipwreckView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _shark1:MovieClip;
		private var _shark2:MovieClip;
		private var _stone:MovieClip;
		
		public function MapShipwreckView(mc:MovieClip)
		{
			_mc = mc;
			init();
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		protected function pageOn(event:ViewEvent):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function init():void
		{
			_shark1 = _mc.shark1_mc;
			_shark2 = _mc.shark2_mc;
			
			_shark1.initX = _shark1.x;
			_shark2.initX = _shark2.x;
			
			_shark1.range = 30;
			_shark2.range = 20;
			
			_shark1.goLeft = false;
			_shark1.orientRight = true; 
			_shark2.goLeft = true;
			
			_stone = _mc.name_mc.stone_mc;
			_stone.visible = false;
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			moveFish(_shark1, .6);
			moveFish(_shark2, .4);
		}
		
		public function showStone():void {
			_stone.visible = true;
		}
		
		private function moveFish(thisMC:MovieClip, thisAmt:Number):void {
			if (thisMC.goLeft) {
				thisMC.x -= thisAmt;
				if (thisMC.x < (thisMC.initX - thisMC.range)) {
					thisMC.goLeft = false;
					if (thisMC.orientRight) {
						thisMC.scaleX = 1;
					} else {
						thisMC.scaleX = -1;
					}
				}
			} else {
				thisMC.x += thisAmt;
				if (thisMC.x > (thisMC.initX + thisMC.range)) {
					thisMC.goLeft = true;
					if (thisMC.orientRight) {
						thisMC.scaleX = -1;
					} else {
						thisMC.scaleX = 1;
					}
				}
			}
		}
		
		public function destroy():void {
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			
			_shark1.initX = _shark2.initX = null;
			
			_shark1.range = _shark2.range = null;
			
			_shark1.goLeft = null;
			_shark1.orientRight = null; 
			_shark2.goLeft = null;
			
			_stone = null;
			_shark1 = null;
			_shark2 = null;
			_mc = null;
		}
	}
}