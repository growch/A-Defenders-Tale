package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.Impatience1MC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.StoryPart;
	
	import util.Formats;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class Impatience1View extends MovieClip implements IPageView
	{
		private var _mc:Impatience1MC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		
		public function Impatience1View()
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
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new Impatience1MC();
			
			_nextY = 110;
			
			_mc.tears1_mc.visible = false;
			_mc.tears2_mc.visible = false;
			
			_bodyParts = DataModel.appData.impatience1.body; 
			
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
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "last") {
						_mc.end_mc.y = Math.round(_tf.y + _tf.height + 80);
						_nextY += _mc.end_mc.height + 80;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					
					if (part.id == "butBut") {
						_mc.tears1_mc.y = _nextY+part.top;
						_mc.tears2_mc.y = _mc.tears1_mc.y + _mc.tears1_mc.height + 90;
					}
					
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += DataModel.appData.impatience1.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.impatience1.decisions,0xFFFFFF,true); //tint it white, showBG
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
			TweenMax.from(_mc.tears1_mc.teardrop_mc, 2, {y:-DataModel.APP_HEIGHT-_mc.tears1_mc.teardrop_mc.height, ease:Quad.easeInOut, delay:1});
			TweenMax.from(_mc.tears1_mc.teardrop_mc, 2.5, {scaleY:.5, ease:Bounce.easeInOut, delay:1});
			TweenMax.from(_mc.tears1_mc.drop1_mc, .4, {alpha:0, delay:2.6});
			TweenMax.from(_mc.tears1_mc.drop2_mc, .4, {alpha:0, delay:2.8});
			TweenMax.from(_mc.tears1_mc.drop3_mc, .4, {alpha:0, delay:3.0});
			
			TweenMax.from(_mc.tears2_mc.teardrop_mc, 2, {y:-DataModel.APP_HEIGHT-_mc.tears2_mc.teardrop_mc.height, ease:Quad.easeInOut});
			TweenMax.from(_mc.tears2_mc.teardrop_mc, 2.5, {scaleY:.5, ease:Elastic.easeInOut});
			TweenMax.from(_mc.tears2_mc.drop1_mc, .4, {alpha:0, delay:1.6});
			TweenMax.from(_mc.tears2_mc.drop2_mc, .4, {alpha:0, delay:1.8});
			TweenMax.from(_mc.tears2_mc.drop3_mc, .4, {alpha:0, delay:2.0});
			
			_mc.tears1_mc.visible = true;
			_mc.tears2_mc.visible = true;
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
			} else {
				
				if (!_scrolling) return;
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