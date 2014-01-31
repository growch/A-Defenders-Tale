package view
{
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;

	public class MapViewPrologue extends MapView
	{
		private var _pageInfo:PageInfo;
		
		public function MapViewPrologue()
		{
			_pageInfo = DataModel.appData.getPageInfo("mapPrologue");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
		}
	}
}