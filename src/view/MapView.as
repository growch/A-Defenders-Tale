package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	import util.SWFAssetLoader;
	
	public class MapView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _catteryBtn:MovieClip;
		private var _sandlandsBtn:MovieClip;
		private var _joylessBtn:MovieClip;
		private var _shipwreckBtn:MovieClip;
		private var _capitolBtn:MovieClip;
		private var _SAL:SWFAssetLoader;
		
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
			_capitolBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_SAL.destroy();
			_SAL = null;
			_mc = null;
		}
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
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
			
			_capitolBtn = _mc.capitol_btn;
			_capitolBtn.mouseChildren = false;
			_capitolBtn.addEventListener(MouseEvent.CLICK, islandClick);
			
			addChild(_mc);
			
		}
		
		protected function islandClick(event:MouseEvent):void
		{
			var thisButton:String = event.target.name;
			var tempObj:Object = new Object();
			
			switch(thisButton)
			{
				case "capitol_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 4;
					tempObj.id = "capitol.CapitolView";
					break;
				}
					
				case "cattery_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 0;
					tempObj.id = "theCattery.Island1View";
					break;
				}
					
				case "joyless_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 1;
					tempObj.id = "joylessMountains.JoylessMountainsIntroView";
					break;
				}	
				
				case "shipwreck_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 2;
					tempObj.id = "shipwreck.ShipwreckCoveView";
					break;
				}		
					
				case "sandlands_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 3;
					tempObj.id = "sandlands.SandlandsView";
					if (DataModel.ISLAND_SELECTED.length < 1) tempObj.id = "sandlands.ShoreView";
					break;
				}		
					
//				default:
//				{
//					break;
//				}
			}
			DataModel.ISLAND_SELECTED.push(DataModel.ISLANDS[DataModel.CURRENT_ISLAND_INT]);
			
			if (DataModel.ISLAND_SELECTED.length <= 1) {
				tempObj.id = "prologue.CrossSeaView";
			}
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
	}
}