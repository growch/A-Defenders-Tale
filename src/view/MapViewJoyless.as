package view
{
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;

	public class MapViewJoyless extends MapView
	{
		private var _pageInfo:PageInfo;
		
		public function MapViewJoyless()
		{
			_pageInfo = DataModel.appData.getPageInfo("mapJoyless");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
		}
	}
}