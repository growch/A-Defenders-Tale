package  control
{
import adobe.utils.CustomActions;
import com.milkmangames.nativeextensions.events.*;
import com.milkmangames.nativeextensions.*;
import flash.display.*
import flash.events.*;
import flash.filters.*;
import flash.geom.*
import flash.text.*;
import flash.utils.ByteArray;

/** GoViralExample App */
public class GoViralExample extends Sprite
{
	//
	// Definitions
	//
	
	/** CHANGE 'YOUR::APP_ID' TO YOUR FACEBOOK APP ID in quotes! */
	//public static const FACEBOOK_APP_ID:String="12345678900";
	public static const FACEBOOK_APP_ID:String=YOUR::APP_ID;

	//
	// Instance Variables
	//
	
	/** Status */
	private var txtStatus:TextField;
	
	/** Buttons */
	private var buttonContainer:Sprite;
	
	/** My Profile */
	private var myProfile:GVFacebookFriend;
	
	//
	// Public Methods
	//
	
	/** Create New GoViralExample */
	public function GoViralExample() 
	{		
		createUI();		
		log("Started GoViral Example.");
		init();

	}

	
	/** Init */
	public function init():void
	{
		// check if GoViral is supported on the machine currently running it
		if (!GoViral.isSupported())
		{
			log("Extension is not supported on this platform.");
			return;
		}

		GoViral.create();
	
		log("GoViral Extension Initialized: "+GoViral.VERSION);

		// initialize facebook.		
		// this is to make sure you remembered to put in your app ID !
		if (FACEBOOK_APP_ID=="YOUR_FACEBOOK_APP_ID")
		{
			log("You forgot to put in Facebook ID!");
		}
		else
		{
			if (!GoViral.goViral.isFacebookSupported())
			{
				log("Sorry, this device does not support Facebook with Adobe AIR.  You can get around this by compiling on a mac with instructions from https://bugbase.adobe.com/index.cfm?event=bug&id=3686856");
			}
			else
			{
				log("Initializing facebook...");
				GoViral.goViral.initFacebook(FACEBOOK_APP_ID, "");
				log("Facebook Initialized! GoViral v"+GoViral.VERSION+"/"+GoViral.goViral.isFacebookAuthenticated());
			}
		}
		
		
		// set up all the event listeners.
		// you only need the ones for the services you want to use.
		
		// facebook events
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);
		
		// facebook events for manually updating permissions
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED, onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED, onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_FAILED, onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_PUBLISH_PERMISSIONS_FAILED, onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_PERMISSIONS_REFRESHED, onFacebookEvent);
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_PERMISSIONS_REFRESH_FAILED, onFacebookEvent);
		
		// facebook event for incoming App Invites
		GoViral.goViral.addEventListener(GVFacebookEvent.FB_APP_INVITE_OPENED, onFacebookEvent);

		showMainUI();
	}

	// Examples of using Facebook methods
	
	/** Login to facebook */
	private function loginFacebook():void
	{
		log("Login with facebook...");
		if(!GoViral.goViral.isFacebookAuthenticated())
		{
			GoViral.goViral.authenticateWithFacebook("public_profile,user_games_activity");

			log("Waiting for login response...");
		}
		else
		{
			log("done (already authenticated)");
		}
		
	}
	
	/** Request New Read Permissions */
	private function requestNewReadPermissions():void
	{
		var newPerms:String="user_friends";
		log("Requesting new permission '"+newPerms+"'...");
		GoViral.goViral.requestNewFacebookReadPermissions(newPerms);
	}
	
	/** Request New Publish Permissions */
	private function requestNewPublishPermissions():void
	{
		var newPerms:String="publish_actions";
		log("Requesting new permission '"+newPerms+"'...");
		GoViral.goViral.requestNewFacebookPublishPermissions(newPerms);
	}
	
	/** Refresh Session Permissions */
	private function refreshSessionPermissions():void
	{
		log("Refreshing session permissions...");
		GoViral.goViral.refreshFacebookSessionPermissions();
	}
	
	/** Logout of facebook */
	private function logoutFacebook():void
	{
		log("logout facebook.");
		GoViral.goViral.logoutFacebook();
	}

	
	/** Share an Open Graph Object with the native Open Graph Action Dialog */
	private function facebookOpenGraphDialog():void
	{
		var bitmapData:BitmapData=getOrCreateBitmapData();		
		
		log("Submitting graph action dialog.....");		

		GoViral.goViral.showFacebookGraphDialog(
			"mmg_goviral:test_action", 
			"mmg_goviral:test_object", 
			"Graph Action Title", 
			"Graph Action Description",
			"https://www.milkmanplugins.com", 
			bitmapData).addDialogListener(function(e:GVFacebookEvent):void {
				switch(e.type)
				{
					case GVFacebookEvent.FB_DIALOG_CANCELED:
						log("The Graph Dialog was canceled.");
						break;
					case GVFacebookEvent.FB_DIALOG_FAILED:
						log("The Graph Dialog has failed:"+e.errorMessage);
						break;
					case GVFacebookEvent.FB_DIALOG_FINISHED:
						log("Successfully posted to graph dialog:"+e.jsonData);
						break;
				}
			});
	}
	
	/** Share with the Native FacebookShare Dialog */
	private function facebookShareDialog():void
	{

		GoViral.goViral.showFacebookShareDialog(
		"Posting from GoViral v5", 
		"This is the description. ", 
		"https://www.milkmanplugins.com",
		"http://www.milkmangames.com/gvremoteimage.jpg").addDialogListener(function(e:GVFacebookEvent):void {
				switch(e.type)
				{
					case GVFacebookEvent.FB_DIALOG_CANCELED:
						log("The Share Dialog was canceled.");
						break;
					case GVFacebookEvent.FB_DIALOG_FAILED:
						log("The Share Dialog has failed:"+e.errorMessage);
						break;
					case GVFacebookEvent.FB_DIALOG_FINISHED:
						log("Successfully posted to share dialog:"+e.jsonData);
						break;
				}
			});

	}
	
	/** Share with the Native Facebook Messenger App Dialog */
	private function facebookMessengerDialog():void
	{
		var canUseMessageDialog:Boolean=GoViral.goViral.isFacebookMessageDialogAvailable();
		if (!canUseMessageDialog)
		{
			log("Facebook Messenger is not installed, sorry!");
			return;
		}
		
		GoViral.goViral.showFacebookMessageDialog(
		"Message from GoViral v5", 
		"This is the caption!", 
		"This is the description. ", 
		"https://www.milkmanplugins.com", 
		"http://www.milkmangames.com/gvremoteimage.jpg").addDialogListener(function(e:GVFacebookEvent):void {
				switch(e.type)
				{
					case GVFacebookEvent.FB_DIALOG_CANCELED:
						log("The Messenger Dialog was canceled.");
						break;
					case GVFacebookEvent.FB_DIALOG_FAILED:
						log("The Messenger Dialog has failed:"+e.errorMessage);
						break;
					case GVFacebookEvent.FB_DIALOG_FINISHED:
						log("Successfully posted to messenger dialog:"+e.jsonData);
						break;
				}
			});	

	}
	
	/** Send a Facebook AppInvite */
	private function facebookAppInviteDialog():void
	{
		if (!GoViral.goViral.isFacebookAppInviteDialogAvailable())
		{
			log("App Invite not supported on this device (old OS.)");
			return;
		}
		log("Showing App Invite Dialog...");
		
		GoViral.goViral.showFacebookAppInviteDialog(
			"https://fb.me/715601218545703",
			"http://www.milkmangames.com/gvremoteimage.jpg").addDialogListener(function(e:GVFacebookEvent):void {
				switch(e.type)
				{
					case GVFacebookEvent.FB_DIALOG_CANCELED:
						log("The AppInvite Dialog was canceled .");
						break;
					case GVFacebookEvent.FB_DIALOG_FAILED:
						log("The AppInvite Dialog has failed:"+e.errorMessage);
						break;
					case GVFacebookEvent.FB_DIALOG_FINISHED:
						log("Successfully posted to AppInvite dialog:"+e.jsonData);
						break;
				}				
			});
	
	}
	
	/** Get a list of all your facebook friends */
	private function getFriendsFacebook():void
	{
		log("getting friends with app...");
		
		GoViral.goViral.requestFacebookFriends().addRequestListener(function(e:GVFacebookEvent):void {
			if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
			{
				var allFriends:String="";
				for each(var friend:GVFacebookFriend in e.friends)
				{
					allFriends+=","+friend.name;
				}
					
				log(e.graphPath+"-= ("+e.friends.length+")="+allFriends+",json="+e.jsonData);
			}
			else
			{
				log("The friends request failed:"+e.errorMessage);
			}
		});

	}

	/** Get your own facebook profile */
	private function getMeFacebook():void
	{
		log("Getting profile...");
		
		GoViral.goViral.requestMyFacebookProfile().addRequestListener(function(e:GVFacebookEvent):void {
			if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
			{
				var myProfile:GVFacebookFriend=e.friends[0];
				log("My Profile: "+myProfile.id+
					", name='"+myProfile.name+
					"',gender='"+myProfile.gender+
					"',bio='"+myProfile.bio+"'");
					
				this.myProfile=myProfile;
			}
			else
			{
				log("profile failed:"+e.errorMessage);
			}
		});
	}
	
	/** Get Facebook Access Token */
	private function getFacebookToken():void
	{
		log("Retrieving access token...");
		
		var accessToken:String=GoViral.goViral.getFbAccessToken();
		var accessExpiry:Number=GoViral.goViral.getFbAccessExpiry();
		var expiryDate:Date=new Date();
		expiryDate.setTime(accessExpiry);
		expiryDate=(accessExpiry==0)?null:expiryDate;
		
		log("auth is:"+GoViral.goViral.isFacebookAuthenticated()+",expiry:"+accessExpiry+"("+expiryDate+"),token: "+accessToken);
	}


	/** Submit Score */
	private function submitScoreFacebook():void
	{

		
		log("Submitting score...");
		GoViral.goViral.postFacebookHighScore(9452099).addRequestListener(function(e:GVFacebookEvent):void{
			if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
			{
				log("Score submitted!");
			}
			else
			{
				log("Score post failed: "+e.errorMessage);
			}
		});
	}
	
	/** Get My Score Facebook */
	private function getMyScoreFacebook():void
	{
		log("Getting high score...");
		GoViral.goViral.facebookGraphRequest("me/scores",
			GVHttpMethod.GET,
			{fields:"score"})
			.addRequestListener(function(e:GVFacebookEvent):void {
				if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
				{
					log("Got score data! "+e.jsonData);
				}
				else
				{
					log("Error getting score: "+e.errorMessage);
				}
		});
	}
	
	/** Get High Scores Facebook */
	private function getHighScoresFacebook():void
	{
		log("Getting high scores...");
		GoViral.goViral.facebookGraphRequest(FACEBOOK_APP_ID+"/scores",
			GVHttpMethod.GET,
			{fields:"score"})
			.addRequestListener(function(e:GVFacebookEvent):void {
				if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
				{
					log("Got scores data! "+e.jsonData);
				}
				else
				{
					log("Error getting scores: "+e.errorMessage);
				}
		});
	}
	
	/** Test what happens when a graph request fails */
	private function testFailingGraphRequest():void
	{
		log("Starting a bad test request...");
		GoViral.goViral.facebookGraphRequest("me/bananas").addRequestListener(function(e:GVFacebookEvent):void {
			if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
			{
				log("Test request success, uhoh! "+e.jsonData);
			}
			else
			{
				log("Bad Request error: "+e.errorMessage);
			}
		});
	
	}
	
	
	/** Make a post graph request */
	private function postGraphFacebook():void
	{		
		// here we send a post directly to the feed without user interaction.
		var params:Object={};
		params.name="Name Test";
		params.caption="Caption Test";
		params.link="https://www.milkmanplugins.com";

		GoViral.goViral.facebookGraphRequest(
			"me/feed",
			GVHttpMethod.POST,
			params,
			"publish_actions").addRequestListener(function(e:GVFacebookEvent):void {
				if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
				{
					log("Successfully posted to feed: "+e.jsonData);
				}
				else
				{
					log("An error occurred posting : "+e.errorMessage);
				}
			});
		
	}
	
	/** Show a facebook game request dialog */
	private function gameRequestFacebook():void
	{
		log("inviting friends..");
		
		
		GoViral.goViral.showFacebookGameRequestDialog(
		"Play my game",
		"Play this game with me!").addDialogListener(function(e:GVFacebookEvent):void {
				switch(e.type)
				{
					case GVFacebookEvent.FB_DIALOG_CANCELED:
						log("The Invite Dialog was canceled.");
						break;
					case GVFacebookEvent.FB_DIALOG_FAILED:
						log("The Invite Dialog has failed:"+e.errorMessage);
						break;
					case GVFacebookEvent.FB_DIALOG_FINISHED:
						log("Successfully invited friends dialog:"+e.jsonData);
						if(e.data.to)
						{
							log("Invited these people :"+e.data.to.join(","));
						}
						break;
				}
			});
	}
	
	/** Post a photo to the facebook stream */
	private function postPhotoFacebook():void
	{
		log("post facebook photo...");
		var bitmapData:BitmapData=getOrCreateBitmapData();

		GoViral.goViral.facebookPostPhoto("posted from AIR sdk", bitmapData).addRequestListener(function(e:GVFacebookEvent):void {
			if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
			{
				log("Posted photo! "+e.jsonData);
			}
			else
			{
				log("Photo request failed:"+e.errorMessage);
			}
		});
	}	
	
	/** Show Page or Profile */
	private function showPageOrProfile():void
	{
		log("Showing page...");
		GoViral.goViral.presentFacebookPageOrProfile("215322531827565");
		log("Did show page.");
	}
	
	/** Get Facebook AD ID */
	private function getFacebookMobileAdID():void
	{
		log("Getting mobile ad id...");
		GoViral.goViral.requestFacebookMobileAdID().addAdIdListener(function(e:GVFacebookEvent):void {
			log("Facebook ad id result:"+e.facebookMobileAdId);
		});		
	}
	
	/** Check you're logged in to facebook before doing anything else. */
	private function checkLoggedInFacebook():Boolean
	{
		// make sure you're logged in first
		if (!GoViral.goViral.isFacebookAuthenticated())
		{
			log("Not logged in!");
			return false;
		}
		return true;
		
	}
	
	// Email
	
	/** Send Test Email */
	private function sendTestEmail():void
	{
		if (!GoViral.goViral.isEmailAvailable())
		{
			log("Email is not enabled on device.");
			return;
		}
		log("Opening email composer...");
		GoViral.goViral.showEmailComposer(
		"This is a subject!",
		"who@where.com,john@doe.com",
		"This is the body of the message.", false).addDialogListener(function(e:GVMailEvent):void {
			switch(e.type)
			{
				case GVMailEvent.MAIL_SENT:
					log("Mail sent!");
					break;
				case GVMailEvent.MAIL_SAVED:
					log("Mail saved.");
					break;
				case GVMailEvent.MAIL_CANCELED:
					log("Mail canceled.");
					break;
				case GVMailEvent.MAIL_FAILED:
					log("Failed sending mail.");
					break;
			}
		});
		log("Email Composer opened.");
	}
	
	/** Send Html Email */
	private function sendHtmlTestEmail():void
	{
		if (!GoViral.goViral.isEmailAvailable())
		{
			log("Email is not enabled on device.");
			return;
		}
		log("Opening email composer...");
		
		var msgBody:String='<html><p>Heres a <a href="https://www.milkmanplugins.com">LINK.</a></p></html>';
		
		GoViral.goViral.showEmailComposer(
		"This is a subject!",
		"who@where.com,john@doe.com",
		msgBody, true).addDialogListener(function(e:GVMailEvent):void {
			switch(e.type)
			{
				case GVMailEvent.MAIL_SENT:
					log("Mail sent!");
					break;
				case GVMailEvent.MAIL_SAVED:
					log("Mail saved.");
					break;
				case GVMailEvent.MAIL_CANCELED:
					log("Mail canceled.");
					break;
				case GVMailEvent.MAIL_FAILED:
					log("Failed sending mail.");
					break;
			}
		});
		log("Email Composer opened.");
	}
	
	/** Send Email with attached image */
	public function sendImageEmail():void
	{
		if (!GoViral.goViral.isEmailAvailable())
		{
			log("Email is not enabled on device.");
			return;
		}
		
		var bitmapData:BitmapData=getOrCreateBitmapData();
		log("Email composer w/image...");

		GoViral.goViral.showEmailComposerWithBitmap(
			"This has an attachment!",
			"john@doe.com",
			"I think youll like my pic",
			false,
			bitmapData).addDialogListener(function(e:GVMailEvent):void {
			switch(e.type)
			{
				case GVMailEvent.MAIL_SENT:
					log("Mail sent!");
					break;
				case GVMailEvent.MAIL_SAVED:
					log("Mail saved.");
					break;
				case GVMailEvent.MAIL_CANCELED:
					log("Mail canceled.");
					break;
				case GVMailEvent.MAIL_FAILED:
					log("Failed sending mail.");
					break;
			}
		});

		log("Email Composer Opened.");
	}
	
	/** Send Email with attached Byte Array */
	public function sendByteArrayEmail():void
	{
		if (!GoViral.goViral.isEmailAvailable())
		{
			log("Email is not enabled on device.");
			return;
		}
		
		// we just make a text file for this example.
		var byteArray:ByteArray=new ByteArray();
		
		byteArray.writeUTF("This is the contents of our sample text file attachment!");
		
		log("Email composer w/byteArray...");

		GoViral.goViral.showEmailComposerWithByteArray(
			"This has an attachment!",
			"john@doe.com",
			"I think youll like my text file",
			false,
			byteArray,
			"text/plain",
			"textfile.txt").addDialogListener(function(e:GVMailEvent):void {
			switch(e.type)
			{
				case GVMailEvent.MAIL_SENT:
					log("Mail sent!");
					break;
				case GVMailEvent.MAIL_SAVED:
					log("Mail saved.");
					break;
				case GVMailEvent.MAIL_CANCELED:
					log("Mail canceled.");
					break;
				case GVMailEvent.MAIL_FAILED:
					log("Failed sending mail.");
					break;
			}
		});

		log("Email Composer Opened.");
	}
	
	//
	// Social Composer
	
	/** Social Composer Facebook */
	public function socialComposerFacebook():void
	{
		log("Check availability...");
		if (!GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.FACEBOOK))
		{
			log("Facebook service not available.");
			return;

		}
		
		var bitmapData:BitmapData=getOrCreateBitmapData();
		
		log("Showing composer...");
		GoViral.goViral.displaySocialComposerView(
			GVSocialServiceType.FACEBOOK, 
			"Hello facebook!",
			bitmapData, 
			"https://www.milkmanplugins.com").addDialogListener(function(e:GVShareEvent):void {
				switch(e.type)
				{
					case GVShareEvent.SOCIAL_COMPOSER_FINISHED:
						log("Facebook composer finished!");
						break;
					case GVShareEvent.SOCIAL_COMPOSER_CANCELED:
						log("Facebook composer canceled.");
						break;
				}
			});
		log("did show Facebook composer.");
	}
	
	/** Social Composer Twitter */
	public function socialComposerTwitter():void
	{
		log("Check availability...");
		if (!GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.TWITTER))
		{
			log("Twitter service not available.");
			return;
		}
		
		var bitmapData:BitmapData=getOrCreateBitmapData();
		
		log("Showing composer...");
		GoViral.goViral.displaySocialComposerView(
			GVSocialServiceType.TWITTER, 
			"Hello twitter with pic!", 
			bitmapData, 
			"https://www.milkmanplugins.com").addDialogListener(function(e:GVShareEvent):void {
				switch(e.type)
				{
					case GVShareEvent.SOCIAL_COMPOSER_FINISHED:
						log("Twitter composer finished!");
						break;
					case GVShareEvent.SOCIAL_COMPOSER_CANCELED:
						log("Twitter composer canceled.");
						break;
				}
			});
		log("did show Twitter composer.");
	}
	
	/** Social Composer SMS */
	public function socialComposerSMS():void
	{
		log("Check availability...");
		if (!GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.SMS))
		{
			log("SMS service not available.");
			return;
		}
		
		var bitmapData:BitmapData=getOrCreateBitmapData();
		
		log("Showing composer...");
		GoViral.goViral.displaySocialComposerView(
			"SMS", 
			"Hello sms msg!", 
			bitmapData,
			"https://www.milkmanplugins.com")..addDialogListener(function(e:GVShareEvent):void {
				switch(e.type)
				{
					case GVShareEvent.SOCIAL_COMPOSER_FINISHED:
						log("SMS composer finished!");
						break;
					case GVShareEvent.SOCIAL_COMPOSER_CANCELED:
						log("SMS composer canceled.");
						break;
				}
			});
			
		log("did show SMS composer.");
	}
	
	/** Social Composer Weibo */
	public function socialComposerWeibo():void
	{
		log("Check availability...");
		if (!GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.SINAWEIBO))
		{
			log("Facebook service not available.");
			return;
		}
		
		log("Showing composer...");
		GoViral.goViral.displaySocialComposerView(
			GVSocialServiceType.SINAWEIBO, 
			"Hello Weibo!", 
			null, 
			"https://www.milkmanplugins.com").addDialogListener(function(e:GVShareEvent):void {
				switch(e.type)
				{
					case GVShareEvent.SOCIAL_COMPOSER_FINISHED:
						log("Weibo composer finished!");
						break;
					case GVShareEvent.SOCIAL_COMPOSER_CANCELED:
						log("Weibo composer canceled.");
						break;
				}
			});
		log("did show Weibo composer.");
	}
	
	//
	// Generic Sharing
	//
	
	/** Send Generic Message */
	public function sendGenericMessage():void
	{
		if (!GoViral.goViral.isGenericShareAvailable())
		{
			log("Generic share doesn't work on this platform.");
			return;
		}
		

		log("Sending generic share intent...");
		GoViral.goViral.shareGenericMessage(
			"The Subject",
			"The message!",
			false,
			350,
			512).addDialogListener(function(e:GVShareEvent):void {
				log("Generic share completed.");
		});
			
		log("Did send generic share intent.");
	}
	
	/** Send Generic Message */
	public function sendGenericMessageWithImage():void
	{
		if (!GoViral.goViral.isGenericShareAvailable())
		{
			log("Generic share doesn't work on this platform.");
			return;
		}
		
		log("Sending generic share img intent...");
		var bitmapData:BitmapData=getOrCreateBitmapData();
		GoViral.goViral.shareGenericMessageWithImage(
			"The Subject",
			"The message!",
			false,
			bitmapData).addDialogListener(function(e:GVShareEvent):void {
				log("Generic share with image completed.");
		});
		
		log("Did send generic share img intent.");
	}	
	
	//
	// twitter
	//
	
	/** Post a status message to Twitter */
	public function postTwitter():void
	{
		log("posting to twitter.");
		
		if (GoViral.goViral.isTweetSheetAvailable())
		{
			GoViral.goViral.showTweetSheet("This is a native twitter post!").addDialogListener(function(e:GVTwitterEvent):void {
				switch(e.type)
				{
					case GVTwitterEvent.TW_DIALOG_FINISHED:
						log("Twitter dialog finished.");
						break;
					case GVTwitterEvent.TW_DIALOG_FAILED:
						log("Twitter dialog failed.");
						break;
					case GVTwitterEvent.TW_DIALOG_CANCELED:
						log("Twitter dialog canceled.");
						break;
				}
			});
			log("Waiting for Twitter response...");
		}
		else
		{
			log("twitter not available>");
			return;
		}
		log("done show tweet.");
	}
	
	/** Post a picture to twitter */
	public function postTwitterPic():void
	{
		log("post twitter pic...");
		
		if (GoViral.goViral.isTweetSheetAvailable())
		{
			var bitmapData:BitmapData=getOrCreateBitmapData();
			GoViral.goViral.showTweetSheetWithImage(
				"This is a twitter post with a pic!",
				bitmapData).addDialogListener(function(e:GVTwitterEvent):void {
				switch(e.type)
				{
					case GVTwitterEvent.TW_DIALOG_FINISHED:
						log("Twitter dialog finished.");
						break;
					case GVTwitterEvent.TW_DIALOG_FAILED:
						log("Twitter dialog failed.");
						break;
					case GVTwitterEvent.TW_DIALOG_CANCELED:
						log("Twitter dialog canceled.");
						break;
				}
			});
			log("Waiting for Twitter response...");
		}
		else
		{
			log("Twitter not available.");
			return;
		}		
	}
	
	/** Show a Twitter Profile */
	private function presentTwitterProfile():void
	{
		log("Showing 'milkmangames' twitter profile...");
		GoViral.goViral.presentTwitterProfile("milkmangames");
		log("Showed twitter profile.");
	}
	
	//
	// Events
	//
	
	/** Handle Facebook Event */
	private function onFacebookEvent(e:GVFacebookEvent):void
	{
		switch(e.type)
		{
			case GVFacebookEvent.FB_LOGGED_IN:
				log("Logged in to facebook:"+GoViral.VERSION+
					",denied: ["+GoViral.goViral.getDeclinedFacebookPermissions()+
					"], user_friends permission?"+GoViral.goViral.isFacebookPermissionGranted("user_friends"));
				break;
				
			case GVFacebookEvent.FB_LOGGED_OUT:
				logStatus("[..Logged out of facebook.]");
				break;
				
			case GVFacebookEvent.FB_LOGIN_CANCELED:
				log("Canceled facebook login.");
				break;
				
			case GVFacebookEvent.FB_LOGIN_FAILED:
				log("Login failed:"+e.errorMessage+",sn?"+e.shouldNotifyFacebookUser+", code?"+e.errorCode);
				break;
				
			case GVFacebookEvent.FB_PUBLISH_PERMISSIONS_FAILED:
			case GVFacebookEvent.FB_READ_PERMISSIONS_FAILED:
				log("perms failed:"+e.errorMessage+",sn?"+e.shouldNotifyFacebookUser+",code?"+e.errorCode+","+e.permissions+", uf="+GoViral.goViral.isFacebookPermissionGranted("user_friends"));
				break;
				
			case GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED:
			case GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED:
				log("Perms updated:"+e.permissions+", uf="+GoViral.goViral.isFacebookPermissionGranted("user_friends"));
				break;
				
			case GVFacebookEvent.FB_PERMISSIONS_REFRESHED:
				log("Perms refreshed, now:"+e.permissions+",uf="+GoViral.goViral.isFacebookPermissionGranted("user_friends"));
				break;
				
			case GVFacebookEvent.FB_PERMISSIONS_REFRESH_FAILED:
				log("Refresh permission failed:"+e.errorMessage+",sn?"+e.shouldNotifyFacebookUser+",code?"+e.errorCode+","+e.permissions+", uf="+GoViral.goViral.isFacebookPermissionGranted("user_friends"));
				break;
			case GVFacebookEvent.FB_APP_INVITE_OPENED:
				log("App Invite OPENED! :"+e.appInviteURL);
				break;
		}
	}	

	//
	// Impelementation
	// Code below creates the UI for the test harness.
	//
	
	/** Log */
	private function log(msg:String):void
	{
		trace("[GoViralExample] "+msg);
		txtStatus.text=msg;
	}
	

	
	private function logStatus(msg:String):void
	{
		txtStatus.appendText("-"+msg);
	}
	
	/** Create UI */
	public function createUI():void
	{
		txtStatus=new TextField();
		
		txtStatus.defaultTextFormat=new flash.text.TextFormat("Arial",19);
		txtStatus.width=stage.stageWidth;
		txtStatus.multiline=true;
		txtStatus.wordWrap=true;
		txtStatus.text="Ready";
		txtStatus.y=txtStatus.textHeight;
		//txtStatus.height=1000;
		txtStatus.mouseEnabled=false;
		txtStatus.type=TextFieldType.DYNAMIC;
		
		addChild(txtStatus);
	}
	
	/** Show Main Menu */
	public function showMainUI():void
	{
		if (buttonContainer)
		{
			removeChild(buttonContainer);
			buttonContainer=null;
		}
		
		buttonContainer=new Sprite();
		buttonContainer.y=txtStatus.height;
		addChild(buttonContainer);
		
		var uiRect:Rectangle=new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
		var layout:ButtonLayout=new ButtonLayout(uiRect,14);
		layout.addButton(new SimpleButton(new Command("Send Test Email",sendTestEmail)));
		layout.addButton(new SimpleButton(new Command("Send Pic Email", sendImageEmail)));	
		layout.addButton(new SimpleButton(new Command("Send HTML Email", sendHtmlTestEmail)));
		layout.addButton(new SimpleButton(new Command("Send ByteArray Email", sendByteArrayEmail)));
		layout.addButton(new SimpleButton(new Command("Tweet Msg",postTwitter)));
		layout.addButton(new SimpleButton(new Command("Tweet Pic", postTwitterPic)));
		layout.addButton(new SimpleButton(new Command("Show Twitter Profile", presentTwitterProfile)));
		layout.addButton(new SimpleButton(new Command("Share Generic",sendGenericMessage)));
		layout.addButton(new SimpleButton(new Command("Share Generic Img", sendGenericMessageWithImage)));
		layout.addButton(new SimpleButton(new Command("SocialComposer Facebook", socialComposerFacebook)));
		layout.addButton(new SimpleButton(new Command("SocialComposer Twitter", socialComposerTwitter)));
		layout.addButton(new SimpleButton(new Command("SocialComposer SMS", socialComposerSMS)));
		layout.addButton(new SimpleButton(new Command("Facebook Stuff >",showFacebookUI)));
		layout.attach(buttonContainer);
		layout.layout();	
	}
	
	/** Show Facebook Menu */
	public function showFacebookUI():void
	{
		// make sure facebook is set up first
		if (FACEBOOK_APP_ID=="YOUR_FACEBOOK_APP_ID")
		{
			log("You forgot to put in Facebook ID!");
			return;
		}
		
		if (buttonContainer)
		{
			removeChild(buttonContainer);
			buttonContainer=null;
		}
		
		buttonContainer=new Sprite();
		buttonContainer.y=txtStatus.height;
		addChild(buttonContainer);
		
		var uiRect:Rectangle=new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
		var layout:ButtonLayout=new ButtonLayout(uiRect,14);
		layout.addButton(new SimpleButton(new Command("Login", loginFacebook)));
		layout.addButton(new SimpleButton(new Command("Graph Action Dialog", facebookOpenGraphDialog)));
		layout.addButton(new SimpleButton(new Command("Native FB Share", facebookShareDialog)));
		layout.addButton(new SimpleButton(new Command("Messenger Dialog", facebookMessengerDialog)));
		layout.addButton(new SimpleButton(new Command("App Invite Dialog", facebookAppInviteDialog)));
		layout.addButton(new SimpleButton(new Command("List friends", getFriendsFacebook)));
		layout.addButton(new SimpleButton(new Command("My profile", getMeFacebook)));
		layout.addButton(new SimpleButton(new Command("Show Page", showPageOrProfile)));		
		layout.addButton(new SimpleButton(new Command("GameRequest dialog",gameRequestFacebook)));
		layout.addButton(new SimpleButton(new Command("Get Token",getFacebookToken)));
		layout.addButton(new SimpleButton(new Command("Logout fb", logoutFacebook)));
		layout.addButton(new SimpleButton(new Command("Even More Facebook >", showFacebookUI2)));
		layout.addButton(new SimpleButton(new Command("< Back",showMainUI)));
		layout.attach(buttonContainer);
		layout.layout();	
	}
	
	/** Show Facebook Menu 2 */
	public function showFacebookUI2():void
	{
		// make sure facebook is set up first
		if (FACEBOOK_APP_ID=="YOUR_FACEBOOK_APP_ID")
		{
			log("You forgot to put in Facebook ID!");
			return;
		}
		
		if (buttonContainer)
		{
			removeChild(buttonContainer);
			buttonContainer=null;
		}
		
		buttonContainer=new Sprite();
		buttonContainer.y=txtStatus.height;
		addChild(buttonContainer);
		
		var uiRect:Rectangle=new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
		var layout:ButtonLayout=new ButtonLayout(uiRect,14);

		layout.addButton(new SimpleButton(new Command("post photo",postPhotoFacebook)));
		layout.addButton(new SimpleButton(new Command("New Read Perms", requestNewReadPermissions)));
		layout.addButton(new SimpleButton(new Command("New Publish Perms", requestNewPublishPermissions)));
		layout.addButton(new SimpleButton(new Command("Refresh Permissions", refreshSessionPermissions)));
		layout.addButton(new SimpleButton(new Command("Send Score", submitScoreFacebook)));
		layout.addButton(new SimpleButton(new Command("Get my Score", getMyScoreFacebook)));
		layout.addButton(new SimpleButton(new Command("Get Leaderboard", getHighScoresFacebook)));
		layout.addButton(new SimpleButton(new Command("Direct Feed Post", postGraphFacebook)));
		layout.addButton(new SimpleButton(new Command("Get FB Mobile AD ID", getFacebookMobileAdID)));
		layout.addButton(new SimpleButton(new Command("Test Bad Request", testFailingGraphRequest)));
		layout.addButton(new SimpleButton(new Command("< Back",showFacebookUI)));
		layout.attach(buttonContainer);
		layout.layout();	
	}
	
	/** Get or Create BitmapData */
	/** Get or Create BitmapData */
	private var myBitmapData:BitmapData;
	private function getOrCreateBitmapData():BitmapData
	{
		if (myBitmapData!=null)
		{
			return myBitmapData;
		}
		
		var canvas:Sprite=new Sprite();
		var matrix:Matrix=new Matrix();
		matrix.createGradientBox(1000, 750, Math.PI*.5, 0, 0);
		canvas.graphics.lineStyle(7, 0x171717);
		canvas.graphics.beginGradientFill(GradientType.LINEAR, [0x626262,0x232323,0], [1,1, 1], [0, 100, 255],matrix);
		canvas.graphics.drawRoundRect(4, 4, 952, 632,90,90);
		canvas.graphics.endFill();
		
		canvas.graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0x333333], [1, 1], [0, 255], matrix);
		canvas.graphics.drawCircle(480, 320, 200);
		canvas.graphics.endFill();
		
		canvas.graphics.beginGradientFill(GradientType.LINEAR, [0xC83F37, 0x6B1414], [1, 1], [0, 255], matrix);
		canvas.graphics.drawCircle(480, 320, 80);
		canvas.graphics.endFill();
		
		var txtLabel:TextField=new TextField();
		txtLabel.defaultTextFormat=new TextFormat("Arial", 42, 0xffffff,true,false,false,null,null,"center");
		txtLabel.text="This bitmap image was posted by an automated test with the GoViral Native Extension API for Adobe AIR from www.milkmanplugins.com";
		txtLabel.filters=[new DropShadowFilter(2, 45, 0, 1, 4, 4, 1, 4, false, false)];

		txtLabel.width=960;
		txtLabel.height=640;
		txtLabel.multiline=true;
		txtLabel.wordWrap=true;
		txtLabel.x=canvas.width*.5-txtLabel.width*.5;
		txtLabel.y=canvas.height*.35;
		canvas.addChild(txtLabel);
		
		myBitmapData=new BitmapData(960, 640, false, 0xffffffff);
		myBitmapData.draw(canvas);
		return myBitmapData;
	}	
}
}


