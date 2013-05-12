package games.bopMice
{
	import flash.display.MovieClip;
	import games.bopMice.core.Game;
	import view.IPageView;
	
	public class BopMice extends MovieClip implements IPageView
	{
		private var _game:Game;
		public function BopMice()
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