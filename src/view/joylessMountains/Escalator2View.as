package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import assets.Escalator2MC;
	
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
	
	public class Escalator2View extends MovieClip implements IPageView
	{
		private var _mc:Escalator2MC;
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
		private var _cloud4:MovieClip;
		private var _cloud5:MovieClip;
		private var _cloud6:MovieClip;
		private var _cloud7:MovieClip;
		private var _cloud8:MovieClip;
		private var _cloud9:MovieClip;
		private var _cloud10:MovieClip;
		private var _cloud11:MovieClip;
		private var _cloud12:MovieClip;
		private var _feather1:MovieClip;
		private var _feather2:MovieClip;
		private var _feather3:MovieClip;
		private var _feather4:MovieClip;
		private var _n:Number = 0;
		private var _force:Number = 20;
		
		public function Escalator2View()
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
			
			_mc = new Escalator2MC();
			
			_nextY = 110;
			
			_feather1 = _mc.monkey_mc.feather1_mc;
			_feather2 = _mc.monkey_mc.feather2_mc;
			_feather3 = _mc.monkey_mc.feather3_mc;
			_feather4 = _mc.monkey_mc.feather4_mc;
			
			_feather1.visible = false;
			_feather2.visible = false;
			_feather3.visible = false;
			_feather4.visible = false;
			
			_cloud1 = _mc.cloud1_mc;
			_cloud2 = _mc.cloud2_mc;
			_cloud3 = _mc.cloud3_mc;
			_cloud4 = _mc.cloud4_mc;
			_cloud5 = _mc.cloud5_mc;
			_cloud6 = _mc.cloud6_mc;
			_cloud7 = _mc.cloud7_mc;
			_cloud8 = _mc.cloud8_mc;
			_cloud9 = _mc.cloud9_mc;
			_cloud10 = _mc.cloud10_mc;
			_cloud11 = _mc.cloud11_mc;
			_cloud12 = _mc.cloud12_mc;
			
			var introInt:int = DataModel.escalator1 == true ? 0 : 1;
//			trace("introInt: "+introInt);
			
			_bodyParts = DataModel.appData.escalator2.body; 
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[intro1]", DataModel.appData.escalator2.intro1[introInt]);
					copy = StringUtil.replace(copy, "[companion1]", DataModel.appData.escalator2.companion1[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "monkey") {
						_mc.monkey_mc.y = _nextY + Math.round(_mc.monkey_mc.height/1.7);
					}
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += DataModel.appData.escalator2.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.escalator2.decisions,0xFFFFFF,true); //tint it white, showBG
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
			
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			//clouds 1-5 big, 6-7 medium, 8-12 small
			
			setTimeout(showFeather,1000,_feather1);
			setTimeout(showFeather,2000,_feather3);
			setTimeout(showFeather,3000,_feather2);
			setTimeout(showFeather,4000,_feather4);
		}
		
		private function showFeather(thisMC:MovieClip):void {
			thisMC.visible = true;
			thisMC._n = 0;
			thisMC._force = 20;
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
			} else {
				
				moveCloud(_cloud1, .3);
				moveCloud(_cloud2, .32);
				moveCloud(_cloud3, .34);
				moveCloud(_cloud4, .36);
				moveCloud(_cloud5, .38);

				moveCloud(_cloud6, .2);
				moveCloud(_cloud7, .25);

				moveCloud(_cloud8, .1);
				moveCloud(_cloud9, .12);
				moveCloud(_cloud10, .13);
				moveCloud(_cloud11, .14);
				moveCloud(_cloud12, .15);
				
				moveFeather(_feather1, 1.4);
				moveFeather(_feather2, 1.6);
				moveFeather(_feather3, 1.2);
				moveFeather(_feather4, 1.8);
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		private function moveCloud(thisCloud:MovieClip, thisAmt:Number):void {
			thisCloud.x -= thisAmt;
			if (thisCloud.x < - thisCloud.width) thisCloud.x = 768;
		}
		
		private function moveFeather(thisMC:MovieClip, thisAmt:Number):void {
//			trace("moveFeather: "+thisMC);
			if (!thisMC.visible) return;
			
			if (thisMC._force <= 0) {
				thisMC._n = 0;
				thisMC._force = 20;
			}

			thisMC._n += .1;
			thisMC.rotation += ((Math.sin(thisMC._n)*thisMC._force) - thisMC.rotation) * .08;
			thisMC._force -= .04;
			
			thisMC.y += thisAmt;
			
			if (thisMC.y > _mc.bg_mc.height - _mc.monkey_mc.y) 
			{
				thisMC.y = 0;
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