//
// Code Below is generic code for building UI
//


import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

/** Simple Button */
class SimpleButton extends Sprite
{
	//
	// Instance Variables
	//
	
	/** Command */
	private var cmd:Command;
	
	/** Width */
	private var _width:Number;
	
	/** Label */
	private var txtLabel:TextField;
	
	//
	// Public Methods
	//
	
	/** Create New SimpleButton */
	public function SimpleButton(cmd:Command)
	{
		super();
		this.cmd=cmd;
		
		mouseChildren=false;
		mouseEnabled=buttonMode=useHandCursor=true;
		
		txtLabel=new TextField();
		txtLabel.defaultTextFormat=new TextFormat("Arial",42,0xFFFFFF);
		txtLabel.mouseEnabled=txtLabel.mouseEnabled=txtLabel.selectable=false;
		txtLabel.text=cmd.getLabel();
		txtLabel.autoSize=TextFieldAutoSize.LEFT;
		
		redraw();
		
		addEventListener(MouseEvent.CLICK,onSelect);
	}
	
	/** Set Width */
	override public function set width(val:Number):void
	{
		this._width=val;
		redraw();
	}

	
	/** Dispose */
	public function dispose():void
	{
		removeEventListener(MouseEvent.CLICK,onSelect);
	}
	
	//
	// Events
	//
	
