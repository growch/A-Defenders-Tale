package view
{
	import assets.StarMC;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import model.DataModel;
	
	public class StarryNight extends MovieClip
	{
		private var _starCount:int;
		private var _timer:Timer;
		private var _areaWidth:int;
		private var _areaHeight:int;
		private var _scaleMin:Number;
		private var _scaleMax:Number;
		private var _speed:int;
		
		public function StarryNight(areaW:int=700,areaH:int=100,scaleMin:Number=.2,scaleMax:Number=.6,speed:int=300)
		{
			super();
			_areaWidth = areaW;
			_areaHeight = areaH;
			_scaleMin = scaleMin;
			_scaleMax = scaleMax;
			_speed = speed;
			
//			addEventListener(Event.ADDED_TO_STAGE, init);
//			init();
		}
		
		public function start() : void {
			_timer = new Timer(_speed); 
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			_timer.start(); 
		}
		
		protected function timerHandler(event:TimerEvent):void
		{
			var star:StarMC = new StarMC();
			var randomX:Number = Math.random() * _areaWidth + 0;
			var randomY:Number = Math.random() * _areaHeight + 0;
			var randScale:Number = DataModel.getInstance().randomRange(_scaleMin, _scaleMax);
			var randAlpha:Number = DataModel.getInstance().randomRange(.7, 1);
			
			star.x = randomX;		
			star.y = randomY;
			star.scaleX = star.scaleY = randScale;
			star.alpha = randAlpha;
			
//			TweenMax.to(star, 1, {glowFilter:{color:0x4B76FC, blurX:10, blurY:10, strength:4, alpha:1}});
			TweenMax.from(star, 1, {alpha:0, ease:Quad.easeOut, onComplete:removeStar, onCompleteParams:[star]});
			
			addChild(star);	
//			trace("add star");
		}
		
		private function removeStar(thisStar:MovieClip):void {
			var randDelay:Number = Math.round(Math.random() * 2);
			TweenMax.to(thisStar, .5, {alpha:0, ease:Quad.easeIn, delay:randDelay, onComplete:function():void{removeChild(thisStar)}});
		}
		
		public function destroy():void {
			//in case forgot to start()
			if (_timer) {
				_timer.stop();
				_timer = null;
			}
			
			
			TweenMax.killAll();
			
			var childNum:int = numChildren;
			var child:MovieClip;
			for (var j:int = 0; j < childNum; j++) 
			{
				child = getChildAt(0) as MovieClip;
				removeChild(child);
				child = null;
			}
		}
		
		public function pause():void
		{
			_timer.stop();
		}
		public function resume():void
		{
			_timer.start();
		}	
	}
}