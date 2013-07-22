package com.leebrimelow.starling
{
	import flash.display.MovieClip;
	
	import starling.display.DisplayObject;

	public class StarlingPool
	{
		public var items:Array;
		private var counter:int;
		
		public function StarlingPool(type:Class, len:int)
		{
			items = new Array();
			counter = len;
			
			var i:int = len;
			while(--i > -1) {
				items[i] = new type();
//				trace(items[i]);
			}
				
		}
		
		public function getSprite():MovieClip
		{
			if(counter > 0)
				return items[--counter];
			else
				throw new Error("You exhausted the pool!");
		}
		
		public function returnSprite(s:MovieClip):void
		{
			items[counter++] = s;
		}
		
		public function destroy():void
		{
			items = null;
		}
	}
}