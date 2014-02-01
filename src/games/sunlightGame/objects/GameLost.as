package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.sunlightGame.core.Game;
	
	public class GameLost extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		
		public function GameLost(game:Game, mc:MovieClip)
		{
			_game = game;
			_mc = mc;
			
			MovieClip(_mc.history_btn).addEventListener(MouseEvent.CLICK, ctaClick);
			MovieClip(_mc.back_btn).addEventListener(MouseEvent.CLICK, ctaClick);
		}
		
		protected function ctaClick(event:MouseEvent):void
		{
			var tempObj:Object = new Object();
			if (event.currentTarget.name == "history_btn"){
//				tempObj.id = "ShowHistoryPanel";
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.OPEN_GLOBAL_NAV, tempObj));
			} else {
				tempObj.id = "BackOneStep";
				tempObj.backOneStep = true;
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
				_game.gameCompleted(tempObj);
			}
			
		}
		
		public function destroy():void {
			MovieClip(_mc.history_btn).removeEventListener(MouseEvent.CLICK, ctaClick);
			MovieClip(_mc.back_btn).removeEventListener(MouseEvent.CLICK, ctaClick);
			_game = null;
			_mc = null;
		}
	}
}