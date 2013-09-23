package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
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
	import view.StarryNight;
	
	public class BoatIntroView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;		
		private var _stars:StarryNight;
		private var _boat:MovieClip;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _range:Number = 2;
		private var _speed:Number = .025;
		private var _bgSound:Track;
		
		public function BoatIntroView()
		{
			_SAL = new SWFAssetLoader("prologue.BoatIntroMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_boat = null;
			_stars.destroy();
			_stars = null;
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
		
		public function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_boat = _mc.boat_mc;
			_nextY = 140;
			
//			_boat.stop();
			
			_boat.mask_mc.cacheAsBitmap = true;
			_boat.waves_mc.cacheAsBitmap = true;
			_boat.waves_mc.mask = _boat.mask_mc;
			
			_stars = new StarryNight(680,350,.5,1,800);
			_stars.x = 50;
			_stars.y = 50;
			var c:ColorTransform = new ColorTransform(); 
			c.color = (0x4124b3);
			_stars.transform.colorTransform = c;
			_mc.addChild(_stars);
			
			// put boat on top of stars
			_mc.addChild(_boat);
			
			_pageInfo = DataModel.appData.getPageInfo("boatIntro");
			_bodyParts = _pageInfo.body;
			
			var introNumber:int;
			if (DataModel.captainBattled && DataModel.defenderInfo.weapon == 0 || DataModel.captainBattled && DataModel.defenderInfo.weapon == 2) {
				introNumber = 0;
				_boat.y = 344;
			} else {
				introNumber = 1;
				_boat.y = 17;
			}
			
			_mc.bg_mc.gotoAndStop(introNumber+1);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[captainBattled]", _pageInfo.captainBattled[introNumber]);
					
					if (introNumber == 0) {
						copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[DataModel.defenderInfo.weapon]);
					} else {
						copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					}
					
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
					
					_tf.y = Math.round(_nextY + part.top);
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
			_decisions = new DecisionsView(_pageInfo.decisions);
			_decisions.y = _nextY;
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
			
			_boat.waves_mc.visible = false;
			
			// load sound
			_bgSound = new Track("assets/audio/prologue/prologue_docks.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
		}
		
		private function pageOn(event:ViewEvent):void {
			_stars.start();
			
			var waveInitX:int = _boat.waves_mc.x;
			var waveInitY:int = _boat.waves_mc.y;
			var waveDownY:int = waveInitY + _boat.waves_mc.height+2;
			_boat.waves_mc.y = waveDownY;
			_boat.waves_mc.visible = true;
			
			boatWaveUp();
			
			function boatWaveUp():void {
				_boat.waves_mc.x = waveInitX -10;
				TweenMax.to(_boat.waves_mc, 1, {y:waveInitY, x:"+10", ease:Quad.easeOut, delay:.5, onComplete:boatWaveDown});
			}
			
			function boatWaveDown(): void {
				TweenMax.to(_boat.waves_mc, 1, {y:waveDownY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:boatWaveUp});
			}
			
			_boat.boat_mc.angle = 0;
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				_stars.pause();
				TweenMax.pauseAll();
				_scrolling = true;
			} else {
				//boat movement
				rotateItem(_boat.boat_mc);
				
				if (!_scrolling) return;
				_stars.resume();
				TweenMax.resumeAll();
				_scrolling = false;
			}
			
		}
		
		private function rotateItem(thisMC:MovieClip):void {
			thisMC.rotation = 0 +  Math.sin(thisMC.angle) * _range;
			thisMC.angle += _speed;
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
	}
}