package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import assets.Island1CatteryMC;
	
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
	
	public class Island1View extends MovieClip implements IPageView
	{
		private var _mc:Island1CatteryMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _cloud1:MovieClip;
		private var _cloud2:MovieClip;
		private var _cloud3:MovieClip;
		private var _wave1:MovieClip;
		private var _wave2:MovieClip;
		private var _wave3:MovieClip;
		private var _wave4:MovieClip;
		
		CatRanchShoreView
		public function Island1View()
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
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			//for delayed calls
			TweenMax.killAll();
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new Island1CatteryMC(); 
			
			_nextY = 110;
			
			_cloud1 = _mc.cloud1_mc;
			_cloud2 = _mc.cloud2_mc;
			_cloud3 = _mc.cloud3_mc;
			
			_wave1 = _mc.waves_mc.wave1_mc;
			_wave2 = _mc.waves_mc.wave2_mc;
			_wave3 = _mc.waves_mc.wave3_mc;
			_wave4 = _mc.waves_mc.wave4_mc;
			_wave1.visible = false;
			_wave2.visible = false;
			_wave3.visible = false;
			_wave4.visible = false;
			
			_bodyParts = DataModel.appData.island1.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", DataModel.appData.island1.companion1[DataModel.defenderInfo.companion]);
					
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
			_nextY += DataModel.appData.island1.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.island1.decisions,0xFFFFFF,true); //tint it white, showBG
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
//			return;
			_wave1.initX = _wave1.x;
			_wave1.initY = _wave1.y;
			_wave1.downY = _wave1.initY + _wave1.height + 2;
			_wave1.y = _wave1.downY;
			
			_wave2.initX = _wave2.x;
			_wave2.initY = _wave2.y;
			_wave2.downY = _wave2.initY + _wave2.height + 2;
			_wave2.y = _wave2.downY;
			
			_wave3.initX = _wave3.x;
			_wave3.initY = _wave3.y;
			_wave3.downY = _wave3.initY + _wave3.height + 2;
			_wave3.y = _wave3.downY;
			
			_wave4.initX = _wave4.x;
			_wave4.initY = _wave4.y;
			_wave4.downY = _wave4.initY + _wave4.height + 2;
			_wave4.y = _wave4.downY;
			
			function waveUp(thisWave:MovieClip):void {
				thisWave.visible = true;
				thisWave.x = thisWave.initX -10;
				TweenMax.to(thisWave, 1, {y:thisWave.initY, x:"+10", ease:Quad.easeOut, delay:.7 + DataModel.getInstance().randomRange(.2, .6), onComplete:waveDown, onCompleteParams:[thisWave]});
			} 			
			function waveDown(thisWave:MovieClip): void {
				TweenMax.to(thisWave, 1, {y:thisWave.downY, x:"+20", ease:Quad.easeIn, delay:0, onComplete:waveUp, onCompleteParams:[thisWave]});
			}
			
			setTimeout(waveUp, 1000, _wave1); 
			setTimeout(waveUp, 1500, _wave2); 
			setTimeout(waveUp, 2000, _wave3); 
			setTimeout(waveUp, 2500, _wave4); 
			
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
			} else {
				
				_cloud1.x -= .3;
				if (_cloud1.x < -_cloud1.width) _cloud1.x = 768;
				_cloud2.x -= .2;
				if (_cloud2.x < -_cloud2.width) _cloud2.x = 768;
				_cloud3.x -= .15;
				if (_cloud3.x < -_cloud3.width) _cloud3.x = 768;
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			// companion take or not
			if (event.data.decisionNumber == 0){
				DataModel.COMPANION_TAKEN = true;
			} else {
				DataModel.COMPANION_TAKEN = false;
			}
			TweenMax.to(_mc, 1, {alpha:0});
//			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}