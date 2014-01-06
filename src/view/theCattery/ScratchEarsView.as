package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class ScratchEarsView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip; 
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _bgSound:Track;
		private var _endSound:Boolean;
		private var _secondSound:Track;
		private var _secondSoundPlayed:Boolean;
		private var _cardTF:Text;
		
		public function ScratchEarsView()
		{
			_SAL = new SWFAssetLoader("theCattery.ScratchEarsMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_mc.card_mc.removeChild(_cardTF);
//			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
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
			
		}
		
		protected function mcAdded(event:Event):void
		{
			_mc.removeEventListener(Event.ADDED_TO_STAGE, mcAdded);
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.MC_READY));
		}
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.addEventListener(Event.ADDED_TO_STAGE, mcAdded);
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			// companion take or not
			var hairIndex:int;
			var hayer:String = DataModel.defenderInfo.hair;
			if (hayer == "bald" || hayer == "none") {
				hairIndex = 0;
			} else if (DataModel.defenderInfo.gender == 0) {
				hairIndex = 1;
			} else if (hayer != "gray" && hayer != "grey" && hayer != "white") {
				hairIndex = 2;
			}
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("scratchEars");
			_bodyParts = _pageInfo.body;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.end_mc);
			DataModel.getInstance().setGraphicResolution(_mc.card_mc);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[hair1]", _pageInfo.hair1[hairIndex]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x000000), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					if (part.id == "last") {
						var index0:int = copy.indexOf("a view", 0);
						var rect0:Rectangle = _tf.getCharBoundaries(index0);
						_mc.card_mc.y = _tf.y + rect0.y + 50;
						
						_cardTF = new Text("DEFENDER " + DataModel.defenderInfo.defender.toUpperCase(), 
							Formats.businessCardFormat(24, "center", -48), 300);
						_cardTF.rotation = 4.4;
						_cardTF.x = 42;
						_cardTF.y = 88;
						_mc.card_mc.addChild(_cardTF);
						
						if (_cardTF.numLines > 1) {
							_cardTF.y -= 48;
						}
						
						_mc.end_mc.y = Math.round(_tf.y + _tf.height + 60);
						_nextY += _mc.end_mc.height;
					}
					
					_nextY += Math.round(_tf.height + part.top);
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
			_decisions = new DecisionsView(_pageInfo.decisions,0x000000,true); //tint it black, showBG
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 210;
			// size bg
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
			
			_bgSound = new Track("assets/audio/cattery/cattery_09.mp3");
			_bgSound.fadeAtEnd = true;
			_bgSound.start(true);
			_bgSound.loop = true;
			
			_secondSound = new Track("assets/audio/cattery/cattery_purring.mp3");
		}
		
		private function pageOn(e:ViewEvent):void {
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY > _dragVCont.maxScroll && !_endSound) {
				DataModel.getInstance().endSound();
				_endSound = true;
			}
			
			if (_dragVCont.scrollY >= 500 && !_secondSoundPlayed) {
				_secondSound.start();
				_secondSoundPlayed = true;
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