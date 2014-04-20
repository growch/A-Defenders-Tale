package control
{
	import com.palDeveloppers.ane.NativeTwitter;
	import com.palDeveloppers.ane.TweetCompositionResult;
	
	import events.ViewEvent;
	
	import model.TwitterFollowerInfo;
	
	public class Twitter
	{
		
		private var _nextCursor:String = "-1";
		private var _maxFollowers:int = 500;
		
		private var _followerCount:int;
		private var _followers:Vector.<TwitterFollowerInfo>;
		private var _tempObj:Object;
		private var _follower:TwitterFollowerInfo;
		public var accessAllowed:Boolean;
		
		public function Twitter()
		{
			init();
		}
		
		private function init():void {
			if (NativeTwitter.isSupported()) {
				_tempObj = new Object();
				
				_followers = new Vector.<TwitterFollowerInfo>;
				_follower = new TwitterFollowerInfo();
				
				accessAllowed = true;
				
				NativeTwitter.instance.twitterUsernamesGot = userNamesGot;
				NativeTwitter.instance.twRequestResult = twRequestResult;
				NativeTwitter.instance.accessDenied = accessDenied;
				NativeTwitter.instance.nonexistentAccount = nonexistentAccount;
				NativeTwitter.instance.tweetComposed = tweetComposed;
				
				if (NativeTwitter.instance.isTwitterSetup()) {
//					getUserName();
//					getFollowers();
					
//					NativeTwitter.instance.composeTweet("testing");
					
				} else {
					EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_NOT_SETUP));
				}
//				trace("isSetup: " + NativeTwitter.instance.isTwitterSetup());
//				trace("accessAllowed: "+accessAllowed);
				
			} else {
				trace("NativeTwitter NOT supported");
			}
		}
		
		private function homeTimelineGot(resultCode:String, data:Object):void {
			var dataS:String = "";
			if (data != null)
				dataS = JSON.stringify(data);
			trace("Home Timeline: " + resultCode + " - " + dataS);
		}
		
		public function destroy():void {
			_tempObj = null;
			_followers = null;
			_follower = null;
		}
		
		public function twitterAvailable():Boolean {
			if (NativeTwitter.isSupported()) {
//				trace("TWITTER IS AVAILABLE !!!");
				return NativeTwitter.instance.isTwitterSetup();
			} else {
//				trace("NativeTwitter NOT supported");
				return false;
			}
			
		}
		
		public function postTweet(tweet:String):void {
			if (!accessAllowed) return;
			
			NativeTwitter.instance.composeTweet(tweet);
		}
		
		private function accessDenied(requestName:String):void {
			accessAllowed = false;
			trace("Access Denied while requesting: " + requestName);
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_ACCESS_DENIED));
		}
		
		private function nonexistentAccount(accountId:int):void {
			trace("Account with id " + accountId + " does not exist");
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_NONEXISTENT_ACCOUNT));
		}
		
		private function tweetComposed(resultCode:int):void {
			var msg:String;
			if ((resultCode & TweetCompositionResult.LONG_TEXT) == TweetCompositionResult.LONG_TEXT) { 
				trace("Tweet text too long");
			} else if ((resultCode & TweetCompositionResult.BAD_IMAGE) == TweetCompositionResult.BAD_IMAGE) {
				trace("Problem attaching image");
			} else if ((resultCode & TweetCompositionResult.LONG_URL) == TweetCompositionResult.LONG_URL) {
				trace("Attached URL too long");
			} else if ((resultCode & TweetCompositionResult.CANCELLED) == TweetCompositionResult.CANCELLED) {
				msg = "Cancelled tweet composition";
				trace(msg);
				_tempObj.msg = msg;
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_DONE, _tempObj));
			} else {
				msg = "Tweet sent";
				trace(msg);
				_tempObj.msg = msg;
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_DONE, _tempObj));
			}
		}
		
		private function twRequestResult(resultCode:String, data:Object):void {
			
			var dataS:String = "";
			if (data != null)
				dataS = JSON.stringify(data);
			
			if (resultCode == "-1") trace("\tEnsure custom params are correctly formatted");
//			trace("TWRequest: " + resultCode + " - " + dataS);
//			trace("data: "+data);
			
			var uLength:int = data.users.length;
			_followerCount += uLength;
//			trace("USER count: "+_followerCount);
			
			for (var i:int = 0; i < uLength; i++) 
			{
//				trace(data.users[i].name);
				_follower = new TwitterFollowerInfo();
				_follower.name = data.users[i].name;
				_follower.screenName = data.users[i].screen_name;
				_followers.push(_follower);
			}
			
			_tempObj.followers = _followers;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_FOLLOWERS_LOAD, _tempObj));
			
			_nextCursor = data.next_cursor_str;
			if (_nextCursor != "0" && _followerCount <= _maxFollowers) {
				getFollowers();
			} 
		}
		
		private function userNamesGot(names:Vector.<String>):void {
//			trace("Registered Twitter names: " + names[0]);
			_tempObj.userName = names[0];
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_USER_LOAD, _tempObj));
		}
		
		
		public function getUserName():void {
			if (!accessAllowed) return;
			
			NativeTwitter.instance.getTwitterUsernames();
		}
		
//		TESTING!!!
		public function getHomeTimeline():void {
			NativeTwitter.instance.getHomeTimeLine();
		}
		
		
		public function getFollowers():void {
			if (!accessAllowed) return;
			
//			trace("Twitter getFollowers");
			NativeTwitter.instance.getTWRequest("followers/list.json?count=200&cursor="+_nextCursor);
//			NativeTwitter.instance.getTWRequest("followers/list.json?count=200&screen_name=jimmykimmel&cursor="+_nextCursor);
		}
	}
}