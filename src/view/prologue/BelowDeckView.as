package view.prologue
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
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class BelowDeckView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _mugText:MovieClip;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _belowDecksSound:Track;
		private var _bgSound:Track;
		private var _scrolling:Boolean;
		private var _introPlayed:Boolean;
		
		public function BelowDeckView()
		{
			_SAL = new SWFAssetLoader("prologue.BelowDeckMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_mugText = null;
//			
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			
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
			
			_mc.mugs_mc.visible = false;
			
			_mugText = _mc.mugs_mc.mugText_mc;
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("belowDeck");
			_bodyParts = _pageInfo.body;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.mugs_mc.mugText_mc);
			DataModel.getInstance().setGraphicResolution(_mc.mugs_mc.mugLeft_mc);
			DataModel.getInstance().setGraphicResolution(_mc.mugs_mc.mugRight_mc);
			DataModel.getInstance().setGraphicResolution(_mc.shipwreck_mc);
			DataModel.getInstance().setGraphicResolution(_mc.cattery_mc);
			DataModel.getInstance().setGraphicResolution(_mc.sandlands_mc);
			DataModel.getInstance().setGraphicResolution(_mc.joyless_mc);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
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
					
					if (part.id == "shipwreck") {
						_mc.shipwreck_mc.y = Math.round(_tf.y + ((_tf.height - _mc.shipwreck_mc.height))/2);
					}
					
					if (part.id == "cattery") {
						_mc.cattery_mc.y = Math.round(_tf.y + ((_tf.height - _mc.cattery_mc.height))/2)-10;
					}
					
					if (part.id == "sandlands") {
						_mc.sandlands_mc.y = Math.round(_tf.y + ((_tf.height - _mc.sandlands_mc.height))/2);
					}
					
					if (part.id == "joyless") {
						_mc.joyless_mc.y = Math.round(_tf.y + ((_tf.height - _mc.joyless_mc.height))/2);
					}
					
					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
					if (part.id == "mugs") {
						_mc.mugs_mc.y = Math.round(_nextY+part.top+40);
						_nextY += _mc.mugs_mc.height + 20;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += Math.round(part.height + part.top);
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc);
			var frameSize:int = _decisions.y + 210;
//			EXCEPTION FOR SCREENSHOT - PREVENTS WHITE FROM SHOWING UP
// 			size black BG
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
			
			// load sound
			_belowDecksSound = new Track("assets/audio/prologue/prologue_below_deck.mp3");
			_belowDecksSound.start(true);
			
			_bgSound = new Track("assets/audio/prologue/prologue_docks.mp3");
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		private function pageOn(event:ViewEvent):void {
			pageAnimation();
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function pageAnimation(): void {
			var mugLX:int = _mc.mugs_mc.mugLeft_mc.x;
			var mugRX:int = _mc.mugs_mc.mugRight_mc.x;
			
			_mc.mugs_mc.mugLeft_mc.x -= _mc.mugs_mc.mugLeft_mc.width - 10;
			_mc.mugs_mc.mugRight_mc.x += _mc.mugs_mc.mugRight_mc.width - 10;
			
			TweenMax.to(_mc.mugs_mc.mugLeft_mc, 1, {bezierThrough:[{x:mugLX+90}, {x:mugLX}], ease:Quad.easeInOut});
			TweenMax.to(_mc.mugs_mc.mugRight_mc, 1, {bezierThrough:[{x:mugRX-90}, {x:mugRX}], ease:Quad.easeInOut});
			
			TweenMax.from(_mugText, .8, {alpha:0, delay:.8});
			
			_mc.mugs_mc.visible = true;
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY > 900 && !_introPlayed) {
				_belowDecksSound.stop(true);
				_bgSound.start(true);
				_introPlayed = true;
			}
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
			} else {
				if (!_scrolling) return;
				
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