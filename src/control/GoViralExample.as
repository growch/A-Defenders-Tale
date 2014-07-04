package  control
{
import com.milkmangames.nativeextensions.events.*;
import com.milkmangames.nativeextensions.*;
import flash.display.*
import flash.events.*;
import flash.filters.*;
import flash.geom.*
import flash.text.*;

/** GoViralExample App */
public class GoViralExample extends Sprite
{
	//
	// Definitions
	//
	
	/** CHANGE 'YOUR::APP_ID' TO YOUR FACEBOOK APP ID in quotes! */
	//public static const FACEBOOK_APP_ID:String="12345678900";
	public static const FACEBOOK_APP_ID:String="351887674885054";

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
				log("Facebook Initialized! GoViral v"+GoViral.VERSION);
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

		showMainUI();
	}

	// Examples of using Facebook methods
	
	/** Login to facebook */
	private function loginFacebook():void
	{
		log("Login with facebook...");
		if(!GoViral.goViral.isFacebookAuthenticated())
		{
			GoViral.goViral.authenticateWithFacebook();

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
		var newPerms:String="email";
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
	
	/** Logout of facebook */
	private function logoutFacebook():void
	{
		log("logout facebook.");
		GoViral.goViral.logoutFacebook();
	}
	
	/** Stage a Facebook Image */
	private function stageFacebookImage():void
	{

		log("Staging image...");
		var bitmapData:BitmapData=getOrCreateBitmapData();
		GoViral.goViral.stageFacebookImage(bitmapData).addRequestListener(function(e:GVFacebookEvent):void{
			log("Image staged result:"+e.jsonData);
		});

	}
	
	/** Share an Open Graph Object with the native Open Graph Action Dialog */
	private function facebookOpenGraphDialog():void
	{
		if (!GoViral.goViral.isFacebookGraphDialogAvailable())
		{
			log("Graph Action Dialog not available - update Facebook app or use classic dialog!");
			return;
		}
		
		var bitmapData:BitmapData=getOrCreateBitmapData();
		
		log("Submitting graph action dialog..");
		GoViral.goViral.showFacebookGraphDialog(
			"mmg_sample:testaction", 
			"mmg_sample:testobject", 
			"Graph Action Title", 
			"Graph Action Description",
			"http://www.milkmangames.com", 
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
		var canUseShareDialog:Boolean=GoViral.goViral.isFacebookShareDialogAvailable();
		
		GoViral.goViral.showFacebookShareDialog(
		"Posting from GoViral v4", 
		"This is the caption!", 
		"This is the description. ", 
		"http://www.milkmangames.com", 
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
			
		// the extension will have automatically defaulted to the classic 'feed' dialog, if share dialog was not available.
		if (!canUseShareDialog)
		{
			log("Native Sharing was not available.  Used Feed Dialog instead.");
		}
	}
	
	/** Post to the facebook wall / feed via the classic web dialog.  The native dialog is now preferred if available. */
	private function postOldFeedDialog():void
	{
		log("posting fb feed dialog....");
		GoViral.goViral.showFacebookFeedDialog(
			"Posting from AIR",
			"This is a caption",
			"This is a message!",
			"This is a description",
			"http://www.milkmangames.com",
			"http://www.milkmangames.com/gvremoteimage.jpg",
			{actions:{name:"Google",link:"http://www.google.com"}}
		).addDialogListener(function(e:GVFacebookEvent):void {
			trace("oldfeed.response");
				switch(e.type)
				{
					case GVFacebookEvent.FB_DIALOG_CANCELED:
						log("The Feed Dialog was canceled.");
						break;
					case GVFacebookEvent.FB_DIALOG_FAILED:
						log("The Feed Dialog has failed:"+e.errorMessage);
						break;
					case GVFacebookEvent.FB_DIALOG_FINISHED:
						log("Successfully posted to Feed dialog:"+e.jsonData);
						break;
				}
			});

	}
	
	/** Request friends using the deprecated/unsupported v1 graph api */
	private function getFriendsDEPRECATED():void
	{
		log("Getting v1 friends...");
		
		GoViral.goViral.facebookGraphRequest("me/friends",GVHttpMethod.GET,null,null,true).addRequestListener(function(e:GVFacebookEvent):void {
			if (e.type==GVFacebookEvent.FB_REQUEST_RESPONSE)
			{
				var allFriends:String="";
				for each(var friend:GVFacebookFriend in e.friends)
				{
					allFriends+=","+friend.name;
				}
					
				log("DEPRECATED"+"-= ("+e.friends.length+")="+allFriends+",json="+e.jsonData);
			}
			else
			{
				log("The v1 friends request failed:"+e.errorMessage);
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
					"',location='"+myProfile.locationName+
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
		GoViral.goViral.postFacebookHighScore(9452042).addRequestListener(function(e:GVFacebookEvent):void{
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
		GoViral.goViral.facebookGraphRequest("me/scores").addRequestListener(function(e:GVFacebookEvent):void {
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
		GoViral.goViral.facebookGraphRequest(FACEBOOK_APP_ID+"/scores").addRequestListener(function(e:GVFacebookEvent):void {
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
	
	/** Make a post graph request */
	private function postGraphFacebook():void
	{		
		// here we send a post directly to the feed without user interaction.
		var params:Object={};
		params.name="Name Test";
		params.caption="Caption Test";
		params.link="http://www.milkmangames.com";
		params.actions=new Array();
		params.actions.push({name:"Link NOW!", link:"http://www.google.com"});

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
	
	/** Show a facebook friend invite dialog */
	private function inviteFriendsFacebook():void
	{
		log("inviting friends...");
		
		GoViral.goViral.showFacebookRequestDialog(
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
			"http://www.milkmangames.com").addDialogListener(function(e:GVShareEvent):void {
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
			"http://www.milkmangames.com").addDialogListener(function(e:GVShareEvent):void {
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
			"http://www.milkmangames.com")..addDialogListener(function(e:GVShareEvent):void {
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
			"http://www.milkmangames.com").addDialogListener(function(e:GVShareEvent):void {
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
			false).addDialogListener(function(e:GVShareEvent):void {
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
					"], profile permission?"+GoViral.goViral.isFacebookPermissionGranted("public_profile"));
				break;
			case GVFacebookEvent.FB_LOGGED_OUT:
				log("Logged out of facebook.");
				break;
			case GVFacebookEvent.FB_LOGIN_CANCELED:
				log("Canceled facebook login.");
				break;
			case GVFacebookEvent.FB_LOGIN_FAILED:
				log("Login failed:"+e.errorMessage+",sn?"+e.shouldNotifyFacebookUser+",cat?"+e.facebookErrorCategoryId);
				break;
			case GVFacebookEvent.FB_PUBLISH_PERMISSIONS_FAILED:
			case GVFacebookEvent.FB_READ_PERMISSIONS_FAILED:
				log("perms failed:"+e.errorMessage+",sn?"+e.shouldNotifyFacebookUser+",cat?"+e.facebookErrorCategoryId+","+e.permissions);
				break;
			case GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED:
			case GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED:
				log("Perms updated:"+e.permissions);
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
		txtStatus.width=768;
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
		
		var uiRect:Rectangle=new Rectangle(0,0,768,1024);
		var layout:ButtonLayout=new ButtonLayout(uiRect,14);
		layout.addButton(new Button(new Command("Send Test Email",sendTestEmail)));
		layout.addButton(new Button(new Command("Send Pic Email",sendImageEmail)));		
		layout.addButton(new Button(new Command("Tweet Msg",postTwitter)));
		layout.addButton(new Button(new Command("Tweet Pic",postTwitterPic)));
		layout.addButton(new Button(new Command("Share Generic",sendGenericMessage)));
		layout.addButton(new Button(new Command("Share Generic Img", sendGenericMessageWithImage)));
		layout.addButton(new Button(new Command("SocialComposer Facebook", socialComposerFacebook)));
		layout.addButton(new Button(new Command("SocialComposer Twitter", socialComposerTwitter)));
		layout.addButton(new Button(new Command("SocialComposer SMS", socialComposerSMS)));
		layout.addButton(new Button(new Command("Facebook Stuff >",showFacebookUI)));
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
		
		var uiRect:Rectangle=new Rectangle(0,0,768,1024);
		var layout:ButtonLayout=new ButtonLayout(uiRect,14);
		layout.addButton(new Button(new Command("Login", loginFacebook)));
		layout.addButton(new Button(new Command("Graph Action Dialog", facebookOpenGraphDialog)));
		layout.addButton(new Button(new Command("Native FB Share", facebookShareDialog)));
		layout.addButton(new Button(new Command("Deprecated Feed Dialog",postOldFeedDialog)));
		layout.addButton(new Button(new Command("List friends", getFriendsFacebook)));
		layout.addButton(new Button(new Command("List Friends DEPRECATED", getFriendsDEPRECATED)));
		layout.addButton(new Button(new Command("My profile", getMeFacebook)));
		layout.addButton(new Button(new Command("Show Page", showPageOrProfile)));		
		layout.addButton(new Button(new Command("invite friends",inviteFriendsFacebook)));
		layout.addButton(new Button(new Command("Get Token",getFacebookToken)));
		layout.addButton(new Button(new Command("Logout fb", logoutFacebook)));
		layout.addButton(new Button(new Command("Even More Facebook >", showFacebookUI2)));
		layout.addButton(new Button(new Command("< Back",showMainUI)));
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
		
		var uiRect:Rectangle=new Rectangle(0,0,768,1024);
		var layout:ButtonLayout=new ButtonLayout(uiRect,14);

		layout.addButton(new Button(new Command("post photo",postPhotoFacebook)));
		layout.addButton(new Button(new Command("New Read Perms", requestNewReadPermissions)));
		layout.addButton(new Button(new Command("New Publish Perms", requestNewPublishPermissions)));
		layout.addButton(new Button(new Command("Stage Facebook Image", stageFacebookImage)));
		layout.addButton(new Button(new Command("Send Score", submitScoreFacebook)));
		layout.addButton(new Button(new Command("Get my Score", getMyScoreFacebook)));
		layout.addButton(new Button(new Command("Get Leaderboard", getHighScoresFacebook)));
		layout.addButton(new Button(new Command("Direct Feed Post",postGraphFacebook)));
		layout.addButton(new Button(new Command("< Back",showFacebookUI)));
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
		txtLabel.text="This bitmap image was posted by an automated test with the GoViral Native Extension API for Adobe AIR from www.milkmangames.com";
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
class Button extends Sprite
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
	
	/** Create New Button */
	public function Button(cmd:Command)
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
	
	public function addButton(btn:Button):uint
	{
		return buttons.push(btn);
	}
	
	public function attach(parent:DisplayObjectContainer):void
	{
		this.parent=parent;
		for each(var btn:Button in this.buttons)
		{
			parent.addChild(btn);
		}
	}
	
	public function layout():void
	{
		var btnX:Number=rect.x+padding;
		var btnY:Number=rect.y;
		for each( var btn:Button in this.buttons)
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