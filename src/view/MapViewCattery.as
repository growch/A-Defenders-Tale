package view
{
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;

	public class MapViewCattery extends MapView
	{
		private var _pageInfo:PageInfo;
		
		public function MapViewCattery()
		{
			_pageInfo = DataModel.appData.getPageInfo("mapCattery");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
		}
	}
}