package control
{
	import flash.events.Event;
	
	import de.danielyan.twitterAppOnly.TwitterSocket;
	import de.danielyan.twitterAppOnly.TwitterSocketEvent;
	
	public class TwitterAccess
	{
		private static const CONSUMER_KEY:String = "T5zs9m9iweTRqjhs3OOSA";
		private static const CONSUMER_SECRET:String = "Pj9c1OabJ7gO1c8iSMdytTbOgiYXSNAuDMvzwBAoFLs";
		
		private var _twitter:TwitterSocket;
		private var _screenName:String;
		private var _nextCursor:String = "-1";
		
		private var _followerCount:int;
		
		
		public function TwitterAccess(screenName:String)
		{
			_screenName = screenName;
			
			init();
		}
		
		private function init():void {
			
			_twitter = new TwitterSocket(CONSUMER_KEY, CONSUMER_SECRET);
			_twitter.addEventListener(TwitterSocket.EVENT_TWITTER_READY, twitterReady);
			_twitter.addEventListener(TwitterSocket.EVENT_TWITTER_RESPONSE, twitterResponse);
			
		}
		
		protected function twitterResponse(event:TwitterSocketEvent):void
		{
			trace("twitterResponse followers count: "+event.response.users.length);
			_followerCount += event.response.users.length;
			
			for (var i:int = 0; i < event.response.users.length; i++) 
			{
				trace(event.response.users[i].name);
			}
			trace("!!!! next_cursor_str: "+event.response.next_cursor_str);
			_nextCursor = event.response.next_cursor_str;
			if (_nextCursor != "0") {
				getFollowers();
			}
		}
		
		protected function twitterReady(event:Event):void
		{
			getFollowers();
		}
		
		private function getFollowers():void {
//			_twitter.request("/1.1/followers/list.json?cursor=-1&screen_name=jimmykimmel&count=200");	
//			_twitter.request("/1.1/followers/list.json?count=200&screen_name="+_screenName);	
			_twitter.request("/1.1/followers/list.json?count=200&screen_name="+_screenName+"&cursor="+_nextCursor);
		}
	}
}