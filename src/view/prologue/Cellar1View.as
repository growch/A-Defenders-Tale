package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import control.EventController;
	import control.GoViralService;
	
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
	
	public class Cellar1View extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _magicSpacer:int = 210;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _bgSound:Track;
		private var _compInt:int;
		private var _scrolling:Boolean;
		private var _endPlayed:Boolean;
		
		public function Cellar1View()
		{
			_SAL = new SWFAssetLoader("prologue.Cellar1MC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_DONE, messageDone);
			EventController.getInstance().addEventListener(ViewEvent.TWITTER_DONE, messageDone);
		}
		
		public function destroy() : void {
//			
			_mc.companion_mc.removeEventListener(MouseEvent.CLICK, clickForSound);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_DONE, messageDone);
			EventController.getInstance().removeEventListener(ViewEvent.TWITTER_DONE, messageDone);
//			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
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
			
			_compInt = DataModel.defenderInfo.companion;
			
			_mc.companion_mc.gotoAndStop(_compInt+1);
			_mc.end_mc.visible = false;
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("cellar1");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[_compInt]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[_compInt]);
					copy = StringUtil.replace(copy, "[companion3]", _pageInfo.companion3[_compInt]);
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[DataModel.defenderInfo.weapon]);
					
					// only add copy for no FB contact
					if (part.id == "noFacebook") {
						// don't add
						if (DataModel.defenderInfo.contactFBID != null) {
							break;
						} 
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
					_tf.y = _nextY + part.top;
					
					if (part.id == "companionImage") {
						_mc.companion_mc.y = Math.round(((_tf.y + _tf.height) - part.height)/2);
					}
					
					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
					if (part.id == "noFacebook" && DataModel.defenderInfo.contactFBID == null) {
							_mc.end_mc.y = _nextY + 30;
							_mc.end_mc.visible = true;
							_nextY += _mc.end_mc.height + 30;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
				
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			if (DataModel.defenderInfo.contactFBID != null) {
				dv.push(_pageInfo.decisions[0]);
				dv.push(_pageInfo.decisions[1]);
				dv.push(_pageInfo.decisions[2]);
				
			} else {
				dv.push(_pageInfo.decisions[1]);
				dv.push(_pageInfo.decisions[2]);
			}	
			_decisions = new DecisionsView(dv);
				
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			// HACK for 3 decisions
			if(dv.length > 2) {
				_magicSpacer += 60;
			}
			
			_frame = new FrameView(_mc.frame_mc);
			var frameSize:int;
			
			// HACK for 3 decisions
			if(dv.length > 2) {
				frameSize = _decisions.y + _magicSpacer;
				_frame.sizeFrame(frameSize);
				_frame.extraDecisionAdjust(60);
				frameSize += 60;
				_decisions.y += 20;
			} else {
				frameSize = _decisions.y + 210;
				_frame.sizeFrame(frameSize);
				if (frameSize < DataModel.APP_HEIGHT) {
					_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
				}
			}
			
			//			EXCEPTION FOR SCREENSHOT - PREVENTS WHITE FROM SHOWING UP
			// 			size black BG
			_mc.bg_mc.height = frameSize;
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			// bg sound
			_bgSound = new Track("assets/audio/prologue/prologue_cellar.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
		}
		
		private function pageOn(event:ViewEvent):void {
			
			_mc.companion_mc.addEventListener(MouseEvent.CLICK, clickForSound);
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
		}
		
		private function clickForSound(e:MouseEvent):void {
			DataModel.getInstance().companionSound();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY >= _dragVCont.maxScroll && !_endPlayed) {
				DataModel.getInstance().endSound();
				_endPlayed = true;
			}
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
//				TweenMax.pauseAll();
				_scrolling = true;
			} else {
				if (!_scrolling) return;
				_scrolling = false;
			}
		}
		
//		protected function facebookContactResponded(event:ViewEvent):void
//		{
//			var decY:int = _decisions.y;
//			_decisions.destroy();
//			_mc.removeChild(_decisions);
//			
//			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
//			dv.push(_pageInfo.decisions[3]);
//			_decisions = new DecisionsView(dv);
//			_decisions.y = decY;
//			_mc.addChild(_decisions);
//			
//			TweenMax.from(_decisions, 1, {alpha:0, delay:0});
//		}
		
		protected function messageDone(event:ViewEvent):void
		{
			var tempObj:Object = new Object();
			tempObj.id = _pageInfo.decisions[3].id;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			if (event.data.id == "FacebookNotifyView") {
				var pronoun3:String = DataModel.getInstance().replaceVariableText('[pronoun3]');
				
				if (DataModel.SOCIAL_PLATFROM == DataModel.SOCIAL_FACEBOOK) {
					if (!DataModel.getGoViral().isSupported) return;
					
					var msg:String = "I have to admit that my quest hasn’t been easy. I’d be Orc chow if " + DataModel.defenderInfo.contactFullName + 
						"hadn’t flexed " + pronoun3 + " diplomatic skills. Wish me luck as I sail for the Barrier Islands."
					DataModel.getGoViral().postFacebookWall("Setting sail in A Defender’s Tale", "Defending the Realm is harder than it looks.", msg);
				} else if (DataModel.SOCIAL_PLATFROM == DataModel.SOCIAL_TWITTER) {
					DataModel.getTwitter().postTweet("Still defending the realm: I’d be Orc chow if @" + DataModel.defenderInfo.twitterHandle + 
						" hadn’t flexed " + pronoun3 + " diplomatic skills. http://bit.ly/1aEYCZJ");
				}
				return;
			}
			
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}