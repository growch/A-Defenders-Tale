package games.bopMice.objects
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import games.bopMice.core.Game;
	
	public class GameWon extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		
		public function GameWon(game:Game, mc:MovieClip)
		{
			_game = game;
			_mc = mc;
			
			MovieClip(_mc.cta_btn).addEventListener(MouseEvent.CLICK, ctaClick);
		}
		
		protected function ctaClick(event:MouseEvent):void
		{
			_game.gameCompleted();
		}
		
		public function destroy():void {
			MovieClip(_mc.cta_btn).removeEventListener(MouseEvent.CLICK, ctaClick);
		}
	}
}