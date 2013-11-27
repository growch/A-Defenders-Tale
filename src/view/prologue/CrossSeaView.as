package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class CrossSeaView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _boat:MovieClip;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		
		public function CrossSeaView()
		{
			_SAL = new SWFAssetLoader("prologue.CrossSeaMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_boat = null;
//			
			_pageInfo = null;
			
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
			_SAL.destroy();
			_SAL = null;
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		public function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("crossSea");
			_bodyParts = _pageInfo.body;
			
			var supplyIndex:int;
			if (DataModel.supplies) {
				supplyIndex = 0;
			} else {
				supplyIndex = 1;
			}
			
			_boat = _mc.boat_mc;
			
			_boat.mask_mc.cacheAsBitmap = true;
			_boat.waves_mc.cacheAsBitmap = true;
			_boat.waves_mc.mask = _boat.mask_mc;
			
			_boat.boatMask_mc.cacheAsBitmap = true;
			_boat.boat_mc.cacheAsBitmap = true;
			_boat.boat_mc.mask = _boat.boatMask_mc;
			
			_boat.boatMask_mc.alpha = 1;
			_boat.mask_mc.alpha = 1;
			
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[supplies]", _pageInfo.supplies[supplyIndex]);
					copy = StringUtil.replace(copy, "[island1]", DataModel.ISLAND_SELECTED[0]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += Math.round(_tf.height + part.top);
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += Math.round(part.height + part.top);
				}
			}
			
			// decision
			_decisions = new DecisionsView(_pageInfo.decisions); //tint white show bg
//			EXCEPTION FOR FIXED HEIGHT BG
			_decisions.y = _mc.bg_mc.height - 50;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 260;
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
			
			//bg sound
			DataModel.getInstance().oceanLoop();
		}
		
		private function pageOn(event:ViewEvent):void {
			_boat.waves_mc.visible = true;
			
			var waveInitX:int = _boat.waves_mc.waves1_mc.x;
			var waveInitY:int = _boat.waves_mc.waves1_mc.y;
			var waveDownY:int = waveInitY + _boat.waves_mc.waves1_mc.height+2;
			_boat.waves_mc.waves1_mc.y = waveDownY;
			
			boatWave1Up();
			
			function boatWave1Up():void {
				_boat.waves_mc.waves1_mc.x = waveInitX -10;
				TweenMax.to(_boat.waves_mc.waves1_mc, 1, {y:waveInitY, x:"+10", ease:Quad.easeOut, delay:.5, onComplete:boatWave1Down});
			} 			
			function boatWave1Down(): void {
				TweenMax.to(_boat.waves_mc.waves1_mc, 1, {y:waveDownY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:boatWave1Up});
			}
			
			var wave2InitX:int = _boat.waves_mc.waves2_mc.x;
			var wave2InitY:int = _boat.waves_mc.waves2_mc.y;
			var wave2DownY:int = wave2InitY + _boat.waves_mc.waves2_mc.height+2;
			_boat.waves_mc.waves2_mc.y = wave2DownY;
			
			TweenMax.delayedCall(1.8, boatWave2Up);
			
			function boatWave2Up():void {
				_boat.waves_mc.waves2_mc.x = wave2InitX -10;
				TweenMax.to(_boat.waves_mc.waves2_mc, 1, {y:wave2InitY, x:"+10", ease:Quad.easeOut, delay:.5, onComplete:boatWave2Down});
			} 			
			function boatWave2Down(): void {
				TweenMax.to(_boat.waves_mc.waves2_mc, 1, {y:wave2DownY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:boatWave2Up});
			}
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_boat.stop();
				_scrolling = true;
			} else {
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_boat.play();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
	}
}