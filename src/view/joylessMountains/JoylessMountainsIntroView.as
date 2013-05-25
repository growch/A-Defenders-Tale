package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import assets.JoylessMountainsIntroMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DecisionInfo;
	import model.StoryPart;
	
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.displayObjects.RadialDot;
	import org.flintparticles.common.initializers.ColorInit;
	import org.flintparticles.common.initializers.ImageClass;
	import org.flintparticles.common.initializers.ScaleImageInit;
	import org.flintparticles.twoD.actions.DeathZone;
	import org.flintparticles.twoD.actions.Move;
	import org.flintparticles.twoD.actions.RandomDrift;
	import org.flintparticles.twoD.emitters.Emitter2D;
	import org.flintparticles.twoD.initializers.Position;
	import org.flintparticles.twoD.initializers.Velocity;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	import org.flintparticles.twoD.zones.LineZone;
	import org.flintparticles.twoD.zones.PointZone;
	import org.flintparticles.twoD.zones.RectangleZone;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	import model.PageInfo;
	
	public class JoylessMountainsIntroView extends MovieClip implements IPageView
	{
		private var _mc:JoylessMountainsIntroMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
//		private var _boat:MovieClip;
		private var _scrolling:Boolean;
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _wave1:MovieClip;
		private var _wave2:MovieClip;
		private var _wave3:MovieClip;
		private var _wave4:MovieClip;
		private var _wave5:MovieClip;
		private var _wave6:MovieClip;
		private var _emitter:Emitter2D;
		private var _renderer:DisplayObjectRenderer;
		private var _pageInfo:PageInfo;
		
		public function JoylessMountainsIntroView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
			_pageInfo = null;
			
			_frame.destroy();
			_frame = null;
			
			_decisions.destroy();
			_mc.removeChild(_decisions);
			_decisions = null;
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn);
			
			_dragVCont.removeChild(_mc);
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			
			//			if(DataModel.ipad1) return;
			_emitter.stop();
			_renderer.removeEmitter( _emitter );
			_mc.cloudSnow_mc.removeChild( _renderer );
			_renderer = null;
			_emitter = null;
			
			//for delayed calls
			TweenMax.killAll();
			
			DataModel.getInstance().removeAllChildren(_mc);
			

		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new JoylessMountainsIntroMC();
			
			_nextY = 110;
			
			_cloud1 = _mc.cloud1_mc;
			_cloud2 = _mc.cloud2_mc;
			_cloud3 = _mc.cloud3_mc;
			
			_wave1 = _mc.waves_mc.wave1_mc;
			_wave2 = _mc.waves_mc.wave2_mc;
			_wave3 = _mc.waves_mc.wave3_mc;
			_wave4 = _mc.waves_mc.wave4_mc;
			_wave5 = _mc.waves_mc.wave5_mc;
			_wave6 = _mc.waves_mc.wave6_mc;
			_wave1.visible = _wave2.visible = _wave3.visible = false;
			_wave4.visible = _wave5.visible = _wave6.visible = false;
			
			var introInt:int;
			if (DataModel.STONE_CAT) {
				introInt = 0;
			} else if (DataModel.STONE_COUNT > 0) {
				introInt = 1;
			} else {
				introInt = 2;
			}
			
			_pageInfo = DataModel.appData.getPageInfo("joylessIntro");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[intro1]", _pageInfo.intro1[introInt]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
//			_decisions.y = _nextY;
			//HACK CUZ DIFFERENT LENGTH INTROS
			_decisions.y = _mc.bg_mc.height - 210;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			//			
			var frameSize:int = _decisions.y + 210;
			// size bg
			_mc.bg_mc.height = frameSize;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
//			_frame = new FrameView(_mc.frame_mc); 
//			
//			var frameSize:int = _decisions.y + 210;
//			_frame.sizeFrame(frameSize);
//			if (frameSize < DataModel.APP_HEIGHT) {
//				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
//			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(e:ViewEvent):void {
//			return;
			initWave(_wave1);
			initWave(_wave2);
			initWave(_wave3);
			initWave(_wave4);
			initWave(_wave5);
			initWave(_wave6);
			
			setTimeout(waveUp, 1000, _wave1); 
			setTimeout(waveUp, 2000, _wave2); 
			setTimeout(waveUp, 3000, _wave3); 
			setTimeout(waveUp, 4000, _wave4);
			setTimeout(waveUp, 5000, _wave5);
			setTimeout(waveUp, 6000, _wave6);
			
			function initWave(thisWave:MovieClip):void {
				thisWave.initX = thisWave.x;
				thisWave.initY = thisWave.y;
				thisWave.downY = thisWave.initY + thisWave.height + 2;
				thisWave.y = thisWave.downY;
			}
			
			function waveUp(thisWave:MovieClip):void {
				thisWave.visible = true;
				thisWave.x = thisWave.initX -10;
				TweenMax.to(thisWave, 1, {y:thisWave.initY, x:"+10", ease:Quad.easeOut, delay:.7 + DataModel.getInstance().randomRange(.2, .6), onComplete:waveDown, onCompleteParams:[thisWave]});
			} 			
			function waveDown(thisWave:MovieClip): void {
				TweenMax.to(thisWave, 1, {y:thisWave.downY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:waveUp, onCompleteParams:[thisWave]});
			}
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			//!IMPORTANT otherwise crashes on iPad1
//			if (DataModel.ipad1) {
//				trace("ipad1 BEYOTCH!!!!");
//				return;
//			}
			
			//snowfall
			_emitter = new Emitter2D();
			
			_emitter.counter = new Steady( 15 );
			
			_emitter.addInitializer( new ImageClass( RadialDot, [2] ) );
			_emitter.addInitializer(new ColorInit(4288043961,4294967295));
			_emitter.addInitializer( new Position( new LineZone( new Point( -5, -5 ), new Point( 140, -5 ) ) ) );
			_emitter.addInitializer( new Velocity( new PointZone( new Point( 0, 45 ) ) ) );
			_emitter.addInitializer( new ScaleImageInit( 0.75, 2 ) );
			
			_emitter.addAction( new Move() );
			_emitter.addAction( new DeathZone( new RectangleZone( -20, -10, 180, 400 ), true ) );
			_emitter.addAction( new RandomDrift( 60, 40 ) );
			
			_renderer = new DisplayObjectRenderer();
			_renderer.addEmitter( _emitter );
			_mc.cloudSnow_mc.addChild( _renderer );
			_renderer.y = _mc.cloudSnow_mc.height;
			
			_emitter.start();
			_emitter.runAhead( 10 );
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				if (_emitter) {
					_emitter.pause();
				}
				_scrolling = true;
			} else {
				
				_cloud1.x -= .3;
				if (_cloud1.x < -_cloud1.width) _cloud1.x = 768;
				_cloud2.x -= .2;
				if (_cloud2.x < -_cloud2.width) _cloud2.x = 768;
				_cloud3.x -= .15;
				if (_cloud3.x < -_cloud3.width) _cloud3.x = 768;
				
				if (!_scrolling) return;
				if (_emitter) {
					_emitter.resume();
				}
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
//			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
//			TweenMax.to(_mc, 1, {alpha:0});
			TweenMax.killAll();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}

		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}