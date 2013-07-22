package games.sunlightGame
{
	import flash.display.MovieClip;
	import games.sunlightGame.core.Game;
	import view.IPageView;
	
	public class SunlightGame extends MovieClip implements IPageView
	{
		private var _game:Game;
		public function SunlightGame()
		{
			_game = new Game();
			addChild(_game);
		}
		
		public function destroy():void {
			_game.destroy();
			removeChild(_game);
			_game = null;
		}
		
	}
}