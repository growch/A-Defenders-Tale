package view
{
	import assets.NavigationMC;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class NavigationView extends MovieClip
	{
		private var _mc:NavigationMC;
		private var _contents:MovieClip;
		private var _glossary:MovieClip;
		private var _sound:MovieClip;
		private var _help:MovieClip;
		private var _about:MovieClip;
		private var _contentsPanel:ContentsPanelView;
		
		private var _soundOn:Boolean = true;
		private var _contentsShowing:Boolean;
		
		private var _contentsOffX:int = -235;
		
		public function NavigationView()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_mc = new NavigationMC();
			
			_contents = _mc.getChildByName("contents_btn") as MovieClip;
			_contents.addEventListener(MouseEvent.CLICK, contentsClick);
			
			_glossary = _mc.getChildByName("glossary_btn") as MovieClip;
			_glossary.addEventListener(MouseEvent.CLICK, glossaryClick);
			
			_sound = _mc.getChildByName("sound_btn") as MovieClip;
			_sound.addEventListener(MouseEvent.CLICK, soundClick);
			
			_help = _mc.getChildByName("help_btn") as MovieClip;
			_help.addEventListener(MouseEvent.CLICK, helpClick);
			
			_about = _mc.getChildByName("about_btn") as MovieClip;
			_about.addEventListener(MouseEvent.CLICK, aboutClick);
			
			_contentsPanel = new ContentsPanelView();
			_contentsPanel.y = _mc.bg_mc.height;
			_contentsPanel.x = _contentsOffX;
			_mc.addChild(_contentsPanel);
			
			
			addChild(_mc);
		}
		
		protected function aboutClick(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function helpClick(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function soundClick(event:MouseEvent):void
		{
			if (_soundOn) {
				_sound.gotoAndStop("off");
			} else {
				_sound.gotoAndStop("on");
			}
			_soundOn = !_soundOn;
		}
		
		protected function glossaryClick(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function contentsClick(event:MouseEvent):void
		{
			if (_contentsShowing) {
				TweenMax.to(_contentsPanel, .6, {x:_contentsOffX, ease:Quad.easeInOut});
			} else {
				TweenMax.to(_contentsPanel, .6, {x:0, ease:Quad.easeInOut});
			}
			
			_contentsShowing = !_contentsShowing;
		}
	}
}