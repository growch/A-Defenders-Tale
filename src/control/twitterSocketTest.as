package control
{
	import flash.events.Event;
	
	import de.danielyan.twitterAppOnly.TwitterSocket;
	import de.danielyan.twitterAppOnly.TwitterSocketEvent;
	
	public class twitterSocketTest
	{
		private var _twitter:TwitterSocket;
		
		public function twitterSocketTest()
		{
			init();
		}
		
		private function init():void {
			_twitter = new TwitterSocket("T5zs9m9iweTRqjhs3OOSA", "Pj9c1OabJ7gO1c8iSMdytTbOgiYXSNAuDMvzwBAoFLs");
			_twitter.addEventListener(TwitterSocket.EVENT_TWITTER_READY, twitterReady);
			_twitter.addEventListener(TwitterSocket.EVENT_TWITTER_RESPONSE, twitterResponse);
			
		}
		
		protected function twitterResponse(event:TwitterSocketEvent):void
		{
			trace("twitterResponse followers count: "+event.response.users.length);
			for (var i:int = 0; i < event.response.users.length; i++) 
			{
				trace(event.response.users[i].name);
			}
		}
		
		protected function twitterReady(event:Event):void
		{
			_twitter.request("/1.1/followers/list.json?cursor=-1&screen_name=jimmykimmel&count=200");
		}
	}
}