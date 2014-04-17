package view.map
{
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import view.IPageView;
	
	public class MapSandlandsView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _bird1:MovieClip;
		private var _bird2:MovieClip;
		private var _bird3:MovieClip;
		private var _bird4:MovieClip;
		private var _range:Number = 4;
		private var _speed:Number = .1;
		private var _stone:MovieClip;
		
		public function MapSandlandsView(mc:MovieClip)
		{
			_mc = mc;
			init();
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		private function init():void
		{
			_bird1 = _mc.bird1_mc.bird_mc;
			_bird2 = _mc.bird2_mc.bird_mc;
			_bird3 = _mc.bird3_mc.bird_mc;
			_bird4 = _mc.bird4_mc.bird_mc;
			
			_bird1.on = _bird2.on = _bird3.on = _bird4.on = false;
			_bird1.initY = _bird1.y;
			_bird2.initY = _bird2.y;
			_bird3.initY = _bird3.y;
			_bird4.initY = _bird4.y;
			_bird1.angle = _bird2.angle = _bird3.angle = _bird4.angle = 0;
			
			_bird1.stop();
			_bird2.stop();
			_bird3.stop();
			_bird4.stop();
			
			_stone = _mc.name_mc.stone_mc;
			_stone.visible = false;

		}
		
		protected function pageOn(event:ViewEvent):void
		{
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			TweenMax.delayedCall(0, birdOn, [_bird1]);
			TweenMax.delayedCall(.4, birdOn, [_bird2]);
			TweenMax.delayedCall(.6, birdOn, [_bird3]);
			TweenMax.delayedCall(.8, birdOn, [_bird4]);
		}
		
		private function playMC(thisMC:MovieClip):void {
			thisMC.play();
		}
		
		private function birdOn(thisBird:MovieClip):void {
			thisBird.play();
			thisBird.on = true;
		}
		
		private function bobItem(thisMC:MovieClip):void {
			if (thisMC.on == false) return;
			thisMC.y = thisMC.initY +  Math.sin(thisMC.angle) * _range;
			thisMC.angle += _speed;
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			bobItem(_bird1);
			bobItem(_bird2);
			bobItem(_bird3);
			bobItem(_bird4);
		}
		
		public function showStone():void {
			_stone.visible = true;
		}
		
		public function destroy():void {
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			
			_bird1.on = _bird2.on = _bird3.on = _bird4.on = null;
			_bird1.angle = _bird2.angle = _bird3.angle = _bird4.angle = null;
			_bird1.initY = _bird2.initY = _bird3.initY = _bird4.initY = null;
			
			_bird1 = null;
			_bird2 = null;
			_bird3 = null;
			_bird4 = null;
			
			_stone = null;
			
			_mc = null;
		}
	}
}