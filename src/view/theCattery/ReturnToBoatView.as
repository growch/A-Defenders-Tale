package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
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
	
	public class ReturnToBoatView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _boat:MovieClip;
		private var _scrolling:Boolean;
		private var _frame:FrameView;
		private var _stars:StarryNight;
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _cloud4:MovieClip;
		private var _cloud5:MovieClip;		
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _bgSound:Track;
		
		public function ReturnToBoatView()
		{
			_SAL = new SWFAssetLoader("theCattery.ReturnToBoatMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_stars.destroy();
			_stars = null;
			_boat = null;
			_cloud1 = null;
			_cloud2 = null;
			_cloud3 = null;
			_cloud4 = null;
			_cloud5 = null;
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
			
			_nextY = 110;
			
			_mc.boat_mc.boatMask_mc.cacheAsBitmap = true;
			_mc.boat_mc.boat_mc.cacheAsBitmap = true;
			_mc.boat_mc.boat_mc.mask = _mc.boat_mc.boatMask_mc;
			_mc.boat_mc.boatMask_mc.alpha = 1;
			
			_cloud1 = _mc.clouds_mc.cloud1_mc;
			_cloud2 = _mc.clouds_mc.cloud2_mc;
			_cloud3 = _mc.clouds_mc.cloud3_mc;
			_cloud4 = _mc.clouds_mc.cloud4_mc;
			_cloud5 = _mc.clouds_mc.cloud5_mc;
			
			_stars = new StarryNight(680, 1200, .2, .8, 200);
			_stars.x = 50;
			_stars.y = 100;
			_mc.addChild(_stars);
			
			//tint
			var c:ColorTransform = new ColorTransform(); 
			c.color = 0xbfb3fc;
			c.alphaMultiplier = .9;
			_stars.transform.colorTransform = c;
			
			_pageInfo = DataModel.appData.getPageInfo("returnToBoat");
			_bodyParts = _pageInfo.body;
			
			_boat = _mc.boat_mc;
			
			var stoneIndex: int = DataModel.getInstance().STONE_COUNT;
			
			var pearlObtInt:int = DataModel.STONE_PEARL ? 0 : 1;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_boat.boat_mc);
			DataModel.getInstance().setGraphicResolution(_cloud1);
			DataModel.getInstance().setGraphicResolution(_cloud2);
			DataModel.getInstance().setGraphicResolution(_cloud3);
			DataModel.getInstance().setGraphicResolution(_cloud4);
			DataModel.getInstance().setGraphicResolution(_cloud5);
			
			var compInt:int = DataModel.defenderInfo.companion;
			var compArticle:String;
			
			if (compInt == 0) {
				compArticle = "an";
			} else {
				compArticle = "a";
			}
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companionArticle]", compArticle);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[pearlObtained]", _pageInfo.pearlObtained[pearlObtInt]);
					copy = StringUtil.replace(copy, "[stones1]", _pageInfo.stones1[stoneIndex]);
					
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
					
					if (part.id == "final") {
						_nextY += _mc.boat_mc.height;
					}
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,666,true); 
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
			
			_bgSound = new Track("assets/audio/prologue/prologue_docks.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;	
			_bgSound.fadeAtEnd = true;	
		}
		
		private function pageOn(e:ViewEvent):void {
			_stars.start();
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_stars.pause();
				_boat.stop();
				_scrolling = true;
			} else {
				
				_cloud1.x -= .2;
				if (_cloud1.x < -_cloud1.width) _cloud1.x = 768;
				
				_cloud2.x -= .3;
				if (_cloud2.x < -_cloud2.width) _cloud2.x = 768;
				
				_cloud3.x -= .15;
				if (_cloud3.x < -_cloud3.width) _cloud3.x = 768;
				
				_cloud4.x -= .35;
				if (_cloud4.x < -_cloud4.width) _cloud4.x = 768;
				
				_cloud5.x -= .1;
				if (_cloud5.x < -_cloud5.width) _cloud5.x = 768;
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_stars.resume();
				_boat.play();
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