package view.map
{
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
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
		private var _ripples:MovieClip;
		
		public function MapSandlandsView(mc:MovieClip)
		{
			_mc = mc;
			init();
		}
		
		private function init():void
		{
			_bird1 = _mc.bird1_mc;
			_bird2 = _mc.bird2_mc;
			_bird3 = _mc.bird3_mc;
			_bird4 = _mc.bird4_mc;
			
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
			
			_ripples = _mc.ripples_mc;
			_ripples.stop();
			
			TweenMax.delayedCall(.4, playMC, [_ripples]);

			TweenMax.delayedCall(.2, birdOn, [_bird1]);
			TweenMax.delayedCall(.5, birdOn, [_bird2]);
			TweenMax.delayedCall(.8, birdOn, [_bird3]);
			TweenMax.delayedCall(1.1, birdOn, [_bird4]);
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
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
		
		public function destroy():void {
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_bird1 = null;
			_bird2 = null;
			_bird3 = null;
			_bird4 = null;
			
			_ripples = null;
			
			_mc = null;
		}
	}
}