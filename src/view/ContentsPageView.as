package view
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.ContentsPageMC;

	public class ContentsPageView extends MovieClip
	{
		private var _mc:ContentsPageMC;
		
		public function ContentsPageView() 
		{
			_mc = new ContentsPageMC();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(_mc);
			
		}
		
		public function get pageHeight():int {
			return _mc.height;
		}
	}
}