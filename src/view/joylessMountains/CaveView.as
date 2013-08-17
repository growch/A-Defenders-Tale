package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import assets.SparkleMotionMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class CaveView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _sparkleTimer:Timer;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _sparkle1:SparkleMotionMC;
		private var _sparkle2:SparkleMotionMC;
		private var _sparkle3:SparkleMotionMC;
		
		public function CaveView()
		{
			_SAL = new SWFAssetLoader("joyless.CaveMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
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
			_SAL.destroy();
			_SAL = null;
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_sparkleTimer.stop();
			_sparkleTimer = null;
		}
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("cave");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[wardrobe1]", _pageInfo.wardrobe1[DataModel.defenderInfo.wardrobe]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					
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
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
//			_decisions.y = _nextY;
			//hack cuz decision had to be over stalagmite
			_decisions.y = _mc.stalagmite_mc.y - 60;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			//			var frameSize:int = _decisions.y + 210;
			//EXCEPTION
			_mc.bg_mc.height = _mc.stalagmite_mc.y + _mc.stalagmite_mc.height;
			var frameSize:int = _mc.bg_mc.height + 20;
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
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			//sort of hacky, so as to not have to remove stop frames from og animation
			_sparkle1 = new SparkleMotionMC();
			_sparkle1.x = _mc.treasure_mc.sparkle1_mc.x;
			_sparkle1.y = _mc.treasure_mc.sparkle1_mc.y;
			_mc.treasure_mc.removeChild(_mc.treasure_mc.sparkle1_mc);
			_mc.treasure_mc.addChild(_sparkle1);
			
			_sparkle2 = new SparkleMotionMC();
			_sparkle2.x = _mc.treasure_mc.sparkle2_mc.x;
			_sparkle2.y = _mc.treasure_mc.sparkle2_mc.y;
			_mc.treasure_mc.removeChild(_mc.treasure_mc.sparkle2_mc);
			_mc.treasure_mc.addChild(_sparkle2);
			
			_sparkle3 = new SparkleMotionMC();
			_sparkle3.x = _mc.treasure_mc.sparkle3_mc.x;
			_sparkle3.y = _mc.treasure_mc.sparkle3_mc.y;
			_mc.treasure_mc.removeChild(_mc.treasure_mc.sparkle3_mc);
			_mc.treasure_mc.addChild(_sparkle3);
			
			_sparkleTimer = new Timer(5000);
			_sparkleTimer.addEventListener(TimerEvent.TIMER, sparkleMotion);
			_sparkleTimer.start();
		}
		
		private function sparkleMotion(e:TimerEvent) : void {
			playSparkle(_sparkle1);
			TweenMax.delayedCall(.3, playSparkle, [_sparkle2]);
			TweenMax.delayedCall(.5, playSparkle, [_sparkle3]);
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
			_sparkleTimer.stop();
			//for delayed calls
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}