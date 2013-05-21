package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import assets.FourthDoorMC;
	
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
	import model.PageInfo;
	
	public class FourthDoorView extends MovieClip implements IPageView
	{
		private var _mc:FourthDoorMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _picture:MovieClip;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _force:Number;
		private var _n:Number;
		private var _scissorsComb:MovieClip;
		private var _scissors:MovieClip;
		private var _comb:MovieClip;
		private var _shineTimer:Timer;
		private var _compAlongIndex:int;
		private var _pageInfo:PageInfo;
		
		public function FourthDoorView()
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
			
			_picture.removeEventListener(MouseEvent.CLICK, swingPic);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new FourthDoorMC();
			
			// companion take or not
			var compTakenInt:int = DataModel.COMPANION_TAKEN ? 0 : 1;
			
			
			_nextY = 110;
			
			_picture = _mc.picture_mc;
			
			_scissorsComb = _mc.scissorsComb_mc;
			_scissors = _scissorsComb.scissors_mc;
			_comb = _scissorsComb.comb_mc;
			
			_scissors.glow_mc.visible = false;
			_comb.glow_mc.visible = false;
			_scissors.shine_mc.visible = false;
			_comb.shine_mc.visible = false;
			
			if (DataModel.COMPANION_TAKEN) {
				_compAlongIndex = 0;
			} else {
				_compAlongIndex = 1;
			}
			
			//TESTING!!!
//			_compAlongIndex = 0;
			
			var supplyIndex:int;
			if (DataModel.supplies) {
				supplyIndex = 0;
			} else {
				supplyIndex = 1;
			}
			
			_pageInfo = DataModel.appData.getPageInfo("prologue");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companionComing1]", _pageInfo.companionComing1[_compAlongIndex]);
					copy = StringUtil.replace(copy, "[companionComing2]", _pageInfo.companionComing2[_compAlongIndex]);
					copy = StringUtil.replace(copy, "[companionComing3]", _pageInfo.companionComing3[_compAlongIndex]);
					copy = StringUtil.replace(copy, "[companionComing4]", _pageInfo.companionComing4[_compAlongIndex]);
					copy = StringUtil.replace(copy, "[companionComing5]", _pageInfo.companionComing5[_compAlongIndex]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion3]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//unique hack due to 2 diff size pages
					if (part.id == "narrowText" && _compAlongIndex == 1) {
						part.width = 350;
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x000000), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					if (part.id == "scissors") {
						if (_compAlongIndex == 0) {
							_scissorsComb.y = _nextY + 160;
							_comb.y += 80;
						} else {
							_scissorsComb.y = _nextY + 20;
							_comb.y -= 40;
						}
					}
					
					_nextY += _tf.height + part.top;
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
					
					if (part.id == "picture") {
						_picture.y = _nextY + 30;
						_nextY += _picture.height;
					}
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0x000000,true); //tint it black, showBG
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
//			_frame.sizeFrame(frameSize);
//			if (frameSize < DataModel.APP_HEIGHT) {
//				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
//			}
			
			//unique hack due to 2 diff size pages
			_compAlongIndex = 0;
			if(_compAlongIndex == 1) {
				//				clipMC(_mc.bg_mc, _decisions.y + 20);
//				_mc.bg_mc.scrollRect = new Rectangle(0, 0, 768, _decisions.y + 20);
				// size bg
				_mc.bg_mc.height = _decisions.y + 207;
				_frame.sizeFrame(_decisions.y + 207);
//				TweenMax.delayedCall(1, clipMC,[_mc.bg_mc, _decisions.y + 20]);
				
			} else {
				// size bg
				_mc.bg_mc.height = frameSize;
				_frame.sizeFrame(frameSize);
			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn});
		}
		
		private function pageOn(e:ViewEvent):void {
			
			_force = 20;
			_n = 0;
			_picture.addEventListener(MouseEvent.CLICK, swingPic); 
			
			_scissors.glow_mc.cacheAsBitmap = true;
			_comb.glow_mc.cacheAsBitmap = true;
			_scissors.glow_mc.mask = _scissors.shine_mc;
			_comb.glow_mc.mask = _comb.shine_mc;
			_scissors.glow_mc.visible = true;
			_comb.glow_mc.visible = true;
			_scissors.shine_mc.visible = true;
			_comb.shine_mc.visible = true;
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_shineTimer = new Timer(5000); 
			_shineTimer.addEventListener(TimerEvent.TIMER, shineTime); 
			_shineTimer.start();
		} 
		
		protected function shineTime(event:TimerEvent):void
		{
			showShine(_scissors);
			setTimeout(showShine, 800, _comb);
		}		
		
		
		private function showShine(thisMC:MovieClip):void {
			TweenMax.to(thisMC.shine_mc, 1, {y:thisMC.glow_mc.height+20, ease:Quad.easeIn, onComplete:function():void {thisMC.shine_mc.y = -240}});
		}
		
		private function swing():void {
			if (_force <= 0) {
				_force = 0;
				return;
			}
			_n += .1;
			_picture.rotation += ((Math.cos(_n)*_force) - _picture.rotation) * .08;
			_force -= .08;
		}
		
		protected function swingPic(event:MouseEvent):void
		{
			_force = 20;
			//			_n = 0;
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
			} else {
				
				swing();
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function clipMC(thisMC:MovieClip, thisHeight:int):void
		{
			thisMC.scrollRect = new Rectangle(0, 0, 768, thisHeight);
			_dragVCont.refreshView(true);
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}