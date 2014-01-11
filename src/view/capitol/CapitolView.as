package view.capitol
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
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
	
	public class CapitolView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _vortex:MovieClip;
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _wave1:MovieClip;
		private var _wave2:MovieClip;
		private var _wave3:MovieClip;
		private var _wave4:MovieClip;
		private var _wave5:MovieClip;
		private var _wave6:MovieClip;
		private var _bgSound:Track;
		
		public function CapitolView()
		{
			_SAL = new SWFAssetLoader("capitol.CapitolMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_vortex = null;
			_cloud1 = null;
			_cloud2 = null;
			_cloud3 = null;
			_wave1 = null;
			_wave2 = null;
			_wave3 = null;
			_wave4 = null;
			_wave5 = null;
			_wave6 = null;
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
			
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
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
			
			_nextY = 140;
			
			DataModel.getInstance().setGraphicResolution(_mc.vortex_mc);
			_vortex = _mc.vortex_mc.vortex_mc;
			_vortex.stop();
			
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
			_wave6 = _mc.waves_mc.wave6_mc;
			_wave1.visible = _wave2.visible = _wave3.visible = false;
			_wave4.visible = _wave5.visible = _wave6.visible = false;
			
			_pageInfo = DataModel.appData.getPageInfo("capitol");
			_bodyParts = _pageInfo.body;
			
			var compInt:int = DataModel.defenderInfo.companion;
			
			var introInt:int = 0;
			if (DataModel.STONE_PEARL && DataModel.STONE_CAT) {
				introInt = 1;
			}
			var stoneCount:int = DataModel.STONE_COUNT == 4 ? 0 : 1;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.island_mc);
			DataModel.getInstance().setGraphicResolution(_cloud1);
			DataModel.getInstance().setGraphicResolution(_cloud2);
			DataModel.getInstance().setGraphicResolution(_cloud3);
			DataModel.getInstance().setGraphicResolution(_wave1);
			DataModel.getInstance().setGraphicResolution(_wave2);
			DataModel.getInstance().setGraphicResolution(_wave3);
			DataModel.getInstance().setGraphicResolution(_wave4);
			DataModel.getInstance().setGraphicResolution(_wave5);
			DataModel.getInstance().setGraphicResolution(_wave6);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[intro1]", _pageInfo.intro1[introInt]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[compInt][stoneCount]);
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[DataModel.defenderInfo.weapon]);
					
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
					
//					if (part.id == "companion") {
//						_mc.companions_mc.y = _nextY;
//					}
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			if (DataModel.STONE_COUNT == 4) {
				dv.push(_pageInfo.decisions[2]);
			} else {
				dv.push(_pageInfo.decisions[0]);
				dv.push(_pageInfo.decisions[1]);
			}		
			_decisions = new DecisionsView(dv,0xFFFFFF,true); 
//			_decisions.y = _nextY;
//			EXCEPTION FIXED BG SIZE
			_decisions.y = _mc.bg_mc.height - 210;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
//			var frameSize:int = _decisions.y + 210;
//			EXCEPTION FIXED BG SIZE
			var frameSize:int = _mc.bg_mc.height;
			//size bg
//			_mc.bg_mc.height = frameSize;
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
			
			DataModel.getInstance().oceanLoop();
			
			_bgSound = new Track("assets/audio/global/Ocean.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
		}
		
		
		private function pageOn(e:ViewEvent):void {
			
			if (!DataModel.ipad1) _vortex.play();
			
			initWave(_wave1);
			initWave(_wave2);
			initWave(_wave3);
			initWave(_wave4);
			initWave(_wave5);
			initWave(_wave6);
			
			TweenMax.delayedCall(1, waveUp, [_wave1]);
			TweenMax.delayedCall(2, waveUp, [_wave2]);
			TweenMax.delayedCall(3, waveUp, [_wave3]);
			TweenMax.delayedCall(4, waveUp, [_wave4]);
			TweenMax.delayedCall(5, waveUp, [_wave5]);
			TweenMax.delayedCall(6, waveUp, [_wave6]);
			
//			!!!!LESSON
//			using setTimeout above and selecting next page quickly, caused swf to not unload
			
			
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
				_scrolling = true;
				_vortex.stop();
			} else {
				
				_cloud1.x -= .3;
				if (_cloud1.x < -_cloud1.width) _cloud1.x = 768;
				_cloud2.x -= .2;
				if (_cloud2.x < -_cloud2.width) _cloud2.x = 768;
				_cloud3.x -= .15;
				if (_cloud3.x < -_cloud3.width) _cloud3.x = 768;
				
				if (!_scrolling) return;
				_vortex.play();
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_dragVCont.stopTween();
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}