package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import assets.MapMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	public class MapView extends MovieClip implements IPageView
	{
		private var _mc:MapMC;
		private var _catteryBtn:MovieClip;
		private var _sandlandsBtn:MovieClip;
		private var _joylessBtn:MovieClip;
		private var _shipwreckBtn:MovieClip;
		
		public function MapView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
		}
		
		public function destroy() : void {
			_catteryBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			_sandlandsBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			_joylessBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			_shipwreckBtn.removeEventListener(MouseEvent.CLICK, islandClick);
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			removeChild(_mc);
			_mc = null;
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new MapMC();
			
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
			
			addChild(_mc);
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0}); 
		}
		
		protected function islandClick(event:MouseEvent):void
		{
			var thisButton:String = event.target.name;
			var tempObj:Object = new Object();
			
			switch(thisButton)
			{
				case "cattery_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 0;
					tempObj.id = "cattery.Island1View";
					break;
				}
					
				case "joyless_btn":
				{
					DataModel.CURRENT_ISLAND_INT = 1;
					tempObj.id = "joyless.JoylessMountainsIntroView";
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
			
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
//			TweenMax.to(_mc, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}