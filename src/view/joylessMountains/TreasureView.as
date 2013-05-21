package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import assets.TreasureMC;
	
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
	import model.PageInfo;
	
	public class TreasureView extends MovieClip implements IPageView
	{
		private var _mc:TreasureMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _sparkleTimer:Timer;
		private var _weaponInt:int;
		private var _pageInfo:PageInfo;
		
		public function TreasureView()
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
			_sparkleTimer.stop();
			_sparkleTimer = null;
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new TreasureMC();
			
			_nextY = 110;
			
			_weaponInt = DataModel.defenderInfo.weapon;
			_mc.end_mc.visible = false;
			_mc.weapon_mc.visible = false;
			_mc.weapon_mc.glows_mc.visible = false;
			_mc.weapon_mc.shine_mc.visible = false;
			_mc.weapon_mc.gotoAndStop(_weaponInt+1);
			_mc.weapon_mc.glows_mc.gotoAndStop(_weaponInt+1);
			var weapon1Text :int = _weaponInt == 0 ? 0 : 1;
			
			_pageInfo = DataModel.appData.getPageInfo("treasure");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[weapon1Text]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[wardrobe1]", _pageInfo.wardrobe1[DataModel.defenderInfo.wardrobe]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[weapon2]", _pageInfo.weapon2[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[companion3]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion4]", _pageInfo.companion4[DataModel.defenderInfo.companion]);
					
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					if (part.id == "notDagger" && _weaponInt == 0) break;
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					
					var index0:int;
					var rect0:Rectangle;
					//!! cuz different layouts depending on weapon
					if (_weaponInt == 0) {
						if (part.id == "treasure") {
							index0 = copy.indexOf("submerged.", 0);
							rect0 = _tf.getCharBoundaries(index0);
							_mc.treasure_mc.y = rect0.y + 80;
						}
						
						_mc.end_mc.visible = true;
						_mc.end_mc.y = Math.round(_mc.treasure_mc.y + _mc.treasure_mc.height - 30);
						_nextY += _mc.end_mc.height + 100;
						
					} else {
						if (part.id == "treasure") { 
							index0 = copy.indexOf("eye.", 0);
							rect0 = _tf.getCharBoundaries(index0);
							_mc.treasure_mc.y = rect0.y;
							
							//<TEXTFORMAT RIGHTMARGIN='260'> in the XML was breaking the below
							//so made new node
//							var index1:int = copy.indexOf("submerged.", 0);
//							var rect1:Rectangle = _tf.getCharBoundaries(index1);
//							_mc.weapon_mc.y = rect0.y + 40;
							
						}
						if (part.id == "notDagger") {
							_mc.weapon_mc.y = _tf.y + 50;
							_mc.weapon_mc.visible = true;	
						}
						
					}	
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			
			// decision
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			if (_weaponInt == 0) {
				dv.push(_pageInfo.decisions[0]);
				dv.push(_pageInfo.decisions[1]);
			} else {
				dv.push(_pageInfo.decisions[2]);
				dv.push(_pageInfo.decisions[3]);
			} 
			
			_decisions = new DecisionsView(dv,0xFFFFFF,true);
			
			_nextY += _pageInfo.decisionsMarginTop
//			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
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
			
			// size bg differently depending on weapon
			_mc.bg_mc.height = frameSize;
			
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
			
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(e:ViewEvent):void {
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_mc.weapon_mc.glows_mc.cacheAsBitmap = true;
			_mc.weapon_mc.shine_mc.cacheAsBitmap = true;
			_mc.weapon_mc.glows_mc.mask = _mc.weapon_mc.shine_mc;
			
			_mc.weapon_mc.glows_mc.visible = true;
			_mc.weapon_mc.shine_mc.visible = true;
			
			shineWeapon();
			
			_sparkleTimer = new Timer(5000);
			_sparkleTimer.addEventListener(TimerEvent.TIMER, sparkleMotion);
			_sparkleTimer.start();
		}
		
		private function shineWeapon():void {
			TweenMax.to(_mc.weapon_mc.shine_mc, .8, {y:420, ease:Quad.easeIn, delay:4, onComplete:resetReplay}); 
		}
		
		private function resetReplay():void {
			_mc.weapon_mc.shine_mc.y = -250;
			shineWeapon();
		}
		
		private function sparkleMotion(e:TimerEvent) : void {
			playSparkle(_mc.treasure_mc.sparkle1_mc);
			TweenMax.delayedCall(.3, playSparkle, [_mc.treasure_mc.sparkle2_mc]);
			TweenMax.delayedCall(.5, playSparkle, [_mc.treasure_mc.sparkle3_mc]);
		}
		
		private function playSparkle(thisMC:MovieClip):void {
			thisMC.play();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
				_sparkleTimer.stop();
				
			} else {
				
				if (!_scrolling) return;
				
				_sparkleTimer.start();
				
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