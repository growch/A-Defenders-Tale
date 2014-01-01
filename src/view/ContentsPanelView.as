package view
{
	import com.adobe.utils.StringUtil;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.ContentPanelInfo;
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	public class ContentsPanelView extends MovieClip 
	{
		public var dragVCont:DraggableVerticalContainer;
		private var _nextY:int;
		private var _pageArray:Vector.<ContentsPageView>;
		private var _pageInfoArray:Vector.<PageInfo>;
		private var _cpv:ContentsPageView;
		private var _pi:PageInfo;
		private var _selectedNamespace:String;
		private var _tempArray:Array;
		private var _restoring:Boolean;
		private var _loaderMax:LoaderMax;
		private var _loadMultiple:Boolean;
		private var _dm:DataModel;
		
		public function ContentsPanelView()
		{
			EventController.getInstance().addEventListener(ViewEvent.ADD_CONTENTS_PAGE, addContentsPage); 
//			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
//			EventController.getInstance().addEventListener(ViewEvent.MAP_SELECT_ISLAND, resetSelectedIsland);
			EventController.getInstance().addEventListener(ApplicationEvent.RESTART_BOOK, resetPanel);
			EventController.getInstance().addEventListener(ApplicationEvent.GOD_MODE_ON, godModeOn);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_nextY = 0;
			
			dragVCont = new DraggableVerticalContainer(0, 0x000000, 0);
			dragVCont.SCROLL_INDICATOR_RIGHT_PADDING = 0;
			dragVCont.width = Math.floor(this.parent.parent.width) - 2;
			dragVCont.height = Math.floor(this.parent.parent.height) - 13; 
			dragVCont.refreshView(true);
			addChild(dragVCont);
			
			_loaderMax = new LoaderMax({name:"mainQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});
			
			
			_dm = DataModel.getInstance();
//			if (DataModel.getInstance().alreadyRead) {
//				trace("BOOK ALREADY READ -> ContentsPanelView");
//			}
			
//			if (_dm.rebuildPrevious) {
////				trace("REBUILDING *** -> ContentsPanelView");
//				_pageArray = new Vector.<ContentsPageView>();
//				_pageInfoArray = DataModel.PAGE_ARRAY;
//				_restoring = true;
//				addPreviousPages();
//			} else {
				_pageArray = new Vector.<ContentsPageView>();
				_pageInfoArray = new Vector.<PageInfo>();
//			}
		}
		
		public function restorePrevious():void {
			_pageArray = new Vector.<ContentsPageView>();
			_pageInfoArray = DataModel.PAGE_ARRAY;
			_restoring = true;
			addPreviousPages();
		}
		
		private function progressHandler(event:LoaderEvent):void { 
//			trace("progress: " + event.target.progress);
		}
		
		private function completeHandler(event:LoaderEvent):void {
//			trace(event.target + " is complete!");
		}
		
		private function errorHandler(event:LoaderEvent):void {
			trace("_loaderMax ++++++ error occured with " + event.target + ": " + event.text);
		}
		
		public function addImageLoader(imgLdr:ImageLoader):void {
			_loaderMax.append(imgLdr);
		}
		
		protected function resetPanel(event:ApplicationEvent):void
		{
			removeOldPages();
		}
		
		protected function godModeOn(event:Event):void
		{
			_loadMultiple = true;
			var cpiVect:Vector.<ContentPanelInfo> = DataModel.appData.parseContentsForGod();
			
			for (var i:int = 0; i < cpiVect.length; i++) 
			{
				var pgInf:PageInfo = new PageInfo();
				pgInf.contentPanelInfo = cpiVect[i];
				addPage(pgInf);
			}
			//LOAD THE IMAGES
			_loaderMax.load(true);
			
			_loadMultiple = false;
		}
		
		protected function addPreviousPages():void
		{
			_loadMultiple = true;
//			trace("addPreviousPages");
//			trace(_pageInfoArray.length);
			
			for (var i:int = 0; i < _pageInfoArray.length; i++) 
			{
				addPage(_pageInfoArray[i]);
			}
			
			//LOAD THE IMAGES
			_loaderMax.load(true);
			
			_restoring = false;
			_loadMultiple = false;
		}
		
		protected function addContentsPage(event:ViewEvent):void
		{
			
			if (DataModel.GOD_MODE) return;
			
			var pgInf:PageInfo = event.data as PageInfo;
			
			if (checkForPage(pgInf)) return;
			
//			trace("CP!!!! addContentsPage");
			
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
		
		
		public function pageVisited(pageID:String):Boolean {
			trace("pageVisited DataModel.CURRENT_PAGE_ID:"+DataModel.CURRENT_PAGE_ID);
			var pageFound:Boolean = false;
			
			for (var i:int = 0; i < _pageArray.length; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				if (pageID == _cpv.pgInfo.contentPanelInfo.pageID) {
					pageFound = true;
				}
			}
			
			return pageFound;
		}

		public function changingPath(nextSelectedID:String):Boolean {
			var nextPageNew:Boolean = false;
			var currentPageIndex:int;
			var nextVisited:String;
//			trace("CHANGING PATH????");
			
			for (var i:int = 0; i < _pageInfoArray.length; i++) 
			{
				_pi = _pageInfoArray[i];
				if (DataModel.CURRENT_PAGE_ID == _pi.contentPanelInfo.pageID) {
					currentPageIndex = i;
					//if the next one is new i.e. beyond _pageInfoArray
					if ((currentPageIndex+1) >= _pageInfoArray.length) {
						return false;
					}
					nextVisited = _pageInfoArray[currentPageIndex+1].contentPanelInfo.pageID;
					break;
				}
			}
//			trace("currentPageIndex: "+currentPageIndex);
//			trace("next visited page: " + _pageInfoArray[currentPageIndex+1].contentPanelInfo.pageID);
//			trace("next CLICKED page: "+nextSelectedID);
			if (nextSelectedID != nextVisited) {
				nextPageNew = true;
			}
//			trace("nextPageNew: "+nextPageNew);
			
			return nextPageNew;
		}
		
		public function backOneStep():String {
			var currentPageIndex:int;
			var previousVisited:String;
			
			for (var i:int = 0; i < _pageInfoArray.length; i++) 
			{
				_pi = _pageInfoArray[i];
				if (DataModel.CURRENT_PAGE_ID == _pi.contentPanelInfo.pageID) {
					currentPageIndex = i;
					//if the next one is beyond _pageInfoArray
//					if ((currentPageIndex+1) >= _pageInfoArray.length) {
//						return false;
//					}
					previousVisited = _pageInfoArray[currentPageIndex-1].contentPanelInfo.pageID;
					break;
				}
			}
//			trace("previousVisited: "+previousVisited);
			return previousVisited;
		}
		
		public function scrollToBottom():void {
			dragVCont.scrollY = dragVCont.maxScroll;
		}
		
		public function addPage(pgInf:PageInfo):void {
			var newPage:ContentsPageView = new ContentsPageView(pgInf,this);
			
			dragVCont.addChild(newPage);
			dragVCont.refreshView(true);
			
			_pageArray.push(newPage);
			
			if (!_restoring) {
				//IMPORTANT FOR RESTORE
				_pageInfoArray.push(pgInf);
				DataModel.PAGE_ARRAY = _pageInfoArray;
			}
			
			if (!_loadMultiple) {
//				trace("load CPV image");
				_loaderMax.load(true);
			}
			
			_nextY += newPage.pageHeight;
//			trace("++++addPage: "+ pgInf.contentPanelInfo.pageID);
			scrollToBottom();
		}
		
//		protected function decisionMade(event:ViewEvent):void
//		{
//			var decisionID:String = event.data.id;
//			
//			var len:int = _pageArray.length;
//			
//			for (var i:int = 0; i < len; i++) 
//			{
//				_cpv = _pageArray[i] as ContentsPageView;
//				
//				
//				if (DataModel.CURRENT_PAGE_ID == _cpv.pgInfo.contentPanelInfo.pageID) {
////					_cpv.activate();
//					
//					if (DataModel.GOD_MODE) return;
//					
//					if (event.data.contentsPanelClick) return;
//					
////					removeOldPages(i+1);
//					return;
//				}
//			}
//		}
		
		public function overwriteHistory():void {
			var len:int = _pageArray.length;
						
			for (var i:int = 0; i < len; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				
				if (DataModel.CURRENT_PAGE_ID == _cpv.pgInfo.contentPanelInfo.pageID) {
					
					if (DataModel.GOD_MODE) return;
					
					removeOldPages(i+1);
					return;
				}
			}
			
		}
		
		private function removeOldPages(startIndex:int = 0):void {
			if (DataModel.GOD_MODE) return;
			
			trace("††††††††††† removeOldPages");
			for (var i:int = startIndex; i < _pageArray.length; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				_nextY -= _cpv.pageHeight;
				_cpv.destroy();
				dragVCont.removeChild(_cpv);
				dragVCont.refreshView(true);
			}
			_pageArray.length = startIndex;
			_pageInfoArray.length = startIndex;
			
			//IMPORTANT FOR RESTORE
			DataModel.PAGE_ARRAY = _pageInfoArray;
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
					
					dragVCont.removeChild(_cpv);
					dragVCont.refreshView(true);
				}
			}
			_pageArray.splice(_tempArray[0], _tempArray.length);
			_pageInfoArray.splice(_tempArray[0], _tempArray.length);
		}
		
		
	}
}