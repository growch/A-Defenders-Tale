package view
{
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	import util.SWFAssetLoader;
	
	import view.map.MapCapitolView;
	import view.map.MapCatteryView;
	import view.map.MapJoylessView;
	import view.map.MapSandlandsView;
	import view.map.MapShipwreckView;
	import model.PageInfo;
	
	public class MapView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _catteryBtn:MovieClip;
		private var _sandlandsBtn:MovieClip;
		private var _joylessBtn:MovieClip;
		private var _shipwreckBtn:MovieClip;
		private var _capitolBtn:MovieClip;
		private var _SAL:SWFAssetLoader;
		private var _sandlands:MapSandlandsView;
		private var _shipwreck:MapShipwreckView;
		private var _joyless:MapJoylessView;
		private var _capitol:MapCapitolView;
		private var _cattery:MapCatteryView;
		private var _pageInfo:PageInfo;
		
		public function MapView()
		{
			_SAL = new SWFAssetLoader("common.MapMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
		}
		
		public function destroy() : void {
			_catteryBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			_sandlandsBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			_joylessBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			_shipwreckBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			if (_capitolBtn) {
				_capitolBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			}
			
			_catteryBtn = null;
			_sandlandsBtn = null;
			_joylessBtn = null;
			_shipwreckBtn = null;
			_capitolBtn = null;
			
			_sandlands.destroy();
			_sandlands = null;
			_shipwreck.destroy();
			_shipwreck = null;
			_joyless.destroy();
			_joyless = null;
			_capitol.destroy();
			_capitol = null;
			_cattery.destroy();
			_cattery = null;
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_SAL.destroy();
			_SAL = null;
			removeChild(_mc);
			_mc = null;
		}
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_catteryBtn = _mc.cattery_btn;
			_catteryBtn.mouseChildren = false;
			_catteryBtn.addEventListener(MouseEvent.CLICK, islandClick);
			
			_sandlandsBtn = _mc.sandlands_btn;
			_sandlandsBtn.mouseChildren = false;
			_sandlandsBtn.addEventListener(MouseEvent.CLICK, islandClick);
			
			_joylessBtn = _mc.joyless_btn;
			_joylessBtn.mouseChildren = false;
			_joylessBtn.addEventListener(MouseEvent.CLICK, islandClick);
			
			_shipwreckBtn = _mc.shipwreck_btn;
			_shipwreckBtn.mouseChildren = false;
			_shipwreckBtn.addEventListener(MouseEvent.CLICK, islandClick);
			
			_sandlands = new MapSandlandsView(_mc.sandlands_mc);
			_shipwreck = new MapShipwreckView(_mc.shipwreck_mc);
			_joyless = new MapJoylessView(_mc.joyless_mc); 
			_capitol = new MapCapitolView(_mc.capitol_mc);
			_cattery = new MapCatteryView(_mc.cattery_mc);
			
			if (DataModel.STONE_COUNT >= 4) {
				_capitol.showCapitol();
				_capitolBtn = _mc.capitol_btn;
				_capitolBtn.mouseChildren = false;
				_capitolBtn.addEventListener(MouseEvent.CLICK, islandClick);
			} 
			
			addChild(_mc);
			
			_pageInfo = DataModel.appData.getPageInfo("map");
//			_pageInfo.contentPanelInfo.body = "What should this copy be if anything?";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
			
			DataModel.getInstance().oceanSound();
		}
		
		protected function islandClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			var thisButton:String = event.target.name;
			var tempObj:Object = new Object();
			
			switch(thisButton)
			{
				case "cattery_btn":
				{
					if (DataModel.STONE_CAT) return;
					DataModel.CURRENT_ISLAND_INT = 0;
					tempObj.id = "theCattery.Island1View";
					break;
				}
					
				case "joyless_btn":
				{
					if (DataModel.STONE_SERPENT) return;
					DataModel.CURRENT_ISLAND_INT = 1;
					tempObj.id = "joylessMountains.JoylessMountainsIntroView";
					break;
				}	
				
				case "shipwreck_btn":
				{
					if (DataModel.STONE_PEARL) return;
					DataModel.CURRENT_ISLAND_INT = 2;
					tempObj.id = "shipwreck.ShipwreckCoveView";
					break;
				}		
					
				case "sandlands_btn":
				{
					if (DataModel.STONE_SAND) return;
					DataModel.CURRENT_ISLAND_INT = 3;
					tempObj.id = "sandlands.SandlandsView";
					if (DataModel.ISLAND_SELECTED.length < 1) tempObj.id = "sandlands.ShoreView";
					break;
				}		
				
				case "capitol_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 4;
					tempObj.id = "capitol.CapitolView";
					break;
				}
//				default:
//				{
//					break;
//				}
			}
			DataModel.ISLAND_SELECTED.push(DataModel.ISLANDS[DataModel.CURRENT_ISLAND_INT]);
			
			if (DataModel.ISLAND_SELECTED.length <= 1) {
//				TESTING!!!!
//				tempObj.id = "prologue.CrossSeaView";
			}
			
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.MAP_SELECT_ISLAND));
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
			
			
		}
		
	}
}