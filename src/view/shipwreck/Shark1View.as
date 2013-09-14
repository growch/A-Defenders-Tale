package view.shipwreck
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.Bubbles;
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class Shark1View extends MovieClip implements IPageView
	{
		private var _mc:MovieClip; 
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _bubbles1:Bubbles;
		private var _renderer1:DisplayObjectRenderer;
		private var _bubbles2:Bubbles;
		private var _renderer2:DisplayObjectRenderer;
		private var _bubbles3:Bubbles;
		private var _renderer3:DisplayObjectRenderer;
		private var _shark:MovieClip;
		private var _fish1:MovieClip;
		private var _fish4:MovieClip;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		
		public function Shark1View()
		{
			_SAL = new SWFAssetLoader("shipwreck.Shark1MC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_bubbles1.stop();
			_bubbles2.stop();
			_bubbles3.stop();
			
			_renderer1.removeEmitter(_bubbles1);
			_renderer2.removeEmitter(_bubbles2);
			_renderer3.removeEmitter(_bubbles3);
			
			_renderer1 = null;
			_renderer2 = null;
			_renderer3 = null;
			
			_bubbles1 = null;
			_bubbles2 = null;
			_bubbles3 = null;
			
			_shark = null;
			_fish1 = null;
			_fish4 = null;
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
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("shark1");
			_bodyParts = _pageInfo.body;
			
			//put these first so text can go on top
			_renderer1 = new DisplayObjectRenderer();
			_mc.addChild(_renderer1);
			_renderer2 = new DisplayObjectRenderer();
			_mc.addChild(_renderer2);
			_renderer3 = new DisplayObjectRenderer();
			_mc.addChild(_renderer3);
			
			_fish1 = _mc.fish1_mc;
			_fish4 = _mc.fish4_mc;
			_shark = _mc.shark_mc;
			
			//put fish back on top of bubbles
			_mc.addChild(_fish4);
			_mc.addChild(_fish1);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[weapon2]", _pageInfo.weapon2[DataModel.defenderInfo.weapon]);

					
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
					
					if (part.id == "shark") {
						_shark.y = Math.round(_tf.y - part.top/2 - (_shark.height/2));
					}
					
					_nextY += _tf.height + part.top;
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY; 
//			_decisions.y = _mc.bg_mc.height - 520;
			
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			//CUSTOM!!!
			var frameSize:int = _decisions.y + 500;
			//CUSTOM
			var diff:int = frameSize - _mc.bg_mc.height;
			_mc.reef_mc.y += diff; 
			_fish1.y += diff; 
			_fish4.y += diff; 
			_mc.bubbles1_mc.y += diff; 
			_mc.bubbles2_mc.y += diff; 
			_mc.bubbles3_mc.y += diff; 
			
			_mc.bg_mc.height = frameSize;
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
			
		}
		
		private function pageOn(e:ViewEvent):void {
			_fish1.goLeft = false;  
			_fish4.goLeft = false;
			_fish1.orientRight = true; 
			_fish4.orientRight = true;
			
			_bubbles1 = new Bubbles();
			_renderer1.addEmitter( _bubbles1 );
			_renderer1.x = _mc.bubbles1_mc.x;
			_renderer1.y = _mc.bubbles1_mc.y;
			_bubbles1.start();
			
			_bubbles2 = new Bubbles();
			_renderer2.addEmitter( _bubbles2 );
			_renderer2.x = _mc.bubbles2_mc.x; 
			_renderer2.y = _mc.bubbles2_mc.y;
			_bubbles2.start();
			
			_bubbles3 = new Bubbles(true, -150);
			_renderer3.addEmitter( _bubbles3 );
			_renderer3.x = _mc.bubbles3_mc.x; 
			_renderer3.y = _mc.bubbles3_mc.y;
			_bubbles3.start();
			

			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				
				_bubbles1.pause()
				_bubbles2.pause();
				_bubbles3.pause();
				_scrolling = true;
			} else {
				
				moveFish(_fish1, .6);
				moveFish(_fish4, .8);
				
//				trace(_dragVCont.scrollY); 1400
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_bubbles1.resume();
				_bubbles2.resume();
				_bubbles3.resume();
				_scrolling = false;
			}
		}
		
		private function moveFish(thisMC:MovieClip, thisAmt:Number):void {
			if (thisMC.goLeft) {
				thisMC.x -= thisAmt;
				if (thisMC.x < - (thisMC.width*2)) {
					thisMC.goLeft = false;
					if (thisMC.orientRight) {
						thisMC.scaleX = 1;
					} else {
						thisMC.scaleX = -1;
					}
					
				}
			} else {
				thisMC.x += thisAmt;
				if (thisMC.x > DataModel.APP_WIDTH + thisMC.width) {
					thisMC.goLeft = true;
					if (thisMC.orientRight) {
						thisMC.scaleX = -1;
					} else {
						thisMC.scaleX = 1;
					}
					
				}
			}
			
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_bubbles1.pause()
			_bubbles2.pause();
			_bubbles3.pause();
			
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}