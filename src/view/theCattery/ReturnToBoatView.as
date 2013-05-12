package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import assets.ReturnToBoatMC;
	
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
	
	public class ReturnToBoatView extends MovieClip implements IPageView
	{
		private var _mc:ReturnToBoatMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _boat:MovieClip;
		private var _scrolling:Boolean;
		private var _frame:FrameView;
		private var _stars:StarryNight;
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _cloud4:MovieClip;
		private var _cloud5:MovieClip;		
		
		public function ReturnToBoatView()
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
			
			
			_stars.destroy();
			_stars = null;
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new ReturnToBoatMC();
			
			_nextY = 110;
			
			_cloud1 = _mc.clouds_mc.cloud1_mc;
			_cloud2 = _mc.clouds_mc.cloud2_mc;
			_cloud3 = _mc.clouds_mc.cloud3_mc;
			_cloud4 = _mc.clouds_mc.cloud4_mc;
			_cloud5 = _mc.clouds_mc.cloud5_mc;
			
			_stars = new StarryNight(680, 1200, .2, .8, 200);
			_stars.x = 50;
			_stars.y = 100;
			_mc.addChild(_stars);
			
			//tint
			var c:ColorTransform = new ColorTransform(); 
			c.color = 0xbfb3fc;
			c.alphaMultiplier = .9;
			_stars.transform.colorTransform = c;
			
			_bodyParts = DataModel.appData.returnToBoat.body;
			
			_boat = _mc.boat_mc;
			
			var stoneIndex: int = DataModel.STONE_COUNT;
			
			var pearlObtInt:int = DataModel.STONE_PEARL ? 0 : 1;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", DataModel.appData.returnToBoat.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", DataModel.appData.returnToBoat.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[pearlObtained]", DataModel.appData.returnToBoat.pearlObtained[pearlObtInt]);
					copy = StringUtil.replace(copy, "[stones1]", DataModel.appData.returnToBoat.stones1[stoneIndex]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "final") {
						_nextY += _mc.boat_mc.height;
					}
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += DataModel.appData.returnToBoat.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.returnToBoat.decisions,666,true); 
//			_decisions.y = _nextY;
			//EXCEPTION CUZ FIXED BG SIZE
			_decisions.y = _mc.bg_mc.height - 210;
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
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn});
		}
		
		private function pageOn(e:ViewEvent):void {
			_stars.start();
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_stars.pause();
				_boat.stop();
				_scrolling = true;
			} else {
				
				_cloud1.x -= .2;
				if (_cloud1.x < -_cloud1.width) _cloud1.x = 768;
				
				_cloud2.x -= .3;
				if (_cloud2.x < -_cloud2.width) _cloud2.x = 768;
				
				_cloud3.x -= .15;
				if (_cloud3.x < -_cloud3.width) _cloud3.x = 768;
				
				_cloud4.x -= .35;
				if (_cloud4.x < -_cloud4.width) _cloud4.x = 768;
				
				_cloud5.x -= .1;
				if (_cloud5.x < -_cloud5.width) _cloud5.x = 768;
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_stars.resume();
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
			// INCREMENT STONE COUNT!
			if (thisPage.decisionNumber == 1) DataModel.STONE_COUNT++;
		}
	}
}