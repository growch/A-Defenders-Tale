package view
{
	import assets.TitleMC;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class TitleScreenView extends MovieClip
	{
		private var _mc:TitleMC;
		private var _fog1:MovieClip;
		private var _sun:MovieClip;
		private var _beginBtn:MovieClip;
		private var _bgSound:Track;
		
		public function TitleScreenView()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_mc = new TitleMC;
			
			_fog1 = _mc.fog1_mc;
			_fog1.visible = false;
			
			_sun = _mc.sun_mc;
			
			_beginBtn = _mc.begin_btn;
			_beginBtn.mouseChildren = false;
			_beginBtn.buttonMode = true;
			_beginBtn.addEventListener(MouseEvent.CLICK, beginBook);
			
			
			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pulseSun}); 
			addChild(_mc);
		}
		
		public function destroy():void
		{
			_beginBtn.removeEventListener(MouseEvent.CLICK, beginBook);
			_bgSound = null;
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
			EventController.getInstance().dispatchEvent(new ApplicationEvent(ApplicationEvent.TITLE_DONE));
		}
		
	}
}