package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DecisionInfo;
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
	
	public class IntroAllIslandsView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _boat:MovieClip;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _wave1:MovieClip;
		private var _wave2:MovieClip;
		private var _wave3:MovieClip;
		private var _wave4:MovieClip;
		private var _wave5:MovieClip;
		
		public function IntroAllIslandsView()
		{
			_SAL = new SWFAssetLoader("prologue.IntroAllIslandsMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
		}
		
		public function destroy() : void {
//			
			_cloud1 = null;
			_cloud2 = null;
			_cloud3 = null;
			_wave1 = null;
			_wave2 = null;
			_wave3 = null;
			_wave4 = null;
			_wave5 = null;
			_boat = null;
//			
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
		
		protected function mcAdded(event:Event):void
		{
			_mc.removeEventListener(Event.ADDED_TO_STAGE, mcAdded);
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.MC_READY));
		}
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.addEventListener(Event.ADDED_TO_STAGE, mcAdded);
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			_boat = _mc.boat_mc;
			_boat.waves_mc.visible = false;
			
			_boat.boatMask_mc.cacheAsBitmap = true;
			_boat.boat_mc.cacheAsBitmap = true;
			_boat.boat_mc.mask = _boat.boatMask_mc;
			_boat.boatMask_mc.alpha = 1;
			
			_boat.mask_mc.cacheAsBitmap = true;
			_boat.waves_mc.cacheAsBitmap = true;
			_boat.waves_mc.mask = _boat.mask_mc;
			
			_mc.mask_mc.cacheAsBitmap = true;
			_mc.waves_mc.cacheAsBitmap = true;
			_mc.waves_mc.mask = _mc.mask_mc;
			_mc.mask_mc.alpha = 1;
			
			_cloud1 = _mc.cloud1_mc;
			_cloud2 = _mc.cloud2_mc;
			_cloud3 = _mc.cloud3_mc;
			
			_wave1 = _mc.waves_mc.wave1_mc;
			_wave2 = _mc.waves_mc.wave2_mc;
			_wave3 = _mc.waves_mc.wave3_mc;
			_wave4 = _mc.waves_mc.wave4_mc;
			_wave5 = _mc.waves_mc.wave5_mc;
			_wave1.visible = _wave2.visible = _wave3.visible = _wave4.visible = _wave5.visible = false;
			
			_pageInfo = DataModel.appData.getPageInfo("introAllIslands");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[Island1]", DataModel.ISLAND_SELECTED[0]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion3]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[islands1]", _pageInfo.islands1[DataModel.CURRENT_ISLAND_INT]);
					copy = StringUtil.replace(copy, "[islands2]", _pageInfo.islands2[DataModel.CURRENT_ISLAND_INT]);
					copy = StringUtil.replace(copy, "[island1]", DataModel.ISLAND_SELECTED[0]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			dv.push(_pageInfo.decisions[DataModel.CURRENT_ISLAND_INT]);
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(dv,0xFFFFFF,true); //tint it white, showBG
//			_decisions.y = _nextY;
			_decisions.y = _mc.bg_mc.height-210;
			_mc.addChild(_decisions);
			
			dv = null;
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 210;
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
			
			//bg sound
			DataModel.getInstance().oceanLoop();
		}
		
		private function pageOn(e:ViewEvent):void {
			_boat.waves_mc.visible = true;
			
			var waveInitX:int = _boat.waves_mc.waves1_mc.x;
			var waveInitY:int = _boat.waves_mc.waves1_mc.y;
			var waveDownY:int = waveInitY + _boat.waves_mc.waves1_mc.height+2;
			_boat.waves_mc.waves1_mc.y = waveDownY;
			
			boatWave1Up();
			
			function boatWave1Up():void {
				_boat.waves_mc.waves1_mc.x = waveInitX -10;
				TweenMax.to(_boat.waves_mc.waves1_mc, 1, {y:waveInitY, x:"+10", ease:Quad.easeOut, delay:.5, onComplete:boatWave1Down});
			} 			
			function boatWave1Down(): void {
				TweenMax.to(_boat.waves_mc.waves1_mc, 1, {y:waveDownY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:boatWave1Up});
			}
			
			var wave2InitX:int = _boat.waves_mc.waves2_mc.x;
			var wave2InitY:int = _boat.waves_mc.waves2_mc.y;
			var wave2DownY:int = wave2InitY + _boat.waves_mc.waves2_mc.height+2;
			_boat.waves_mc.waves2_mc.y = wave2DownY;
			
			TweenMax.delayedCall(1.6, boatWave2Up);
			
			function boatWave2Up():void {
				_boat.waves_mc.waves2_mc.x = wave2InitX -10;
				TweenMax.to(_boat.waves_mc.waves2_mc, 1, {y:wave2InitY, x:"+10", ease:Quad.easeOut, delay:.5, onComplete:boatWave2Down});
			} 			
			function boatWave2Down(): void {
				TweenMax.to(_boat.waves_mc.waves2_mc, 1, {y:wave2DownY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:boatWave2Up});
			}
			
			initWave(_wave1);
			initWave(_wave2);
			initWave(_wave3);
			initWave(_wave4);
			initWave(_wave5);
			
			TweenMax.delayedCall(1, waveUp, [_wave1]);
			TweenMax.delayedCall(2, waveUp, [_wave2]);
			TweenMax.delayedCall(3, waveUp, [_wave3]);
			TweenMax.delayedCall(4, waveUp, [_wave4]);
			TweenMax.delayedCall(5, waveUp, [_wave5]);
			
			function initWave(thisWave:MovieClip):void {
				thisWave.initX = thisWave.x;
				thisWave.initY = thisWave.y;
				thisWave.downY = thisWave.initY + thisWave.height + 2;
				thisWave.y = thisWave.downY;
			}
			
			function waveUp(thisWave:MovieClip):void {
				thisWave.visible = true;
				thisWave.x = thisWave.initX -10;
				TweenMax.to(thisWave, 1, {y:thisWave.initY, x:"+10", ease:Quad.easeOut, delay:.7 + DataModel.getInstance().randomRange(.2, .6), onComplete:waveDown, onCompleteParams:[thisWave]});
			} 			
			function waveDown(thisWave:MovieClip): void {
				TweenMax.to(thisWave, 1, {y:thisWave.downY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:waveUp, onCompleteParams:[thisWave]});
			}
			
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_boat.stop();
				_scrolling = true;
			} else {
				
				_cloud1.x -= .3;
				if (_cloud1.x < -_cloud1.width) _cloud1.x = 768;
				_cloud2.x -= .2;
				if (_cloud2.x < -_cloud2.width) _cloud2.x = 768;
				_cloud3.x -= .15;
				if (_cloud3.x < -_cloud3.width) _cloud3.x = 768;
				
				//some weird bug. dunno why!
				if (!_boat.boat_mc.cacheAsBitmap) {
					_boat.boat_mc.cacheAsBitmap = true;
				}
				if (!_boat.waves_mc.cacheAsBitmap) {
					_boat.waves_mc.cacheAsBitmap = true;
				}

				if (!_scrolling) return;
				TweenMax.resumeAll();
				_boat.play();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}