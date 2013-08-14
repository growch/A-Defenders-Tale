package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import games.sunlightGame.core.Game;
	
	public class Nero extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		private var _head:MovieClip;
		private var counter:int;
		private var faceTime:int = 10;

		public function Nero(game:Game, mc:MovieClip)
		{
			_game = game; 
			_mc = mc;
			_head = _mc.head_mc;
			_head.stop();
			
		}
		
		public function get neroMC():MovieClip {
			return _mc;
		}
		
		public function spawn():void {
			_head.gotoAndStop("laughing");
			counter = 0;
		}
		
		public function getSunlight():void {
			_head.gotoAndStop("evil");
			counter = 0;
		}
		
		public function enemyHit():void {
			_head.gotoAndStop("mad");
			counter = 0;
		}
		
		public function update():void
		{
			counter++;
			
			if (counter > faceTime) {
				_head.gotoAndStop(1);
			}
//			if (_game.fire) {
//
//			} else {
//
//			}

		}
	}
}