package view
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import assets.FadeToBlackMC;
	import assets.NavigationMC;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.DataModel;
	
	public class NavigationView extends MovieClip
	{
		private var _mc:NavigationMC;
		private var _contents:MovieClip;
		private var _sound:MovieClip;
		private var _help:MovieClip;
		private var _restart:MovieClip;
		private var _about:MovieClip;
		private var _contentsPanel:ContentsPanelView;
		private var _aboutPanel:AboutPanelView;
		
		private var _navBtnArray:Array;
		
		private var _soundOn:Boolean = true;
//		private var _contentsShowing:Boolean;
		
//		private var _contentsOffX:int = -235;
		
		private static const CLOSED_Y:int = -910;
		private static const OPEN_Y:int = -735;
		private static const HELP_Y:int = -140;
		private static const RESTART_Y:int = -70;
		private static const CONTENTS_Y:int = 0;
		
		private var _gear:MovieClip;
		private var _panelOpen:Boolean;
		private var _helpPanel:MovieClip;
		private var _restartPanel:MovieClip;
		private var _contentsMC:MovieClip;
		private var _aboutMC:MovieClip;
		private var _blocker:FadeToBlackMC;
		
		
		public function NavigationView()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			EventController.getInstance().addEventListener(ViewEvent.CLOSE_GLOBAL_NAV, closeNav);
		}
		
		protected function closeNav(event:Event):void
		{
			hidePanel();
		}
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_blocker = new FadeToBlackMC();
			_blocker.cacheAsBitmap = true;
			TweenMax.to(_blocker, 0, {autoAlpha:0});
			addChild(_blocker);
			
			_mc = new NavigationMC();
			_mc.cacheAsBitmap = true;
			
			_mc.x = 30;
			_mc.y = CLOSED_Y;
			
			_panelOpen = false;
			
			_gear = _mc.gear_mc;
			_gear.mouseChildren = false;
			_gear.addEventListener(MouseEvent.CLICK, panelToggle);
			
			_contents = _mc.getChildByName("contents_btn") as MovieClip;
			_contents.addEventListener(MouseEvent.CLICK, contentsClick);
			_contents.stop();
			
			_sound = _mc.getChildByName("sound_btn") as MovieClip;
			_sound.addEventListener(MouseEvent.CLICK, soundClick);
			_sound.stop();
			
			_help = _mc.getChildByName("help_btn") as MovieClip;
			_help.addEventListener(MouseEvent.CLICK, helpClick);
			_help.stop();
			
			_helpPanel = _mc.help_mc;
			TweenMax.to(_helpPanel, 0, {autoAlpha:0});
			
			_restartPanel = _mc.restart_mc;
			TweenMax.to(_restartPanel, 0, {autoAlpha:0});
			_restartPanel.restart_btn.addEventListener(MouseEvent.CLICK, restartPanelClick);
			_restartPanel.map_btn.addEventListener(MouseEvent.CLICK, restartPanelClick);
			
			_restart = _mc.getChildByName("restart_btn") as MovieClip;
			_restart.addEventListener(MouseEvent.CLICK, restartClick);
			_restart.stop();
			
			_about = _mc.getChildByName("about_btn") as MovieClip;
			_about.addEventListener(MouseEvent.CLICK, aboutClick);
			_about.stop();
//			
			_contentsMC = _mc.contents_mc;
			_contentsPanel = new ContentsPanelView();
			_contentsMC.holder_mc.addChild(_contentsPanel);
			TweenMax.to(_contentsMC, 0, {autoAlpha:0});
			
			_aboutMC = _mc.about_mc;
			_aboutPanel = new AboutPanelView(_aboutMC);
			_aboutMC.holder_mc.addChild(_aboutPanel);
			TweenMax.to(_aboutMC, 0, {autoAlpha:0});
			
			_navBtnArray = [_contents, _restart, _help, _about];
			
			addChild(_mc);
		}
		
		protected function panelToggle(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			if (!_panelOpen) {
				showPanel();
			} else {
				hidePanel();
			}
		}
		
		private function showPanel():void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.OPEN_GLOBAL_NAV));
			
			_contents.gotoAndStop("_off");
			_restart.gotoAndStop("_off");
			_help.gotoAndStop("_off");
			TweenMax.to(_mc, .6, {y:OPEN_Y, ease:Quad.easeInOut});
			_panelOpen = true;
		}
		
		private function hidePanel():void {
			TweenMax.to(_mc, .6, {y:CLOSED_Y, ease:Quad.easeInOut, onComplete:panelsOff});
			_panelOpen = false;
			TweenMax.to(_blocker, 0, {autoAlpha:0});
		}
		
		private function panelsOff():void {
			TweenMax.to(_helpPanel, 0, {autoAlpha:0});
			TweenMax.to(_contentsMC, 0, {autoAlpha:0});
			TweenMax.to(_aboutMC, 0, {autoAlpha:0});
			TweenMax.to(_restartPanel, 0, {autoAlpha:0});
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GLOBAL_NAV_CLOSED));
		}
		
		protected function restartClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			showRestart();
			
