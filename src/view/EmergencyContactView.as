package view
{
	import com.greensock.TweenMax;
	import com.milkmangames.nativeextensions.GVFacebookFriend;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.EmergencyContactMC;
	
	import control.EventController;
	import control.GoViralService;
	import control.TwitterAccess;
	
	import events.ViewEvent;
	
	import model.TwitterFollowerInfo;

	
	import model.DataModel;
	
	public class EmergencyContactView extends MovieClip
	{
		private var _mc:EmergencyContactMC;
		private var _signInSelect:EmergencySignInSelectView;
		private var _goViral:GoViralService;
		private var _contactSelect:EmergencyContactSelectView;
		private var _contactMC:MovieClip;
		private var _signInMC:MovieClip;
		private var _twitter:TwitterAccess;
		
		public function EmergencyContactView()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.LOGIN_FACEBOOK, loginFacebook);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_LOGGED_IN, showFriends);
			EventController.getInstance().addEventListener(ViewEvent.LOGIN_TWITTER, showFriends);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_DEFENDER_INFO, addFBName);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_DEFENDER_FRIENDS, addFBFriends);
			EventController.getInstance().addEventListener(ViewEvent.TWITTER_FOLLOWERS_LOAD, addTwitterFollowers);
		}
		
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_mc = new EmergencyContactMC();
			
			_signInMC = _mc.getChildByName("singIn_mc") as MovieClip;
			_signInSelect = new EmergencySignInSelectView(_signInMC);
			
			_contactMC = _mc.getChildByName("contactSelect_mc") as MovieClip;
			_contactSelect = new EmergencyContactSelectView(_contactMC);
			_contactMC.visible = false;
			
			TweenMax.from(_mc, 1, {alpha:0, onComplete:initGV}); 
			addChild(_mc);
			
		}
		
		private function initGV():void {
			_goViral = DataModel.getGoViral(); 
		}
		
		protected function loginFacebook(event:ViewEvent):void
		{
			_goViral.loginFacebook();	
		}
		
		protected function showFriends(event:ViewEvent):void
		{
			_signInMC.visible = false;
			if (DataModel.SOCIAL_PLATFROM == DataModel.SOCIAL_FACEBOOK) {
				_goViral.getMeFacebook();
				_goViral.getFriendsFacebook();
			} else if (DataModel.SOCIAL_PLATFROM == DataModel.SOCIAL_TWITTER) {
				//TODO show Twitter login info
				_twitter = new TwitterAccess("bob_schneider");
			}
			
			_contactMC.visible = true;
		}
		
		protected function addFBName(event:ViewEvent):void
		{
			var thisName:GVFacebookFriend = event.data as GVFacebookFriend;
			_contactSelect.populateFacebookName(thisName.name);
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
			_signInSelect.destroy();
			_contactSelect.destroy();
			
//			_goViral.dispose();
			EventController.getInstance().removeEventListener(ViewEvent.LOGIN_TWITTER, showFriends);
			EventController.getInstance().removeEventListener(ViewEvent.LOGIN_FACEBOOK, loginFacebook);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_LOGGED_IN, showFriends);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_DEFENDER_INFO, addFBName);
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_DEFENDER_FRIENDS, addFBFriends);
			
			removeChild(_mc);
		}
	}
}