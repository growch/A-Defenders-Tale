package view.theCattery
{
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.bopMice.core.Game;
	
	import view.IPageView;
	
	public class BopMiceView extends MovieClip implements IPageView
	{
		private var _game:Game;
		
		
		public function BopMiceView()
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
			TweenMax.to(_game, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}