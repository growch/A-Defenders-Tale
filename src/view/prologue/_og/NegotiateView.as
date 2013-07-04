package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import assets.NegotiateMC;
	
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
	
	public class NegotiateView extends MovieClip implements IPageView
	{
		private var _mc:NegotiateMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _almsGiven:int = 0;;
		private var _frame:FrameView;
		private var _noteTimer:Timer;
		private var _singleStart:Array;
		private var _doubleStart:Array;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		
		public function NegotiateView()
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
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_dragVCont.removeChild(_mc);
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			_noteTimer.stop();
			_noteTimer = null;
			
			removeEventListener(Event.ENTER_FRAME, frameLoop);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			if (DataModel.coinCount < 1) {
				_almsGiven = 1;
			}
			
			_mc = new NegotiateMC();
			_mc.instrument_mc.gotoAndStop(int(DataModel.defenderInfo.instrument)+1);
			_mc.instrument_mc.glows_mc.gotoAndStop(int(DataModel.defenderInfo.instrument)+1);
			_mc.instrument_mc.glows_mc.visible = false;
			_mc.instrument_mc.shine_mc.visible = false;
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("negotiate");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[coins]", _pageInfo.coins[_almsGiven]);
					copy = StringUtil.replace(copy, "[instrument1]", _pageInfo.instrument1[DataModel.defenderInfo.instrument]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
				} else if (part.type == "image") {
					
					if (part.id == "coinImage") {
						_mc.coin_mc.y = Math.round(_nextY+part.top)+15;
					}
					
					if (part.id == "instrumentImage") {
						_mc.instrument_mc.y = Math.round(_nextY+part.top)-130;
					}
					
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
					
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions);
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
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
			
			_mc.instrument_mc.noteSingle_mc.alpha = 0;
			_singleStart = [_mc.instrument_mc.noteSingle_mc.x, _mc.instrument_mc.noteSingle_mc.y];
			_mc.instrument_mc.noteDouble_mc.alpha = 0;
			_doubleStart = [_mc.instrument_mc.noteDouble_mc.x, _mc.instrument_mc.noteDouble_mc.y];
			
			_mc.instrument_mc.glows_mc.cacheAsBitmap = true;
			_mc.instrument_mc.shine_mc.cacheAsBitmap = true;
			_mc.instrument_mc.glows_mc.mask = _mc.instrument_mc.shine_mc;
			_mc.instrument_mc.glows_mc.visible = true;
			_mc.instrument_mc.shine_mc.visible = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			
			_noteTimer = new Timer(3000);
			_noteTimer.addEventListener(TimerEvent.TIMER, showNotes);
			_noteTimer.start();
			
			setTimeout(function():void{_mc.coin_mc.gotoAndStop(5);}, 3000);
			
			addEventListener(Event.ENTER_FRAME, frameLoop);
		}
		
		protected function frameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
				_noteTimer.stop();
			} else {
				if (!_scrolling) return;
				
				_noteTimer.start();
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function showNotes(event:TimerEvent):void
		{
			TweenMax.to(_mc.instrument_mc.shine_mc, 1.4, {y:520, ease:Quad.easeIn, onComplete:function():void {_mc.instrument_mc.shine_mc.y = -400}}); 
			TweenMax.to(_mc.instrument_mc.noteSingle_mc, .4, {alpha:1});
			TweenMax.to(_mc.instrument_mc.noteSingle_mc, 2, {bezierThrough:[{x:-12, y:70}, {x:20, y:-10}, {x:-2, y:-40}],
															onComplete:function():void {
																_mc.instrument_mc.noteSingle_mc.x = _singleStart[0];
																_mc.instrument_mc.noteSingle_mc.y = _singleStart[1];
															}}); 
			TweenMax.to(_mc.instrument_mc.noteSingle_mc, .4, {alpha:0, delay:1});
			
			TweenMax.to(_mc.instrument_mc.noteDouble_mc, .4, {alpha:1, delay:.4});
			TweenMax.to(_mc.instrument_mc.noteDouble_mc, 2, {bezierThrough:[{x:50, y:72}, {x:100, y:32}, {x:40, y:-30}], delay:.4,
				onComplete:function():void {
					_mc.instrument_mc.noteDouble_mc.x = _doubleStart[0];
					_mc.instrument_mc.noteDouble_mc.y = _doubleStart[1];
				}}); 
			TweenMax.to(_mc.instrument_mc.noteDouble_mc, .4, {alpha:0, delay:1.8});
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
//			TweenMax.to(_mc, 1, {alpha:0});
//			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			_noteTimer.stop();
			TweenMax.killAll();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}