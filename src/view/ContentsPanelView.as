package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	public class ContentsPanelView extends MovieClip 
	{
		private var _dragVCont:DraggableVerticalContainer;
		private var _nextY:int;
		private var _pageArray:Array;
		
		public function ContentsPanelView()
		{
			
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
			
			
			addPage();
			addPage();
			addPage();
			addPage();
			addPage();
			addPage();
			addPage();
			addPage();
		}
		
		public function addPage():void {
			var newPage:ContentsPageView = new ContentsPageView();
			
			_dragVCont.addChild(newPage);
			_dragVCont.refreshView(true);
			
			_pageArray.push(newPage);
			
			_nextY += newPage.pageHeight;
			
		}
	}
}