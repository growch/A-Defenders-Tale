package view
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
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
//		private var _contentsPanel:ContentsPanelView;
		public var contentsPanel:ContentsPanelView;
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
		private var _navOpen:Boolean;
		private var _helpPanel:MovieClip;
		private var _restartPanel:MovieClip;
		private var _contentsMC:MovieClip;
		private var _aboutMC:MovieClip;
		private var _contentScreen:MovieClip;
		private var _blocker:FadeToBlackMC;
		private var _panelHolder:Sprite;
		
		
		public function NavigationView()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			EventController.getInstance().addEventListener(ViewEvent.CLOSE_NAV_DECISION_CLICK, closeNav);
			EventController.getInstance().addEventListener(ViewEvent.PEEK_NAVIGATION, peekNavigation);
			EventController.getInstance().addEventListener(ViewEvent.OPEN_GLOBAL_NAV, openNavShowContents);
		}
		
		protected function openNavShowContents(event:Event):void
		{
			buttonOnOffOthers(_contents);
			
			if (_blocker.alpha != .5) {
				TweenMax.to(_blocker, .5, {autoAlpha:.5, onComplete:showContents});
			} else {
				showContents();
			}
			
			buttonOnOffOthers(_contents);
		}
		
		protected function closeNav(event:ViewEvent):void
		{
			closeNavigation(event.data);
		}
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_blocker = new FadeToBlackMC();
//			_blocker.cacheAsBitmap = true;
			TweenMax.to(_blocker, 0, {autoAlpha:0});
			addChild(_blocker);
			
			_mc = new NavigationMC();
			_mc.cacheAsBitmap = true;
			
			_mc.x = 30;
			_mc.y = CLOSED_Y;
			
			_navOpen = false;
			
			_gear = _mc.gear_mc;
			_gear.mouseChildren = false;
			_gear.addEventListener(MouseEvent.CLICK, navigationToggle);
			
			_contents = _mc.getChildByName("contents_btn") as MovieClip;
			_contents.addEventListener(MouseEvent.CLICK, contentsClick);
			_contents.stop();
			
			_contentScreen = _mc.getChildByName("contentScreen_mc") as MovieClip;
			
			_sound = _mc.getChildByName("sound_btn") as MovieClip;
			_sound.addEventListener(MouseEvent.CLICK, soundClick);
			_sound.stop();
			
			_help = _mc.getChildByName("help_btn") as MovieClip;
			_help.addEventListener(MouseEvent.CLICK, helpClick);
			_help.stop();
			
			_restart = _mc.getChildByName("restart_btn") as MovieClip;
			_restart.addEventListener(MouseEvent.CLICK, restartClick);
			_restart.stop();
			
			_about = _mc.getChildByName("about_btn") as MovieClip;
			_about.addEventListener(MouseEvent.CLICK, aboutClick);
			_about.stop();
			
			_helpPanel = _mc.help_mc;
			
			_restartPanel = _mc.restart_mc;
			_restartPanel.restart_btn.addEventListener(MouseEvent.CLICK, restartPanelClick);
			_restartPanel.map_btn.addEventListener(MouseEvent.CLICK, restartPanelClick);

			_contentsMC = _mc.contents_mc;
			contentsPanel = new ContentsPanelView();
			_contentsMC.holder_mc.addChild(contentsPanel);
			
			_aboutMC = _mc.about_mc;
			_aboutPanel = new AboutPanelView(_aboutMC);
			_aboutMC.holder_mc.addChild(_aboutPanel);
			
			_navBtnArray = [_contents, _restart, _help, _about];
			
			_panelHolder = new Sprite();
			_mc.addChild(_panelHolder);
			
			_panelHolder.addChild(_helpPanel);
			_panelHolder.addChild(_restartPanel);
			_panelHolder.addChild(_contentsMC);
			_panelHolder.addChild(_aboutMC);
			
			//put screen back on top
			_mc.addChild(_contentScreen);
			
			addChild(_mc);
		}
		
		protected function peekNavigation(event:ViewEvent):void
		{
			openNavigation();
			TweenMax.delayedCall(2, closeNavigation);
		}
		
		protected function navigationToggle(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			if (!_navOpen) {
				openNavigation();
			} else {
				closeNavigation();
			}
		}
		
		private function openNavigation():void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GLOBAL_NAV_OPEN));
			
			_contents.gotoAndStop("_off");
			_restart.gotoAndStop("_off");
			_help.gotoAndStop("_off");
			TweenMax.to(_mc, .6, {y:OPEN_Y, ease:Quad.easeInOut});
			_navOpen = true;
		}
		
		private function closeNavigation(thisPageObj:Object=null):void {
			TweenMax.to(_mc, .6, {y:CLOSED_Y, ease:Quad.easeInOut, onComplete:panelsOff, onCompleteParams:[thisPageObj]});
			_navOpen = false;
			TweenMax.to(_blocker, 0, {autoAlpha:0});
		}
		
		private function panelsOff(thisPageObj:Object=null):void {
//			TweenMax.to(_helpPanel, 0, {autoAlpha:0});
//			TweenMax.to(_contentsMC, 0, {autoAlpha:0});
//			TweenMax.to(_aboutMC, 0, {autoAlpha:0});
//			TweenMax.to(_restartPanel, 0, {autoAlpha:0});
			TweenMax.to(_panelHolder, 0, {autoAlpha:0});
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GLOBAL_NAV_CLOSED));
			
			if (thisPageObj) {
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, thisPageObj));
			}
		}
		
		protected function restartClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			showRestart();
			
//			closeNavigation();
			
//			var tempObj:Object = new Object();
//			tempObj.id = "TitleScreenView";
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
//			EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.RESTART_BOOK));
		}
		
		protected function restartPanelClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			closeNavigation();

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
			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			TweenMax.to(_mc, .6, {y:RESTART_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_restartPanel]});
		}
		
		protected function aboutClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			showAbout();
		}
		
		private function showAbout():void {
			buttonOnOffOthers(_about);
			
			TweenMax.to(_blocker, .5, {autoAlpha:.5});  
			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			TweenMax.to(_mc, .6, {y:CONTENTS_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_aboutMC]});
		}
		
		protected function helpClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			showHelp();
		}
		
		private function showHelp():void {
			buttonOnOffOthers(_help);
			
			TweenMax.to(_blocker, .5, {autoAlpha:.5});
			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			TweenMax.to(_mc, .6, {y:HELP_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_helpPanel]});
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
			buttonOnOffOthers(_contents);
			
			if (_blocker.alpha != .5) {
				TweenMax.to(_blocker, .5, {autoAlpha:.5, onComplete:showContents});
			} else {
				showContents();
			}
			
		}
		
		private function showContents():void {
			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			TweenMax.to(_mc, .8, {y:CONTENTS_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_contentsMC]});
		}
		
		private function fadeInMC(thisMC:MovieClip):void {
			_helpPanel.visible = false;
			_restartPanel.visible = false;
			_contentsMC.visible = false;
			_aboutMC.visible = false;
			
			thisMC.visible = true;
			
			_navOpen = true;
			
//			TweenMax.to(thisMC, 1, {autoAlpha:1});
//			TweenMax.to(_panelHolder, .5, {autoAlpha:1});
			TweenMax.to(_contentScreen, .5, {autoAlpha:0});
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