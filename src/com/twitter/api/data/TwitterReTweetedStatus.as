package com.twitter.api.data{

	import com.twitter.api.utils.TwitterUtils;

	public class TwitterReTweetedStatus 
	{
		public var createdAt:Date;
		public var id:Number;
		public var text:String;
		public var retweetedStatus:TwitterStatus;
		public var user:TwitterUser;
		
		function TwitterReTweetedStatus(status:Object, twitterUser:TwitterUser = null) 
		{       
			this.createdAt = TwitterUtils.makeDate(status.created_at);
			id = status.id;
			text = status.text;
			retweetedStatus = new TwitterStatus(status.retweeted_status);
			var tmpName:String = status.user;
			var userName:String = tmpName.split(" ")[0];
			if (twitterUser)
			{
				user = twitterUser;
			} else if (status.user!=null) {
				user = new TwitterUser(status.user);
			}
			if ((user.id==0 || user.name==null || user.name=="") && userName!="") {
				user = new TwitterUser(null);
				user.name = userName;
			}       
		}
	}
}
