package view.sandlands
{
	import flash.display.MovieClip;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.sandlands.GameSandstone;
	
	import view.IPageView;
	
	public class SandstoneGameView extends MovieClip implements IPageView
	{
		private var _game:GameSandstone;
		
		public function SandstoneGameView()
		{
			_game = new GameSandstone();
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