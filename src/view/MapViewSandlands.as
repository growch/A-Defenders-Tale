package view
{
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;

	public class MapViewSandlands extends MapView
	{
		private var _pageInfo:PageInfo;
		
		public function MapViewSandlands()
		{
			_pageInfo = DataModel.appData.getPageInfo("mapSandlands");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
		}
	}
}