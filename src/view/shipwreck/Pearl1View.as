package view.shipwreck
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
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
	
	public class Pearl1View extends MovieClip implements IPageView
	{
		private var _mc:MovieClip; 
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _jellyArray:Array;
		private var _counter:int = 0;
		private var _pageInfo:PageInfo;
		private var _jellyTimer:Timer;
		private var _timerSpeed:int = 1000;
		private var _SAL:SWFAssetLoader;
		private var _bgSound:Track;
		private var _ariaSound:Track;
		private var ariaPlayed:Boolean;
		private var _endPlayed:Boolean;
		private var _jellyCount:int;
		private var _i:int;
		private var _thisJelly:MovieClip;
		
		public function Pearl1View()
		{
			_SAL = new SWFAssetLoader("shipwreck.Pearl1MC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
			_jellyTimer.stop();
			_jellyTimer = null;
			
//			_jellyArray = null;
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
			
			_pageInfo = DataModel.appData.getPageInfo("pearl1");
			_bodyParts = _pageInfo.body;
			
			_jellyArray = new Array();
			_jellyCount = 6;
			
			for (var i:int = 0; i < _jellyCount; i++) 
			{
				var thisJ:MovieClip = _mc["jelly"+String(i+1)+"_mc"] as MovieClip;
				//GRAPHICS
				DataModel.getInstance().setGraphicResolution(thisJ);
				thisJ = thisJ.jellyfish_mc;
				thisJ.hit_mc.visible = false;
				thisJ.stop();
				
				_jellyArray.push(thisJ);
				
			}
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.sand_mc);
			DataModel.getInstance().setGraphicResolution(_mc.end_mc);
			
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
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "end") {
						_mc.end_mc.y = _nextY + 180; 
						
						//EXCEPTION
//						_jelly5.y = _mc.end_mc.y - 160;
//						_jelly6.y = _mc.end_mc.y - 40;
						_jellyArray[4].parent.y = _mc.end_mc.y - 160;
						_jellyArray[5].parent.y = _mc.end_mc.y - 40;
						
						_nextY += 120;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					
					//EXCEPTION
					_jellyArray[0].parent.y = _nextY + 20;
					_jellyArray[1].parent.y = _nextY + 200;
					_jellyArray[2].parent.y = _nextY;
					_jellyArray[3].parent.y = _nextY + 200;
					
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY; 
			
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			//CUSTOM!!!
			var frameSize:int = _decisions.y + 400;
			//CUSTOM
			var diff:int = frameSize - _mc.bg_mc.height; 
			_mc.sand_mc.y += diff;  
			
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
			
			// bg sound
			_bgSound = new Track("assets/audio/shipwreck/shipwreck_04.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
			_ariaSound = new Track("assets/audio/shipwreck/shipwreck_07.mp3");
			_ariaSound.loop = true;
			_ariaSound.fadeAtEnd = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			_jellyTimer = new Timer(_timerSpeed);
			_jellyTimer.addEventListener(TimerEvent.TIMER, animateJelly); 
			_jellyTimer.start();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function animateJelly(e:TimerEvent):void {
			if (DataModel.ipad1) return;
			
			var thisJelly:MovieClip = _jellyArray[_counter] as MovieClip;
			thisJelly.play(); 
			_counter++;
			if (_counter > _jellyArray.length-1) {
				_counter = 0;
			}
		}
		
		private function playAria():void
		{
			_bgSound.stop(true);
			_ariaSound.start(true);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY > 300 && !ariaPlayed) {
				playAria();
				ariaPlayed = true;
			}
			
			if (_dragVCont.scrollY >= _dragVCont.maxScroll && !_endPlayed) {
				DataModel.getInstance().endSound();
				_endPlayed = true;
			}
			
			updateJellies();
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_jellyTimer.stop();
					
				_scrolling = true;
			} else {
				
				if (!_scrolling) return;
				
				_jellyTimer.start();
				
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		private function updateJellies():void {
			if (DataModel.ipad1) return;
			
			for (_i = 0; _i < _jellyCount; _i++) 
			{
				_thisJelly = _jellyArray[_i] as MovieClip
				if (_thisJelly.currentFrame == _thisJelly.totalFrames) {
					_thisJelly.gotoAndStop(1);
				}
			}
			
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_jellyTimer.stop();
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