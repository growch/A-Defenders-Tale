package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	import games.sunlightGame.core.Game;
	
	public class Nero extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		private var _head:MovieClip;

		public function Nero(game:Game, mc:MovieClip)
		{
			_game = game; 
			_mc = mc;
			_head = _mc.head_mc;
			_head.stop()
		}
		
		public function update():void
		{
			if (_game.fire) {

			} else {

			}

		}
	}
}