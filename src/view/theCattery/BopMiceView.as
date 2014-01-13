package view.theCattery
{
	import flash.display.MovieClip;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import games.bopMice.core.Game;
	
	import model.DataModel;
	
	import view.IPageView;
	import model.PageInfo;
	
	public class BopMiceView extends MovieClip implements IPageView
	{
		private var _game:Game;
		private var _pageInfo:PageInfo;
		
		public function BopMiceView()
		{
			_game = new Game();
			addChild(_game);
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_pageInfo = DataModel.appData.getPageInfo("bopMice");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
		}
		
		public function destroy() : void {
			_game.destroy();
			removeChild(_game);
			_game = null;
			
			_pageInfo = null;
			
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}