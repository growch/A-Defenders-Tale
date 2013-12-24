package view
{
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import assets.ContentsPageMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.PageInfo;
	
	import util.fpmobile.controls.DraggableVerticalContainer;

	public class ContentsPageView extends MovieClip
	{
		private var _mc:ContentsPageMC;
		public var pgInfo:PageInfo;
		
		private static const ACTIVE_COLOR:uint = 0xFFFFFF;
		private static const INACTIVE_COLOR:uint = 0x040404;
		private var _active:Boolean;
		private var _loader:ImageLoader;
		private var _dv:DraggableVerticalContainer;
		
		public function ContentsPageView(info:PageInfo, dv:DraggableVerticalContainer) 
		{
			pgInfo = info;
			
			_mc = new ContentsPageMC();
			_dv = dv;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			EventController.getInstance().addEventListener(ViewEvent.ADD_CONTENTS_PAGE, onNewPageAdd); 
//			EventController.getInstance().addEventListener(ViewEvent.DEACTIVATE_OTHER_PAGES, deactivateNonSelected); 
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, deactivateNonSelected); 
		}
		
		protected function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
//			_active = true;
			
			_mc.title_txt.text = pgInfo.contentPanelInfo.title;
			
			var bodyText:String = pgInfo.contentPanelInfo.body;
			bodyText = bodyText.slice(0, 115).concat(bodyText.length > 115 ? "..." : "");

			_mc.body_txt.text = bodyText;
			
			_loader = new ImageLoader(pgInfo.contentPanelInfo.image, {container:_mc.imageHolder_mc, x:0, y:0, scaleX:.5, scaleY:.5});
			_loader.load();
			_loader.autoDispose = true;
			
			activate();
			
			addChild(_mc);
			
			_mc.mouseChildren = false;
			_mc.cacheAsBitmap = true;
			_mc.addEventListener(MouseEvent.CLICK, pageClick);
		}
		
		public function destroy():void
		{
			_dv = null;
			_loader.dispose(true);
			_loader = null;
			pgInfo = null;
			EventController.getInstance().removeEventListener(ViewEvent.ADD_CONTENTS_PAGE, onNewPageAdd); 
//			EventController.getInstance().removeEventListener(ViewEvent.DEACTIVATE_OTHER_PAGES, deactivateNonSelected);
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, deactivateNonSelected);
			_mc.removeEventListener(MouseEvent.CLICK, pageClick);
			removeChild(_mc);
			_mc = null;
		}
		
		protected function pageClick(event:MouseEvent):void
		{
			if (_active) return;
			
			if (_dv.isDragging || _dv.isTweening) return;
			
			activate();
			
			var tempObj:Object = new Object();
			tempObj.id = pgInfo.contentPanelInfo.pageID;
			tempObj.contentsPage = true;
			tempObj.contentsPanelClick = true;
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_NAV_DECISION_CLICK, tempObj));
			
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_GLOBAL_NAV));
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DEACTIVATE_OTHER_PAGES, tempObj));
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_GLOBAL_NAV));
		}
		
		protected function deactivateNonSelected(event:ViewEvent):void
		{
//			var pageInfo:PageInfo = event.data as PageInfo;
			if (!event.data) return;
			if (!pgInfo) return;
			
//			trace("deactivate contents page: "+pgInfo.contentPanelInfo.pageID);
			
			if (event.data.id != pgInfo.contentPanelInfo.pageID) {
				deactivate();
			}
		}
		
		protected function onNewPageAdd(event:ViewEvent):void
		{
//			trace("onNewPageAdd event.data: "+event.data);
//			trace("pgInfo: "+pgInfo);
			if(!pgInfo) return;
			var pageInfo:PageInfo = event.data as PageInfo;
			if (pageInfo.contentPanelInfo.pageID != pgInfo.contentPanelInfo.pageID) {
				deactivate();
			}
		}
		
		public function activate():void
		{
			if (_active) return;
			
			_mc.bg_mc.gotoAndStop("active");
			_mc.title_txt.textColor = ACTIVE_COLOR;
			_mc.body_txt.textColor = ACTIVE_COLOR;
			_active = true;
			
		}
		
		protected function deactivate():void
		{
			if (!_active) return;
			
			_mc.bg_mc.gotoAndStop("inactive");
			_mc.title_txt.textColor = INACTIVE_COLOR;
			_mc.body_txt.textColor = INACTIVE_COLOR;
			_active = false;
			
		}
		
		public function get pageHeight():int {
			return _mc.height;
		}
		
	}
}