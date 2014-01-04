package view.shipwreck
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
	
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.Bubbles2;
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class CompanionView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _dungeonFish:MovieClip;
		private var _bubblesDung:Bubbles2; 
		private var _rendererDung:DisplayObjectRenderer;
		private var _pageInfo:PageInfo;
		private var _fish2:MovieClip;
		private var _fish3:MovieClip;
		private var _SAL:SWFAssetLoader;
		private var _bgSound:Track;
		private var _surfaceSound:Track;
		private var _nextSoundPlayed:Boolean;
		
		public function CompanionView()
		{
			_SAL = new SWFAssetLoader("shipwreck.CompanionMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_rendererDung.removeEmitter(_bubblesDung);
			_dungeonFish.removeChild(_rendererDung);
			_rendererDung = null;
			
			_mc.weapon_mc.removeEventListener(MouseEvent.CLICK, weaponClickShine);
			
			_dungeonFish = null;
			_fish2 = null;
			_fish3 = null;
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
			
			_pageInfo = DataModel.appData.getPageInfo("companion");
			_bodyParts = _pageInfo.body;
			
			_fish2 = _mc.fish2_mc;
			_fish3 = _mc.fish3_mc;
			
			//put fish back on top of bubbles
			_mc.addChild(_fish2);
			_mc.addChild(_fish3);
			
			_dungeonFish = _mc.dungeonFish_mc;
			_dungeonFish.visible = false; 
			_rendererDung = new DisplayObjectRenderer();
			_dungeonFish.addChild(_rendererDung);
			
			
			//!IMPORTANT
			DataModel.STONE_PEARL= true;
			DataModel.STONE_COUNT++;
			
			_mc.weapon_mc.stoneSerpent_mc.visible = false;
			if (DataModel.STONE_SERPENT) _mc.weapon_mc.stoneSerpent_mc.visible = true;
			_mc.weapon_mc.stoneSand_mc.visible = false;
			if (DataModel.STONE_SAND) _mc.weapon_mc.stoneSand_mc.visible = true;
			_mc.weapon_mc.stoneCat_mc.visible = false;
			if (DataModel.STONE_CAT) _mc.weapon_mc.stoneCat_mc.visible = true;
			
			var weaponIndex:int = DataModel.defenderInfo.weapon;
			
			_mc.weapon_mc.gotoAndStop(weaponIndex+1); // zero based
			_mc.weapon_mc.glows_mc.gotoAndStop(weaponIndex+1); // zero based
			_mc.weapon_mc.glows_mc.visible = false;
			_mc.weapon_mc.shine_mc.visible = false;
			
			var compInt:int = DataModel.defenderInfo.companion;
			
			var island1Int: int = DataModel.STONE_COUNT >= 4 ? 1:0;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_fish2.f1_mc);
			DataModel.getInstance().setGraphicResolution(_fish2.f2_mc);
			DataModel.getInstance().setGraphicResolution(_fish3.f1_mc);
			DataModel.getInstance().setGraphicResolution(_fish3.f2_mc);
			DataModel.getInstance().setGraphicResolution(_dungeonFish);
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
					
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[compInt]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[compInt]);
					copy = StringUtil.replace(copy, "[islands1]", _pageInfo.islands1[island1Int]);
					
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
					
					if (part.id == "dungeonFish") {
						_dungeonFish.y = Math.round(_tf.y - part.top/2);
					}
					
					if (part.id == "weapon") {
						_mc.weapon_mc.y = _nextY + _tf.height/5;
					}
					
					_nextY += _tf.height + part.top;
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					
					//EXCEPTION
					_fish2.y = _nextY + 420;
					_fish3.y = _nextY + 50;
					
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY; 
			
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 260;
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
			
			// bg sound
			_bgSound = new Track("assets/audio/shipwreck/shipwreck_04.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
			_surfaceSound = new Track("assets/audio/shipwreck/shipwreck_01.mp3");
			_surfaceSound.loop = true;
			_surfaceSound.fadeAtEnd = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			_fish2.goLeft = false;
			_fish3.goLeft = false;
			_fish2.orientRight = true; 
			_fish3.orientRight = true; 
			
			_mc.weapon_mc.glows_mc.cacheAsBitmap = true;
			_mc.weapon_mc.shine_mc.cacheAsBitmap = true;
			_mc.weapon_mc.glows_mc.mask = _mc.weapon_mc.shine_mc;
			
			_mc.weapon_mc.glows_mc.visible = true;
			_mc.weapon_mc.shine_mc.visible = true;
			
			_mc.weapon_mc.addEventListener(MouseEvent.CLICK, weaponClickShine);

			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function weaponClickShine(event:MouseEvent):void
		{
			shineWeapon();
		}
		
		private function shineWeapon():void {
			DataModel.getInstance().weaponSound();
			TweenMax.to(_mc.weapon_mc.shine_mc, .8, {y:420, ease:Quad.easeIn, delay:0, onComplete:resetShine}); 
		}
		
		private function resetShine():void {
			_mc.weapon_mc.shine_mc.y = -250;
		}
		
		private function showDungBubbles():void {
			_bubblesDung = new Bubbles2();
			_rendererDung.addEmitter(_bubblesDung);
			_bubblesDung.start();
			TweenMax.delayedCall(3, _bubblesDung.stopBubbles);
		}
		
		private function nextSound():void
		{
			_bgSound.stop(true);
			_surfaceSound.start(true);
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			
			if (!_dungeonFish.visible && _dragVCont.scrollY > 200) {
				_dungeonFish.visible = true;
				TweenMax.from(_dungeonFish, 1.5, {x:-_dungeonFish.width, ease:Quad, onComplete:showDungBubbles});
				TweenMax.from(_dungeonFish, .5, {rotation:-5, ease:Quad, repeat:2, yoyo:true});
			}
			
//			trace(_dragVCont.scrollY);
			if (_dragVCont.scrollY > 1800 && !_nextSoundPlayed) {
				nextSound();
				_nextSoundPlayed = true;
			}
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				
				_scrolling = true;
			} else {
				
				moveFish(_fish2, .8);
				moveFish(_fish3, .6);
				
//				trace(_dragVCont.scrollY); 1400
				
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