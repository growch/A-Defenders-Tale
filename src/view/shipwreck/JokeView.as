package view.shipwreck
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	import assets.JokeMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DecisionInfo;
	import model.PageInfo;
	import model.StoryPart;
	
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	import util.Formats;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.ApplicationView;
	import view.Bubbles;
	import view.Bubbles2;
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	import view.MapView;
	
	public class JokeView extends MovieClip implements IPageView
	{
		private var _mc:JokeMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		private var _fish1:MovieClip;
		private var _fish2:MovieClip;
		private var _fish3:MovieClip;
		private var _fish4:MovieClip;
		private var _dv:Vector.<DecisionInfo>;
		private var _submit1:MovieClip;
		private var _submit2:MovieClip;
		private var _whoText:TextField;
		private var _finalText:TextField;
		
//		ApplicationView, MapView
		
		public function JokeView()
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
			
			
			DataModel.getInstance().removeAllChildren(_mc);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new JokeMC(); 
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("joke");
			_bodyParts = _pageInfo.body;
			
			
			_fish1 = _mc.fish1_mc;
			_fish2 = _mc.fish2_mc;
			_fish3 = _mc.fish3_mc;
			_fish4 = _mc.fish4_mc;
			
			_submit1 = _mc.submit1_mc;
			_submit2 = _mc.submit2_mc;
			
			_submit2.visible = false;
			
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
					_mc.addChild(_tf);
					
					if (part.id == "who") {
						_whoText = _tf;
						_whoText.visible = false;
						_submit1.y = _nextY + 40;
					}
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "final") {
						_finalText = _tf;
						_finalText.visible = false;
					}
					
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop;
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY; 
			_mc.addChild(_decisions);
//			EXCEPTION
			_decisions.visible = false;
			
			//EXCEPTION
			var ogBGH:int = _mc.bg_mc.height;
			_mc.bg_mc.height = _decisions.y + 210;
			
			var diff:int =  ogBGH - _mc.bg_mc.height; 
			_fish2.y -= diff;
			_fish3.y -= diff;
			_fish4.y -= diff;
//			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _mc.bg_mc.height;
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
			_fish1.orientRight = true; 
			_fish2.goLeft = true;
			_fish3.goLeft = true;
			_fish4.goLeft = false;  
			_fish4.orientRight = true; 
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_submit1.submit_btn.addEventListener(MouseEvent.CLICK, knockQuestion);
			_submit2.submit_btn.addEventListener(MouseEvent.CLICK, knockAnswer);
		}
		
		private function knockQuestion(e:MouseEvent):void {
			if (_submit1.submit_txt.text == "") return;
			_submit1.submit_btn.removeEventListener(MouseEvent.CLICK, knockQuestion);
			
			_whoText.text = "“" + _submit1.submit_txt.text + _whoText.text;
			//otherwise text wasn't showing up
			_whoText.height += 100;
			_submit2.y = _whoText.y + _whoText.textHeight + 40;
			
			TweenMax.to(_submit1, .5, {autoAlpha:0});
			TweenMax.from(_whoText, .5, {autoAlpha:0});
			TweenMax.from(_submit2, .5, {autoAlpha:0});
		}
		
		private function knockAnswer(e:MouseEvent):void {
			if (_submit2.submit_txt.text == "") return;
			_submit2.submit_btn.removeEventListener(MouseEvent.CLICK, knockAnswer);
			
			_whoText.text = _whoText.text +  "“" + _submit2.submit_txt.text + "”";
			//otherwise text wasn't showing up
			_whoText.height += 100;
			_finalText.y = _whoText.y + _whoText.textHeight + 40;
			
			TweenMax.to(_submit2, .5, {autoAlpha:0});
			TweenMax.from(_finalText, .5, {autoAlpha:0});
			TweenMax.from(_decisions, .5, {autoAlpha:0});
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				
				_scrolling = true;
			} else {
				
				moveFish(_fish1, .5);
				moveFish(_fish2, .8);
				moveFish(_fish3, .6);
				moveFish(_fish4, .4);
				
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
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
			
			TweenMax.killAll();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}