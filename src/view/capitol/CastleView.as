package view.capitol
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
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
	
	public class CastleView extends MovieClip implements IPageView
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
		private var _SAL:SWFAssetLoader;
		private var _bgSound:Track;
		private var _deadEnd:Boolean;
		private var _finalSoundPlayed:Boolean;
		
		public function CastleView()
		{
			_SAL = new SWFAssetLoader("capitol.CastleMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
			_mc.weapon_mc.removeEventListener(MouseEvent.CLICK, weaponClick);
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
			
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
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
			
			_nextY = 140;
			
			_mc.end_mc.visible = false;
			
			_pageInfo = DataModel.appData.getPageInfo("castle");
			_bodyParts = _pageInfo.body;
			
			var weaponIndex:int = DataModel.defenderInfo.weapon;
			
			_mc.weapon_mc.shine_mc.cacheAsBitmap = true;
			_mc.weapon_mc.glows_mc.cacheAsBitmap = true;
			_mc.weapon_mc.glows_mc.mask = _mc.weapon_mc.shine_mc;
			
			_mc.weapon_mc.gotoAndStop(weaponIndex+1); // zero based
			_mc.weapon_mc.glows_mc.gotoAndStop(weaponIndex+1); // zero based
			
			_mc.weapon_mc.visible = false;
			
			var hasSandstone:int = DataModel.STONE_SAND ? 0 : 1;
			// 1 = false !!!
			_deadEnd = !DataModel.STONE_SAND;
			
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.end_mc);
			DataModel.getInstance().setGraphicResolution(_mc.weapon_mc.stonePearl_mc);
			DataModel.getInstance().setGraphicResolution(_mc.weapon_mc.stoneSerpent_mc);
			DataModel.getInstance().setGraphicResolution(_mc.weapon_mc.stoneCat_mc);
			DataModel.getInstance().setGraphicResolution(_mc.weapon_mc.stoneSand_mc);
			DataModel.getInstance().setGraphicResolution(_mc.weapon_mc.weapon_mc);
			DataModel.getInstance().setGraphicResolution(_mc.weapon_mc.glows_mc.weapon_mc);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[0][hasSandstone]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion3]", _pageInfo.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[weapon2]", _pageInfo.weapon2[DataModel.defenderInfo.weapon]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x14142a), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					_nextY += _tf.height + part.top;
					
					if (hasSandstone == 1 && part.id == "bottomText") {
						
						_mc.end_mc.visible = true;
						_mc.end_mc.y = _nextY + 60;
						
						_nextY += _mc.end_mc.height + 50;
						
						break;
					} else {
						if (part.id == "bottomText") {
							var index0:int = copy.indexOf("puff", 0);
							var rect0:Rectangle = _tf.getCharBoundaries(index0);
							_mc.weapon_mc.y = _tf.y + rect0.y + 80;
							_mc.weapon_mc.visible = true;
						}
						
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
//			_decisions = new DecisionsView(_pageInfo.decisions,0X040404,true); //tint it white, showBG
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			if (DataModel.STONE_SAND) {
				dv.push(_pageInfo.decisions[2]);
			} else {
				dv.push(_pageInfo.decisions[0]);
				dv.push(_pageInfo.decisions[1]);
			}		
			_decisions = new DecisionsView(dv,0X040404,true);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 260;
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
			
			_bgSound = new Track("assets/audio/capitol/capitol_OutdoorSounds.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			_mc.weapon_mc.addEventListener(MouseEvent.CLICK, weaponClick);
		}
		
		private function weaponClick(e:MouseEvent):void {
			shineWeapon();
		}
		
		private function shineWeapon():void {
			TweenMax.to(_mc.weapon_mc.shine_mc, .8, {y:420, ease:Quad.easeIn, onComplete:reset}); 
			DataModel.getInstance().weaponSound();
		}
		
		private function reset():void {
			_mc.weapon_mc.shine_mc.y = -250;
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY >= _dragVCont.maxScroll && !_finalSoundPlayed && _deadEnd) {
				DataModel.getInstance().endSound();
				_finalSoundPlayed = true;
			}
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
			} else {
				
				if (!_scrolling) return;
				
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_dragVCont.stopTween();
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			
			//for delayed calls
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}