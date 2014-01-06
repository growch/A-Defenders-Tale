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
	
	public class GameWonView extends MovieClip implements IPageView
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
		
		
		public function GameWonView()
		{
			_SAL = new SWFAssetLoader("theCattery.GameWonMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			!!!
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
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
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
			
			_pageInfo = DataModel.appData.getPageInfo("gameWon");
			_bodyParts = _pageInfo.body;
			
			var weaponIndex:int = DataModel.defenderInfo.weapon;
			
			_mc.weapon_mc.gotoAndStop(weaponIndex+1); // zero based
			_mc.weapon_mc.glows_mc.gotoAndStop(weaponIndex+1); // zero based
			_mc.weapon_mc.glows_mc.visible = false;
			_mc.weapon_mc.shine_mc.visible = false;
			
			var stoneIndex: int;
			if (DataModel.STONE_COUNT >=1 && DataModel.STONE_COUNT <= 2) {
				stoneIndex = 1;
			} else if (DataModel.STONE_COUNT == 3) {
				stoneIndex = 2;
			}
			
			//!IMPORTANT
			DataModel.STONE_CAT = true;
			DataModel.STONE_COUNT++;
			
			_mc.weapon_mc.stonePearl_mc.visible = false;
			if (DataModel.STONE_PEARL) _mc.weapon_mc.stonePearl_mc.visible = true;
			_mc.weapon_mc.stoneSand_mc.visible = false;
			if (DataModel.STONE_SAND) _mc.weapon_mc.stoneSand_mc.visible = true;
			_mc.weapon_mc.stoneSerpent_mc.visible = false;
			if (DataModel.STONE_SERPENT) _mc.weapon_mc.stoneSerpent_mc.visible = true;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
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
					
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[weaponIndex]);
					copy = StringUtil.replace(copy, "[stones1]", _pageInfo.stones1[weaponIndex][stoneIndex]);
					
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
					
					if (part.id == "weapon") {
						_mc.weapon_mc.y = _tf.y;	
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
			
			_bgSound = new Track("assets/audio/cattery/cattery_02.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			_mc.weapon_mc.glows_mc.cacheAsBitmap = true;
			_mc.weapon_mc.shine_mc.cacheAsBitmap = true;
			_mc.weapon_mc.glows_mc.mask = _mc.weapon_mc.shine_mc;
			
			_mc.weapon_mc.glows_mc.visible = true;
			_mc.weapon_mc.shine_mc.visible = true;
			
//			shineWeapon();
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_mc.weapon_mc.addEventListener(MouseEvent.CLICK, weaponClick);
		}
		
		private function weaponClick(e:MouseEvent):void {
			shineWeapon();
		}
		
		private function shineWeapon():void {
			TweenMax.to(_mc.weapon_mc.shine_mc, .8, {y:420, ease:Quad.easeIn, onComplete:resetReplay}); 
			DataModel.getInstance().weaponSound();
		}
		
		private function resetReplay():void {
			_mc.weapon_mc.shine_mc.y = -250;
//			shineWeapon();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
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
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}