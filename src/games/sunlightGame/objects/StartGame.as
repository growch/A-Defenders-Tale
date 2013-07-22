package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import games.bopMice.core.Game;
	
	public class StartGame extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		
		public function StartGame(game:Game, mc:MovieClip)
		{
			_game = game;
			_mc = mc;
			
			MovieClip(_mc.cta_btn).addEventListener(MouseEvent.CLICK, startClick);
		}
		
		protected function startClick(event:MouseEvent):void
		{
			MovieClip(_mc.cta_btn).removeEventListener(MouseEvent.CLICK, startClick);
			_game.startGame();
		}
	}
}