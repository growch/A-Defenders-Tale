package view.shipwreck
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import assets.fonts.Caslon224BookItalic;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DecisionInfo;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class JokeView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
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
		private var _SAL:SWFAssetLoader;
		private var _sub1Text:TextField;
		private var _sub2Text:TextField;
		private var _bgSound:Track;
		
		public function JokeView()
		{
			_SAL = new SWFAssetLoader("shipwreck.JokeMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_sub1Text.removeEventListener(FocusEvent.FOCUS_IN, clearText);
			_sub2Text.removeEventListener(FocusEvent.FOCUS_IN, clearText);
			
			_sub1Text = null;
			_sub2Text = null;
			
			_fish1 = null;
			_fish2 = null;
			_fish3 = null;
			_fish4 = null;
			
			_submit1 = null;
			_submit2 = null;
			
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
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("joke");
			_bodyParts = _pageInfo.body;
			
			_fish1 = _mc.fish1_mc;
			_fish2 = _mc.fish2_mc;
			_fish3 = _mc.fish3_mc;
			_fish4 = _mc.fish4_mc;
			
			_submit1 = _mc.submit1_mc;
			_submit2 = _mc.submit2_mc;
			
			
			var tf:TextFormat = new TextFormat();
			tf.size = 32;
			tf.color = 0x8D8D8D;
			tf.align = "center";
			tf.font = new Caslon224BookItalic().fontName;
			
			_sub1Text = new TextField();
			_sub1Text.type = TextFieldType.INPUT;
			_sub1Text.antiAliasType = AntiAliasType.ADVANCED;
			_sub1Text.embedFonts = true;
			_sub1Text.width = 363;
			_sub1Text.x = -44;
			_sub1Text.y = 8;
			_sub1Text.defaultTextFormat = tf;
			_sub1Text.text = "enter knock knock name";
			_submit1.addChild(_sub1Text);
			
			_sub2Text = new TextField();
			_sub2Text.type = TextFieldType.INPUT;
			_sub2Text.antiAliasType = AntiAliasType.ADVANCED;
			_sub2Text.embedFonts = true;
			_sub2Text.width = 552;
			_sub2Text.x = 8;
			_sub2Text.y = 8;
			_sub2Text.defaultTextFormat = tf;
			_sub2Text.text = "enter punchline";
			_submit2.addChild(_sub2Text);
			
			_sub1Text.addEventListener(FocusEvent.FOCUS_IN, clearText);
			_sub2Text.addEventListener(FocusEvent.FOCUS_IN, clearText);
			
			_submit2.visible = false;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
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
					loader.autoDispose = true;
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
			_mc.bg_mc.height = _decisions.y + 210;
			
			_fish2.y -= _fish2.y - _decisions.y - 20;
			_fish3.y -= _fish3.y - _decisions.y + 100;
			_fish4.y -= _fish4.y - _decisions.y - 20;
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
			
			_bgSound = new Track("assets/audio/shipwreck/shipwreck_04.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		private function clearText(e:FocusEvent):void {
			e.target.text = "";
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
			if (_sub1Text.text == "") return;
			_submit1.submit_btn.removeEventListener(MouseEvent.CLICK, knockQuestion);
			
			_whoText.text = "“" + _sub1Text.text + _whoText.text;
			//otherwise text wasn't showing up
			_whoText.height += 100;
			_submit2.y = _whoText.y + _whoText.textHeight + 40;
			
			TweenMax.to(_submit1, .5, {autoAlpha:0});
			TweenMax.from(_whoText, .5, {autoAlpha:0});
			TweenMax.from(_submit2, .5, {autoAlpha:0});
		}
		
		private function knockAnswer(e:MouseEvent):void {
			if (_sub2Text.text == "") return;
			_submit2.submit_btn.removeEventListener(MouseEvent.CLICK, knockAnswer);
			
			_whoText.text = _whoText.text +  "“" + _sub2Text.text + "”";
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
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}