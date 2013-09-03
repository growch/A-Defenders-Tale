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

	public class ContentsPageView extends MovieClip
	{
		private var _mc:ContentsPageMC;
		public var pgInfo:PageInfo;
		
		private static const ACTIVE_COLOR:uint = 0xFFFFFF;
		private static const INACTIVE_COLOR:uint = 0x040404;
		private var _active:Boolean;
		private var _loader:ImageLoader;
		
		public function ContentsPageView(info:PageInfo) 
		{
			pgInfo = info;
			
			_mc = new ContentsPageMC();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			EventController.getInstance().addEventListener(ViewEvent.ADD_CONTENTS_PAGE, onNewPageAdd); 
			EventController.getInstance().addEventListener(ViewEvent.DEACTIVATE_OTHER_PAGES, deactivateNonSelected); 
		}
		
		protected function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_active = true;
			
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
			_mc.addEventListener(MouseEvent.CLICK, pageClick);
		}
		
		public function destroy():void
		{
			_loader.dispose(true);
			_loader = null;
			pgInfo = null;
			EventController.getInstance().removeEventListener(ViewEvent.ADD_CONTENTS_PAGE, onNewPageAdd); 
			EventController.getInstance().removeEventListener(ViewEvent.DEACTIVATE_OTHER_PAGES, deactivateNonSelected);
			_mc.removeEventListener(MouseEvent.CLICK, pageClick);
			removeChild(_mc);
			_mc = null;
		}
		
		protected function pageClick(event:MouseEvent):void
		{
			if (_active) return;
			
			activate();
			
			var tempObj:Object = new Object();
			tempObj.id = pgInfo.contentPanelInfo.pageID;
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DEACTIVATE_OTHER_PAGES, tempObj));
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_GLOBAL_NAV));
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
			
		}
		
		protected function deactivateNonSelected(event:ViewEvent):void
		{
//			var pageInfo:PageInfo = event.data as PageInfo;
			if (event.data.id != pgInfo.contentPanelInfo.pageID) {
				deactivate();
			}
		}
		
		protected function onNewPageAdd(event:ViewEvent):void
		{
			var pageInfo:PageInfo = event.data as PageInfo;
			if (pageInfo.contentPanelInfo.pageID != pgInfo.contentPanelInfo.pageID) {
				deactivate();
			}
		}
		
		public function activate():void
		{
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