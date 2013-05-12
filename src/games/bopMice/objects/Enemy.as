package games.bopMice.objects
{
//	import core.Assets;
	import flash.display.MovieClip;
	import flash.utils.setTimeout;
	
	import games.bopMice.core.Game;
	
//	import states.Play;
	
	public class Enemy extends flash.display.MovieClip 
	{
		private var enemy:MovieClip;
		public var showing:Boolean;
		public var hit:Boolean;
		private var _popUpTimer:Number;
		private var _popDuration:Number = .8;
		private var _enemMC:MovieClip;
		private var _hitMC:MovieClip;
		
		public function Enemy(enemMC:MovieClip)
		{
			_enemMC = enemMC;
			setToIdle();
			_hitMC = _enemMC.getChildByName("hit_mc") as MovieClip;
		}
		
		private function setToIdle():void
		{
			_enemMC.gotoAndStop("idle");
		}
		
		public function get hitMC():MovieClip {
			_hitMC = _enemMC.getChildByName("hit_mc") as MovieClip;
			return _hitMC;
		}
		
		public function showEnemy():void {
			showing = true;
			_popUpTimer = Game.FPS * _popDuration;
//			enemyUp.currentFrame = 1;
			_enemMC.gotoAndPlay("up");
		}
		
		public function hideEnemy():void {
//			enemyDown.currentFrame = 1;
			_enemMC.gotoAndPlay("down");
		}
		
		public function hitEnemy():void {
			showing = false;
			_enemMC.gotoAndPlay("hit");
			setTimeout(reset, 500);
		}
		
		private function reset():void {
//			_enemMC.gotoAndStop("idle");
			setToIdle();
//			hit = false;
//			showing = false;
			showingOff();
		}
		
		private function showingOff():void {
			showing = false;
		}
		
		public function update():void {
			if (showing) {
				_popUpTimer--;
				
				//teasing
				if (_enemMC.currentFrameLabel == "upEnd") {
					if(Math.random() < 0.016) {
						_enemMC.gotoAndPlay("tease");
						_popUpTimer = Game.FPS * _popDuration;
					}
				}
				
				if (_popUpTimer <= 0) {
					hideEnemy();
//					showing = false;
					showingOff();
//					setTimeout(showingOff, 300);
				}
			}
		}
	}
}