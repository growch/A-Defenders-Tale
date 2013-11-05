package com.twitter.api.data{

	import com.twitter.api.utils.TwitterUtils;

	public class TwitterSearchData
	{
		public var createdAt:Date;
		public var arrayTweetStatus:Array;
		
		function TwitterSearchData(statuses:Array, createdAt:String) 
		{       
			this.createdAt = TwitterUtils.makeDate(createdAt);
			arrayTweetStatus = statuses;
		}
	}
}