//			hidePanel();
			
//			var tempObj:Object = new Object();
//			tempObj.id = "TitleScreenView";
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
//			EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.RESTART_BOOK));
		}
		
		protected function restartPanelClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			hidePanel();

			var tempObj:Object = new Object();
			
			if (MovieClip(event.currentTarget).name == "restart_btn") {
				tempObj.id = "TitleScreenView";
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
				EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.RESTART_BOOK));
			} else {
				tempObj.id = "MapView";
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
			}
			
		}
		
		
		private function showRestart():void {
			buttonOnOffOthers(_restart);
			
			TweenMax.to(_blocker, .5, {autoAlpha:.5});
			TweenMax.to(_mc, .6, {y:RESTART_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_restartPanel]});
//			TweenMax.to(_restartPanel, 1, {autoAlpha:1});
			TweenMax.to(_helpPanel, 0, {autoAlpha:0});
			TweenMax.to(_contentsMC, 0, {autoAlpha:0});
			TweenMax.to(_aboutMC, 0, {autoAlpha:0});
		}
		
		protected function aboutClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			showAbout();
		}
		
		private function showAbout():void {
			
			trace("showAbout");
			
			buttonOnOffOthers(_about);
			
			TweenMax.to(_blocker, .5, {autoAlpha:.5});  
			TweenMax.to(_mc, .6, {y:CONTENTS_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_aboutMC]});
			TweenMax.to(_helpPanel, 0, {autoAlpha:0});
			TweenMax.to(_contentsMC, 0, {autoAlpha:0});
//			TweenMax.to(_aboutMC, 1, {autoAlpha:1});
			TweenMax.to(_restartPanel, 0, {autoAlpha:0});
		}
		
		protected function helpClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			showHelp();
		}
		
		private function showHelp():void {
			buttonOnOffOthers(_help);
			
			TweenMax.to(_blocker, .5, {autoAlpha:.5});
			TweenMax.to(_mc, .6, {y:HELP_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_helpPanel]});
//			TweenMax.to(_helpPanel, 1, {autoAlpha:1});
			TweenMax.to(_contentsMC, 0, {autoAlpha:0});
			TweenMax.to(_aboutMC, 0, {autoAlpha:0});
			TweenMax.to(_restartPanel, 0, {autoAlpha:0});
		}
		
		protected function soundClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			if (_soundOn) {
				_sound.gotoAndStop("_off");
			} else {
				_sound.gotoAndStop("_on");
			}
			_soundOn = !_soundOn;
			EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.TOGGLE_MUTE));
		}
		
		
		protected function contentsClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			TweenMax.to(_blocker, .5, {autoAlpha:.5});
			
			buttonOnOffOthers(_contents);
			
			TweenMax.to(_mc, .8, {y:CONTENTS_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_contentsMC]});
//			TweenMax.to(_contentsMC, 1, {autoAlpha:1});
			TweenMax.to(_aboutMC, 0, {autoAlpha:0});
			TweenMax.to(_restartPanel, 0, {autoAlpha:0});
			TweenMax.to(_helpPanel, 0, {autoAlpha:0});
		}
		
		private function fadeInMC(thisMC:MovieClip):void {
			TweenMax.to(thisMC, 1, {autoAlpha:1});
		}
		
		private function buttonOnOffOthers(thisBtn:MovieClip):void {
			for (var i:int = 0; i < _navBtnArray.length; i++) 
			{
				if (thisBtn == _navBtnArray[i]) {
					thisBtn.gotoAndStop("_on");
					
				} else {
					_navBtnArray[i].gotoAndStop("_off");
				}
			}
			
		}
	}
}