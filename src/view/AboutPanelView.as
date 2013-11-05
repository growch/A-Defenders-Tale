package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import util.fpmobile.controls.DraggableVerticalContainer;

	public class AboutPanelView extends MovieClip 
	{
		private var _dragVCont:DraggableVerticalContainer;
		private var _textMC:MovieClip;
		
		public function AboutPanelView(contentObject:MovieClip)
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			_textMC = contentObject;
		}
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_dragVCont = new DraggableVerticalContainer(0, 0x000000, 0);
			_dragVCont.SCROLL_INDICATOR_RIGHT_PADDING = 0;
			_dragVCont.width = Math.floor(this.parent.parent.width) - 2;
			_dragVCont.height = 670;
			
			_dragVCont.addChild(_textMC);
			
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
		}
		
	}
}