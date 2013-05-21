package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.PicnicMC;
	
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
	import model.PageInfo;
	
	public class PicnicView extends MovieClip implements IPageView
	{
		private var _mc:PicnicMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _bellR1:MovieClip;
		private var _bellR2:MovieClip;
		private var _bellR3:MovieClip;
		private var _bellR4:MovieClip;
		private var _pageInfo:PageInfo;
		
		public function PicnicView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
			_pageInfo = null;
			
			_frame.destroy();
			_frame = null;
			
			_decisions.destroy();
			_mc.removeChild(_decisions);
			_decisions = null;
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			//for delayed calls
			TweenMax.killAll();
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new PicnicMC();
			
			_nextY = 330;
			
			_bellR1 = _mc.vine_mc.bell1_mc;
			_bellR2 = _mc.vine_mc.bell2_mc;
			_bellR3 = _mc.vine_mc.bell3_mc;
			_bellR4 = _mc.vine_mc.bell4_mc;
			_bellR1.stop();
			_bellR2.stop();
			_bellR3.stop();
			_bellR4.stop();
			
			var supplyInt:int;
			if (!DataModel.STONE_CAT) {
				supplyInt = 1;
			}
			//TESTING
//			supplyInt = 1;
			
			_pageInfo = DataModel.appData.getPageInfo("picnic");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]",_pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]",_pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion3]",_pageInfo.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion4]",_pageInfo.companion4[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[supplies]",_pageInfo.supplies[supplyInt]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "last") {
						_mc.end_mc.y = Math.round(_tf.y + _tf.height + 80);
						_nextY += _mc.end_mc.height + 60;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY +=_pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.picnic.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_frame = new FrameView(_mc.frame_mc); 
			
			var frameSize:int = _decisions.y + 250;
			// size bg
			_mc.bg_mc.height = frameSize;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(e:ViewEvent):void {
			_bellR1.play();
			_bellR2.play();
			_bellR3.play();
			_bellR4.play();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				
				_bellR1.stop();
				_bellR2.stop();
				_bellR3.stop();
				_bellR4.stop();
				
				_scrolling = true;
				
			} else {
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				
				_bellR1.play();
				_bellR2.play();
				_bellR3.play();
				_bellR4.play();
				
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			TweenMax.to(_mc, 1, {alpha:0});
		}

		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}