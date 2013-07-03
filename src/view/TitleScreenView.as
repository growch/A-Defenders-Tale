package view
{
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ApplicationEvent;
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
		
		public function TitleScreenView()
		{
			_SAL = new SWFAssetLoader("common.TitleScreenMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
		}
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_fog1 = _mc.fog1_mc;
			_fog1.visible = false;
			
			_sun = _mc.sun_mc;
			
			_beginBtn = _mc.begin_btn;
			_beginBtn.mouseChildren = false;
			_beginBtn.buttonMode = true;
			_beginBtn.addEventListener(MouseEvent.CLICK, beginBook);
			
			_bgSound = new Track("assets/audio/intro.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pulseSun}); 
			addChild(_mc);
		}
		
		public function destroy():void
		{
			_beginBtn.removeEventListener(MouseEvent.CLICK, beginBook);
			_bgSound = null;
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_SAL.destroy();
			_SAL = null;
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
			TweenMax.to(_beginBtn, .6, {scaleX:1.2, scaleY:1.2, ease:Quad.easeOut});
			showFog();
		}		
		
		
		private function showFog() : void {
			TweenMax.killTweensOf(_sun);
			_fog1.visible = true;
			TweenMax.from(_fog1, 2.8, {alpha:0, y:"+1200", scaleX:4, scaleY:4});
			TweenMax.to(_mc.bg_mc, .2, {alpha:0, delay:2.4}); 
			TweenMax.to(_sun, .2, {alpha:0, delay:2.4}); 
			TweenMax.to(_mc, .3, {alpha:0, delay:2.4, onComplete:nextScreen});
		}
		
		private function nextScreen() : void {
			_bgSound.stop(true);
//			EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.SHOW_APPLICATION));
			var tempObj:Object = new Object();
			tempObj.id = "ApplicationView";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
		}
		
	}
}