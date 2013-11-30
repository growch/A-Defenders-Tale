package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.sunlightGame.EnemyMC;
	
	import model.DataModel;
	
	
	public class Enemy extends flash.display.MovieClip 
	{
		private var _enemMC:MovieClip;
		private var _hitMC:MovieClip;
		private var _hitBigMC:MovieClip;
		private var _angleX:Number = 0;
		private var _amplitudeX:int = 6;
//		private var _stepX:Number = Math.PI*0.04;
		private var _stepX:Number;
//		private var _shiftX:int = 0;
		private var _startX:Number;
		public var ySpeed:Number;
		public var moveLateral:Boolean;
		private var _direction:Number;
		private var count:int;
		private var lateralDistance:Number = 3;
		public var heroCollision:Boolean;
		
		public function Enemy()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_direction = Math.round(DataModel.getInstance().randomRange(0,1));
			_direction = _direction * 2 - 1;
//			trace("_direction: "+ _direction);
			
			ySpeed = DataModel.getInstance().randomRange(2,3);
			
			_stepX = Math.PI*(DataModel.getInstance().randomRange(.01, .02));
			
			_enemMC = new EnemyMC();
			_hitMC = _enemMC.getChildByName("hitSmall_mc") as MovieClip;
			_hitBigMC = _enemMC.getChildByName("hitBig_mc") as MovieClip;
			addChild(_enemMC);
			
			_startX = x;
		}
		
		public function get hitMC():MovieClip {
			return _hitMC;
		}
		
		public function get hitBigMC():MovieClip {
			return _hitBigMC;
		}
		
		public function destroy():void {
			removeChild(_enemMC);
		}
		
		public function update():void {
			if (_enemMC.currentFrame < 30) return;
			
			if (moveLateral) {
				goLateral();
			} else {
				goDown();
			}
			if(Math.random() < 0.005)
				_direction = -_direction;   
		}
		
		public function bounceOff():void
		{
			_direction = -_direction;
			x += lateralDistance * 5 * _direction;
			y += ySpeed * 5;
			
		}
		
		private function goLateral():void
		{
			y -= 1;
			x += lateralDistance * _direction;
		}
		
		private function goDown():void {
			y += ySpeed;
			
			_angleX += _stepX;
			x += (_direction/2) * (_amplitudeX * Math.sin(_angleX));
		}
		
		public function reset():void
		{
			_enemMC.gotoAndPlay(1);
		}
	}
}