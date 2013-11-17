package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import model.DataModel;
	
	import util.fpmobile.controls.DraggableVerticalContainer;

	public class AboutPanelView extends MovieClip 
	{
		private var _dragVCont:DraggableVerticalContainer;
		private var _textMC:MovieClip;
		private var _mc:MovieClip;
		
		public function AboutPanelView(thisMC:MovieClip)
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			_mc = thisMC;
			_textMC = _mc.text_mc;
			
			_mc.mask_mc.visible = false;
			if (!DataModel.ipad1) {
				_mc.mask_mc.cacheAsBitmap = true;
				_mc.mask_mc.alpha = 1;
				_mc.holder_mc.cacheAsBitmap = true;
				_mc.holder_mc.mask = _mc.mask_mc;
			}
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