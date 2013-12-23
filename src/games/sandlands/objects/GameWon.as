package games.sandlands.objects
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import games.sandlands.GameSandstone;
	
	public class GameWon extends MovieClip
	{
		private var _game:GameSandstone;
		private var _mc:MovieClip;
		
		public function GameWon(game:GameSandstone, mc:MovieClip)
		{
			_game = game;
			_mc = mc;
			
			MovieClip(_mc.cta_btn).addEventListener(MouseEvent.CLICK, ctaClick);
		}
		
		protected function ctaClick(event:MouseEvent):void
		{
			var tempObj:Object = new Object();
			tempObj.id = "sandlands.SandstoneWinView";
			_game.gameCompleted(tempObj);
		}
		
		public function destroy():void {
			MovieClip(_mc.cta_btn).removeEventListener(MouseEvent.CLICK, ctaClick);
			_game = null;
			_mc = null;
		}
	}
}