	/** On Press */
	private function onSelect(e:MouseEvent):void
	{
		this.cmd.execute();
	}
	
	//
	// Implementation
	//
	
	/** Redraw */
	private function redraw():void
	{		
		txtLabel.text=cmd.getLabel();
		_width=_width||txtLabel.width*1.1;
		
		graphics.clear();
		graphics.beginFill(0x444444);
		graphics.lineStyle(2,0);
		graphics.drawRoundRect(0,0,_width,txtLabel.height*1.1,txtLabel.height*.4);
		graphics.endFill();
		
		txtLabel.x=_width/2-(txtLabel.width/2);
		txtLabel.y=txtLabel.height*.05;
		addChild(txtLabel);
	}
}

/** Button Layout */
class ButtonLayout
{
	private var buttons:Array;
	private var rect:Rectangle;
	private var padding:Number;
	private var parent:DisplayObjectContainer;
	
	public function ButtonLayout(rect:Rectangle,padding:Number)
	{
		this.rect=rect;
		this.padding=padding;
		this.buttons=new Array();
	}
	
	public function addButton(btn:SimpleButton):uint
	{
		return buttons.push(btn);
	}
	
	public function attach(parent:DisplayObjectContainer):void
	{
		this.parent=parent;
		for each(var btn:SimpleButton in this.buttons)
		{
			parent.addChild(btn);
		}
	}
	
	public function layout():void
	{
		var btnX:Number=rect.x+padding;
		var btnY:Number=rect.y;
		for each( var btn:SimpleButton in this.buttons)
		{
			btn.width=rect.width-(padding*2);
			btnY+=this.padding;
			btn.x=btnX;
			btn.y=btnY;
			btnY+=btn.height;
		}
	}
}

/** Inline Command */
class Command
{
	/** Callback Method */
	private var fnCallback:Function;
	
	/** Label */
	private var label:String;
	
	//
	// Public Methods
	//
	
	/** Create New Command */
	public function Command(label:String,fnCallback:Function)
	{
		this.fnCallback=fnCallback;
		this.label=label;
	}
	
	//
	// Command Implementation
	//
	
	/** Get Label */
	public function getLabel():String
	{
		return label;
	}
	
	/** Execute */
	public function execute():void
	{
		fnCallback();
	}
}