package view
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	import util.SWFAssetLoader;
	
	public class TitleScreenView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _fog1:MovieClip;
		private var _sun:MovieClip;
		private var _beginBtn:MovieClip;
		private var _bgSound:Track;
		private var _SAL:SWFAssetLoader;
		private var _helpWanted:MovieClip;
		private var _continueBtn:MovieClip;
		
		public function TitleScreenView()
		{
			_SAL = new SWFAssetLoader("common.TitleScreenMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_fog1 = _mc.fog1_mc;
			_fog1.visible = false;
			
			_sun = _mc.sun_mc;
			
			_beginBtn = _mc.begin_btn;
			_beginBtn.mouseChildren = false;
			_beginBtn.addEventListener(MouseEvent.CLICK, beginBook);
			
			_bgSound = new Track("assets/audio/global/DefenderTheme.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
			_helpWanted = _mc.helpWanted_mc;
			TweenMax.to(_helpWanted, 0, {autoAlpha:0});
			
			_continueBtn = _helpWanted.cta_btn;
			_continueBtn.addEventListener(MouseEvent.CLICK, continueClick);
			
			_helpWanted.mask_mc.cacheAsBitmap = true;
			_helpWanted.text_mc.cacheAsBitmap = true;
			_helpWanted.text_mc.mask = _helpWanted.mask_mc;
			
			
			addChild(_mc);
		}
		
		public function destroy():void
		{
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			_beginBtn.removeEventListener(MouseEvent.CLICK, beginBook);
			_beginBtn = null;
			
			_continueBtn.removeEventListener(MouseEvent.CLICK, continueClick);
			_continueBtn = null;
			
			_helpWanted = null;
			
			_fog1 = null;
			_sun = null;
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
			
			TweenMax.to(_beginBtn, .5, {scaleX:1.1, scaleY:1.1, ease:Quad.easeOut});
			
			TweenMax.killTweensOf(_sun);
			_fog1.visible = true;
			TweenMax.from(_fog1, 2.8, {alpha:0, y:"+1200", scaleX:4, scaleY:4});
//			TweenMax.to(_mc.bg_mc, .2, {alpha:0, delay:2.4}); 
//			TweenMax.to(_sun, .2, {alpha:0, delay:2.4}); 
//			TweenMax.to(_mc, .2, {alpha:0, delay:2.4});
			
			TweenMax.delayedCall(2.0, showHelp);
		}		
		
//		WTF!!!!! for some reason this function was causing swf to not UNLOAD!!!
//		LESSON??? IT'S THE onComplete (i think?)
		private function showFog() : void {
//			TweenMax.killTweensOf(_sun);
//			_fog1.visible = true;
//			TweenMax.from(_fog1, 2.8, {alpha:0, y:"+1200", scaleX:4, scaleY:4});
//			TweenMax.to(_mc.bg_mc, .2, {alpha:0, delay:2.4}); 
//			TweenMax.to(_sun, .2, {alpha:0, delay:2.4}); 
//			TweenMax.to(_mc, .3, {alpha:0, delay:2.4, onComplete:nextScreen});
		}
		
		
		private function showHelp():void {
			_helpWanted.mask_mc.alpha = 1;
			
			TweenMax.to(_helpWanted, 1, {autoAlpha:1});
			
			var offX:int = _helpWanted.mask_mc.line1_mc.x - _helpWanted.mask_mc.line1_mc.width;
			
			TweenMax.from(_helpWanted.mask_mc.line1_mc, 2, {x:offX, delay:1.2});
			TweenMax.from(_helpWanted.mask_mc.line2_mc, 2, {x:offX, delay:3.0});
			TweenMax.from(_helpWanted.mask_mc.line3_mc, 2.4, {x:offX, delay:4.6});
			TweenMax.from(_helpWanted.mask_mc.line4_mc, 2.5, {x:offX, delay:6.5});
			TweenMax.from(_helpWanted.mask_mc.line5_mc, 2, {x:offX, delay:8.4});
			
			
		}
		
		private function continueClick(e:MouseEvent):void {
			
			TweenMax.to(_mc.bg_mc, .6, {alpha:0}); 
			TweenMax.to(_sun, .6, {alpha:0}); 
			TweenMax.to(_mc, .6, {alpha:0});
			
			TweenMax.delayedCall(.6, nextScreen);
		}
		
		private function nextScreen() : void {
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			
			var tempObj:Object = new Object();
			tempObj.id = "ApplicationView";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
		}
		
	}
}