package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.utils.setTimeout;
	
	import assets.IntroAllIslandsMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DecisionInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	import view.theCattery.Island1View;
	import model.PageInfo;
	
	public class IntroAllIslandsView extends MovieClip implements IPageView
	{
		private var _mc:IntroAllIslandsMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _boat:MovieClip;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		
		Island1View
		public function IntroAllIslandsView()
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
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_dragVCont.removeChild(_mc);
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new IntroAllIslandsMC();
			
			_nextY = 110;
			
			_boat = _mc.boat_mc;
			_boat.waves_mc.visible = false;
			
			_pageInfo = DataModel.appData.getPageInfo("introAllIslands");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[Island1]", DataModel.ISLAND_SELECTED[0]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion3]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[islands1]", _pageInfo.islands1[DataModel.CURRENT_ISLAND_INT]);
					copy = StringUtil.replace(copy, "[islands2]", _pageInfo.islands2[DataModel.CURRENT_ISLAND_INT]);
					copy = StringUtil.replace(copy, "[island1]", DataModel.ISLAND_SELECTED[0]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			dv.push(_pageInfo.decisions[DataModel.CURRENT_ISLAND_INT]);
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(dv);
//			_decisions.y = _nextY;
			_decisions.y = _mc.bg_mc.height-210;
			_mc.addChild(_decisions);
			
			//tint it white
			var c:ColorTransform = new ColorTransform(); 
			c.color = (0xFFFFFF);
			_decisions.transform.colorTransform = c;
			
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
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(e:ViewEvent):void {
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
			
			setTimeout(boatWave2Up, 1600);
			
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
			TweenMax.to(_mc, 1, {alpha:0});
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}