package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.BelowDeckMC;
	
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
	import view.MapView;
	
	public class BelowDeckView extends MovieClip implements IPageView
	{
		private var _mc:BelowDeckMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _mugs:DisplayObject;
		
		MapView
		public function BelowDeckView()
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
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_dragVCont.removeChild(_mc);
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new BelowDeckMC();
			_mc.mugs_mc.visible = false;
			
			_nextY = 110;
			
			_bodyParts = DataModel.appData.belowDeck.body;
			
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
					
					if (part.id == "shipwreck") {
						_mc.shipwreck_mc.y = Math.round(_tf.y + ((_tf.height - _mc.shipwreck_mc.height))/2);
					}
					
					if (part.id == "cattery") {
						_mc.cattery_mc.y = Math.round(_tf.y + ((_tf.height - _mc.cattery_mc.height))/2)-10;
					}
					
					if (part.id == "sandlands") {
						_mc.sandlands_mc.y = Math.round(_tf.y + ((_tf.height - _mc.sandlands_mc.height))/2);
					}
					
					if (part.id == "joyless") {
						_mc.joyless_mc.y = Math.round(_tf.y + ((_tf.height - _mc.joyless_mc.height))/2);
					}
					
					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, onComplete:onImageLoad, scaleX:.5, scaleY:.5});
					
					if (part.id == "mugs") {
						_mc.mugs_mc.y = Math.round(_nextY+part.top-20);
					}
					
					//begin loading
					loader.load();
					_nextY += Math.round(part.height + part.top);
				}
			}
			
			function onImageLoad(event:LoaderEvent):void {
				_mugs = event.target.content;
				_mugs.alpha = 0;
			}
			
			// decision
			_nextY += DataModel.appData.belowDeck.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.belowDeck.decisions);
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
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageAnimation}); 
		}
		
		private function pageOn(event:ViewEvent):void {
			pageAnimation();
		}
		
		private function pageAnimation(): void {
			var mugLX:int = _mc.mugs_mc.mugLeft_mc.x;
			var mugRX:int = _mc.mugs_mc.mugRight_mc.x;
			
			_mc.mugs_mc.mugLeft_mc.x -= _mc.mugs_mc.mugLeft_mc.width - 10;
			_mc.mugs_mc.mugRight_mc.x += _mc.mugs_mc.mugRight_mc.width - 10;
			
			TweenMax.to(_mc.mugs_mc.mugLeft_mc, 1, {bezierThrough:[{x:mugLX+90}, {x:mugLX}], ease:Quad.easeInOut});
			TweenMax.to(_mc.mugs_mc.mugRight_mc, 1, {bezierThrough:[{x:mugRX-90}, {x:mugRX}], ease:Quad.easeInOut});
			
			TweenMax.to(_mugs, .8, {alpha:1, delay:.8});
			
			_mc.mugs_mc.visible = true;
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
//			TweenMax.to(_mc, 1, {alpha:0});
//			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			TweenMax.killAll();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}