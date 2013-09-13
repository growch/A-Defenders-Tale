package games.bopMice.objects
{
	import flash.display.MovieClip;
	import games.bopMice.core.Game;
	
	public class Hero extends MovieClip
	{
		private var _game:Game;
		private var _player:MovieClip;
		public var malletDown:Boolean;
		public var hitMC:MovieClip;

		
		public function Hero(game:Game, mc:MovieClip)
		{
			_game = game; 
			_player = mc;
			hitMC = _player.getChildByName("hit_mc") as MovieClip;
			
		}
		
		public function update():void
		{
			if (_game.fire ) {
				if (!malletDown) {
					_player.gotoAndPlay("hit");
					malletDown = true;
				}
			} else {
				_player.gotoAndStop("idle");
				malletDown = false;
			}
			_player.x += (_player.stage.mouseX - _player.x) * 0.8;
			_player.y += (_player.stage.mouseY - _player.y) * 0.8;
		}
		
		public function destroy():void
		{
			_game = null;
			_player = null;
			hitMC = null;
		}
	}
}