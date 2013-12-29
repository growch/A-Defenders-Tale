﻿package control {		import com.greensock.TweenMax;	import com.greensock.easing.Quad;	import com.greensock.loading.ImageLoader;		import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.display.MovieClip;	import flash.display.Sprite;	import flash.events.Event;	import flash.net.registerClassAlias;	import flash.system.ApplicationDomain;	import flash.system.Capabilities;	import flash.system.ImageDecodingPolicy;	import flash.system.LoaderContext;	import flash.system.System;	import flash.utils.getDefinitionByName;		import assets.ContentsPageMC;	import assets.FadeToBlackMC;		import events.ApplicationEvent;	import events.ViewEvent;		import model.ContentPanelInfo;	import model.DataModel;	import model.DecisionInfo;	import model.DefenderApplicationInfo;	import model.PageInfo;	import model.StoryPart;		import pl.randori.ane.Localytics;		import util.fpmobile.controls.DraggableVerticalContainer;		import view.ApplicationView;	import view.ContentsConfirmOverlayView;	import view.ContentsPageView;	import view.IPageView;	import view.MapView;	import view.NavigationView;	import view.NoInternetView;	import view.TitleScreenView;	import view.UnlockView;	import view._DebugView;	import view.capitol.AloneView;	import view.capitol.CapitolView;	import view.capitol.CastleView;	import view.capitol.ConfrontNeroView;	import view.capitol.DelayView;	import view.capitol.DontDrinkView;	import view.capitol.DrinkView;	import view.capitol.FightSmashleyView;	import view.capitol.GiantessView;	import view.capitol.GoWithPreviousView;	import view.capitol.ReasonSmashleyView;	import view.capitol.ReturnToShipView;	import view.capitol.SunlightGameView;	import view.capitol.TogetherView;	import view.capitol.WinView;	import view.joylessMountains.AwakenSerpentView;	import view.joylessMountains.CaveView;	import view.joylessMountains.Climb1View;	import view.joylessMountains.Climb2View;	import view.joylessMountains.Climb3View;	import view.joylessMountains.Climb4View;	import view.joylessMountains.DinnerView;	import view.joylessMountains.ElevatorView;	import view.joylessMountains.Escalator1View;	import view.joylessMountains.Escalator2View;	import view.joylessMountains.ExploreView;	import view.joylessMountains.Impatience1View;	import view.joylessMountains.Impatience2View;	import view.joylessMountains.Impatience3View;	import view.joylessMountains.JoylessMountainsIntroView;	import view.joylessMountains.METS4EvaView;	import view.joylessMountains.PicnicView;	import view.joylessMountains.Platform3View;	import view.joylessMountains.Platform4View;	import view.joylessMountains.PlayRiddlesView;	import view.joylessMountains.PlaySongView;	import view.joylessMountains.RallyView;	import view.joylessMountains.RiddleIntroView;	import view.joylessMountains.RosesView;	import view.joylessMountains.SnowmonchView;	import view.joylessMountains.StealStoneView;	import view.joylessMountains.StoneView;	import view.joylessMountains.TalkView;	import view.joylessMountains.TreasureView;	import view.prologue.BelowDeckView;	import view.prologue.BoatIntroView;	import view.prologue.BoatView;	import view.prologue.Cellar1View;	import view.prologue.Cellar2View;	import view.prologue.CrossSeaView;	import view.prologue.DocksView;	import view.prologue.FightView;	import view.prologue.IntroAllIslandsView;	import view.prologue.NegotiateView;	import view.prologue.PrologueView;	import view.prologue.ReasonView;	import view.prologue.SeaMonsterView;	import view.prologue.StealView;	import view.prologue.SuppliesView;	import view.prologue.TravelerView;	import view.prologue.TruthView;	import view.prologue.coins.Coin1View;	import view.prologue.coins.Coin2View;	import view.prologue.coins.Coin3View;	import view.prologue.coins.Coin4View;	import view.prologue.coins.Coin5View;	import view.prologue.coins.Coin6View;	import view.prologue.coins.Coin7View;	import view.sandlands.ApprenticeView;	import view.sandlands.FindWizardView;	import view.sandlands.HutView;	import view.sandlands.Sand2View;	import view.sandlands.Sand3View;	import view.sandlands.SandView;	import view.sandlands.SandlandsView;	import view.sandlands.SandstoneGameView;	import view.sandlands.SandstoneWinView;	import view.sandlands.ShipView;	import view.sandlands.ShoreView;	import view.sandlands.StraightView;	import view.sandlands.WaitView;	import view.sandlands.Well2View;	import view.sandlands.Well3View;	import view.sandlands.Well4View;	import view.sandlands.WellView;	import view.sandlands.WindingView;	import view.shipwreck.CaptainView;	import view.shipwreck.CompanionView;	import view.shipwreck.FollowCommodoreView;	import view.shipwreck.Jellyfish1View;	import view.shipwreck.JellyfishGameView;	import view.shipwreck.JokeView;	import view.shipwreck.Pearl1View;	import view.shipwreck.Reef1View;	import view.shipwreck.Reef2View;	import view.shipwreck.Shark1View;	import view.shipwreck.Shark2View;	import view.shipwreck.ShipwreckCoveView;	import view.shipwreck.SmegView;	import view.shipwreck.Starfish1View;	import view.shipwreck.Starfish2View;	import view.shipwreck.Starfish3View;	import view.theCattery.AcceptOfferView;	import view.theCattery.BallView;	import view.theCattery.BopMiceView;	import view.theCattery.CatRanchShoreView;	import view.theCattery.CatlingAffairsView;	import view.theCattery.FollowView;	import view.theCattery.FourthDoorView;	import view.theCattery.GameWonView;	import view.theCattery.Island1View;	import view.theCattery.KittenContactView;	import view.theCattery.LingerView;	import view.theCattery.MouseConsultationView;	import view.theCattery.NoTrespassingView;	import view.theCattery.PlayWithKittensView;	import view.theCattery.PrivateAudienceView;	import view.theCattery.RefuseOfferView;	import view.theCattery.RendezvousView;	import view.theCattery.ReturnToBoatView;	import view.theCattery.ScratchEarsView;	import view.theCattery.ThirdDoorView;

	/**	 * @author Mark Grochowski	 */	public class ViewController 	{		private var _mc : MovieClip;		private var _dm:DataModel;//		private var _titleScreen:TitleScreenView;//		private var _applicationScreen:ApplicationView;		private var _goViral:GoViralService;		private var _sectionHolder:Sprite;		private var _navigation:NavigationView;		private var _currentPage:IPageView;		private var _newPageClass:Class;		private var _fade:FadeToBlackMC;		private var _screenShot:Sprite;		private var _screenshotBMD:BitmapData;		private var _screenshotBMP:Bitmap;		private var _notificationHolder:Sprite;		private var _noInternet:NoInternetView;		private var _contentsPanelOverlay:ContentsConfirmOverlayView;		private var _unlockOverlay:UnlockView;		private var _viewReady:Boolean;		private var _assetUnloaded:Object;		private static const APP_KEY_LOCALYTICS:String = "672392a4c2e7053bb575585-0a2175b2-6fd4-11e3-945f-005cf8cbabd8";				private var _godMode:Object;				//HACK - this is to force the compiler to include these clases into the build;//		COMMON		TitleScreenView, ApplicationView, MapView//		PROLOGUE		PrologueView, Coin1View, Coin2View, Coin3View, Coin4View, Coin5View, Coin6View, Coin7View, BelowDeckView, BoatIntroView,		BoatView, Cellar1View, Cellar2View, CrossSeaView, DocksView, FightView, IntroAllIslandsView, NegotiateView, ReasonView,		SeaMonsterView, StealView, SuppliesView, TravelerView, TruthView//		JOYLESS		AwakenSerpentView, CaveView, Climb1View, Climb2View, Climb3View, Climb4View, DinnerView, ElevatorView, Escalator1View, 		Escalator2View, ExploreView, Impatience1View, Impatience2View, Impatience3View, JoylessMountainsIntroView,		METS4EvaView, PicnicView, Platform3View, Platform4View, PlayRiddlesView, PlaySongView, RallyView, RiddleIntroView, RosesView,		SnowmonchView, StealStoneView, TalkView, StoneView, TreasureView//		SANDLANDS		ApprenticeView, FindWizardView, HutView, Sand2View, Sand3View, SandlandsView, SandstoneGameView, SandstoneWinView, 		SandView, ShipView,	ShoreView, StraightView, WaitView, Well2View, Well3View, Well4View, WellView, WindingView//		SHIPWRECK		CaptainView, CompanionView, FollowCommodoreView, Jellyfish1View, JellyfishGameView, JokeView, Pearl1View,		Reef1View, Reef2View, Shark1View, Shark2View, ShipwreckCoveView, SmegView, Starfish1View, Starfish2View, Starfish3View//		THE CATTERY		AcceptOfferView, BallView, BopMiceView, CatlingAffairsView, CatRanchShoreView, _DebugView, FollowView, FourthDoorView, GameWonView,		Island1View, LingerView, MouseConsultationView, NoTrespassingView, PrivateAudienceView, RefuseOfferView, RendezvousView,		ReturnToBoatView, ScratchEarsView, ThirdDoorView, KittenContactView, PlayWithKittensView//		CAPITOL		CapitolView, GiantessView, FightSmashleyView, ReasonSmashleyView, CastleView, ConfrontNeroView, SunlightGameView, 		WinView, DrinkView, DontDrinkView, ReturnToShipView, GoWithPreviousView, DelayView, TogetherView, AloneView				public function ViewController( mc : MovieClip )		{			_mc = mc;						var myOS:String = Capabilities.os; 			var myOSLowerCase:String = myOS.toLowerCase();			if(myOSLowerCase.indexOf("ipad1,", 0) >= 0) {				DataModel.ipad1 = true;			} 			//			NEEDED FOR AOT COMPILING. OTHERWISE ASSET SWFS WON'T LOAD/RELOAD			DataModel.LoadContext = new LoaderContext(false, ApplicationDomain.currentDomain, null);//			!IMPORTANT!			DataModel.LoadContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD; //DOES THIS MAKE DIFFERENCE?						EventController.getInstance().addEventListener(ApplicationEvent.APPLICATION_SUBMITTED, appSubmitted);			EventController.getInstance().addEventListener(ApplicationEvent.RESTORE_PREVIOUS, restorePreviousBook);			EventController.getInstance().addEventListener(ApplicationEvent.NO_INTERNET, noInternet);			EventController.getInstance().addEventListener(ViewEvent.CLOSE_OVERLAY, removeOverlay);			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, assetLoaded);			EventController.getInstance().addEventListener(ViewEvent.ASSET_UNLOADED, assetUnloaded);//			EventController.getInstance().addEventListener(ApplicationEvent.RESTART_BOOK, restartBook);			EventController.getInstance().addEventListener(ViewEvent.GLOBAL_NAV_OPEN, navOpen);			EventController.getInstance().addEventListener(ViewEvent.GLOBAL_NAV_CLOSED, navClosed);			EventController.getInstance().addEventListener(ViewEvent.SHOW_PAGE, showPage);			EventController.getInstance().addEventListener(ViewEvent.SHOW_UNLOCK, showUnlock);									_dm = DataModel.getInstance(); 			_dm.getHistory();			_dm.checkUnlock();			//			TESTING!!!!!//			_dm.rebuildPrevious = true;//			if (_dm.rebuildPrevious) {//				_dm.restoreHistory();//			}						_sectionHolder = new Sprite(); 			_mc.addChild(_sectionHolder);			//			for iPad1 performance when navigation open			_screenShot = new Sprite();			_screenShot.cacheAsBitmap = true;			_screenShot.mouseChildren = false;			_screenShot.mouseEnabled = false;			_mc.addChild(_screenShot);						_fade = new FadeToBlackMC();//			_fade.cacheAsBitmap = true; ~~~!!!!!! THIS CAUSED CRASHES ON iPAD 1 !!!!!			TweenMax.to(_fade, 0, {autoAlpha:0});			_mc.addChild(_fade);						_navigation = new NavigationView();			//crashing without this on iPad1			TweenMax.to(_navigation, 0, {autoAlpha:0});			_mc.addChild(_navigation);			//			TESTING!!!!!!//			!!!!!!!!!!!! TURN THIS OFF FOR FINAL !!!!!!!!!!!!!!!!!//			testData(); //NEEDED FOR BELOW INDIVIDUAL PAGES//			!!!!!!!!!!!! TURN THIS OFF FOR FINAL !!!!!!!!!!!!!!!!!						//			TESTING!!!!//			_godMode = true;			//			TESTING!!!//			if (_dm.rebuildPrevious) {//				addPage(DataModel.PAGE_ARRAY[DataModel.PAGE_ARRAY.length-1].contentPanelInfo.pageID);//			} else {////				addPage("sandlands.WindingView");////				addPage("theCattery.FourthDoorView");////				addPage("capitol.SunlightGameView");////				addPage("TitleScreenView");////				addPage("ApplicationView");////				addPage("MapView");////				addPage("_DebugView");////				addPage("theCattery.PrivateAudienceView");////				addPage("shipwreck.FollowCommodoreView");//				addPage("prologue.coins.Coin4View"); ////				addPage("joylessMountains.TreasureView");//			}						//TODO TURN ON FOR FINAL!!!!!//			make titlescreen first page and implement restore after title screen			addPage("TitleScreenView");						//crashing without this on iPad1			TweenMax.to(_navigation, 0, {autoAlpha:1});						_notificationHolder = new Sprite();			_mc.addChild(_notificationHolder);			//			Localytics.isSupported;//			if (Localytics.isSupported) {//				Localytics.startSession(APP_KEY_LOCALYTICS);//			}					}				protected function restorePreviousBook(event:ApplicationEvent):void
		{			_dm.restoreHistory();			_navigation.contentsPanel.restorePrevious();
			addPage(DataModel.PAGE_ARRAY[DataModel.PAGE_ARRAY.length-1].contentPanelInfo.pageID);
		}				protected function assetLoaded(event:Event):void
		{
			_assetUnloaded = false;
		}		protected function assetUnloaded(event:Event):void
		{
			_assetUnloaded = true;
		}				protected function removeOverlay(event:ViewEvent):void
		{
			if (_noInternet) {				_noInternet.destroy();				_notificationHolder.removeChild(_noInternet);				_noInternet = null;			}
			if (_contentsPanelOverlay) {				_contentsPanelOverlay.destroy();				_notificationHolder.removeChild(_contentsPanelOverlay);				_contentsPanelOverlay = null;			}			if (_unlockOverlay) {				removeScreenshot();				_unlockOverlay.destroy();				_notificationHolder.removeChild(_unlockOverlay);				_unlockOverlay = null;			}		}				private function takeScreenshot():void {			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.TAKE_SCREENSHOT));			_sectionHolder.visible = false;						_screenshotBMD = new BitmapData(_mc.stage.stageWidth, _mc.stage.stageHeight, false);			_screenshotBMP = new Bitmap(_screenshotBMD);			_screenshotBMD.draw(_sectionHolder); 			//			_sectionHolder.visible = false;						_screenShot.addChild(_screenshotBMP);		}				private function removeScreenshot():void {			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.REMOVE_SCREENSHOT));//			trace("removeScreenshot");			_screenShot.removeChild(_screenshotBMP);			_sectionHolder.visible = true;			_screenshotBMD.dispose();		}				protected function navOpen(event:ViewEvent):void
		{			if (!DataModel.ipad1) return;							takeScreenshot();
		}				protected function navClosed(event:ViewEvent):void		{			if (!DataModel.ipad1) return;							removeScreenshot();		}		//		protected function restartBook(event:ApplicationEvent):void
//		{
//			_dm.resetBookData();
//		}				protected function noInternet(event:ApplicationEvent):void
		{
			_noInternet = new NoInternetView();			_notificationHolder.addChild(_noInternet);
		}		protected function showUnlock(event:ViewEvent):void
		{			takeScreenshot();
			_unlockOverlay = new UnlockView();			_notificationHolder.addChild(_unlockOverlay);
		}				protected function showPage(event:ViewEvent):void
		{//			trace("show page event.data.id: "+event.data.id);//			trace("_dm.contentsPageSelected: "+_dm.contentsPageSelected);//			trace("event.data.contentsPanelClick: "+event.data.contentsPanelClick);//			if (_dm.contentsPageSelected && !event.data.contentsPanelClick //				&& _navigation.contentsPanel.changingPath(event.data.id)) {						if (!event.data.contentsPanelClick && _navigation.contentsPanel.changingPath(event.data.id)) {				var tempObj:Object = new Object();				tempObj.id = event.data.id;								if (event.data.overwriteHistory) {					_navigation.contentsPanel.overwriteHistory();				} else {					_contentsPanelOverlay = new ContentsConfirmOverlayView(tempObj);					_notificationHolder.addChild(_contentsPanelOverlay);					return;				}							}						if (event.data.backOneStep) {				// returns appropriate id								event.data.id = _navigation.contentsPanel.backOneStep();			}						TweenMax.to(_fade, 1, {autoAlpha:1, onComplete:addPage, onCompleteParams:[event.data.id]});		}						protected function appSubmitted(event:ApplicationEvent):void
		{						var infObj:Object = event.data as Object;						DataModel.defenderInfo.defender = infObj.defender;			DataModel.defenderInfo.age = infObj.age;			DataModel.defenderInfo.hair = infObj.hair;			DataModel.defenderInfo.beverage = infObj.beverage;			DataModel.defenderInfo.gender = infObj.gender;			DataModel.defenderInfo.romantic = infObj.romantic;			DataModel.defenderInfo.companion = infObj.companion;			DataModel.defenderInfo.weapon = infObj.weapon;			DataModel.defenderInfo.instrument = infObj.instrument;			DataModel.defenderInfo.wardrobe = infObj.wardrobe;
			DataModel.defenderInfo.contact = infObj.contact;			DataModel.defenderInfo.contactGender = int(infObj.contactGender);			DataModel.defenderInfo.applicationDate = new Date();						// TESTING !!!!!!			if (infObj.defender == "") {				testData();			}//			TESTING!!!!!			if (String(infObj.defender).toUpperCase() == "GOD") {//				godMode();				_godMode = true;			}						var randNum:int;						if (DataModel.defenderInfo.gender == 2) {				// assign either male of female if undecided				randNum = Math.round(_dm.randomRange(0,1));				DataModel.defenderInfo.gender = randNum;			}			if (DataModel.defenderInfo.romantic == 2) {				// assign either male of female if undecided				randNum = Math.round(_dm.randomRange(0,1));				DataModel.defenderInfo.romantic = randNum;			}						TweenMax.to(_currentPage, 1, {y:-DataModel.APP_HEIGHT, 				ease:Quad.easeInOut, onComplete:addPage, onCompleteParams:["prologue.PrologueView"]});		}				private function testData():void {			if (!DataModel.defenderInfo) {				DataModel.defenderInfo = new DefenderApplicationInfo();			}//			DataModel.defenderInfo.defender = "Sarah";			DataModel.defenderInfo.defender = "Martha Mary Marlene May";			DataModel.defenderInfo.age = "30";			DataModel.defenderInfo.hair = "blond";			DataModel.defenderInfo.beverage = "Pinot Grigio";			DataModel.defenderInfo.gender = 1;			DataModel.defenderInfo.romantic = 0;			DataModel.defenderInfo.companion = 2;			DataModel.defenderInfo.weapon = 0;			DataModel.defenderInfo.instrument = 1;			DataModel.defenderInfo.wardrobe = 0;			DataModel.defenderInfo.contact = "Millicent";//			DataModel.defenderInfo.contactFullName = "Darci Manley";//			DataModel.defenderInfo.contactFBID = "100004309001809";			DataModel.defenderInfo.contactFullName = "Mark Grochowski";			DataModel.defenderInfo.contactFBID = "631203695";			DataModel.defenderInfo.twitterHandle = "@growch";//			DataModel.defenderInfo.contactFBID = null;			DataModel.defenderInfo.contactGender = 0;			DataModel.defenderInfo.applicationDate = new Date();						DataModel.SOCIAL_PLATFORM = DataModel.SOCIAL_FACEBOOK;//			DataModel.SOCIAL_PLATFROM = DataModel.SOCIAL_TWITTER;		}				private function godMode():void {			trace("godMode ON");			DataModel.GOD_MODE = true;			if (!DataModel.defenderInfo) {				DataModel.defenderInfo = new DefenderApplicationInfo();			}			DataModel.defenderInfo.defender = "Martha Mary Marlene May";			DataModel.defenderInfo.age = "30";			DataModel.defenderInfo.hair = "blond";			DataModel.defenderInfo.beverage = "Pinot Grigio";			DataModel.defenderInfo.gender = 1;			DataModel.defenderInfo.romantic = 0;			DataModel.defenderInfo.companion = 0;			DataModel.defenderInfo.weapon = 0;			DataModel.defenderInfo.instrument = 0;			DataModel.defenderInfo.wardrobe = 0;			DataModel.defenderInfo.contact = "Millicent";			DataModel.defenderInfo.contactFullName = "Darci Manley";			DataModel.defenderInfo.contactFBID = "100004309001809";			//			DataModel.defenderInfo.contactFBID = null;			DataModel.defenderInfo.contactGender = 0;			DataModel.defenderInfo.applicationDate = new Date();						EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.GOD_MODE_ON));		}						private function removeCurrentPage() : void {						if (_currentPage != null) {				_currentPage.destroy();				_sectionHolder.removeChild(MovieClip(_currentPage));				_currentPage = null;				_newPageClass = null;			}					}		private function addPage(thisPage:String, thisPackage:String = "view.") : void {			//			_mc.stage.frameRate = 30;						DataModel.CURRENT_PAGE_ID = thisPage;						removeCurrentPage();						//!GARBAGE COLLECT			System.gc();			//!GARBAGE COLLECT			System.gc();			//			trace("addPage _assetUnloaded: "+_assetUnloaded);			if (_assetUnloaded != null) {				if (!_assetUnloaded) {					TweenMax.delayedCall(.3, addPage, [thisPage, thisPackage]);					return;				}			}			//			trace(_godMode);			if (_godMode == true) {				godMode();			}						_newPageClass = getDefinitionByName(thisPackage+thisPage) as Class;			//			trace("addPage: "+thisPage);//			if (thisPage == "ApplicationView" || thisPage == "prologue.PrologueView") {//				EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.RESTART_BOOK));//			}						_currentPage = new _newPageClass();			_sectionHolder.addChild(MovieClip(_currentPage));						TweenMax.to(_fade, 0, {autoAlpha:1});			//			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, newPageOn);			EventController.getInstance().addEventListener(ViewEvent.MC_READY, newPageOn);									if (_dm.rebuildPrevious) {				trace("VC book has been read. REBUILD PREVIOUS SESSION!");				_dm.rebuildPrevious = false;			}		}				protected function newPageOn(event:Event):void
		{//			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, newPageOn);			EventController.getInstance().removeEventListener(ViewEvent.MC_READY, newPageOn);			//			trace("newPageOn");			if (_newPageClass == BopMiceView) {				_mc.stage.frameRate = DataModel.BOP_MICE_FPS;			} else {				_mc.stage.frameRate = 60;			}			//			TweenMax.to(_fade, 1, {autoAlpha:0, onComplete:delayedPageIn, delay:0});			TweenMax.to(_fade, 1, {autoAlpha:0, onComplete:pageIn, delay:0});			//			TESTING!!!!! AUDIO MUTED in _muted var of Tracks.as!!!		}				private function delayedPageIn():void {			TweenMax.delayedCall(.5, pageIn);		}				private function pageIn():void {//			trace("page in");//			System.gc();			if (_newPageClass != ApplicationView && _newPageClass != TitleScreenView) {				_dm.saveHistory();			}						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.PAGE_ON));					}			}}