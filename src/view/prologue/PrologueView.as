package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import assets.PrologueMC;
	
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
	import view.StarryNight;
	import view.prologue.coins.Coin1View;
	
	public class PrologueView extends MovieClip implements IPageView
	{
		private var _mc:PrologueMC;
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
		private var _bmpD:BitmapData;
		private var _bmp:Bitmap;
		private var _bgSound:Track;
		
		DocksView, Coin1View
		public function PrologueView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
		}
		
		public function destroy():void
		{
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
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			TweenMax.killAll();
			
			_bgSound = null;
			
			_stars.destroy();
			_stars = null;
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade); 
			
			_mc = new PrologueMC();
			
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
			
			_bodyParts = DataModel.appData.prologue.body;
			
			var appDate:Date = DataModel.defenderInfo.applicationDate;
			var threeMonthsAgo:Date = new Date();
			threeMonthsAgo.setTime(appDate.time - ( 90 * 24 * 60 * 60 * 1000 ));
//			trace("threeMonthsAgo: "+threeMonthsAgo); 
			
			var multiplier:int = DataModel.resMultiplier;
			
			
			for each (var part:StoryPart in _bodyParts) 
			{
				
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[wardrobe1]", DataModel.appData.prologue.wardrobe1[DataModel.defenderInfo.gender][DataModel.defenderInfo.wardrobe]);
					copy = StringUtil.replace(copy, "[wardrobe2]", DataModel.appData.prologue.wardrobe2[DataModel.defenderInfo.wardrobe]);
					copy = StringUtil.replace(copy, "[instrument1]", DataModel.appData.prologue.instrument1[DataModel.defenderInfo.instrument]);
					copy = StringUtil.replace(copy, "[companion1]", DataModel.appData.prologue.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[date]", _monthArray[threeMonthsAgo.month] + " " + threeMonthsAgo.date + _dateSuffixArray[threeMonthsAgo.date]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size*multiplier, part.alignment, part.leading*multiplier), part.width*multiplier, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_tf.cacheAsBitmap = true;
					_tf.cacheAsBitmapMatrix = new Matrix();
					
					if (part.id == "lantern") {
						_mc.lantern_mc.y = _tf.y - 100;
						_mc.firefliesLamp_mc.y = _mc.lantern_mc.y + 237;
					}

//					_bmpD = new BitmapData(_tf.width,_tf.height,true,0xff0000);
//					_bmpD.draw(_tf);
//					_bmp = new Bitmap(_bmpD);
//					_bmp.smoothing = true;
//					_bmp.x = _tf.x;
//					_bmp.y = _tf.y;
//					_textHolder.addChild(_bmp);
//					_mc.addChild(_bmp);

					_mc.addChild(_tf);
					
					_nextY += Math.round(_tf.height + part.top);
					
				} else if (part.type == "image") {
				
					if (part.id == "fireflyText") {
						_mc.firefliesText_mc.y = Math.round(_nextY+part.top + 30);
					}
					
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += DataModel.appData.prologue.decisionsMarginTop;
			_decisions = new DecisionsView(DataModel.appData.prologue.decisions);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc);
			
			_frame.sizeFrame(_decisions.y + 210);

			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
			
			// load sound
			_bgSound = new Track("assets/audio/prologue/prologue.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
		}
		
		private function pageOn(event:ViewEvent):void {
			_stars.start();
			fadeUpLantern();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_mc.firefliesText_mc.stopFlies();
				_mc.firefliesLamp_mc.stopFlies();
				_stars.pause();

				_scrolling = true;
			} else {
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_mc.firefliesText_mc.playFlies();
				_mc.firefliesLamp_mc.playFlies();
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
			// fade down sound
			_bgSound.stop(true);
//			TweenMax.to(_mc, 1, {alpha:0});
//			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			// coin/alms count
//			if (event.data.decisionNumber == 1) {
//				DataModel.coinCount++;
//			}
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			// coin/alms count
			if (thisPage.decisionNumber == 1) {
				DataModel.coinCount++;
			}
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}