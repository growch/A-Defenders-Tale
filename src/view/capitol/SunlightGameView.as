package view.capitol
{
	import flash.display.MovieClip;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.sunlightGame.core.Game;
	
	import model.DataModel;
	
	import view.IPageView;
	import model.PageInfo;
	
	public class SunlightGameView extends MovieClip implements IPageView
	{
		private var _game:Game;
		private var _pageInfo:PageInfo;
		
		public function SunlightGameView()
		{
			_game = new Game();
			addChild(_game);
			
			_pageInfo = DataModel.appData.getPageInfo("sunlightGame");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
			
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