package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.DocksMC;
	
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
	
	public class DocksView extends MovieClip implements IPageView
	{
		private var _mc:DocksMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _almsGiven:int = 0;;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _cloud4:MovieClip;
		private var _cloud5:MovieClip;
		
		StealView, NegotiateView
		public function DocksView()
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
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_dragVCont.removeChild(_mc);
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, frameLoop);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			if (DataModel.coinCount > 0) {
				_almsGiven = 1;
			} else {
				_almsGiven = 0;
			}
			
			_mc = new DocksMC();
			
			_nextY = 110;
			
			_cloud1 = _mc.clouds_mc.cloud1_mc;
			_cloud2 = _mc.clouds_mc.cloud2_mc;
			_cloud3 = _mc.clouds_mc.cloud3_mc;
			_cloud4 = _mc.clouds_mc.cloud4_mc;
			_cloud5 = _mc.clouds_mc.cloud5_mc;
			
			_mc.boat_mc.stop();
			
			_bodyParts = DataModel.appData.docks.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[alms]", DataModel.appData.docks.alms[_almsGiven]);
					copy = StringUtil.replace(copy, "[gender1]", DataModel.appData.docks.gender1[DataModel.defenderInfo.gender]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = Math.round(_nextY + part.top);
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += Math.round(part.height + part.top);
				}
			}
			
			// decision
			_decisions = new DecisionsView(DataModel.appData.docks.decisions);
			_decisions.y = _nextY + DataModel.appData.docks.decisionsMarginTop;
			_mc.addChild(_decisions);
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_frame = new FrameView(_mc.frame_mc);
			
			var frameSize:int = _decisions.y + 210;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(event:ViewEvent):void {
			_mc.boat_mc.play();
			addEventListener(Event.ENTER_FRAME, frameLoop);
		}
		
		protected function frameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_mc.boat_mc.stop();
				
				_scrolling = true;
			} else {
				
				_cloud1.x -= .2;
				if (_cloud1.x < -_cloud1.width) _cloud1.x = 768;
				
				_cloud2.x -= .3;
				if (_cloud2.x < -_cloud2.width) _cloud2.x = 768;
				
				_cloud3.x -= .15;
				if (_cloud3.x < -_cloud3.width) _cloud3.x = 768;
				
				_cloud4.x -= .35;
				if (_cloud4.x < -_cloud4.width) _cloud4.x = 768;
				
				_cloud5.x -= .1;
				if (_cloud5.x < -_cloud5.width) _cloud5.x = 768;
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_mc.boat_mc.play();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.to(_mc, 1, {alpha:0});
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}