package view
{
	import com.twitter.api.Twitter;
	
	import flash.display.MovieClip;
	
	import de.danielyan.twitterAppOnly;
	
	public class TwitterTest extends MovieClip
	{
		private var twitter:Twitter;
		
		public function TwitterTest():void {
			
			init();
		}
		
		private function init():void
		{
			twitter = new Twitter();
			twitter.setAuthenticationCredentials("growch", "gooch75");
//			twitter.loadFollowersIds("growch");
			twitter.loadFriendsIds("growch");
		}		

	}
}