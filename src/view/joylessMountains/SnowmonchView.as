package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import assets.SnowmonchMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.StoryPart;
	
	import org.flintparticles.twoD.renderers.BitmapRenderer;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	import view.Smoke;
	
	
	public class SnowmonchView extends MovieClip implements IPageView
	{
		private var _mc:SnowmonchMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _renderer:BitmapRenderer;
		private var _smoke1:Smoke;
		private var _smoke2:Smoke;
		private var _smokeTimer:Timer;
		
		public function SnowmonchView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
			_frame.destroy();
			
			_frame = null;
			
			_decisions.destroy();
			_mc.removeChild(_decisions);
			_decisions = null;
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			//for delayed calls
			TweenMax.killAll();
			
			_smokeTimer.stop();
			_smokeTimer = null;
			
			_smoke1.stop();
			_smoke2.stop();
			_renderer.removeEmitter( _smoke1 );
			_renderer.removeEmitter( _smoke2 );
			_mc.snowmonch_mc.removeChild( _renderer );
			_renderer = null;
			_smoke1 = null;
			_smoke2 = null;
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new SnowmonchMC();
			
			_nextY = 110;
			
			_bodyParts = DataModel.appData.snowmonch.body; 
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", DataModel.appData.snowmonch.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", DataModel.appData.snowmonch.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[wardrobe1]", DataModel.appData.snowmonch.wardrobe1[DataModel.defenderInfo.wardrobe]);

					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "snowmonch") {
						_mc.snowmonch_mc.y = _nextY + 40;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += DataModel.appData.snowmonch.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.snowmonch.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_frame = new FrameView(_mc.frame_mc); 
			
			var frameSize:int = _decisions.y + 210;
			// size bg
			_mc.bg_mc.height = frameSize;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(e:ViewEvent):void {
			
			
			
			_smoke1 = new Smoke();
			_smoke1.x = _mc.snowmonch_mc.nostrilL_mc.x;
			_smoke1.y = _mc.snowmonch_mc.nostrilL_mc.y;
			
			_smoke2 = new Smoke();
			_smoke2.x = _mc.snowmonch_mc.nostrilR_mc.x;
			_smoke2.y = _mc.snowmonch_mc.nostrilR_mc.y;
			
			_renderer = new BitmapRenderer( new Rectangle( 200, 0, 300, 400 ) );
			_renderer.addEmitter( _smoke1 );
			_renderer.addEmitter( _smoke2 );
			_mc.snowmonch_mc.addChild( _renderer );
			
			startSmoke();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function startSmoke():void {
			showSmoke();
			_smokeTimer = new Timer(7000);
			_smokeTimer.addEventListener(TimerEvent.TIMER, smokeEvent);
			_smokeTimer.start();
		}
		
		private function smokeEvent(e:TimerEvent):void {
			showSmoke();
		}
		
		private function showSmoke():void {
			TweenMax.to(_renderer, 0, {autoAlpha:1});
			_smoke1.start();
			_smoke2.start();
			TweenMax.to(_renderer, 1.5, {autoAlpha:0, delay:4, onComplete:stopSmoke}); 
		}
		
		private function stopSmoke():void {
			_smoke1.stop();
			_smoke2.stop();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
				_smoke1.pause();
				_smoke2.pause();
				_smokeTimer.reset();
				
			} else {
				
				if (!_scrolling) return;
				
				_smoke1.resume();
				_smoke2.resume();
				_smokeTimer.start();
				
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}

		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			TweenMax.to(_mc, 1, {alpha:0});
		}

		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}