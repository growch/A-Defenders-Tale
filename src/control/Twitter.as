package control
{
	import com.palDeveloppers.ane.NativeTwitter;
	
	import de.danielyan.twitterAppOnly.TwitterSocketEvent;
	
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
		
		
		public function Twitter()
		{
			init();
		}
		
		private function init():void {
			if (NativeTwitter.isSupported()) {
				NativeTwitter.instance.homeTimelineRequested = homeTimelineGot;
				NativeTwitter.instance.twRequestResult = twRequestResult;
				
				//				NativeTwitter.instance.getHomeTimeLine();
				
			} else {
				trace("NativeTwitter NOT supported");
			}
		}
		
		public function destroy():void {

		}
		
		private function twRequestResult(resultCode:String, data:Object):void {
			var dataS:String = "";
			if (data != null)
				dataS = JSON.stringify(data);
			
			trace("USER count: "+data.users.length);
			
			if (resultCode == "-1") trace("\tEnsure custom params are correctly formatted");
			trace("TWRequest: " + resultCode + " - " + dataS);
		}
		
		private function homeTimelineGot(resultCode:String, data:Object):void {
			trace("homeTimelineGot");
			var dataS:String = "";
			if (data != null)
				dataS = JSON.stringify(data);
			trace("Home Timeline: " + resultCode + " - " + dataS);
		}
		
		protected function twitterResponse(event:TwitterSocketEvent):void
		{
			// USER REQUEST  event.response[0].screen_name
			if (event.response[0]) {
				trace("twitterResponse: "+event.response[0].name);
				_tempObj.userName = event.response[0].name;
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_USER_LOAD, _tempObj));
				return;
			}
			
			//FOLLOWERS REQUEST
			trace("twitterResponse followers count: "+event.response.users.length);
			_followerCount += event.response.users.length;
			
			for (var i:int = 0; i < event.response.users.length; i++) 
			{
				trace(event.response.users[i].name);
				_follower = new TwitterFollowerInfo();
				_follower.name = event.response.users[i].name;
				_follower.screenName = event.response.users[i].screen_name;
				_followers.push(_follower);
			}
//			trace("!!!! next_cursor_str: "+event.response.next_cursor_str);
			
			_tempObj.followers = _followers;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_FOLLOWERS_LOAD, _tempObj));
			
			_nextCursor = event.response.next_cursor_str;
			if (_nextCursor != "0" && _followerCount <= _maxFollowers) {
				getFollowers();
			} else {
				
			}
		}

		
		private function getUserName():void {
			trace("TwitterAccess getUserName: "+_screenName);
//			_twitter.request("/1.1/users/lookup.json?screen_name="+_screenName);
		}
		
		
		private function getFollowers():void {
			trace("TwitterAccess getFollowers");
//			_twitter.request("/1.1/followers/list.json?cursor=-1&screen_name=jimmykimmel&count=200");	
//			_twitter.request("/1.1/followers/list.json?count=200&screen_name="+_screenName);	
//			_twitter.request("/1.1/followers/list.json?count=200&screen_name="+_screenName+"&cursor="+_nextCursor);
			NativeTwitter.instance.getTWRequest("followers/list.json?count=200&cursor="+_nextCursor);
		}
	}
}