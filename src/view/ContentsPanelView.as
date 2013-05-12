package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import model.DataModel;
	
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	public class ContentsPanelView extends MovieClip //235
	{
		private var _dragVCont:DraggableVerticalContainer;
		public function ContentsPanelView()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_dragVCont = new DraggableVerticalContainer(0, 0x000000, .8, true);
			_dragVCont.width = 235;
			_dragVCont.height = DataModel.APP_HEIGHT-61; 
//			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
		}
	}
}