package view.shipwreck
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import assets.Reef1MC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import org.flintparticles.twoD.renderers.BitmapRenderer;
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	import util.Formats;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.Bubbles;
	import view.Bubbles2;
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class Reef1View extends MovieClip implements IPageView
	{
		private var _mc:Reef1MC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _bubbles1:Bubbles;
		private var _renderer1:DisplayObjectRenderer;
		private var _bubbles2:Bubbles;
		private var _renderer2:DisplayObjectRenderer;
		private var _bubbles3:Bubbles;
		private var _renderer3:DisplayObjectRenderer;
		private var _bubbles4:Bubbles;
		private var _renderer4:DisplayObjectRenderer;
		private var _dungeonFish:MovieClip;
		private var _bubblesDung:Bubbles2; 
		private var _rendererDung:DisplayObjectRenderer;
		private var _pageInfo:PageInfo;
		private var _clownFish:MovieClip;
		private var _fish2:MovieClip;
		private var _fish3:MovieClip;
		private var _fish4:MovieClip;
		
		Shark1View
		public function Reef1View()
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
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			//for delayed calls
			TweenMax.killAll();
			
			_bubbles1.stop();
			_bubbles2.stop();
			_bubbles3.stop();
			_bubbles4.stop();
			_bubblesDung.stop();
			
			_renderer1.removeEmitter(_bubbles1);
			_renderer2.removeEmitter(_bubbles2);
			_renderer3.removeEmitter(_bubbles3);
			_renderer4.removeEmitter(_bubbles4);
			_rendererDung.removeEmitter(_bubblesDung);

			_dungeonFish.removeChild(_rendererDung);
			
			_renderer1 = null;
			_renderer2 = null;
			_renderer3 = null;
			_renderer4 = null;
			_rendererDung = null;
			
			DataModel.getInstance().removeAllChildren(_mc);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new Reef1MC(); 
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("reef1");
			_bodyParts = _pageInfo.body;
			
			//put these first so text can go on top
			_renderer1 = new DisplayObjectRenderer();
			_mc.addChild(_renderer1);
			_renderer2 = new DisplayObjectRenderer();
			_mc.addChild(_renderer2);
			_renderer3 = new DisplayObjectRenderer();
			_mc.addChild(_renderer3);
			_renderer4 = new DisplayObjectRenderer();
			_mc.addChild(_renderer4);
			
			
			_clownFish = _mc.clown_mc;
			_fish2 = _mc.fish2_mc;
			_fish3 = _mc.fish3_mc;
			_fish4 = _mc.fish4_mc;
			
			//put fish back on top of bubbles
			_mc.addChild(_clownFish);
			_mc.addChild(_fish2);
			_mc.addChild(_fish3);
			_mc.addChild(_fish3);
			
			_dungeonFish = _mc.dungeonFish_mc;
			_dungeonFish.visible = false; 
			_rendererDung = new DisplayObjectRenderer();
			_dungeonFish.addChild(_rendererDung);
			
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					if (part.id == "dungeonFish") {
						_dungeonFish.y = Math.round(_tf.y - part.top/2);
					}
					
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
//			_decisions.y = _nextY; FIXED BG HEIGHT
			_decisions.y = _mc.bg_mc.height - 520;
			
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _mc.bg_mc.height;
			//size bg FIXED BG HEIGHT
//			_mc.bg_mc.height = frameSize;
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
			
		}
		
		private function pageOn(e:ViewEvent):void {
			_fish2.goLeft = true;
			_fish3.goLeft = true;
			_fish4.goLeft = false;  
			_clownFish.goLeft = false;
			_fish4.orientRight = true; 
			_clownFish.orientRight = true;
			
			_bubbles1 = new Bubbles();
			_renderer1.addEmitter( _bubbles1 );
			_renderer1.x = _mc.bubbles1_mc.x;
			_renderer1.y = _mc.bubbles1_mc.y;
			_bubbles1.start();
			
			_bubbles2 = new Bubbles();
			_renderer2.addEmitter( _bubbles2 );
			_renderer2.x = _mc.bubbles2_mc.x; 
			_renderer2.y = _mc.bubbles2_mc.y;
			_bubbles2.start();
			
			_bubbles3 = new Bubbles(true, -150);
			_renderer3.addEmitter( _bubbles3 );
			_renderer3.x = _mc.bubbles3_mc.x; 
			_renderer3.y = _mc.bubbles3_mc.y;
			_bubbles3.start();
			
			_bubbles4 = new Bubbles(true, -150);
			_renderer4.addEmitter( _bubbles4 );
			_renderer4.x = _mc.bubbles4_mc.x; 
			_renderer4.y = _mc.bubbles4_mc.y;
			_bubbles4.start();

			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function showDungBubbles():void {
			_bubblesDung = new Bubbles2();
			_rendererDung.addEmitter(_bubblesDung);
			_bubblesDung.start();
			setTimeout(_bubblesDung.stopBubbles, 3000);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			
			if (!_dungeonFish.visible && _dragVCont.scrollY > 1200) {
				_dungeonFish.visible = true;
				TweenMax.from(_dungeonFish, 1.5, {x:-_dungeonFish.width, ease:Quad, onComplete:showDungBubbles});
				TweenMax.from(_dungeonFish, .5, {rotation:-5, ease:Quad, repeat:2, yoyo:true});
			}
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
//				TweenMax.pauseAll();
				
				_bubbles1.pause()
				_bubbles2.pause();
				_bubbles3.pause();
				_bubbles4.pause();
				_scrolling = true;
			} else {
				
				moveFish(_fish2, .8);
				moveFish(_fish3, .6);
				moveFish(_fish4, .4);
				moveFish(_clownFish, .4);
				
//				trace(_dragVCont.scrollY); 1400
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_bubbles1.resume();
				_bubbles2.resume();
				_bubbles3.resume();
				_bubbles4.resume();
				_scrolling = false;
			}
		}
		
		private function moveFish(thisMC:MovieClip, thisAmt:Number):void {
			if (thisMC.goLeft) {
				thisMC.x -= thisAmt;
				if (thisMC.x < - (thisMC.width*2)) {
					thisMC.goLeft = false;
					if (thisMC.orientRight) {
						thisMC.scaleX = 1;
					} else {
						thisMC.scaleX = -1;
					}
					
				}
			} else {
				thisMC.x += thisAmt;
				if (thisMC.x > DataModel.APP_WIDTH + thisMC.width) {
					thisMC.goLeft = true;
					if (thisMC.orientRight) {
						thisMC.scaleX = -1;
					} else {
						thisMC.scaleX = 1;
					}
					
				}
			}
			
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_bubbles1.pause()
			_bubbles2.pause();
			_bubbles3.pause();
			_bubbles4.pause();
			
			TweenMax.killAll();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}