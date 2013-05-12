package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import assets.CaveMC;
	
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
	
	public class CaveView extends MovieClip implements IPageView
	{
		private var _mc:CaveMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _sparkleTimer:Timer;
		
		public function CaveView()
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
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			//for delayed calls
			TweenMax.killAll();
			_sparkleTimer.stop();
			_sparkleTimer = null;
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new CaveMC();
			
			_nextY = 110;
			
			_bodyParts = DataModel.appData.cave.body; 
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", DataModel.appData.cave.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[wardrobe1]", DataModel.appData.cave.wardrobe1[DataModel.defenderInfo.wardrobe]);
					copy = StringUtil.replace(copy, "[companion2]", DataModel.appData.cave.companion2[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					if(part.id == "treasure") {
						_mc.treasure_mc.y = _tf.y + 20;
					}
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "final") {
						_mc.stalagmite_mc.y = _nextY +120;
						_nextY += _mc.stalagmite_mc.height;
					}
					
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += DataModel.appData.cave.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.cave.decisions,0xFFFFFF,true); //tint it white, showBG
//			_decisions.y = _nextY;
			//hack cuz decision had to be over stalagmite
			_decisions.y = _mc.stalagmite_mc.y - 60;
			_mc.addChild(_decisions);
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_frame = new FrameView(_mc.frame_mc); 
			
//			var frameSize:int = _decisions.y + 210;
			//EXCEPTION
			_mc.bg_mc.height = _mc.stalagmite_mc.y + _mc.stalagmite_mc.height;
			var frameSize:int = _mc.bg_mc.height + 20;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(e:ViewEvent):void {
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_sparkleTimer = new Timer(5000);
			_sparkleTimer.addEventListener(TimerEvent.TIMER, sparkleMotion);
			_sparkleTimer.start();
		}
		
		private function sparkleMotion(e:TimerEvent) : void {
			playSparkle(_mc.treasure_mc.sparkle1_mc);
			TweenMax.delayedCall(.3, playSparkle, [_mc.treasure_mc.sparkle2_mc]);
			TweenMax.delayedCall(.5, playSparkle, [_mc.treasure_mc.sparkle3_mc]);
		}
		
		private function playSparkle(thisMC:MovieClip):void {
			thisMC.play();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
				_sparkleTimer.stop();
				
			} else {
				
				if (!_scrolling) return;
				
				_sparkleTimer.start();
				
				TweenMax.resumeAll();
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