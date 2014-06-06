package view
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.DataModel;
	
	import util.SWFAssetLoader;
	
	public class TitleScreenView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _fog:MovieClip;
		private var _sun:MovieClip;
		private var _beginBtn:MovieClip;
		private var _beginNewBtn:MovieClip;
		private var _continuePreviousBtn:MovieClip;
		private var _bgSound:Track;
		private var _SAL:SWFAssetLoader;
		private var _helpWanted:MovieClip;
		private var _continueBtn:MovieClip;
		private var _screenshotBMD:BitmapData;
		private var _screenshotBMP:Bitmap;
		private var _VOSound:Track;
		private var _dm:DataModel;
		
		public function TitleScreenView()
		{
			_SAL = new SWFAssetLoader("common.TitleScreenMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		protected function mcAdded(event:Event):void
		{
			_mc.removeEventListener(Event.ADDED_TO_STAGE, mcAdded);
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.MC_READY));
		}
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.addEventListener(Event.ADDED_TO_STAGE, mcAdded);
			
			_dm = DataModel.getInstance();
			
			_fog = _mc.fog1_mc;
			_fog.visible = false;
			
			_sun = _mc.sun_mc;
			
			_beginBtn = _mc.begin_btn;
			_beginBtn.mouseChildren = false;
			_beginBtn.addEventListener(MouseEvent.CLICK, beginBook);
			
			_beginNewBtn = _mc.revisit_mc.beginNew_btn;
			_beginNewBtn.mouseChildren = false;
			_beginNewBtn.addEventListener(MouseEvent.CLICK, beginBook);

			_continuePreviousBtn = _mc.revisit_mc.continue_btn;
			_continuePreviousBtn.mouseChildren = false;
			_continuePreviousBtn.addEventListener(MouseEvent.CLICK, beginBook);
			
			// check if already used app
			if (DataModel.getInstance().alreadyRead) {
				_beginBtn.visible = false;
			} else {
				_mc.revisit_mc.visible = false;
			}
			
			_VOSound = new Track("assets/audio/global/Intro.mp3");
			
			_bgSound = new Track("assets/audio/global/DefenderTheme.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
			_helpWanted = _mc.helpWanted_mc;
			TweenMax.to(_helpWanted, 0, {autoAlpha:0});
			
			_continueBtn = _helpWanted.cta_btn;
			_continueBtn.addEventListener(MouseEvent.CLICK, continueClick);
			
//			_helpWanted.mask_mc.cacheAsBitmap = true;
//			_helpWanted.description_mc.cacheAsBitmap = true;
//			_helpWanted.description_mc.mask = _helpWanted.mask_mc;
//			_helpWanted.mask_mc.alpha = 1;
			_helpWanted.mask_mc.visible = false;
			_helpWanted.description_mc.visible = false;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_helpWanted.help_mc);
			DataModel.getInstance().setGraphicResolution(_helpWanted.description_mc);
			
			addChild(_mc);
		}
		
		public function destroy():void
		{
			if (_screenshotBMD) {
				_screenshotBMD.dispose();
				_screenshotBMD = null;
				
				_screenshotBMP = null;
			}
			
//			trace("TITLE DESTROY!!!");
			
			_dm = null;
			
//			TweenMax.killAll();
//			_mc.stopAllMovieClips();
			
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			_beginBtn.removeEventListener(MouseEvent.CLICK, beginBook);
			_beginBtn = null;

			_beginNewBtn.removeEventListener(MouseEvent.CLICK, beginBook);
			_beginNewBtn = null;

			_continuePreviousBtn.removeEventListener(MouseEvent.CLICK, beginBook);
			_continuePreviousBtn = null;
			
			_continueBtn.removeEventListener(MouseEvent.CLICK, continueClick);
			_continueBtn = null;
			
			_helpWanted = null;
			
			_fog = null;
			_sun = null;
			
			_VOSound.destroy();
			_bgSound.destroy();
			
			_VOSound = null;
			_bgSound = null;
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_SAL.destroy();
			_SAL = null;
			
			removeChild(_mc);
			_mc = null;
			
		}
		
		private function pageOn(e:ViewEvent):void {
			pulseSun();
		}
		
		private function pulseSun(): void {
			TweenMax.to(_sun, 1.2, {alpha:0, ease:Quad.easeInOut,repeat:-1,yoyo:true});
		}

		
		protected function beginBook(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			var thisBtn:MovieClip = event.target as MovieClip;
			
			TweenMax.to(thisBtn, .5, {scaleX:1.1, scaleY:1.1, ease:Quad.easeOut});
			
			TweenMax.killTweensOf(_sun);
			_fog.visible = true;
			
			if (thisBtn == _continuePreviousBtn) {
				_dm.rebuildPrevious = true;
//				TweenMax.from(_fog, 2.8, {alpha:0, y:"+1200", scaleX:4, scaleY:4, onComplete:fadeDownMC});
				//SOMETHING ABOUT ONCOMPLETE CAUSING SWF TO NOT UNLOAD
				TweenMax.from(_fog, 2.8, {alpha:0, y:"+1200", scaleX:4, scaleY:4});
				TweenMax.delayedCall(2.7, nextScreen);
			} else {
				TweenMax.from(_fog, 2.8, {alpha:0, y:"+1200", scaleX:4, scaleY:4, onComplete:takeScreenshot});
			}
			
			thisBtn = null;
		}		
		
		
		private function takeScreenshot():void {
			_screenshotBMD = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
			_screenshotBMP = new Bitmap(_screenshotBMD);
			_screenshotBMD.draw(_mc);
			
			_mc.addChild(_screenshotBMP);
			
			_mc.removeChild(_mc.bg_mc);
			_mc.removeChild(_sun);
			_mc.removeChild(_fog);
			_mc.removeChild(_beginBtn);
			
			//put this back on top
			_mc.addChild(_helpWanted);
			
			showHelp();
		}
		
		private function showHelp():void {
			TweenMax.to(_helpWanted, .6, {autoAlpha:1, onComplete:animateLines});
			_bgSound.volumeTo(1000, .35);
		}
		
		private function animateLines():void {
//			var offX:int = _helpWanted.mask_mc.line1_mc.x - _helpWanted.mask_mc.line1_mc.width;
//			
//			TweenMax.from(_helpWanted.mask_mc.line1_mc, 2.2, {x:offX, delay:1});
//			TweenMax.from(_helpWanted.mask_mc.line2_mc, 2.5, {x:offX, delay:4.0});
//			TweenMax.from(_helpWanted.mask_mc.line3_mc, 3.6, {x:offX, delay:6.4});
//			TweenMax.from(_helpWanted.mask_mc.line4_mc, 3.5, {x:offX, delay:8.5});
//			TweenMax.from(_helpWanted.mask_mc.line5_mc, 3.6, {x:offX, delay:11.2});
			
			TweenMax.from(_helpWanted.description_mc, 3.2, {alpha:0, delay:1});
			
			_helpWanted.description_mc.visible = true;
			
			_VOSound.start();
		}
		
		private function fadeDownParts():void {
//			TweenMax.allTo([_mc.bg_mc, _sun], .6, {autoAlpha:0, onComplete:nextScreen});
			TweenMax.allTo([_mc.bg_mc, _sun, _fog, _beginBtn], .4, {autoAlpha:0}, 0, showHelp);
		}
		
		private function continueClick(e:MouseEvent):void {
//			fadeDownMC();
			nextScreen();
		}
		
//		private function fadeDownMC():void {
//			TweenMax.killAll();
//			TweenMax.to(_mc, .6, {autoAlpha:0});
//			TweenMax.delayedCall(.5, nextScreen);
//		}
		
		private function nextScreen() : void {
			_bgSound.stop(true);
			_VOSound.stop(true);
			
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			
			if (_dm.rebuildPrevious) {
//				trace("RESTORING FROM TITLE");
				EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.RESTORE_PREVIOUS));
			} else {
//				trace("NEW BOOK FROM TITLE");
				var tempObj:Object = new Object();
				tempObj.id = "ApplicationView";
				tempObj.overwriteHistory = true;
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
				
				tempObj.id = null;
				tempObj.overwriteHistory = null;
				tempObj = null;
			}
			
		}
		
	}
}