package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import assets.StealMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DecisionInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	Cellar1View, NegotiateView
	public class StealView extends MovieClip implements IPageView
	{
		private var _mc:StealMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text; 
		private var _decisions:DecisionsView;		
		private var _frame:FrameView;
		
		public function StealView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
//			*** USED LATER
			DataModel.captainBattled = true;
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
		}
		
		public function destroy():void
		{
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
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade); 
			
			_mc = new StealMC();
			_mc.companion_mc.gotoAndStop(int(DataModel.defenderInfo.companion)+1); // zero based
			_mc.weapon_mc.gotoAndStop(int(DataModel.defenderInfo.weapon)+1); // zero based
			_mc.weapon_mc.glows_mc.gotoAndStop(int(DataModel.defenderInfo.weapon)+1); // zero based
			
			_mc.tornado_mc.visible = false;
			_mc.weapon_mc.glows_mc.visible = false;
			_mc.weapon_mc.shine_mc.visible = false;
			
			_nextY = 110;
			
			_bodyParts = DataModel.appData.steal.body;
			
			var weaponInt:int = int(DataModel.defenderInfo.weapon);
			
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[weapon1]", DataModel.appData.steal.weapon1[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[weapon2]", DataModel.appData.steal.weapon2[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[weapon3]", DataModel.appData.steal.weapon3[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[weapon4]", DataModel.appData.steal.weapon4[DataModel.defenderInfo.weapon]);
					copy = StringUtil.replace(copy, "[companion1]", DataModel.appData.steal.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", DataModel.appData.steal.companion2[DataModel.defenderInfo.companion]);
					
					
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
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			if (weaponInt == 0 || weaponInt == 2) {
				dv.push(DataModel.appData.steal.decisions[0]);
			} else {
				dv.push(DataModel.appData.steal.decisions[1]);
			}
			
			_nextY += DataModel.appData.steal.decisionsMarginTop
			_decisions = new DecisionsView(dv);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);

			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_frame = new FrameView(_mc.frame_mc);
			
			var frameSize:int = _decisions.y + 210;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
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
			TweenMax.to(_mc, 1, {alpha:0});
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}