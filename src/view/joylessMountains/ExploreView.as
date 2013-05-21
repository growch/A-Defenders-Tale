package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import assets.ExploreMC;
	
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
	
	public class ExploreView extends MovieClip implements IPageView
	{
		private var _mc:ExploreMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _singleStart:Array;
		private var _doubleStart:Array;
		private var _noteTimer:Timer;
		private var _bellL1:MovieClip;
		private var _bellL2:MovieClip;
		private var _bellL3:MovieClip;
		private var _bellL4:MovieClip;
		private var _bellR1:MovieClip;
		private var _bellR2:MovieClip;
		private var _bellR3:MovieClip;
		private var _bellR4:MovieClip;
		private var _pageInfo:PageInfo;
		
		public function ExploreView()
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
			
			_noteTimer.stop();
			_noteTimer = null;
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new ExploreMC();
			
			_nextY = 110;
			
			_bellL1 = _mc.vines_mc.vineLeft_mc.bell1_mc;
			_bellL2 = _mc.vines_mc.vineLeft_mc.bell2_mc;
			_bellL3 = _mc.vines_mc.vineLeft_mc.bell3_mc;
			_bellL4 = _mc.vines_mc.vineLeft_mc.bell4_mc;
			_bellL1.stop();
			_bellL2.stop();
			_bellL3.stop();
			_bellL4.stop();
			
			_bellR1 = _mc.vines_mc.vineRight_mc.bell1_mc;
			_bellR2 = _mc.vines_mc.vineRight_mc.bell2_mc;
			_bellR3 = _mc.vines_mc.vineRight_mc.bell3_mc;
			_bellR4 = _mc.vines_mc.vineRight_mc.bell4_mc;
			_bellR1.stop();
			_bellR2.stop();
			_bellR3.stop();
			_bellR4.stop();
			
			_mc.instrument_mc.gotoAndStop(int(DataModel.defenderInfo.instrument)+1);
			_mc.instrument_mc.glows_mc.gotoAndStop(int(DataModel.defenderInfo.instrument)+1);
			_mc.instrument_mc.glows_mc.visible = false;
			_mc.instrument_mc.shine_mc.visible = false;
			
			var supplyInt:int;
			if (DataModel.supplies && !DataModel.STONE_CAT) {
				supplyInt = 1;
			}
			//TESTING
//			supplyInt = 1;
			
			_pageInfo = DataModel.appData.getPageInfo("explore");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion3]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[instrument1]", _pageInfo.instrument1[DataModel.defenderInfo.instrument]);
					copy = StringUtil.replace(copy, "[supplies]", _pageInfo.supplies[supplyInt]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "vine") {
						_mc.vines_mc.y = _nextY - 40;
					}
					
					if (part.id == "instrument") {
						_mc.instrument_mc.y = _tf.y - 60;
						if (DataModel.defenderInfo.instrument == 1) {
							if (supplyInt != 1)	_mc.instrument_mc.y = _tf.y - 120;
						} 
						
					}
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			//HACK
			if (supplyInt == 1) _nextY -= 100;
			
			if (DataModel.defenderInfo.instrument == 1 && supplyInt != 1) _nextY -= 100;
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
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
			
			_mc.instrument_mc.noteSingle_mc.alpha = 0;
			_singleStart = [_mc.instrument_mc.noteSingle_mc.x, _mc.instrument_mc.noteSingle_mc.y];
			_mc.instrument_mc.noteDouble_mc.alpha = 0;
			_doubleStart = [_mc.instrument_mc.noteDouble_mc.x, _mc.instrument_mc.noteDouble_mc.y];
			
			_mc.instrument_mc.glows_mc.cacheAsBitmap = true;
			_mc.instrument_mc.shine_mc.cacheAsBitmap = true;
			_mc.instrument_mc.glows_mc.mask = _mc.instrument_mc.shine_mc;
			_mc.instrument_mc.glows_mc.visible = true;
			_mc.instrument_mc.shine_mc.visible = true;
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(e:ViewEvent):void {
			_noteTimer = new Timer(3000);
			_noteTimer.addEventListener(TimerEvent.TIMER, showNotes); 
			_noteTimer.start();
			
			_bellL1.play();
			_bellL2.play();
			_bellL3.play();
			_bellL4.play();
			
			_bellR1.play();
			_bellR2.play();
			_bellR3.play();
			_bellR4.play();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
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
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_noteTimer.stop();
				
				_bellL1.stop();
				_bellL2.stop();
				_bellL3.stop();
				_bellL4.stop();
				
				_bellR1.stop();
				_bellR2.stop();
				_bellR3.stop();
				_bellR4.stop();
				
				_scrolling = true;
				
			} else {
				
				if (!_scrolling) return;
				_noteTimer.start();
				TweenMax.resumeAll();
				
				_bellL1.play();
				_bellL2.play();
				_bellL3.play();
				_bellL4.play();
				
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