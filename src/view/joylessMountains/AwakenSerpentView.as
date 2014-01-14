package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import org.flintparticles.twoD.renderers.BitmapRenderer;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	import view.Smoke;
	
	public class AwakenSerpentView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _renderer:BitmapRenderer;
		private var _smoke1:Smoke;
		private var _smoke2:Smoke;
		private var _smokeTimer:Timer;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _bgSound:Track;
		private var _secondSound:Track;
		
		public function AwakenSerpentView()
		{
			_SAL = new SWFAssetLoader("joyless.AwakenSerpentMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
			TweenMax.killAll();
			
			//			if (!DataModel.ipad1) {
			_smokeTimer.stop();
			_smokeTimer = null;
			
			_smoke1.stop();
			_smoke2.stop();
			_renderer.removeEmitter( _smoke1 );
			_renderer.removeEmitter( _smoke2 );
			_mc.snowmonch_mc.removeChild( _renderer );
			_renderer = null;
			_smoke1 = null;
			_smoke2 = null;
			//			}
			
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
			
			_pageInfo = DataModel.appData.getPageInfo("awakenSerpent");
			_bodyParts = _pageInfo.body;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.snowmonch_mc.serpent_mc);
			DataModel.getInstance().setGraphicResolution(_mc.snowmonch_mc.serpent_mc.eyelid_mc);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[wardrobe1]", _pageInfo.wardrobe1[DataModel.defenderInfo.wardrobe]);
					
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
					
					if (part.id == "snowmonch") {
						_mc.snowmonch_mc.y = _nextY + 40;
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
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 210;
			// size bg
			_mc.bg_mc.height = frameSize;
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
			
			_bgSound = new Track("assets/audio/joyless/joyless_18.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
			_secondSound = new Track("assets/audio/joyless/joyless_02.mp3");
			_secondSound.loop = true;
			_secondSound.fadeAtEnd = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			
			TweenMax.to(_mc.snowmonch_mc.serpent_mc.eyelid_mc, 2.5, {x:"-5",y:"-15",ease:Elastic.easeInOut, onComplete:startSmoke});
				
			_smoke1 = new Smoke();
			_smoke1.x = _mc.snowmonch_mc.nostrilL_mc.x;
			_smoke1.y = _mc.snowmonch_mc.nostrilL_mc.y;
			
			_smoke2 = new Smoke();
			_smoke2.x = _mc.snowmonch_mc.nostrilR_mc.x;
			_smoke2.y = _mc.snowmonch_mc.nostrilR_mc.y;
			
			_renderer = new BitmapRenderer( new Rectangle( 200, 0, 300, 420 ) );
			_renderer.addEmitter( _smoke1 );
			_renderer.addEmitter( _smoke2 );
			_mc.snowmonch_mc.addChild( _renderer );
			
			_smokeTimer = new Timer(6000);
			_smokeTimer.addEventListener(TimerEvent.TIMER, smokeEvent);
			
//			startSmoke();
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			TweenMax.delayedCall(5, secondSound);
		}
		
		private function secondSound():void
		{
			_bgSound.stop(true);
			_secondSound.start(true);
		}
		
		private function startSmoke():void {
			showSmoke();
			
			_smokeTimer.start();
		}
		
		private function smokeEvent(e:TimerEvent):void {
			showSmoke();
		}
		
		private function showSmoke():void {
			TweenMax.to(_renderer, 0, {autoAlpha:1});
			_smoke1.start();
			_smoke2.start();
			TweenMax.to(_renderer, 1.5, {autoAlpha:0, delay:4, onComplete:stopSmoke}); 
		}
		
		private function stopSmoke():void {
			_smoke1.stop();
			_smoke2.stop();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
				_smoke1.pause();
				_smoke2.pause();
				_smokeTimer.reset();
				
			} else {
				
				if (!_scrolling) return;
				
				_smoke1.resume();
				_smoke2.resume();
				_smokeTimer.start();
				
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
			_smokeTimer.stop();
			//for delayed calls
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}