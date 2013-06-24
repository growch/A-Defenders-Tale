package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	import assets.BoatIntroMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.StoryPart;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	import view.StarryNight;
	import model.PageInfo;
	
	public class BoatIntroView extends MovieClip implements IPageView
	{
		private var _mc:BoatIntroMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;		
		private var _stars:StarryNight;
		private var _rotInc:Number;
		private var _boat:MovieClip;
		private var _posNegBoat:int;
		private var _frameCount:int;
		private var _posNegWave:int;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		
		public function BoatIntroView()
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
			
			_stars.destroy();
			_stars = null;
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new BoatIntroMC();
			_boat = _mc.boat_mc;
			_nextY = 140;
			
			_boat.stop();
			
			_stars = new StarryNight(680,350,.5,1,800);
			_stars.x = 50;
			_stars.y = 50;
//			_stars.alpha = .8;
//			TweenMax.to(_stars,0,{colorMatrixFilter:{colorize:0x191052, amount:.6}});
			var c:ColorTransform = new ColorTransform(); 
			c.color = (0x4124b3);
			_stars.transform.colorTransform = c;
			_mc.addChild(_stars);
			
			// put boat on top of stars
			_mc.addChild(_boat);
			
			_pageInfo = DataModel.appData.getPageInfo("boatIntro");
			_bodyParts = _pageInfo.body;
			
			var introNumber:int;
			if (DataModel.captainBattled && DataModel.defenderInfo.weapon == 0 || DataModel.captainBattled && DataModel.defenderInfo.weapon == 2) {
				introNumber = 0;
				_boat.y = 344;
			} else {
				introNumber = 1;
				_boat.y = 17;
			}
			
			_mc.bg_mc.gotoAndStop(introNumber+1);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[captainBattled]", _pageInfo.captainBattled[introNumber]);
					
					if (introNumber == 0) {
						copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[DataModel.defenderInfo.weapon]);
					} else {
						copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					}
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					
					_tf.y = Math.round(_nextY + part.top);
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
			_decisions = new DecisionsView(_pageInfo.decisions);
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
			
			_boat.waves_mc.visible = false;
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageAnimation}); 
		}
		
		private function pageOn(event:ViewEvent):void {
			_boat.play();
			_stars.start();
			
			var waveInitX:int = _boat.waves_mc.x;
			var waveInitY:int = _boat.waves_mc.y;
			var waveDownY:int = waveInitY + _boat.waves_mc.height+2;
			_boat.waves_mc.y = waveDownY;
			_boat.waves_mc.visible = true;
			
			boatWaveUp();
			
			function boatWaveUp():void {
				_boat.waves_mc.x = waveInitX -10;
				TweenMax.to(_boat.waves_mc, 1, {y:waveInitY, x:"+10", ease:Quad.easeOut, delay:.5, onComplete:boatWaveDown});
			}
			
			function boatWaveDown(): void {
				TweenMax.to(_boat.waves_mc, 1, {y:waveDownY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:boatWaveUp});
			}
			
			_rotInc = .07;
			_posNegBoat = 1;
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				_stars.pause();
				_boat.stop();
				TweenMax.pauseAll();
				_scrolling = true;
			} else {
				//boat movement
				if(_frameCount & 1) {
					// so it's not every frame
				} else {
					//boat
					_boat.boat_mc.rotation -= _posNegBoat * _rotInc;
					if(_boat.boat_mc.rotation >= 1) {
						_posNegBoat = 1;
					} 
					if(_boat.boat_mc.rotation <= - 1) {
						_posNegBoat = -1;
					}
				}
				_frameCount++;
				
				if (!_scrolling) return;
				_stars.resume();
				_boat.play();
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