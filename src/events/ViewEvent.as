package events {	import flash.events.Event;	/**	 * @author Mark Grochowski	 */	public class ViewEvent extends Event
	{		public static const CLOSE_EMERGENCY_OVERLAY : String = "close_emergency_overlay";		public static const CLOSE_TWITTER_OVERLAY : String = "close_twitter_overlay";		public static const LOGIN_FACEBOOK:String = "login_facebook";		public static const FACEBOOK_LOGGED_IN:String = "facebook_logged_in";		public static const FACEBOOK_DEFENDER_INFO:String = "facebook_defender_info";		public static const FACEBOOK_DEFENDER_FRIENDS:String = "facebook_defender_friends";		public static const FACEBOOK_CONTACT_RESPONSE:String = "facebook_contact_response";		public static const CONTACT_SELECTED:String = "contact_selected";		public static const LOGIN_TWITTER:String = "login_twitter";		public static const TWITTER_NOT_SETUP:String = "twitter_not_setup";		public static const TWITTER_ACCESS_DENIED:String = "twitter_access_denied";		public static const TWITTER_NONEXISTENT_ACCOUNT:String = "twitter_nonexistent_account";		public static const TWITTER_FOLLOWERS_LOAD:String = "twitter_followers_load";		public static const TWITTER_USER_LOAD:String = "twitter_user_load";		public static const SHOW_UNLOCK:String = "show_unlock";		public static const UNLOCK_PURCHASED:String = "unlock_purchased";		public static const UNLOCK_NOT:String = "unlock_not";//		public static const UNLOCK_CANCELLED:String = "unlock_cancelled";		public static const SHOW_PAGE:String = "show_page";		public static const PAGE_ON:String = "page";		public static const DECISION_CLICK:String = "decision_click";		public static const MC_READY:String = "mc_ready";		public static const ASSET_LOADED:String = "asset_loaded";		public static const ASSET_UNLOADED:String = "asset_unloaded";		public static const SAND_GAME_STONE_FOUND:String = "sand_game_stone_found";		public static const SAND_GAME_OWL_SOUND:String = "sand_game_owl_sound";		public static const SAND_GAME_CLICK_SOUND:String = "sand_game_click_sound";		public static const ADD_CONTENTS_PAGE:String = "add_contents_page";		public static const OPEN_GLOBAL_NAV:String = "open_global_nav";		public static const CLOSE_GLOBAL_NAV:String = "close_global_nav";		public static const CLOSE_NAV_DECISION_CLICK:String = "close_nav_decision_click";		public static const GLOBAL_NAV_OPEN:String = "global_nav_open";		public static const GLOBAL_NAV_CLOSED:String = "global_nav_closed";		public static const TAKE_SCREENSHOT:String = "take_screenshot";		public static const REMOVE_SCREENSHOT:String = "remove_screenshot";		public static const DEACTIVATE_OTHER_PAGES:String = "deactivate_other_pages";		public static const MAP_SELECT_ISLAND:String = "map_select_island";		public static const APPLICATION_OPTION_CLICK:String = "application_option_click";		public static const TWITTER_DONE:String = "twitter_done";		public static const FACEBOOK_DONE:String = "facebook_done";		public static const SOCIAL_MESSAGE:String = "social_message";		public static const CLOSE_OVERLAY:String = "close_overlay";		public static const PEEK_NAVIGATION:String = "peek_navigation";				public var data : Object;		private var _type : String;		private var _bubbles : Boolean;		private var _cancelable : Boolean;						public function ViewEvent(type : String, info : Object = null, bubbles : Boolean = false, cancelable : Boolean = false)		{			super( type, bubbles, cancelable );			data = info;			_type = type;			_bubbles = bubbles;			_cancelable = cancelable;		}		override public function clone() : Event		{			return new ViewEvent( _type, data, _bubbles, _cancelable );		} 		}}