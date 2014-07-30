package view
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import assets.FadeToBlackMC;
	import assets.NavigationMC;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.DataModel;
	
	import util.MouseSpeed;
	
	public class NavigationView extends MovieClip
	{
		private var _mc:NavigationMC;
		private var _contents:MovieClip;
		private var _sound:MovieClip;
		private var _help:MovieClip;
		private var _restart:MovieClip;
		private var _about:MovieClip;
		public var contentsPanel:ContentsPanelView;
		private var _aboutPanel:AboutPanelView;
		
		private var _navBtnArray:Array;
		
		private var _soundOn:Boolean = true;
		
		private static const CLOSED_Y:int = -910;
		private static const OPEN_Y:int = -735;
		private static const HELP_Y:int = -140;
		private static const RESTART_Y:int = -130;
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
		
//		private var destination:Point=new Point();
//		private var dragging:Boolean=false;
//		private var speed:Number=5;
//		private var offset:Point=new Point(); // our offset
//		private var offsetY:Number;
//		private var ySpeed:Object;
//		private var ms:MouseSpeed = new MouseSpeed();
		
		public function NavigationView()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			EventController.getInstance().addEventListener(ViewEvent.CLOSE_NAV_DECISION_CLICK, closeNavDecisionClick);
			EventController.getInstance().addEventListener(ViewEvent.PEEK_NAVIGATION, peekNavigation);
			EventController.getInstance().addEventListener(ViewEvent.OPEN_GLOBAL_NAV, openNavShowContents);
		}
		
		protected function openNavShowContents(event:Event):void
		{
			buttonOnOffOthers(_contents);
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GLOBAL_NAV_OPEN));
			
			if (_blocker.alpha != .5) {
				TweenMax.to(_blocker, .5, {autoAlpha:.5, onComplete:showContents});
			} else {
				showContents();
			}
			
			buttonOnOffOthers(_contents);
			
//			IMPORTANT OTHERWISE BUG WITH SCREENSHOT
			_navOpen = true;
		}
		
		protected function closeNavDecisionClick(event:ViewEvent):void
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
//			_mc.cacheAsBitmap = true;
			
			_mc.x = 30;
			_mc.y = CLOSED_Y;
			
			_navOpen = false;
			
			_gear = _mc.gear_mc;
			_gear.mouseChildren = false;
			_gear.addEventListener(MouseEvent.CLICK, navigationToggle);
//			WHAT A DRAG!
//			_gear.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
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

			_contentsMC = _mc.contents_mc;
			contentsPanel = new ContentsPanelView();
			_contentsMC.holder_mc.addChild(contentsPanel);
//			IMPORTANT!!! for performance?
			_contentsMC.visible = false;
			
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
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_gear);
			
			//put screen back on top
			_mc.addChild(_contentScreen);
			
			addChild(_mc);
		}
		
//		private function mouseDownHandler(e:MouseEvent):void
//		{
//			_mc.stage.addEventListener(Event.ENTER_FRAME, drag);
//			_mc.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
////			offsetX = mouseX - object.x;
//			var object:Object = e.target;
//			var objPos:Point = _mc.localToGlobal(new Point(object.x, object.y));
//			offsetY = mouseY - objPos.y - object.mouseY;
//			trace("offsetY: "+offsetY);
//			trace("mouseY: "+mouseY);
//			trace("object.mouseY: "+object.mouseY);
////			trace("object.y: "+object.y);
//			trace(_mc.localToGlobal(new Point(object.x, object.y)));
//			//
//			dragging = true;
//		}
		
//		private function mouseUpHandler(e:MouseEvent):void
//		{
//			_mc.stage.removeEventListener(Event.ENTER_FRAME, drag);
//			_mc.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
////			xSpeed = ms.getXSpeed();
////			ySpeed = ms.getYSpeed();
//			
//			TweenMax.to(_mc, .6, {y:CONTENTS_Y, ease:Quad.easeInOut});
//			
//			//
//			dragging = false;
//		}
		
