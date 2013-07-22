package view.capitol
{
	import flash.display.MovieClip;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.sunlightGame.core.Game;
	
	import view.IPageView;
	
	public class SunlightGameView extends MovieClip implements IPageView
	{
		private var _game:Game;
		
		public function SunlightGameView()
		{
			_game = new Game();
			addChild(_game);
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
		}
		
		public function destroy() : void {
			_game.destroy();
			removeChild(_game);
			_game = null;
			
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}