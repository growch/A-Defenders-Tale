package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
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
	
	public class StealView extends MovieClip implements IPageView
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
		
		public function StealView()
		{
			_SAL = new SWFAssetLoader("prologue.StealMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
//			*** USED LATER
			DataModel.captainBattled = true;
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
		}
		
		public function destroy():void
		{
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
		
		public function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade); 
			
			_mc.companion_mc.gotoAndStop(int(DataModel.defenderInfo.companion)+1); // zero based
			_mc.weapon_mc.gotoAndStop(int(DataModel.defenderInfo.weapon)+1); // zero based
			_mc.weapon_mc.glows_mc.gotoAndStop(int(DataModel.defenderInfo.weapon)+1); // zero based
			
			_mc.tornado_mc.visible = false;
			_mc.weapon_mc.glows_mc.visible = false;
			_mc.weapon_mc.shine_mc.visible = false;
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("steal");
			_bodyParts = _pageInfo.body;
			
			var weaponInt:int = int(DataModel.defenderInfo.weapon);
			
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[weapon2]", _pageInfo.weapon2[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[weapon3]", _pageInfo.weapon3[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[weapon4]", _pageInfo.weapon4[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// HACKY CUZ DARCI MADE ONE GRAPHIC THAT OTHER OPTIONS DON'T HAVE
					if (weaponInt == 1  && copy.indexOf("[exceptionalGraphic]") != -1) {
						_mc.tornado_mc.visible = true;
						_mc.tornado_mc.y = _nextY + part.top + 200;
						copy = StringUtil.replace(copy, "[exceptionalGraphic]", "");
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					if (part.id == "companionImage") {
						_mc.companion_mc.y = Math.round(_tf.y + 40);
					}
					
					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			if (weaponInt == 0 || weaponInt == 2) {
				dv.push(_pageInfo.decisions[0]);
			} else {
				dv.push(_pageInfo.decisions[1]);
			}
			
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(dv);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc);
			var frameSize:int = _decisions.y + 210;
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
			
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
			//HACK cuz mask was going off top of frame screwing up height
			_mc.weapon_mc.scrollRect = new Rectangle(-20, -40, 400, 737);
			TweenMax.delayedCall(1, clipMC,[_mc.weapon_mc, 737]);
			_mc.weapon_mc.x -= 20;
			_mc.weapon_mc.y -= 20;
		}
		
		private function pageOn(e:ViewEvent):void {
			_mc.weapon_mc.glows_mc.cacheAsBitmap = true;
			_mc.weapon_mc.shine_mc.cacheAsBitmap = true;
			_mc.weapon_mc.glows_mc.mask = _mc.weapon_mc.shine_mc;
			
			_mc.weapon_mc.glows_mc.visible = true;
			_mc.weapon_mc.shine_mc.visible = true;
			
			TweenMax.to(_mc.weapon_mc.shine_mc, .8, {y:420, ease:Quad.easeIn});
		}
		
		protected function clipMC(thisMC:MovieClip, thisHeight:int):void
		{
			thisMC.scrollRect = new Rectangle(-20, -40, 400, thisHeight);
			_dragVCont.refreshView(true);
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}