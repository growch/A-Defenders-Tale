package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import assets.CatRanchShoreMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.StoryPart;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class CatRanchShoreView extends MovieClip implements IPageView
	{
		private var _mc:CatRanchShoreMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _picture:MovieClip;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _force:Number;
		private var _n:Number;
		
		CatlingAffairsView
		public function CatRanchShoreView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 

			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
			_frame.destroy();
			_frame = null;
			
			_decisions.destroy();
			_mc.removeChild(_decisions);
			_decisions = null;
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			DataModel.getInstance().removeAllChildren(_mc);
			_dragVCont.removeChild(_mc);
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_picture.removeEventListener(MouseEvent.CLICK, swingPic);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new CatRanchShoreMC();
			
			_nextY = 110;
			
			_picture = _mc.picture_mc;
			var compAlongIndex:int;
			if (DataModel.COMPANION_TAKEN) {
				compAlongIndex = 0;
			} else {
				compAlongIndex = 1;
			}
			
			var supplyIndex:int;
			if (DataModel.supplies) {
				supplyIndex = 0;
			} else {
				supplyIndex = 1;
			}
			
			_bodyParts = DataModel.appData.catRanchShore.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					if (compAlongIndex == 0) {
						copy = StringUtil.replace(copy, "[companionComing1]", DataModel.appData.catRanchShore.companionComing1[compAlongIndex]);
					} else {
					// this is an array within an array
						copy = StringUtil.replace(copy, "[companionComing1]", DataModel.appData.catRanchShore.companionComing1[compAlongIndex][DataModel.defenderInfo.companion]);
					}
					
					copy = StringUtil.replace(copy, "[companionComing2]", DataModel.appData.catRanchShore.companionComing2[compAlongIndex]);
					copy = StringUtil.replace(copy, "[supplies]", DataModel.appData.catRanchShore.supplies[supplyIndex]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x000000), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = Math.round(_nextY + part.top);
					_mc.addChild(_tf);
					
					if (part.id == "picture") {
						_picture.y = Math.round(_tf.y + _tf.height) + 30;
					}
					
					_nextY += Math.round(_tf.height + part.top);
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += Math.round(part.height + part.top);
				}
			}
			
			// decision
			_nextY += DataModel.appData.catRanchShore.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.catRanchShore.decisions,0x000000,true); //tint it black, showBG
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_frame = new FrameView(_mc.frame_mc); 
			
			var frameSize:int = _decisions.y + 210;
			// size bg
			_mc.bg_mc.height = frameSize;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn});
			trace("WTF");
		}
		
		private function pageOn(e:ViewEvent):void {
//			return;
			_force = 20;
			_n = 0;
			_picture.addEventListener(MouseEvent.CLICK, swingPic);
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function swing():void {
			if (_force <= 0) {
				_force = 0;
				return;
			}
			_n += .1;
			_picture.rotation += ((Math.cos(_n)*_force) - _picture.rotation) * .08;
			_force -= .08;
		}
		
		protected function swingPic(event:MouseEvent):void
		{
			_force = 20;
//			_n = 0;
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
			} else {
				
				swing();
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
//			TweenMax.to(_mc, 1, {alpha:0});
//			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}