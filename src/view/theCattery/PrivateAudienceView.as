package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
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
	
	public class PrivateAudienceView extends MovieClip implements IPageView
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
		private var _nextSound:Track;
		
		public function PrivateAudienceView()
		{
			_SAL = new SWFAssetLoader("theCattery.PrivateAudienceMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			!!!
			_mc.vizier_mc.removeEventListener(MouseEvent.CLICK, clickToShine);
//			
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			
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
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("privateAudience");
			_bodyParts = _pageInfo.body;
			
			_mc.vizier_mc.glow_mc.visible = false;
			_mc.vizier_mc.shine_mc.visible = false;
			
			// companion take or not
			var compTakenInt:int = DataModel.COMPANION_TAKEN ? 0 : 1;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.end_mc);
			DataModel.getInstance().setGraphicResolution(_mc.vizier_mc);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companionComing1]", _pageInfo.companionComing1[compTakenInt]);
					copy = StringUtil.replace(copy, "[companionComing2]", _pageInfo.companionComing2[compTakenInt]);
					copy = StringUtil.replace(copy, "[companionComing3]", _pageInfo.companionComing3[compTakenInt]);
					
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
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "final") {
						_mc.end_mc.y = _nextY + 40;
						_nextY += _mc.end_mc.height + 20;
					}
					
					if (part.id == "vizier") {
						_mc.vizier_mc.y = _nextY + 20;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier});
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
			
			_bgSound = new Track("assets/audio/cattery/cattery_03.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;	
			_bgSound.fadeAtEnd = true;	
			_bgSound.addEventListener(Event.SOUND_COMPLETE, nextSound);
			
			_nextSound = new Track("assets/audio/cattery/cattery_09.mp3");
		}
		
		private function nextSound(e:Event):void
		{
			_bgSound.stop(true);
			_nextSound.start(true);
		}
		
		private function pageOn(e:ViewEvent):void {
			
			_mc.vizier_mc.glow_mc.cacheAsBitmap = true;
			_mc.vizier_mc.shine_mc.cacheAsBitmap = true;
			_mc.vizier_mc.glow_mc.mask = _mc.vizier_mc.shine_mc;
			
			_mc.vizier_mc.glow_mc.visible = true;
			_mc.vizier_mc.shine_mc.visible = true;
			
			shineOn();
			
			_mc.vizier_mc.addEventListener(MouseEvent.CLICK, clickToShine);
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY > _dragVCont.maxScroll && !_endSound) {
				DataModel.getInstance().endSound();
				_endSound = true;
			}
		}
		
		private function clickToShine(e:MouseEvent):void {
			shineOn();
		}
		
		private function shineOn():void {
			TweenMax.to(_mc.vizier_mc.shine_mc, .8, {y:150, ease:Quad.easeIn, onComplete:resetReplay}); 
		}
		
		private function resetReplay():void {
			_mc.vizier_mc.shine_mc.y = 40;
//			shineOn();
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_dragVCont.stopTween();
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}