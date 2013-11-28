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
	import model.DecisionInfo;
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
	
	public class FourthDoorView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
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
		private var _compAlongIndex:int;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _bgSound:Track;
		private var _thirdDoor:Boolean;
		private var _nextSoundPlayed:Boolean;
		private var _graphicSound:Track;
		
		public function FourthDoorView()
		{
			_SAL = new SWFAssetLoader("theCattery.FourthDoorMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			!!!
			_picture.removeEventListener(MouseEvent.CLICK, swingPic);
			_scissors.removeEventListener(MouseEvent.CLICK, scissorClick);
			_comb.removeEventListener(MouseEvent.CLICK, combClick);
			
			_picture = null;
			_scissors = null;
			_comb = null;
			
			_scissorsComb = null;
//			_compAlongIndex = null;
//			
			_pageInfo = null;
			_bodyParts = null;
			
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
			
			// IMPORTANT! used in KittenContact
			DataModel.bleujeanna = true;
			
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
			
//			TESTING!!!
//			DataModel.thirdDoor = true;
//			
			
			_thirdDoor = DataModel.thirdDoor;
			
			var supplyIndex:int;
			if (DataModel.supplies) {
				supplyIndex = 0;
			} else {
				supplyIndex = 1;
			}
			
			_pageInfo = DataModel.appData.getPageInfo("fourthDoor");
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
					if (_thirdDoor) {
						copy = StringUtil.replace(copy, "[companionComing5]", "");
					} else {
						copy = StringUtil.replace(copy, "[companionComing5]", _pageInfo.companionComing5[_compAlongIndex]);
					}
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion3]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
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
					loader.autoDispose = true;
					_nextY += part.height + part.top;
					
					if (part.id == "picture") {
						_picture.y = _nextY + 30;
						_nextY += _picture.height;
					}
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
//			_decisions = new DecisionsView(_pageInfo.decisions,0x000000,true); //tint it black, showBG
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			
			if (_thirdDoor) {
				dv.push(_pageInfo.decisions[0]);
			} else {
				dv.push(_pageInfo.decisions[1]);
				dv.push(_pageInfo.decisions[2]);
			}
			_decisions = new DecisionsView(dv,0x000000,true);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 210;
			//unique hack due to 2 diff size pages
			_compAlongIndex = 0;
			if(_compAlongIndex == 1) {
				// size bg
				_mc.bg_mc.height = _decisions.y + 207;
				_frame.sizeFrame(_decisions.y + 207);
			} else {
				// size bg
				_mc.bg_mc.height = frameSize;
				_frame.sizeFrame(frameSize);
			}
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_bgSound = new Track("assets/audio/cattery/cattery_04.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
			_graphicSound = new Track("assets/audio/cattery/cattery_scissors.mp3");
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
			
			_scissors.addEventListener(MouseEvent.CLICK, scissorClick);
			_comb.addEventListener(MouseEvent.CLICK, combClick);
			
		} 
		
		protected function scissorClick(event:MouseEvent):void
		{
			showShine(_scissors);
		}
		
		protected function combClick(event:MouseEvent):void
		{
			showShine(_comb);
		}
		
		protected function shineTime():void
		{
			showShine(_scissors);
			TweenMax.delayedCall(.8, showShine, [_comb]);
		}		
		
		private function showShine(thisMC:MovieClip):void {
			if (thisMC == _scissors) {
				_graphicSound.start();
			}
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
			if (_dragVCont.scrollY > 1000 && !_nextSoundPlayed) {
				showShine(_scissors);
				_nextSoundPlayed = true;
			}
			
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
		
//		protected function clipMC(thisMC:MovieClip, thisHeight:int):void
//		{
//			thisMC.scrollRect = new Rectangle(0, 0, 768, thisHeight);
//			_dragVCont.refreshView(true);
//		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}