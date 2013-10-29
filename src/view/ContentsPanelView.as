package view
{
	import com.adobe.utils.StringUtil;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.ContentPanelInfo;
	import model.DataModel;
	import model.PageInfo;
	
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	public class ContentsPanelView extends MovieClip 
	{
		private var _dragVCont:DraggableVerticalContainer;
		private var _nextY:int;
		private var _pageArray:Array;
		private var _cpv:ContentsPageView;
		private var _selectedNamespace:String;
		private var _tempArray:Array;
		
		public function ContentsPanelView()
		{
			EventController.getInstance().addEventListener(ViewEvent.ADD_CONTENTS_PAGE, addContentsPage); 
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			EventController.getInstance().addEventListener(ViewEvent.MAP_SELECT_ISLAND, resetSelectedIsland);
			EventController.getInstance().addEventListener(ApplicationEvent.RESTART_BOOK, resetPanel);
			EventController.getInstance().addEventListener(ApplicationEvent.GOD_MODE_ON, godModeOn);
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_pageArray = new Array();
			
			_nextY = 0;
			
			_dragVCont = new DraggableVerticalContainer(0, 0x000000, 0);
			_dragVCont.SCROLL_INDICATOR_RIGHT_PADDING = 0;
			_dragVCont.width = Math.floor(this.parent.parent.width) - 2;
			_dragVCont.height = Math.floor(this.parent.parent.height) - 2; 
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
		}
		
		protected function resetPanel(event:ApplicationEvent):void
		{
			removeOldPages();
		}
		
		protected function godModeOn(event:Event):void
		{
			var cpiVect:Vector.<ContentPanelInfo> = DataModel.appData.parseContentsForGod();
			
			for (var i:int = 0; i < cpiVect.length; i++) 
			{
				var pgInf:PageInfo = new PageInfo();
				pgInf.contentPanelInfo = cpiVect[i];
				addPage(pgInf);
			}
			
		}
		
		protected function addContentsPage(event:ViewEvent):void
		{
			if (DataModel.GOD_MODE) return;
			
			var pgInf:PageInfo = event.data as PageInfo;
			
			if (checkForPage(pgInf)) return;
			
			addPage(pgInf);
		}
		
		private function checkForPage(pgInf:PageInfo):Boolean {
			var pageFound:Boolean = false;
			
			for (var i:int = 0; i < _pageArray.length; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				if (pgInf.contentPanelInfo.pageID == _cpv.pgInfo.contentPanelInfo.pageID) {
					pageFound = true;
				}
			}
			
			return pageFound;
		}
		
		public function scrollToBottom():void {
			_dragVCont.scrollY = _dragVCont.maxScroll;
		}
		
		public function addPage(pgInf:PageInfo):void {
			var newPage:ContentsPageView = new ContentsPageView(pgInf,_dragVCont);
			
			_dragVCont.addChild(newPage);
			_dragVCont.refreshView(true);
			
			_pageArray.push(newPage);
			
			_nextY += newPage.pageHeight;
//			trace("++++addPage: "+ pgInf.contentPanelInfo.pageID);
			scrollToBottom();
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			if (DataModel.GOD_MODE) return;
			
			var decisionID:String = event.data.id;
			
			var len:int = _pageArray.length;
			
			for (var i:int = 0; i < len; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				
				
				if (DataModel.CURRENT_PAGE_ID == _cpv.pgInfo.contentPanelInfo.pageID) {
					_cpv.activate();
					removeOldPages(i+1);
					return;
				}
			}
		}
		
		private function removeOldPages(startIndex:int = 0):void {
			if (DataModel.GOD_MODE) return;
			
			for (var i:int = startIndex; i < _pageArray.length; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				_nextY -= _cpv.pageHeight;
				_cpv.destroy();
				_dragVCont.removeChild(_cpv);
				_dragVCont.refreshView(true);
			}
			_pageArray.length = startIndex;
		}
		
		protected function resetSelectedIsland(event:ViewEvent):void
		{
			_selectedNamespace = DataModel.ISLAND_NAMESPACE[DataModel.CURRENT_ISLAND_INT];
			
			var len:int = _pageArray.length;
			var i:int;
			_tempArray = [];
			
			for (i = 0; i < len; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				if (StringUtil.beginsWith(_cpv.pgInfo.contentPanelInfo.pageID, _selectedNamespace)) {
					_nextY -= _cpv.pageHeight;
					_cpv.destroy();
					_tempArray.push(i);
					
					_dragVCont.removeChild(_cpv);
					_dragVCont.refreshView(true);
				}
			}
			_pageArray.splice(_tempArray[0], _tempArray.length);
		}
		
		
	}
}