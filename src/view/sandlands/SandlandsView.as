package view.sandlands
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
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
	
	public class SandlandsView extends MovieClip implements IPageView
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
		private var _wave1:MovieClip;
		private var _wave2:MovieClip;
		private var _wave3:MovieClip;
		private var _wave4:MovieClip;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _bird1:MovieClip;
		private var _bird2:MovieClip;
		private var _bird3:MovieClip;
		private var _bird4:MovieClip;
		private var _bird5:MovieClip;
		private var _bird6:MovieClip;
		private var _bgSound:Track;
		
		public function SandlandsView()
		{
			_SAL = new SWFAssetLoader("sandlands.SandlandsMC", this);
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
			
			_bird1 = null;
			_bird2 = null;
			_bird3 = null;
			_bird4 = null;
			_bird5 = null;
			_bird6 = null;
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
			
			_mc.mask_mc.cacheAsBitmap = true;
			_mc.waves_mc.cacheAsBitmap = true;
			_mc.waves_mc.mask = _mc.mask_mc;
			_mc.mask_mc.alpha = 1;
			
			_nextY = 110;
			
			_cloud1 = _mc.cloud1_mc;
			_cloud2 = _mc.cloud2_mc;
			_cloud3 = _mc.cloud3_mc;
			
			_wave1 = _mc.waves_mc.wave1_mc;
			_wave2 = _mc.waves_mc.wave2_mc;
			_wave3 = _mc.waves_mc.wave3_mc;
			_wave4 = _mc.waves_mc.wave4_mc;
			_wave1.visible = false;
			_wave2.visible = false;
			_wave3.visible = false;
			_wave4.visible = false;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bird1_mc);
			DataModel.getInstance().setGraphicResolution(_mc.bird2_mc);
			DataModel.getInstance().setGraphicResolution(_mc.bird3_mc);
			DataModel.getInstance().setGraphicResolution(_mc.bird4_mc);
			DataModel.getInstance().setGraphicResolution(_mc.bird5_mc);
			DataModel.getInstance().setGraphicResolution(_mc.bird6_mc);
			
			_bird1 = _mc.bird1_mc.bird_mc;
			_bird2 = _mc.bird2_mc.bird_mc;
			_bird3 = _mc.bird3_mc.bird_mc;
			_bird4 = _mc.bird4_mc.bird_mc;
			_bird5 = _mc.bird5_mc.bird_mc;
			_bird6 = _mc.bird6_mc.bird_mc;
			
			birdsOff();
			
			_pageInfo = DataModel.appData.getPageInfo("sandlands");
			_bodyParts = _pageInfo.body;
			
			var introInt:int = 0;
			var lastIsland:String = DataModel.ISLAND_SELECTED[DataModel.ISLAND_SELECTED.length-1];
			if (lastIsland == "The Joyless Mountains") {
				introInt = 1;
			}
			if (lastIsland == "The Cattery") {
				introInt = 3;
			}
			if (lastIsland != "Joyless Mountains" && lastIsland != "The Cattery" && DataModel.getInstance().STONE_COUNT >= 1) {
				introInt = 2;
			}
			
			var stoneInt:int = DataModel.getInstance().STONE_COUNT > 1 ? 1:0;
			var stoneNumberArray:Array = ['one', 'two', 'three', 'four'];
			
			//LOW RES GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_cloud1);
			DataModel.getInstance().setGraphicResolution(_cloud2);
			DataModel.getInstance().setGraphicResolution(_cloud3);
			DataModel.getInstance().setGraphicResolution(_wave1);
			DataModel.getInstance().setGraphicResolution(_wave2);
			DataModel.getInstance().setGraphicResolution(_wave3);
			DataModel.getInstance().setGraphicResolution(_wave4);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[intro1]", _pageInfo.intro1[introInt]);
					copy = StringUtil.replace(copy, "[stone1]", _pageInfo.stones1[stoneInt]);
					copy = StringUtil.replace(copy, "[stoneCount]", stoneNumberArray[DataModel.getInstance().STONE_COUNT-1]);

					
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
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop;
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
//			_decisions.y = _nextY;
			//EXCEPTION CUZ FIXED BG SIZE
			_decisions.y = _mc.bg_mc.height - 210;
			_mc.addChild(_decisions);
			
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
			
			_bgSound = new Track("assets/audio/sandlands/sandlands_SL_01.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
		}
		
		private function pageOn(e:ViewEvent):void {
			_wave1.initX = _wave1.x;
			_wave1.initY = _wave1.y;
			_wave1.downY = _wave1.initY + _wave1.height + 2;
			_wave1.y = _wave1.downY;
			
			_wave2.initX = _wave2.x;
			_wave2.initY = _wave2.y;
			_wave2.downY = _wave2.initY + _wave2.height + 2;
			_wave2.y = _wave2.downY;
			
			_wave3.initX = _wave3.x;
			_wave3.initY = _wave3.y;
			_wave3.downY = _wave3.initY + _wave3.height + 2;
			_wave3.y = _wave3.downY;
			
			_wave4.initX = _wave4.x;
			_wave4.initY = _wave4.y;
			_wave4.downY = _wave4.initY + _wave4.height + 2;
			_wave4.y = _wave4.downY;
			
			function waveUp(thisWave:MovieClip):void {
				thisWave.visible = true;
				thisWave.x = thisWave.initX -10;
				TweenMax.to(thisWave, 1, {y:thisWave.initY, x:"+10", ease:Quad.easeOut, delay:.7 + DataModel.getInstance().randomRange(.2, .6), onComplete:waveDown, onCompleteParams:[thisWave]});
			} 			
			function waveDown(thisWave:MovieClip): void {
				TweenMax.to(thisWave, 1, {y:thisWave.downY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:waveUp, onCompleteParams:[thisWave]});
			}
			
			TweenMax.delayedCall(1, waveUp, [_wave1]);
			TweenMax.delayedCall(1.5, waveUp, [_wave2]);
			TweenMax.delayedCall(2, waveUp, [_wave3]);
			TweenMax.delayedCall(2.5, waveUp, [_wave4]);
			
			TweenMax.delayedCall(.2, birdOn, [_bird1]);
			TweenMax.delayedCall(.4, birdOn, [_bird2]);
			TweenMax.delayedCall(.6, birdOn, [_bird3]);
			TweenMax.delayedCall(.8, birdOn, [_bird4]);
			TweenMax.delayedCall(1, birdOn, [_bird5]);
			TweenMax.delayedCall(1.2, birdOn, [_bird6]);
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function birdOn(thisBird:MovieClip):void {
			thisBird.play();
		}
		
		private function birdsOn():void {
			_bird1.play();
			_bird2.play();
			_bird3.play();
			_bird4.play();
			_bird5.play();
			_bird6.play();
		}
		private function birdsOff():void {
			_bird1.stop();
			_bird2.stop();
			_bird3.stop();
			_bird4.stop();
			_bird5.stop();
			_bird6.stop();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				birdsOff();
				_scrolling = true;
			} else {
				
				_cloud1.x -= .3;
				if (_cloud1.x < -_cloud1.width) _cloud1.x = 768;
				_cloud2.x -= .2;
				if (_cloud2.x < -_cloud2.width) _cloud2.x = 768;
				_cloud3.x -= .15;
				if (_cloud3.x < -_cloud3.width) _cloud3.x = 768;
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				birdsOn();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			if (!DataModel.unlocked && event.data.id != "TitleScreenView" && !event.data.contentsPanelClick) {
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_UNLOCK));
				return;
			}
			
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