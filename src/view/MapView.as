package view
{
	import com.greensock.TweenMax;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	
	import util.SWFAssetLoader;
	
	import view.map.MapCapitolView;
	import view.map.MapCatteryView;
	import view.map.MapJoylessView;
	import view.map.MapSandlandsView;
	import view.map.MapShipwreckView;
	
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
		private var _bgSound:Track;
		private var _VOSound:Track;
		private var _voArray:Array = ["assets/audio/cattery/cattery_VO.mp3", "assets/audio/joyless/joyless_VO.mp3", 
			"assets/audio/shipwreck/shipwreck_VO.mp3", "assets/audio/sandlands/sandlands_VO.mp3", "assets/audio/capitol/capitol_VO.mp3"];
		private var _voDurations:Array = [10, 8, 8, 8, 7];
		private var _tempObj:Object;
		private var _islandClicked:Boolean;
		private var _fog:MovieClip;
		private var _screenshotBMD:BitmapData;
		private var _screenshotBMP:Bitmap;
		
		public function MapView()
		{
			_SAL = new SWFAssetLoader("common.MapMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
		}
		
		public function destroy() : void {
			if (_VOSound) {
				_VOSound.removeEventListener(Event.COMPLETE, voSoundComplete);
				_VOSound = null;
			}
			
			if (_screenshotBMD) {
				_screenshotBMD.dispose();
				_screenshotBMD = null;
				
				removeChild(_screenshotBMP);
				
				_screenshotBMP = null;
			}
			
			_tempObj = null;
			
			removeChild(_fog);
			_fog = null;
			
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			EventController.getInstance().removeEventListener(ViewEvent.CLOSE_OVERLAY, closeNewPathOverlay);
			
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
		
		protected function mcAdded(event:Event):void
		{
			_mc.removeEventListener(Event.ADDED_TO_STAGE, mcAdded);
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.MC_READY));
		}
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.addEventListener(Event.ADDED_TO_STAGE, mcAdded);
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			EventController.getInstance().addEventListener(ViewEvent.CLOSE_OVERLAY, closeNewPathOverlay);
			
			_fog = _mc.fog1_mc;
			_fog.visible = false;
			
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
			
			_capitol = new MapCapitolView(_mc.capitol_mc);
			_cattery = new MapCatteryView(_mc.cattery_mc);
			_joyless = new MapJoylessView(_mc.joyless_mc); 
			_sandlands = new MapSandlandsView(_mc.sandlands_mc);
			_shipwreck = new MapShipwreckView(_mc.shipwreck_mc);
			
			if (DataModel.STONE_CAT) _cattery.showStone();
			if (DataModel.STONE_SERPENT) _joyless.showStone();
			if (DataModel.STONE_SAND) _sandlands.showStone();
			if (DataModel.STONE_PEARL) _shipwreck.showStone();
			
			
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
			
			_bgSound = new Track("assets/audio/global/Ocean.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		protected function closeNewPathOverlay(event:ViewEvent):void
		{
			_fog.visible = false;
			_islandClicked = false;
			if (_screenshotBMP) {
				_screenshotBMD.dispose();
				removeChild(_screenshotBMP);
			}
			_mc.visible = true;
		}
		
		protected function islandClick(event:MouseEvent):void
		{
			if (_islandClicked) return;
			
			DataModel.getInstance().buttonTap();
			
			var thisButton:String = event.target.name;
			_tempObj = new Object();
			
			switch(thisButton)
			{
				case "cattery_btn":
				{
					if (DataModel.STONE_CAT) return;
					DataModel.CURRENT_ISLAND_INT = 0;
					_tempObj.id = "theCattery.Island1View";
					break;
				}
					
				case "joyless_btn":
				{
					if (DataModel.STONE_SERPENT) return;
					DataModel.CURRENT_ISLAND_INT = 1;
					_tempObj.id = "joylessMountains.JoylessMountainsIntroView";
					break;
				}	
				
				case "shipwreck_btn":
				{
					if (DataModel.STONE_PEARL) return;
					DataModel.CURRENT_ISLAND_INT = 2;
					_tempObj.id = "shipwreck.ShipwreckCoveView";
					break;
				}		
					
				case "sandlands_btn":
				{
					if (DataModel.STONE_SAND) return;
					DataModel.CURRENT_ISLAND_INT = 3;
					_tempObj.id = "sandlands.SandlandsView";
					if (DataModel.ISLAND_SELECTED.length < 1) _tempObj.id = "sandlands.ShoreView";
					break;
				}		
				
				case "capitol_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 4;
					_tempObj.id = "capitol.CapitolView";
					break;
				}
//				default:
//				{
//					break;
//				}
			}
			DataModel.ISLAND_SELECTED.push(DataModel.ISLANDS[DataModel.CURRENT_ISLAND_INT]);
			
			_islandClicked = true;
			
			
			takeScreenshot();
			
			if (DataModel.ISLAND_SELECTED.length <= 1) {
				_tempObj.id = "prologue.CrossSeaView";
			} 
			
			_VOSound = new Track(_voArray[DataModel.CURRENT_ISLAND_INT]);
			_VOSound.addEventListener(Event.SOUND_COMPLETE, voSoundComplete);
			
			_bgSound.volumeTo(1000, .5);
			_VOSound.start();
			
			TweenMax.delayedCall(1, showFog);
		}
		
		private function takeScreenshot():void {
			_mc.visible = false;
			
			_screenshotBMD = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
			_screenshotBMP = new Bitmap(_screenshotBMD);
			_screenshotBMD.draw(_mc);
			
			addChild(_screenshotBMP);
			
//			_sectionHolder.visible = false;
			
			addChild(_fog);
		}
		
		
		private function showFog():void {
			var duration:int = _voDurations[DataModel.CURRENT_ISLAND_INT];
//			TweenMax.from(_fog, 4, {alpha:0, y:"+1200", scaleX:4, scaleY:4});
			TweenMax.from(_fog, duration, {alpha:0, y:"+1200", scaleX:4, scaleY:4});
			_fog.visible = true;
		}
		
		protected function voSoundComplete(event:Event):void
		{
			nextPage();
		}
		
		private function nextPage():void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.MAP_SELECT_ISLAND));
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, _tempObj));
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		
	}
}