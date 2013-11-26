﻿package control {import com.milkmangames.nativeextensions.GVFacebookFriend;import com.milkmangames.nativeextensions.GVHttpMethod;import com.milkmangames.nativeextensions.GVSocialServiceType;import com.milkmangames.nativeextensions.GoViral;import com.milkmangames.nativeextensions.events.GVFacebookEvent;import com.milkmangames.nativeextensions.events.GVMailEvent;import com.milkmangames.nativeextensions.events.GVShareEvent;import com.milkmangames.nativeextensions.events.GVTwitterEvent;import flash.display.Bitmap;import flash.display.MovieClip;import flash.display.Sprite;import flash.events.MouseEvent;import flash.events.TimerEvent;import flash.geom.Rectangle;import flash.text.TextField;import flash.utils.Timer;import events.ApplicationEvent;import events.ViewEvent;import model.DataModel;
/** GoViralExample App */public class GoViralService extends MovieClip{	//	// Definitions	//		/** CHANGE THIS TO YOUR FACEBOOK APP ID! */	public static const FACEBOOK_APP_ID:String="351887674885054";	//	App ID/API Key//	351887674885054//	App Secret//	0454c1ace2245a7f8867eb0d61fd9d75//  Access token//	351887674885054|xkEKjHQGdFOxXIkOcG_WPRmWDmw		/** An embedded image for testing image attachments. *///	[Embed(source="v202.jpg")]	private var testImageClass:Class;	//	// Instance Variables	//	private var _commentLikeTimer:Timer;	private var _timerDelay:Number = 10000;	private var _wallpostID:String;		public var isSupported:Boolean;		/** Status */	private var txtStatus:TextField;		/** Buttons */	private var buttonContainer:Sprite;		//	// Public Methods	//			/** Create New GoViralExample */	public function GoViralService() 	{				createUI();				log("Started GoViral Example.");		init();	}		/** Init */	public function init():void	{		// check if GoViral is supported.  note that this just determines platform support- iOS - and not		// whether the particular version supports it.				if (!GoViral.isSupported())		{			log("Extension is not supported on this platform.");			return;		}				isSupported = true;				log("will create.");				// initialize the extension.		GoViral.create();				log("Extension Initialized.");				// initialize facebook.				// this is to make sure you remembered to put in your app ID !		if (FACEBOOK_APP_ID=="YOUR_FACEBOOK_APP_ID")		{			log("You forgot to put in Facebook ID!");		}		else		{			log("Init facebook...");			// as of April 2013, Facebook is dropping support for iOS devices with a version below 5.  You can check this with isFacebookSupported():			if (GoViral.goViral.isFacebookSupported())			{				GoViral.goViral.initFacebook(FACEBOOK_APP_ID, "");				log("GoViral initialized.");			}			else			{				log("Warning: Facebook not supported on this device.");			}					}				// set up all the event listeners.		// you only need the ones for the services you want to use.				// mail events//		GoViral.goViral.addEventListener(GVMailEvent.MAIL_CANCELED,onMailEvent);//		GoViral.goViral.addEventListener(GVMailEvent.MAIL_FAILED,onMailEvent);//		GoViral.goViral.addEventListener(GVMailEvent.MAIL_SAVED,onMailEvent);//		GoViral.goViral.addEventListener(GVMailEvent.MAIL_SENT,onMailEvent);				// facebook events		GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED,onFacebookEvent);		GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED,onFacebookEvent);		GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED,onFacebookEvent);		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);		GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);		GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onFacebookEvent);		GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onFacebookEvent);				// twitter events		GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_CANCELED,onTwitterEvent);		GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_FAILED,onTwitterEvent);		GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_FINISHED,onTwitterEvent);				//		showMainUI();//		showFacebookUI();	}		public function dispose() : void {		logoutFacebook();				GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_CANCELED,onFacebookEvent);		GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FAILED,onFacebookEvent);		GoViral.goViral.removeEventListener(GVFacebookEvent.FB_DIALOG_FINISHED,onFacebookEvent);		GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);		GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);		GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);		GoViral.goViral.removeEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);		GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onFacebookEvent);		GoViral.goViral.removeEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE,onFacebookEvent);				GoViral.goViral.removeEventListener(GVTwitterEvent.TW_DIALOG_CANCELED,onTwitterEvent);		GoViral.goViral.removeEventListener(GVTwitterEvent.TW_DIALOG_FAILED,onTwitterEvent);		GoViral.goViral.removeEventListener(GVTwitterEvent.TW_DIALOG_FINISHED,onTwitterEvent);				stopTimer();				GoViral.goViral.dispose();	}	// facebook		/** Login to facebook */	public function loginFacebook():void	{//		log("Login facebook...");//		if(!GoViral.goViral.isFacebookAuthenticated())//		{////			GoViral.goViral.authenticateWithFacebook("user_likes,user_photos,publish_stream");//			GoViral.goViral.authenticateWithFacebook("publish_stream");//		} else {//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_LOGGED_IN));//		}//		log("done.");		log("Login facebook...");		if(!GoViral.goViral.isFacebookAuthenticated())		{						// you must set at least one read permission.  if you don't know what to pick, 'basic_info' is fine.			// PUBLISH PERMISSIONS are NOT permitted by Facebook here anymore.//			GoViral.goViral.authenticateWithFacebook("user_likes,user_photos"); 			GoViral.goViral.authenticateWithFacebook("basic_info"); 		} else {			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_LOGGED_IN));		}		log("done.");	}		/** Logout of facebook */	public function logoutFacebook():void	{		log("logout fb.");		GoViral.goViral.logoutFacebook();		log("done logout.");	}	//	public function postWallHelp():void {//		if (!checkLoggedInFacebook()) return;//		////		var msg:String = "Help me, I'm stuck in A Defender's Tale! Please leave a comment of encouragement or like this post.";////		log(msg);////		GoViral.goViral.facebookGraphRequest(DataModel.defenderInfo.contactFBID+"/feed",GVHttpMethod.POST,{message:msg},"message");//		//		log("Graph posting...");//		var params:Object={};//		params.name="Help me, I'm stuck in A Defender's Tale!";//		params.caption="@Mark Grochowski is my emergency contact.";//		params.link="http://www.adefenderstale.com";//		params.picture="http://www.adefenderstale.com/media/stills/iPad_01.png";////		params.tags = DataModel.defenderInfo.contactFBID;////		params.actions=new Array();////		params.actions.push({name:"Link NOW!",link:"http://www.google.com"});//		//		// notice the "publish_actions", a required publish permission to write to the graph!//		GoViral.goViral.facebookGraphRequest("me/feed",GVHttpMethod.POST,params,"publish_actions"); ////		GoViral.goViral.facebookGraphRequest(DataModel.defenderInfo.contactFBID+"/feed",GVHttpMethod.POST,params,"publish_actions");//		log("post complete.");//	}	//	public function postHelpFacebook():void//	{//		if (!checkLoggedInFacebook()) return;//		//		log("posting fb feed...");//		GoViral.goViral.showFacebookFeedDialog(//			"An urgent message from A Defender's Tale  (available for iPad in the Itunes store)",//			"Help me, I'm stuck in A Defender's Tale!",//			//			"@"+DataModel.defenderInfo.contactFullName + " is my emergency contact. However, anyone can help! Please leave a comment of encouragement or like this post.",//			//			"@"+DataModel.defenderInfo.contactFullName + " is my emergency contact. However, anyone can help! Please leave a comment of encouragement or like this post.",//			"@[Mark Grochowski] is my emergency contact. However, anyone can help! Please leave a comment of encouragement or like this post.",//			"@[Mark Grochowski] is my emergency contact. However, anyone can help! Please leave a comment of encouragement or like this post.",//			"http://www.adefenderstale.com",//			"http://www.adefenderstale.com/media/stills/iPad_01.png",//			{tags:"100004309001809"}//		);//		//		log("done feed post.");//	}		public function postFacebookWall(title:String, caption:String, message:String):void	{		if (!checkLoggedInFacebook()) {			loginFacebook();			return;		}				log("posting fb feed...");		GoViral.goViral.showFacebookFeedDialog(			title + " (available for iPad)",			caption,			message,			message,			"http://www.adefenderstale.com",			"http://www.adefenderstale.com/media/stills/iPad_01.png"		);				log("done feed post.");	}			/** Post to the facebook wall / feed via dialog */	public function postFeedFacebook():void	{		if (!checkLoggedInFacebook()) return;				log("posting fb feed...");		GoViral.goViral.showFacebookFeedDialog(			"Posting from AIR",			"This is a caption",			"This is a message!",			"This is a description",			"http://www.milkmangames.com",			"http://www.milkmangames.com/blog/wp-content/uploads/2012/01/v202.jpg"		);				log("done feed post.");	}		public function postFinishedAppFacebook():void	{		if (!checkLoggedInFacebook()) return;				log("posting fb feed...");		var params:Object={};		params.tags = DataModel.defenderInfo.contactFBID;		params.comment = "Testing comment";				GoViral.goViral.showFacebookFeedDialog(			"Posting from A Defender's Tale  (available for iPad in the Itunes store)",			"I defended the Realm!",			"I defended the Realm!",			"It was an amazing challenge, but somehow I did it. Now you can too: http://www.adefenderstale.com",			"http://www.adefenderstale.com",			"http://www.adefenderstale.com/media/stills/iPad_01.png",			params		);				log("done feed post.");	}			public function sendFacebookContactMessage(thisMessage:String):void	{		if (!checkLoggedInFacebook()) return;				log("sendFacebookContactMessage");		GoViral.goViral.showFacebookRequestDialog(thisMessage,"An Urgent Message from A Defender's Tale",null, null, DataModel.defenderInfo.contactFBID);		log("sent friend message.");	}		/** Get a list of all your facebook friends */	public function getFriendsFacebook():void	{//		if (!checkLoggedInFacebook()) return;//		//		log("getting friends...");//		GoViral.goViral.requestFacebookFriends();//		log("sent friend list request.");				if (!checkLoggedInFacebook()) return;				log("getting friends.(finstn)..");		GoViral.goViral.requestFacebookFriends({fields:"installed,first_name"});		log("sent friend list request.");		}		/** Get your own facebook profile */	public function getMeFacebook():void	{		if (!checkLoggedInFacebook()) return;				log("Getting profile...");		GoViral.goViral.requestMyFacebookProfile();		log("sent profile request.");	}		/** Get Facebook Access Token */	public function getFacebookToken():void	{		log("Retrieving access token...");		var accessToken:String=GoViral.goViral.getFbAccessToken();		var accessExpiry:Number=GoViral.goViral.getFbAccessExpiry();		log("expiry:"+accessExpiry+",Token is:"+accessToken);	}		/** Make a post graph request */	public function postGraphFacebook():void	{		if (!checkLoggedInFacebook()) return;				log("Graph posting...");		var params:Object={};		params.name="Name Test";		params.caption="Caption Test";		params.link="http://www.google.com";		params.picture="http://www.milkmangames.com/blog/wp-content/uploads/2012/01/v202.jpg";		params.actions=new Array();		params.actions.push({name:"Link NOW!",link:"http://www.google.com"});				// notice the "publish_actions", a required publish permission to write to the graph!		GoViral.goViral.facebookGraphRequest("me/feed",GVHttpMethod.POST,params,"publish_actions");		log("post complete.");	}		/** Show a facebook friend invite dialog */	public function inviteFriendsFacebook():void	{		if (!checkLoggedInFacebook()) return;				log("inviting friends.");		GoViral.goViral.showFacebookRequestDialog("This is just a test","My Title","somedata");		log("sent friend invite.");	}		/** Post a photo to the facebook stream */	public function postPhotoFacebook():void	{		if (!checkLoggedInFacebook()) return;				log("post facebook pic...");		var asBitmap:Bitmap=new testImageClass() as Bitmap;				GoViral.goViral.facebookPostPhoto("posted from mobile sdk",asBitmap.bitmapData);				log("posted fb pic.");			}			/** Check you're logged in to facebook before doing anything else. */	private function checkLoggedInFacebook():Boolean	{		// make sure you're logged in first		if (!GoViral.goViral.isFacebookAuthenticated())		{			log("Not logged in!");			return false;		}		return true;	}		//	// Email	//		/** Send Test Email */	public function sendTestEmail():void	{		if (GoViral.goViral.isEmailAvailable())		{			log("Opening email composer...");			GoViral.goViral.showEmailComposer("This is a subject!","who@where.com,john@doe.com","This is the body of the message.",false);			log("Composer opened.");		}		else		{			log("Email is not set up on this device.");		}	}		/** Send Email with attached image */	public function sendImageEmail():void	{		var asBitmap:Bitmap=new testImageClass() as Bitmap;		log("Email composer w/image...");		if (GoViral.goViral.isEmailAvailable())		{			GoViral.goViral.showEmailComposerWithBitmap("This has an attachment!","john@doe.com","I think youll like my pic",false,asBitmap.bitmapData);		}		else		{			log("Email is not available on this device.");			return;		}		log("Mail composer opened.");	}		//	// Android Generic Sharing	//		/** Send Generic Message */	public function sendGenericMessage():void	{		if (!GoViral.goViral.isGenericShareAvailable())		{			log("Generic share doesn't work on this platform.");			return;		}				log("Sending generic share intent...");		GoViral.goViral.shareGenericMessage("The Subject","The message!",false);		log("done send share intent.");	}		/** Send Generic Message */	public function sendGenericMessageWithImage():void	{		if (!GoViral.goViral.isGenericShareAvailable())		{			log("Generic share doesn't work on this platform.");			return;		}				log("Sending generic share img intent...");		var asBitmap:Bitmap=new testImageClass() as Bitmap;		GoViral.goViral.shareGenericMessageWithImage("The Subject","The message!",false,asBitmap.bitmapData);		log("done send share img intent.");	}		/** iOS 6 only sharing */	public function shareSocialComposer():void	{		// note that SINA_WEIBO and TWITTER are also available...		if (GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.FACEBOOK))		{			log("launch ios 6 social composer...");			var asBitmap:Bitmap=new testImageClass() as Bitmap;			GoViral.goViral.displaySocialComposerView(GVSocialServiceType.FACEBOOK,"Social Composer message",asBitmap.bitmapData,"http://www.milkmangames.com");		}		else		{			log("social composer service not available on device.");		}	}			public function twitterAvailable():Boolean {		var avail:Boolean//		if (GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.TWITTER)) {		if (GoViral.goViral.isTweetSheetAvailable()) {			avail = true;		} else {			avail = false;		}//		log("IS TWITTER AVAILABLE? : "+avail);		return avail;	}		//	// twitter	//		/** Post a status message to Twitter */	public function postTwitter(theMessage:String = "A Message from A Defender's Tale"):void	{		log("posting to twitter.");				// You should check GoViral.goViral.isTweetSheetAvailable() to determine		// if you're able to use the built-in iOS Twitter UI.  If the phone supports it		// (because its running iOS 5.0+, or an Android device with Twitter) it will return true and you can call		// 'showTweetSheet'. 				if (GoViral.goViral.isTweetSheetAvailable())		{			GoViral.goViral.showTweetSheet(theMessage);		}		else		{			log("Twitter not available on this device.");			return;		}	}		/** Post a picture to twitter */	public function postTwitterPic():void	{		log("post twitter pic.");				// You should check GoViral.goViral.isTweetSheetAvailable() to determine		// if you're able to use the built-in iOS Twitter UI.  If the phone supports it		// (because its running iOS 5.0+, or an Android device with Twitter) it will return true and you can call		// 'showTweetSheetWithImage'.		if (GoViral.goViral.isTweetSheetAvailable())		{			var asBitmap:Bitmap=new testImageClass() as Bitmap;			GoViral.goViral.showTweetSheetWithImage("This is a twitter post with a pic!",asBitmap.bitmapData);		}		else		{			log("Twitter not available on this device.");			return;		}		log("done show tweet.");	}			//	// Events	//		/** Handle Facebook Event */	private function onFacebookEvent(e:GVFacebookEvent):void	{		// post id				log("onFacebookEvent e: "+e);//		THE JSON IS THE RAW DATA, YOU WANT THIS IF YOU WANT TO KNOW WHAT IS IN OBJECT RETURNED//		log("e.jsonData: "+e.jsonData);//		log("e.data: "+e.data);		switch(e.type)		{			case GVFacebookEvent.FB_DIALOG_CANCELED:				log("Facebook dialog '"+e.dialogType+"' canceled.");				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_DONE));				break;			case GVFacebookEvent.FB_DIALOG_FAILED:				log("dialog err:"+e.errorMessage);				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_DONE));				break;			case GVFacebookEvent.FB_DIALOG_FINISHED:				log("Facebook dialog '"+e.dialogType+"' finished.");				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_DONE));				// sucessful post to feed//				if (e.dialogType == "feed") {//					_wallpostID = e.data.post_id;//					if (!_commentLikeTimer) {//						_commentLikeTimer =  new Timer(_timerDelay);//						_commentLikeTimer.addEventListener(TimerEvent.TIMER, checkForCommentsLikes);//						_commentLikeTimer.start();//	//					log("FEEEEED DONE e.jsonData: "+e.jsonData);//					}//				}								break;			case GVFacebookEvent.FB_LOGGED_IN:				log("Logged in to facebook!");				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_LOGGED_IN));				break;			case GVFacebookEvent.FB_LOGGED_OUT:				log("Logged out of facebook.");				break;			case GVFacebookEvent.FB_LOGIN_CANCELED:				log("Canceled facebook login.");				break;			case GVFacebookEvent.FB_REQUEST_FAILED:				log("Facebook '"+e.graphPath+"' failed:"+e.errorMessage);				break;			case GVFacebookEvent.FB_REQUEST_RESPONSE://				log("gvFbRawResponse");								// sucessful post to feed//				if(e.graphPath.search("feed") != -1) {//					_wallpostID = e.data.post_id;//					_commentLikeTimer =  new Timer(_timerDelay);//					_commentLikeTimer.addEventListener(TimerEvent.TIMER, checkForCommentsLikes);//					_commentLikeTimer.start();//					return;//				}								// comment posted or help post liked				if(e.graphPath.search("comments") != -1 || e.graphPath.search("likes") != -1) {					if (e.data.data.length > 0) {						stopTimer();//						log("YOU ARE FREEEE!");						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_CONTACT_RESPONSE));					}										return;				}								// handle a friend list- there will be only 1 item in it if 				// this was a 'my profile' request.								if (e.friends!=null)				{										// 'me' was a request for own profile.					if (e.graphPath=="me")					{						var myProfile:GVFacebookFriend=e.friends[0];//						log("Me: name='"+myProfile.name+"',gender='"+myProfile.gender+"',location='"+myProfile.locationName+"',bio='"+myProfile.bio+"'");						log("myProfile commented out");						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_DEFENDER_INFO, myProfile));						return;					}										// 'me/friends' was a friends request.					if (e.graphPath=="me/friends")					{											var allFriends:String="";						var friendsVector:Vector.<GVFacebookFriend> = new Vector.<GVFacebookFriend>();						for each(var friend:GVFacebookFriend in e.friends)						{							allFriends+=","+friend.name;							friendsVector.push(friend);						}						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.FACEBOOK_DEFENDER_FRIENDS, friendsVector));//						log(e.graphPath+"= ("+e.friends.length+")="+allFriends+",json="+e.jsonData);						log("friends list commented out");					}				}				else				{					log(e.graphPath+" res="+e.jsonData);				}				break;		}	}		private function stopTimer():void
	{		if (_commentLikeTimer != null) {			_commentLikeTimer.removeEventListener(TimerEvent.TIMER, checkForCommentsLikes);			_commentLikeTimer.stop();			_commentLikeTimer = null;		}
				log("stopTimer");
	}		protected function checkForCommentsLikes(event:TimerEvent):void
	{
		log("checkForCommentsLikes");		GoViral.goViral.facebookGraphRequest(_wallpostID+"/comments",GVHttpMethod.GET);
		GoViral.goViral.facebookGraphRequest(_wallpostID+"/likes",GVHttpMethod.GET);
	}		/** Handle Twitter Event */	private function onTwitterEvent(e:GVTwitterEvent):void	{		var tempObj:Object = new Object();				switch(e.type)		{			case GVTwitterEvent.TW_DIALOG_CANCELED:				log("Twitter canceled.");				tempObj.message = "canceled";				break;			case GVTwitterEvent.TW_DIALOG_FAILED:				log("Twitter failed: "+e.errorMessage);				tempObj.message = "failed";				break;			case GVTwitterEvent.TW_DIALOG_FINISHED:				log("Twitter finished.");				tempObj.message = "finished";				break;		}		EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TWITTER_DONE, tempObj));	}		/** Handle Mail Event */	private function onMailEvent(e:GVMailEvent):void	{		switch(e.type)		{			case GVMailEvent.MAIL_CANCELED:				log("Mail canceled.");				break;			case GVMailEvent.MAIL_FAILED:				log("Mail failed:"+e.errorMessage);				break;			case GVMailEvent.MAIL_SAVED:				log("Mail saved.");				break;			case GVMailEvent.MAIL_SENT:				log("Mail sent!");				break;		}	}		/** Handle Generic Share Event */	private function onShareEvent(e:GVShareEvent):void	{		log("share finished.");	}	//	// Impelementation	//		/** Log */	private function log(msg:String):void	{		trace("[GoViralService] "+msg);//		txtStatus.text=msg;		txtStatus.appendText("\n"+msg);	}		private function logStatus(msg:String):void	{		txtStatus.appendText("-"+msg);	}		/** Create UI */	public function createUI():void	{		txtStatus=new TextField();				txtStatus.defaultTextFormat=new flash.text.TextFormat("Arial Bold",22);		txtStatus.width=DataModel.APP_WIDTH;		txtStatus.height=DataModel.APP_HEIGHT;		txtStatus.multiline=true;		txtStatus.wordWrap=true;		txtStatus.text="Ready";		txtStatus.textColor = 0xFFFFFF;		txtStatus.y=txtStatus.textHeight;		addChild(txtStatus);	}		/** Show Main Menu */	public function showMainUI():void	{		if (buttonContainer)		{			removeChild(buttonContainer);			buttonContainer=null;		}				buttonContainer=new Sprite();		buttonContainer.y=txtStatus.height;		addChild(buttonContainer);				var uiRect:Rectangle=new Rectangle(0,0,DataModel.APP_WIDTH,DataModel.APP_HEIGHT);		var layout:ButtonLayout=new ButtonLayout(uiRect,14);		layout.addButton(new SimpleButton(new Command("Send Test Email",sendTestEmail)));		layout.addButton(new SimpleButton(new Command("Send Pic Email",sendImageEmail)));				layout.addButton(new SimpleButton(new Command("Tweet Msg",postTwitter)));		layout.addButton(new SimpleButton(new Command("Tweet Pic",postTwitterPic)));		layout.addButton(new SimpleButton(new Command("Facebook Stuff >",showFacebookUI)));		layout.attach(buttonContainer);		layout.layout();		}		/** Show Facebook Menu */	public function showFacebookUI():void	{		// make sure facebook is set up first		if (FACEBOOK_APP_ID=="YOUR_FACEBOOK_APP_ID")		{			log("You forgot to put in Facebook ID!");			return;		}				if (buttonContainer)		{			removeChild(buttonContainer);			buttonContainer=null;		}				buttonContainer=new Sprite();		buttonContainer.y=txtStatus.height;		addChild(buttonContainer);				var uiRect:Rectangle=new Rectangle(0,0,DataModel.APP_WIDTH,DataModel.APP_HEIGHT);		var layout:ButtonLayout=new ButtonLayout(uiRect,14);		layout.addButton(new SimpleButton(new Command("Login to Facebook",loginFacebook)));//		layout.addButton(new SimpleButton(new Command("Post wall",postFeedFacebook)));//		layout.addButton(new SimpleButton(new Command("I'm stuck WTF?",postWallHelp)));//		layout.addButton(new SimpleButton(new Command("post wall pic",postPhotoFacebook)));//		layout.addButton(new SimpleButton(new Command("List friends",getFriendsFacebook)));//		layout.addButton(new SimpleButton(new Command("My profile",getMeFacebook)));//		layout.addButton(new SimpleButton(new Command("Ask for Help!",inviteFriendsFacebook)));//		layout.addButton(new SimpleButton(new Command("Get Token",getFacebookToken)));		layout.addButton(new SimpleButton(new Command("Logout of Facebook",logoutFacebook)));//		layout.addButton(new SimpleButton(new Command("< Back",showMainUI)));		layout.attach(buttonContainer);		layout.layout();			trace("showFacebookUI");	}	}}//// Code Below is generic code for building UI//import flash.display.DisplayObjectContainer;import flash.display.Sprite;import flash.events.MouseEvent;import flash.geom.Rectangle;import flash.text.TextField;import flash.text.TextFieldAutoSize;import flash.text.TextFormat;/** Simple Button */class SimpleButton extends Sprite{	//	// Instance Variables	//		/** Command */	private var cmd:Command;		/** Width */	private var _width:Number;		/** Label */	private var txtLabel:TextField;		//	// Public Methods	//		/** Create New SimpleButton */	public function SimpleButton(cmd:Command)	{		super();		this.cmd=cmd;				mouseChildren=false;		mouseEnabled=buttonMode=useHandCursor=true;				txtLabel=new TextField();		txtLabel.defaultTextFormat=new TextFormat("Arial",42,0xFFFFFF);		txtLabel.mouseEnabled=txtLabel.mouseEnabled=txtLabel.selectable=false;		txtLabel.text=cmd.getLabel();		txtLabel.autoSize=TextFieldAutoSize.LEFT;				redraw();				addEventListener(MouseEvent.CLICK,onSelect);	}		/** Set Width */	override public function set width(val:Number):void	{		this._width=val;		redraw();	}		/** Dispose */	public function dispose():void	{		removeEventListener(MouseEvent.CLICK,onSelect);	}		//	// Events	//		/** On Press */	private function onSelect(e:MouseEvent):void	{		this.cmd.execute();	}		//	// Implementation	//		/** Redraw */	private function redraw():void	{				txtLabel.text=cmd.getLabel();		_width=_width||txtLabel.width*1.1;				graphics.clear();		graphics.beginFill(0x444444);		graphics.lineStyle(2,0);		graphics.drawRoundRect(0,0,_width,txtLabel.height*1.1,txtLabel.height*.4);		graphics.endFill();				txtLabel.x=_width/2-(txtLabel.width/2);		txtLabel.y=txtLabel.height*.05;		addChild(txtLabel);	}}/** Button Layout */class ButtonLayout{	private var buttons:Array;	private var rect:Rectangle;	private var padding:Number;	private var parent:DisplayObjectContainer;		public function ButtonLayout(rect:Rectangle,padding:Number)	{		this.rect=rect;		this.padding=padding;		this.buttons=new Array();	}		public function addButton(btn:SimpleButton):uint	{		return buttons.push(btn);	}		public function attach(parent:DisplayObjectContainer):void	{		this.parent=parent;		for each(var btn:SimpleButton in this.buttons)		{			parent.addChild(btn);		}	}		public function layout():void	{		var btnX:Number=rect.x+padding;		var btnY:Number=rect.y;		for each( var btn:SimpleButton in this.buttons)		{			btn.width=rect.width-(padding*2);			btnY+=this.padding;			btn.x=btnX;			btn.y=btnY;			btnY+=btn.height;		}	}}/** Inline Command */class Command{	/** Callback Method */	private var fnCallback:Function;		/** Label */	private var label:String;		//	// Public Methods	//		/** Create New Command */	public function Command(label:String,fnCallback:Function)	{		this.fnCallback=fnCallback;		this.label=label;	}		//	// Command Implementation	//		/** Get Label */	public function getLabel():String	{		return label;	}		/** Execute */	public function execute():void	{		fnCallback();	}}