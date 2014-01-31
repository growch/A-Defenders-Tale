package view
{
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;

	public class MapViewShipwreck extends MapView
	{
		private var _pageInfo:PageInfo;
		
		public function MapViewShipwreck()
		{
			_pageInfo = DataModel.appData.getPageInfo("mapShipwreck");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
		}
	}
}