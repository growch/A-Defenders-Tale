package view.shipwreck
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
	
	public class ShipwreckCoveView extends MovieClip implements IPageView
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
		private var _wreckShip:MovieClip;
		private var _wreckMast:MovieClip;
		private var _range:Number = 5;
		private var _speed:Number = .1;
		private var _counter:int;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _bird1:MovieClip;
		private var _bird2:MovieClip;
		private var _bird3:MovieClip;
		private var _bird4:MovieClip;
		private var _bird5:MovieClip;
		private var _bird6:MovieClip;
		private var _bgSound:Track;
		
		public function ShipwreckCoveView()
		{
			_SAL = new SWFAssetLoader("shipwreck.ShipwreckCoveMC", this);
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
			
			_wreckShip = null;
			_wreckMast = null;
			
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
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			_mc.mask_mc.cacheAsBitmap = true;
			_mc.waves_mc.cacheAsBitmap = true;
			_mc.waves_mc.mask = _mc.mask_mc;
			_mc.mask_mc.alpha = 1;
			
			
			_mc.wreckMask_mc.cacheAsBitmap = true;
			_mc.wreckage_mc.cacheAsBitmap = true;
			_mc.wreckage_mc.mask = _mc.wreckMask_mc;
			_mc.wreckMask_mc.alpha = 1;
			
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
			
			_bird1 = _mc.bird1_mc;
			_bird2 = _mc.bird2_mc;
			_bird3 = _mc.bird3_mc;
			_bird4 = _mc.bird4_mc;
			_bird5 = _mc.bird5_mc;
			_bird6 = _mc.bird6_mc;
			
			birdsOff();
			
			_wreckShip = _mc.wreckage_mc.ship_mc;
			_wreckMast = _mc.wreckage_mc.mast_mc;
			
			_pageInfo = DataModel.appData.getPageInfo("shipwreckCove");
			_bodyParts = _pageInfo.body;
			
			var introInt:int = 0;
			var lastIsland:String = DataModel.ISLAND_SELECTED[DataModel.ISLAND_SELECTED.length-1];
			if (lastIsland == "Joyless Mountains") {
				introInt = 1;
			}
			if (lastIsland != "Joyless Mountains" && lastIsland != "The Cattery") {
				introInt = 2;
			}
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[intro1]", _pageInfo.intro1[introInt]);
					
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
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY;
			//EXCEPTION CUZ FIXED BG SIZE
//			_decisions.y = _mc.bg_mc.height - 210;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			//			var frameSize:int = _decisions.y + 210;
			//EXCEPTION CUZ FIXED BG SIZE
			var frameSize:int = _mc.bg_mc.height;
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
			
			// load sound
			_bgSound = new Track("assets/audio/shipwreck/shipwreck_01.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
		}
		
		private function pageOn(e:ViewEvent):void {
//			return;
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
			TweenMax.delayedCall(.5, birdOn, [_bird3]);
			TweenMax.delayedCall(.8, birdOn, [_bird4]);
			TweenMax.delayedCall(1.0, birdOn, [_bird5]);
			TweenMax.delayedCall(1.2, birdOn, [_bird6]);
				
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_wreckMast.angle = 0;
			_wreckShip.angle = 0;
			_wreckMast.initY = _wreckMast.y;
			_wreckShip.initY = _wreckShip.y;
		}
		
		private function bobItem(thisMC:MovieClip):void {
			thisMC.y = thisMC.initY +  Math.sin(thisMC.angle) * _range;
			thisMC.angle += _speed;
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
				
				_counter++;
				
				if (_counter%3 == 0) {
					bobItem(_wreckMast);
				}
				
				if (_counter%4 == 0) {
					bobItem(_wreckShip);
				}
				
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				birdsOn();
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