package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
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
	
	public class Escalator1View extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _cloud4:MovieClip;
		private var _cloud5:MovieClip;
		private var _cloud6:MovieClip;
		private var _cloud7:MovieClip;
		private var _cloud8:MovieClip;
		private var _cloud9:MovieClip;
		private var _cloud10:MovieClip;
		private var _cloud11:MovieClip;
		private var _cloud12:MovieClip;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		
		public function Escalator1View()
		{
			_SAL = new SWFAssetLoader("joyless.Escalator1MC", this);
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
		}
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			_cloud1 = _mc.cloud1_mc;
			_cloud2 = _mc.cloud2_mc;
			_cloud3 = _mc.cloud3_mc;
			_cloud4 = _mc.cloud4_mc;
			_cloud5 = _mc.cloud5_mc;
			_cloud6 = _mc.cloud6_mc;
			_cloud7 = _mc.cloud7_mc;
			_cloud8 = _mc.cloud8_mc;
			_cloud9 = _mc.cloud9_mc;
			_cloud10 = _mc.cloud10_mc;
			_cloud11 = _mc.cloud11_mc;
			_cloud12 = _mc.cloud12_mc;
			
			//USED IN ESCALATOR2
			DataModel.escalator1 = true;
			
			var introInt:int = DataModel.climbDone == false ? 0 : 1;
//			trace("introInt: "+introInt);
			
			_pageInfo = DataModel.appData.getPageInfo("escalator1");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[intro1]", _pageInfo.intro1[introInt]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
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
			var frameSize:int = _decisions.y + 210;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			// hack to keep bg from getting cut off with long Def names
			_mc.bg_mc.height = frameSize;
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
		}
		
		private function pageOn(e:ViewEvent):void {
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			//clouds 1-5 big, 6-7 medium, 8-12 small
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
			} else {
				
				moveCloud(_cloud1, .3);
				moveCloud(_cloud2, .32);
				moveCloud(_cloud3, .34);
				moveCloud(_cloud4, .36);
				moveCloud(_cloud5, .38);

				moveCloud(_cloud6, .2);
				moveCloud(_cloud7, .25);

				moveCloud(_cloud8, .1);
				moveCloud(_cloud9, .12);
				moveCloud(_cloud10, .13);
				moveCloud(_cloud11, .14);
				moveCloud(_cloud12, .15);
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		private function moveCloud(thisCloud:MovieClip, thisAmt:Number):void {
			thisCloud.x -= thisAmt;
			if (thisCloud.x < - thisCloud.width) thisCloud.x = 768;
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			//for delayed calls
			TweenMax.killAll();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
	}
}