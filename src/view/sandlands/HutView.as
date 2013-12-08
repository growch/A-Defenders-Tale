package view.sandlands
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
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
	
	public class HutView extends MovieClip implements IPageView
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
		private var _introInt:int;
		private var _bubblingCauldron:MovieClip;
		private var _bgSound:Track;
		private var _secondSound:Track;
		private var _finalSoundPlayed:Boolean;
		
		public function HutView()
		{
			_SAL = new SWFAssetLoader("sandlands.HutMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_bubblingCauldron = null;
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
			
			//LOW RES GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.end_mc);
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("hut");
			_bodyParts = _pageInfo.body;
			
			if (DataModel.sand5Ft && DataModel.dropsCorrect) {
				_introInt = 2;
			} else if (!DataModel.sand5Ft) {
				_introInt = 0;
			} else {
				_introInt = 1;
			}
			
			_mc.end_mc.visible = false; 
			
			//LOW RES GRAPHICS
			if (DataModel.highRes) {
				_mc.cauldron_mc.gotoAndStop(2);
			} else {
				_mc.cauldron_mc.gotoAndStop(1);
			}
			
			_mc.cauldron_mc.correct_mc.stop();
			_mc.cauldron_mc.incorrect_mc.stop();
			
			_mc.cauldron_mc.correct_mc.visible = false;
			_mc.cauldron_mc.incorrect_mc.visible = false;
			
			if (_introInt == 2) {
				_bubblingCauldron =	_mc.cauldron_mc.correct_mc;
			} else {
				_bubblingCauldron =	_mc.cauldron_mc.incorrect_mc;
			}
			
			_bubblingCauldron.visible = true;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[intro1]", _pageInfo.intro1[_introInt]);
					copy = StringUtil.replace(copy, "[intro2]", _pageInfo.intro2[_introInt]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x331a0f), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "cauldron") {
						_mc.cauldron_mc.y = Math.round(_tf.y + (_tf.height - _mc.cauldron_mc.height)/2);
					}
					
				} else if (part.type == "image") {
					//!IMPORTANT
					if (_introInt != 2) {
						_mc.end_mc.y = _nextY + 50;
						_nextY += 80;
						_mc.end_mc.visible = true;
						break;
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
//			_decisions = new DecisionsView(_pageInfo.decisions,0x040404,true); //tint it, showBG
			
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			if (_introInt == 2) {
				dv.push(_pageInfo.decisions[2]);
			} else {
				dv.push(_pageInfo.decisions[0]);
				dv.push(_pageInfo.decisions[1]);
			}
			_decisions = new DecisionsView(dv,0x040404,true);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 210;
			//size bg
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
			
			_bgSound = new Track("assets/audio/sandlands/sandlands_SL_02.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
			_secondSound = new Track("assets/audio/sandlands/sandlands_SL_15.mp3");
			_secondSound.fadeAtEnd = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			_bubblingCauldron.play();
			
			TweenMax.delayedCall(5, secondSound);
		}
		
		private function secondSound():void {
			_bgSound.stop(true);
			_secondSound.start(true);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY >= _dragVCont.maxScroll && !_finalSoundPlayed && _introInt != 2) {
				DataModel.getInstance().endSound();
				_finalSoundPlayed = true;
			}
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				_bubblingCauldron.stop();
				
				TweenMax.pauseAll();
				_scrolling = true;
			} else {
				if (!_scrolling) return;
				_bubblingCauldron.play();
				
				TweenMax.resumeAll();
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