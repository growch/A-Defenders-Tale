package view.shipwreck
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import assets.Jellyfish1MC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class Jellyfish1View extends MovieClip implements IPageView
	{
		private var _mc:Jellyfish1MC; 
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _jelly1:MovieClip;
		private var _jelly2:MovieClip;
		private var _jelly3:MovieClip;
		private var _jelly4:MovieClip;
		private var _jelly5:MovieClip;
		private var _jelly6:MovieClip;
		private var _jelly7:MovieClip;
		private var _jelly8:MovieClip;
		private var _jellyArray:Array;
		private var _counter:int = 0;
		private var _pageInfo:PageInfo;
		private var _jellyTimer:Timer;
		private var _timerSpeed:int = 800;
		
		public function Jellyfish1View()
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
			
			DataModel.getInstance().removeAllChildren(_mc);
			
			_jellyTimer.stop();
			_jellyTimer = null;
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new Jellyfish1MC(); 
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("jellyfish1");
			_bodyParts = _pageInfo.body;
			
			_jelly1 = _mc.jelly1_mc; 
			_jelly2 = _mc.jelly2_mc; 
			_jelly3 = _mc.jelly3_mc; 
			_jelly4 = _mc.jelly4_mc; 
			_jelly5 = _mc.jelly5_mc; 
			_jelly6 = _mc.jelly6_mc; 
			_jelly7 = _mc.jelly7_mc; 
			_jelly8 = _mc.jelly8_mc; 
			
			
			_jelly1.stop();
			_jelly2.stop();
			_jelly3.stop();
			_jelly4.stop();
			_jelly5.stop();
			_jelly6.stop();
			_jelly7.stop();
			_jelly8.stop(); 
			
			_jellyArray = new Array();
			_jellyArray.push(_jelly1);
			_jellyArray.push(_jelly2);
			_jellyArray.push(_jelly3);
			_jellyArray.push(_jelly4);
			_jellyArray.push(_jelly5);
			_jellyArray.push(_jelly6);
			_jellyArray.push(_jelly7);
			_jellyArray.push(_jelly8);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "end") {
						_mc.end_mc.y = _nextY + 60; 
						_nextY += 100;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY; 
			
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			//CUSTOM!!!
			var frameSize:int = _decisions.y + 400;
			//CUSTOM
			var diff:int = frameSize - _mc.bg_mc.height; 
			_mc.sand_mc.y += diff;  
			
			_mc.bg_mc.height = frameSize;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
		}
		
		private function pageOn(e:ViewEvent):void {
			//TODO MIGHT HAVE TO KILL ANIMATION FOR IPAD1
			if (DataModel.ipad1) _timerSpeed = 3000;
			_jellyTimer = new Timer(_timerSpeed);
			_jellyTimer.addEventListener(TimerEvent.TIMER, animateJelly); 
			_jellyTimer.start();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function animateJelly(e:TimerEvent):void {
			var thisJelly:MovieClip = _jellyArray[_counter] as MovieClip;
			thisJelly.play(); 
			_counter++;
			if (_counter > _jellyArray.length-1) {
				_counter = 0;
			}
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_jellyTimer.stop();
					
				_scrolling = true;
			} else {
				
				if (!_scrolling) return;
				
				_jellyTimer.start();
				
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		
		protected function decisionMade(event:ViewEvent):void
		{
			_jellyTimer.stop();
			TweenMax.killAll();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}