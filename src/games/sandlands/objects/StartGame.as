package games.sandlands.objects
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import games.sandlands.GameSandstone;

 games.sandlands.GameSandstone
	
	public class StartGame extends MovieClip
	{
		private var _game:GameSandstone;
		private var _mc:MovieClip;
		
		public function StartGame(game:GameSandstone, mc:MovieClip)
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