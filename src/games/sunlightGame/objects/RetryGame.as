package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import games.bopMice.core.Game;
	
	public class RetryGame extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		
		public function RetryGame(game:Game, mc:MovieClip)
		{
			_game = game;
			_mc = mc;
			
			MovieClip(_mc.cta_btn).addEventListener(MouseEvent.CLICK, ctaClick);
		}
		
		protected function ctaClick(event:MouseEvent):void
		{
			_game.restartGame();
		}
		
		public function destroy():void {
			MovieClip(_mc.cta_btn).removeEventListener(MouseEvent.CLICK, ctaClick);
		}
	}
}