package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	public class ContentsPanelView extends MovieClip 
	{
		private var _dragVCont:DraggableVerticalContainer;
		private var _nextY:int;
		private var _pageArray:Array;
		private var _cpv:ContentsPageView;
		
		public function ContentsPanelView()
		{
			EventController.getInstance().addEventListener(ViewEvent.ADD_CONTENTS_PAGE, addContentsPage); 
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
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
//			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
		}
		
		protected function addContentsPage(event:ViewEvent):void
		{
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
		
		public function addPage(pgInf:PageInfo):void {
			var newPage:ContentsPageView = new ContentsPageView(pgInf,_dragVCont);
			
			_dragVCont.addChild(newPage);
			_dragVCont.refreshView(true);
			
			_pageArray.push(newPage);
			
			_nextY += newPage.pageHeight;
			
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
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
		
		private function removeOldPages(startIndex:int):void {
			for (var i:int = startIndex; i < _pageArray.length; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				_nextY -= _cpv.pageHeight;
				_cpv.destroy();
				_dragVCont.removeChild(_cpv);
				_dragVCont.refreshView(true);
//				trace("remove: "+_cpv.pgInfo.contentPanelInfo.pageID);
			}
			_pageArray.length = startIndex;
		}
	}
}