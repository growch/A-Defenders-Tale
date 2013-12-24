package view
{
	import com.greensock.TweenMax;
	import com.milkmangames.nativeextensions.GVFacebookFriend;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.EmergencyContactMC;
	
	import control.EventController;
	import control.GoViralService;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.TwitterFollowerInfo;
	
	public class EmergencyContactView extends MovieClip
	{
		private var _mc:EmergencyContactMC;
		private var _signInSelect:SocialSignInSelectView;
		private var _goViral:GoViralService;
		private var _contactSelect:SocialContactSelectView;
		private var _twitterSelect:SocialTwitterView;
		private var _contactMC:MovieClip;
		private var _twitterMC:MovieClip;
		private var _signInMC:MovieClip;
		private var _companion:String;
		private var _deathArray:Array = ["thrown into a troll’s cookpot", "barbequed by a dragon", "squashed by a giant"];
		private var _suddenDeath:String;
		
		public function EmergencyContactView()
		{
//			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			EventController.getInstance().addEventListener(ViewEvent.LOGIN_FACEBOOK, loginFacebook);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_LOGGED_IN, showFriends);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_DEFENDER_INFO, addFBName);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_DEFENDER_FRIENDS, addFBFriends);
			EventController.getInstance().addEventListener(ViewEvent.TWITTER_FOLLOWERS_LOAD, addTwitterFollowers);
			EventController.getInstance().addEventListener(ViewEvent.TWITTER_USER_LOAD, addTwitterName);
			EventController.getInstance().addEventListener(ViewEvent.LOGIN_TWITTER, loginTwitter);
			EventController.getInstance().addEventListener(ViewEvent.CONTACT_SELECTED, contactSelected);
			EventController.getInstance().addEventListener(ViewEvent.TWITTER_DONE, twitterDone);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_DONE, facebookDone);
			EventController.getInstance().addEventListener(ViewEvent.CLOSE_TWITTER_OVERLAY, removeTwitterOverlay);
			EventController.getInstance().addEventListener(ViewEvent.TWITTER_ACCESS_DENIED, twitterDenied);
		}
		
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_mc = new EmergencyContactMC();
			
			_signInMC = _mc.getChildByName("singIn_mc") as MovieClip;
			_signInSelect = new SocialSignInSelectView(_signInMC);
			
			_contactMC = _mc.getChildByName("contactSelect_mc") as MovieClip;
			_contactSelect = new SocialContactSelectView(_contactMC);
			_contactMC.visible = false;
			
			_twitterMC = _mc.getChildByName("twitter_mc") as MovieClip;
			_twitterSelect = new SocialTwitterView(_twitterMC);
			_twitterMC.visible = false;
			
			
			addChild(_mc);
			
			_mc.addEventListener(Event.ADDED_TO_STAGE, mcOnStage);
			
			_companion = DataModel.companionSelected ? "pet " + DataModel.defenderOptions.companionArray[DataModel.defenderInfo.companion] : "trusty sidekick";
		
			var randNum:int = Math.round(DataModel.getInstance().randomRange(0, _deathArray.length-1));
			_suddenDeath = _deathArray[randNum];
		}
		
		protected function mcOnStage(event:Event):void
		{
			_mc.removeEventListener(Event.ADDED_TO_STAGE, mcOnStage); 
			
			TweenMax.from(_mc, .5, {alpha:0, onComplete:initGV}); 
		}
		
		private function initGV():void {
			_goViral = DataModel.getGoViral(); 
			trace("initGV _goViral: "+_goViral);
			if (_goViral.isSupported) {
				trace("IS TWITTER AVAILABLE? : "+_goViral.twitterAvailable());
			}
			
		}
		
		protected function contactSelected(event:ViewEvent):void
		{
			if (!DataModel.SOCIAL_CONNECTED) {
				//not really but will work
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SOCIAL_MESSAGE));
				return;
			}
			if (_goViral.isSupported) {
				if (DataModel.SOCIAL_PLATFORM == DataModel.SOCIAL_FACEBOOK) {
					var msg:String = "I’m leaving town for an epic adventure to help defend a realm in peril. Should I be " + 
						_suddenDeath + ", I hereby bequeath my " + _companion + " to " + DataModel.defenderInfo.contactFullName;
					_goViral.postFacebookWall("A message from A Defender's Tale", "I'm off to defend the realm!", msg);
				} else if (DataModel.SOCIAL_PLATFORM == DataModel.SOCIAL_TWITTER) {
					DataModel.getTwitter().postTweet("Leaving town to help defend a realm in peril. Should I fail, I bequeath my " + _companion + " to @" + DataModel.defenderInfo.twitterHandle + 
						" http://bit.ly/1aEYCZJ");
				}
			} else {
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SOCIAL_MESSAGE));
			}
		}
		
		protected function loginFacebook(event:ViewEvent):void
		{
			_goViral.loginFacebook();	
		} 
		
		protected function loginTwitter(event:ViewEvent):void
		{
			_signInMC.visible = false;
			
			if (DataModel.getTwitter().twitterAvailable()) {
				DataModel.getTwitter().getUserName();
				DataModel.getTwitter().getFollowers();
			} else {
				_twitterSelect.twitterDisabled();
			}
			
			_twitterMC.visible = true;
		}
		
		protected function twitterDenied(event:ViewEvent):void
		{
			_signInMC.visible = false;
			
			_twitterSelect.twitterDisabled();
			
			_twitterMC.visible = true;
		}
		
		protected function showFriends(event:ViewEvent):void
		{
			//THIS COULD BE BETTER - for when logged into FB but haven't clicked button yet 
			// i.e. when this view inits
			if(!DataModel.SOCIAL_CONNECTED) return;
			
			trace("showFriends");
			_signInMC.visible = false;
				
			_goViral.getMeFacebook();
			_goViral.getFriendsFacebook();
			
			_contactMC.visible = true;
		}
		
		protected function addFBName(event:ViewEvent):void
		{
			var thisName:GVFacebookFriend = event.data as GVFacebookFriend;
			_contactSelect.populateSocialName(thisName.name);
		}
		
		protected function addTwitterName(event:ViewEvent):void
		{
			_contactSelect.populateSocialName(event.data.userName);
		}
		
		protected function addFBFriends(event:ViewEvent):void
		{
			var friendsVector:Vector.<GVFacebookFriend> = event.data as Vector.<GVFacebookFriend>;
			var sortedVector:Vector.<GVFacebookFriend> = friendsVector.sort(sortPeople);
			_contactSelect.populateFacebookFriends(sortedVector);
		}
		
		protected function addTwitterFollowers(event:ViewEvent):void
		{
			var followersVector:Vector.<TwitterFollowerInfo> = event.data.followers as Vector.<TwitterFollowerInfo>;
//			var sortedVector:Vector.<GVFacebookFriend> = friendsVector.sort(sortPeople);
			trace("!!!!!! followersVector: "+followersVector);
//			return;
			_contactSelect.populateTwitterFollowers(followersVector);
			
			_twitterMC.visible = false;
			_contactMC.visible = true;
		}
		
		protected function twitterDone(event:ViewEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SOCIAL_MESSAGE));
		}	

		protected function facebookDone(event:ViewEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SOCIAL_MESSAGE));
		}	
		
		protected function removeTwitterOverlay(event:Event):void
		{
			_twitterMC.visible = false;
			_signInMC.visible = true;
		}
		
		private function sortPeople(x:GVFacebookFriend, y:GVFacebookFriend):Number
		{
			// sort by  name
			var lastNameSort:Number = sortStrings(x.name, y.name);
			return lastNameSort;
//			if (lastNameSort != 0)
//			{
//				return lastNameSort;
//			}
//			else
//			{
				// if the last names are identical, sort by first name
//				return sortStrings(x.firstName, y.firstName);
//			}
		}
		
		
		private function sortStrings(x:String, y:String):Number
		{
			if (x < y)
			{
				return -1;
			}
			else if (x > y)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		public function destroy():void
		{
			_contactMC = null;
			_signInMC = null;
			_twitterMC = null;
			
			_signInSelect.destroy();
			_contactSelect.destroy();
			_twitterSelect.destroy();
			
			_signInSelect = null;
			_contactSelect = null;
			_twitterSelect = null;
			
			EventController.getInstance().removeEventListener(ViewEvent.LOGIN_FACEBOOK, loginFacebook);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_LOGGED_IN, showFriends);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_DEFENDER_INFO, addFBName);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_DEFENDER_FRIENDS, addFBFriends);
			EventController.getInstance().removeEventListener(ViewEvent.TWITTER_FOLLOWERS_LOAD, addTwitterFollowers);
			EventController.getInstance().removeEventListener(ViewEvent.TWITTER_USER_LOAD, addTwitterName);
			EventController.getInstance().removeEventListener(ViewEvent.LOGIN_TWITTER, loginTwitter);
			EventController.getInstance().removeEventListener(ViewEvent.CONTACT_SELECTED, contactSelected);
			EventController.getInstance().removeEventListener(ViewEvent.TWITTER_DONE, twitterDone);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_DONE, facebookDone);
			EventController.getInstance().removeEventListener(ViewEvent.CLOSE_TWITTER_OVERLAY, removeTwitterOverlay);
			EventController.getInstance().removeEventListener(ViewEvent.TWITTER_ACCESS_DENIED, twitterDenied);
			
			removeChild(_mc);
		}
	}
}