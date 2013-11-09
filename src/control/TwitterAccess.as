package control
{
	import flash.events.Event;
	
	import de.danielyan.twitterAppOnly.TwitterSocket;
	import de.danielyan.twitterAppOnly.TwitterSocketEvent;
	
	import events.ViewEvent;
	
	import model.StoryPart;
	import model.TwitterFollowerInfo;
	
	public class TwitterAccess
	{
		private static const CONSUMER_KEY:String = "T5zs9m9iweTRqjhs3OOSA";
		private static const CONSUMER_SECRET:String = "Pj9c1OabJ7gO1c8iSMdytTbOgiYXSNAuDMvzwBAoFLs";
		
		private var _twitter:TwitterSocket;
		private var _screenName:String;
		private var _nextCursor:String = "-1";
		private var _maxFollowers:int = 500;
		
		private var _followerCount:int;
		private var _followers:Vector.<TwitterFollowerInfo>;
		private var _tempObj:Object;
		private var _follower:TwitterFollowerInfo;
		
		
		public function TwitterAccess(screenName:String)
		{
			_screenName = screenName;
			
			init();
		}
		
		private function init():void {
			
			_twitter = new TwitterSocket(CONSUMER_KEY, CONSUMER_SECRET);
			_twitter.addEventListener(TwitterSocket.EVENT_TWITTER_READY, twitterReady);
			_twitter.addEventListener(TwitterSocket.EVENT_TWITTER_RESPONSE, twitterResponse);
			
			_followers = new Vector.<TwitterFollowerInfo>;
			_follower = new TwitterFollowerInfo();
			
			_tempObj = new Object();
		}
		
		public function destroy():void {
			_twitter.removeEventListener(TwitterSocket.EVENT_TWITTER_READY, twitterReady);
			_twitter.removeEventListener(TwitterSocket.EVENT_TWITTER_RESPONSE, twitterResponse);
		}
		
		protected function twitterResponse(event:TwitterSocketEvent):void
		{
			trace("twitterResponse followers count: "+event.response.users.length);
			_followerCount += event.response.users.length;
			
//			_followers.length = 0;
			
			
			for (var i:int = 0; i < event.response.users.length; i++) 
			{
				trace(event.response.users[i].name);
				_follower = new TwitterFollowerInfo();
				_follower.name = event.response.users[i].name;
				_follower.screenName = event.response.users[i].screen_name;
				_followers.push(_follower);
			}
			trace("!!!! next_cursor_str: "+event.response.next_cursor_str);
			
			_tempObj.followers = _followers;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_FOLLOWERS_LOAD, _tempObj));
			
			_nextCursor = event.response.next_cursor_str;
			if (_nextCursor != "0" && _followerCount <= _maxFollowers) {
				getFollowers();
			} else {
				
			}
		}
		
		protected function twitterReady(event:Event):void
		{
			getFollowers();
		}
		
		private function getFollowers():void {
			trace("TwitterAccess getFollowers");
//			_twitter.request("/1.1/followers/list.json?cursor=-1&screen_name=jimmykimmel&count=200");	
//			_twitter.request("/1.1/followers/list.json?count=200&screen_name="+_screenName);	
			_twitter.request("/1.1/followers/list.json?count=200&screen_name="+_screenName+"&cursor="+_nextCursor);
		}
	}
}