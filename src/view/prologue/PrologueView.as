package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	import assets.FirefliesLampMC;
	import assets.FirefliesTextMC;
	
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
	
	public class PrologueView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text; 
		private var _decisions:DecisionsView;		
		private var _lantern:MovieClip;
		private var _stars:StarryNight;
		private var _monthArray:Array = ["January","February","March","April","May","June","July","August","September","October","November","Decemeber"];
		private var _dateSuffixArray:Array = ["","st","nd","rd","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th","th",
											"st","nd","rd","th","th","th","th","th","th","th","st"];
		private var _frame:FrameView;
		private var _scrolling:Boolean;
//		private var _bmpD:BitmapData;
//		private var _bmp:Bitmap;
		private var _bgSound:Track;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _firefliesText:MovieClip;
		private var _firefliesLamp:MovieClip;
		
		public function PrologueView()
		{
			_SAL = new SWFAssetLoader("prologue.PrologueMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
			
		}
		
		public function destroy():void
		{
			
			TweenMax.killAll();
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			_mc.stopAllMovieClips();
			
			_bgSound = null;
			
			_stars.destroy();
			_mc.removeChild(_stars);
			_stars = null;
			
			_lantern = null;
			_firefliesText = null;
			_firefliesLamp = null;
			
			_monthArray = null;
			_dateSuffixArray = null;
//			
			_pageInfo = null;
			_bodyParts = null;
			
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
			
			// mc assets
			_lantern = _mc.lantern_mc;
			
			_stars = new StarryNight(680, 450, .3, .8);
			_stars.x = 50;
			_stars.y = 100;
			_mc.addChild(_stars);
			
			//tint
			var c:ColorTransform = new ColorTransform(); 
			c.color = 0x95b7ff;
//			c.alphaMultiplier = .9;
			_stars.transform.colorTransform = c;
			
			// starting Y MAYBE PUT IN DM????
			_nextY = 65;
			
			_pageInfo = DataModel.appData.getPageInfo("prologue");
			_bodyParts = _pageInfo.body;
			
			var appDate:Date = DataModel.defenderInfo.applicationDate;
			var threeMonthsAgo:Date = new Date();
			threeMonthsAgo.setTime(appDate.time - ( 90 * 24 * 60 * 60 * 1000 ));
//			trace("threeMonthsAgo: "+threeMonthsAgo); 
			
			_firefliesText = new FirefliesTextMC();
			_firefliesText.x = _mc.firefliesText_mc.x;
			_mc.removeChild(_mc.firefliesText_mc);
			_mc.addChild(_firefliesText);
			
			_firefliesLamp = new FirefliesLampMC();
			_firefliesLamp.x = _mc.firefliesLamp_mc.x;
			_mc.removeChild(_mc.firefliesLamp_mc);
			_mc.addChild(_firefliesLamp);
			
			for each (var part:StoryPart in _bodyParts) 
			{
				
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[wardrobe1]", _pageInfo.wardrobe1[DataModel.defenderInfo.gender][DataModel.defenderInfo.wardrobe]);
					copy = StringUtil.replace(copy, "[wardrobe2]", _pageInfo.wardrobe2[DataModel.defenderInfo.wardrobe]);
					copy = StringUtil.replace(copy, "[instrument1]", _pageInfo.instrument1[DataModel.defenderInfo.instrument]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[date]", _monthArray[threeMonthsAgo.month] + " " + threeMonthsAgo.date + _dateSuffixArray[threeMonthsAgo.date]);
					
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
					
//					_tf.cacheAsBitmap = true;
//					_tf.cacheAsBitmapMatrix = new Matrix();
					
					if (part.id == "lantern") {
						_mc.lantern_mc.y = _tf.y - 100;
						_firefliesLamp.y = _mc.lantern_mc.y + 237;
					}

					_mc.addChild(_tf);
					
					_nextY += Math.round(_tf.height + part.top);
					
				} else if (part.type == "image") {
				
					if (part.id == "fireflyText") {
						_firefliesText.y = Math.round(_nextY+part.top + 30);
					}
					
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop;
			_decisions = new DecisionsView(_pageInfo.decisions);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc);
			
			var frameSize:int = _decisions.y + 210;
//			EXCEPTION FOR SCREENSHOT - PREVENTS WHITE FROM SHOWING UP
// 			size black BG
			_mc.black_mc.height = frameSize;
			_frame.sizeFrame(frameSize);

			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			// load sound
			_bgSound = new Track("assets/audio/prologue/prologue_outside.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		private function pageOn(event:ViewEvent):void {
			_stars.start();
			fadeUpLantern();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			if (!DataModel.getInstance().navigationPeeked) {
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.PEEK_NAVIGATION));
				DataModel.getInstance().navigationPeeked = true;
			}
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_firefliesText.stopFlies();
				_firefliesLamp.stopFlies();
				_stars.pause();

				_scrolling = true;
			} else {
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_firefliesText.playFlies();
				_firefliesLamp.playFlies();
				_stars.resume();
				
				_scrolling = false;
			}
		}
		
		private function fadeUpLantern(): void {
			TweenMax.to(_lantern.lit_mc, DataModel.getInstance().randomRange(1.5,2), {alpha:1, ease:Bounce.easeInOut,onComplete:fadeDownLantern});
		}
		
		private function fadeDownLantern(): void {
			TweenMax.to(_lantern.lit_mc, 1, {alpha:0, ease:Bounce.easeInOut,delay:DataModel.getInstance().randomRange(1.5,2), onComplete:fadeUpLantern});
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			// coin/alms count
			if (event.data.decisionNumber == 1) {
				DataModel.coinCount++;
			}
			TweenMax.killAll();
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
	}
}