//		private function drag(e:Event):void
//		{
//			
////			object.x = mouseX - offsetX;
////			_mc.y = mouseY - offsetY;
//			if(dragging){
//				destination.x=mouseX;
//				destination.y=mouseY+CLOSED_Y;
//			}
//			//object.x-=(object.x-destination.x)/speed;
//			_mc.y-=((_mc.y-destination.y)/speed);
//			
//			if (_mc.y <= CLOSED_Y) {
//				_mc.y = CLOSED_Y;
//				//				return;
//			}
//			if (_mc.y > CONTENTS_Y) {
//				_mc.y = CONTENTS_Y;
//			}
//		}

		
		protected function peekNavigation(event:ViewEvent):void
		{
			openNavigation();
			TweenMax.delayedCall(1, closeNavigation);
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
			//this was causing crashes
//			TweenMax.to(_mc, .6, {y:CLOSED_Y, ease:Quad.easeInOut, onComplete:panelsOff, onCompleteParams:[thisPageObj]});
			_navOpen = false;
			TweenMax.to(_blocker, 0, {autoAlpha:0});
			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			
			if (thisPageObj) {
				panelsOff(thisPageObj);
			} else {
				TweenMax.to(_mc, .6, {y:CLOSED_Y, ease:Quad.easeInOut});
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GLOBAL_NAV_CLOSED));
			}
		}
		
		private function panelsOff(thisPageObj:Object=null):void {
//			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.GLOBAL_NAV_CLOSED));
			
			if (thisPageObj) {
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, thisPageObj));
			}
			TweenMax.to(_mc, .6, {y:CLOSED_Y, ease:Quad.easeInOut});
		}
		
		protected function restartClick(event:MouseEvent):void
		{
			if (MovieClip(event.currentTarget).currentFrameLabel == "_on") return;
			
			DataModel.getInstance().buttonTap();
			buttonOnOffOthers(_restart);
			
			if (_blocker.alpha != .5) {
				TweenMax.to(_blocker, .5, {autoAlpha:.5, onComplete:showRestart});
			} else {
				showRestart();
			}
			
		}
		
		protected function restartPanelClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			closeNavigation();

			var tempObj:Object = new Object();
			
			if (MovieClip(event.currentTarget).name == "restart_btn") {
				tempObj.id = "TitleScreenView";
				EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.RESTART_BOOK));
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
			}
		}
		
		private function showRestart():void {
			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			if (_mc.y == RESTART_Y) {
				fadeInMC(_restartPanel);
			} else {
				TweenMax.to(_mc, .6, {y:RESTART_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_restartPanel]});
			}
			
		}
		
		protected function aboutClick(event:MouseEvent):void
		{
			if (MovieClip(event.currentTarget).currentFrameLabel == "_on") return;
			
			DataModel.getInstance().buttonTap();
			buttonOnOffOthers(_about);
			
			if (_blocker.alpha != .5) {
				TweenMax.to(_blocker, .5, {autoAlpha:.5, onComplete:showAbout});
			} else {
				showAbout();
			}
		}
		
		private function showAbout():void {
			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			if (_mc.y == CONTENTS_Y) {
				fadeInMC(_aboutMC);
			} else {
				TweenMax.to(_mc, .6, {y:CONTENTS_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_aboutMC]});
			}
			
		}
		
		protected function helpClick(event:MouseEvent):void
		{
			if (MovieClip(event.currentTarget).currentFrameLabel == "_on") return;
			
			DataModel.getInstance().buttonTap();
			buttonOnOffOthers(_help);
			
			if (_blocker.alpha != .5) {
				TweenMax.to(_blocker, .5, {autoAlpha:.5, onComplete:showHelp});
			} else {
				showHelp();
			}
		}
		
		private function showHelp():void {
			TweenMax.to(_contentScreen, 0, {autoAlpha:1});
			
			if (_mc.y == HELP_Y) {
				fadeInMC(_helpPanel);
			} else {
				TweenMax.to(_mc, .6, {y:HELP_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_helpPanel]});
			}
			
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
			if (MovieClip(event.currentTarget).currentFrameLabel == "_on") return;
			
			_contentsMC.visible = false;
			
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
			
			if (_mc.y == CONTENTS_Y) {
				fadeInMC(_contentsMC);
			} else {
//				TweenMax.to(_mc, .8, {y:CONTENTS_Y, ease:Quad.easeInOut, onComplete:fadeInMC, onCompleteParams:[_contentsMC]});
				TweenMax.to(_mc, .8, {y:CONTENTS_Y, ease:Quad.easeInOut});
				TweenMax.delayedCall(.8, fadeInMC, [_contentsMC]);
			}
		}
		
		private function fadeInMC(thisMC:MovieClip):void {
			_helpPanel.visible = false;
			_restartPanel.visible = false;
			_contentsMC.visible = false;
			_aboutMC.visible = false;
			
			thisMC.visible = true;
			
//			IMPORTANT!!!!
			/*
			app was crashing in God Mode when HISTORY was open
			turning off cacheAsBitmap on ContentsPage items and swapping X1 for imageBG_mc gfx fixed it!!!!
			*/
			
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