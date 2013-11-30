package view.theCattery
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
	
	public class ThirdDoorView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _scrolling:Boolean;
		private var _ballAnimating:Boolean;
		private var _bgSound:Track;
		private var _endSound:Boolean;
		private var _socialConnectInt:int;
		private var _messageDone:Boolean;
		
		public function ThirdDoorView()
		{
			_SAL = new SWFAssetLoader("theCattery.ThirdDoorMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_DONE, messageDone);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_LOGGED_IN, fbLogin);
			EventController.getInstance().addEventListener(ViewEvent.TWITTER_DONE, messageDone);
		}
		
		public function destroy() : void {
//			
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_DONE, messageDone);
			EventController.getInstance().removeEventListener(ViewEvent.TWITTER_DONE, messageDone);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_LOGGED_IN, fbLogin);
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
			
			_pageInfo = DataModel.appData.getPageInfo("thirdDoor");
			_bodyParts = _pageInfo.body;
			
			_mc.ball_mc.visible = false;
			_mc.end_mc.visible = false;
			
			//!!!! used later in FourthDoor
			DataModel.thirdDoor = true;
			
			// companion take or not
			var compTakenInt:int = DataModel.COMPANION_TAKEN ? 0 : 1;
//			1 = TRUE
			
			_socialConnectInt = DataModel.SOCIAL_CONNECTED ? 1 : 0;
			// 0 = TRUE
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companionComing1]", _pageInfo.companionComing1[compTakenInt][_socialConnectInt]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x000000), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "final" && _socialConnectInt == 0) {
						_mc.end_mc.y = _nextY + 40;
						_nextY += _mc.end_mc.height + 20;
						_mc.end_mc.visible = true;
					}
						
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
					
					if (part.id == "ball") {
						_mc.ball_mc.y = _nextY - part.top - 10;
					}
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
//			_decisions = new DecisionsView(_pageInfo.decisions,0x000000,true); //tint it black, showBG
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			
			if (_socialConnectInt == 1) {
				dv.push(_pageInfo.decisions[0]);
				dv.push(_pageInfo.decisions[1]);
			} else {
				dv.push(_pageInfo.decisions[2]);
				dv.push(_pageInfo.decisions[3]);
			}
			_decisions = new DecisionsView(dv,0x000000,true);
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
			
			_bgSound = new Track("assets/audio/cattery/cattery_13.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			_mc.ball_mc.gotoAndStop(1);
			_mc.ball_mc.visible = true;
			_mc.ball_mc.play();
			_ballAnimating = true;
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY > _dragVCont.maxScroll && !_endSound && _socialConnectInt == 0) {
				DataModel.getInstance().endSound();
				_endSound = true;
			}
			
			if (_ballAnimating) {
				if (_mc.ball_mc.currentFrame == _mc.ball_mc.totalFrames) {
					_mc.ball_mc.stop();
					_mc.ball_mc.shadow_mc.stop();
					_ballAnimating = false;
				}
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
		
		
		protected function messageDone(event:ViewEvent):void
		{
			_messageDone = true;
			
			var tempObj:Object = new Object();
			tempObj.id = _pageInfo.decisions[0].id;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		protected function fbLogin(event:ViewEvent):void
		{
			var tempObj:Object = new Object();
			tempObj.id = _pageInfo.decisions[0].id;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			if (event.data.id == "theCattery.KittenContactView" && !_messageDone) {
				if (DataModel.SOCIAL_PLATFROM == DataModel.SOCIAL_FACEBOOK) {
					if (!DataModel.getGoViral().isSupported) return;
					
					var msg:String = DataModel.defenderInfo.contactFullName + 
						" just saved the day against the worst kind of trick: hoards of squeezable kittens! " +
						"I couldn’t have picked a better emergency contact. " +
						"Soon I’ll have the cat’s eye stone and be even closer to saving the realm!"
					DataModel.getGoViral().postFacebookWall("Hoards of squeezable kittens in A Defender’s Tale", "Still over here, defending the realm.", msg);
				} else if (DataModel.SOCIAL_PLATFROM == DataModel.SOCIAL_TWITTER) {
					DataModel.getTwitter().postTweet("@" + DataModel.defenderInfo.twitterHandle + 
						" just saved the day against the worst kind of trick: hoards of squeezable kittens!");
				}
				return;
			}
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}