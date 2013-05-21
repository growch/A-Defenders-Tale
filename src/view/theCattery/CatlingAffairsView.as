package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.CatlingAffairsMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.StoryPart;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	import model.PageInfo;
	
	public class CatlingAffairsView extends MovieClip implements IPageView
	{
		private var _mc:CatlingAffairsMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _smokes:MovieClip;
		private var _pageInfo:PageInfo;
		
		
		public function CatlingAffairsView()
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
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new CatlingAffairsMC();
			
			// companion take or not
			var compTakenInt:int = DataModel.COMPANION_TAKEN ? 0 : 1;
			
			_nextY = 110;
			
			_smokes = _mc.smokes_mc;
			_smokes.visible = false;
			
			
			var compAlongIndex:int;
			if (DataModel.COMPANION_TAKEN) {
				compAlongIndex = 0;
			} else {
				compAlongIndex = 1;
			}
			
			var supplyIndex:int;
			if (DataModel.supplies) {
				supplyIndex = 0;
			} else {
				supplyIndex = 1;
			}
			
			_pageInfo = DataModel.appData.getPageInfo("catlingAffairs");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companionComing1]", _pageInfo.companionComing1[compAlongIndex]);
					copy = StringUtil.replace(copy, "[companionComing2]", _pageInfo.companionComing2[compAlongIndex]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x000000), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0x000000,true); //tint it black, showBG
//			_decisions.y = _nextY;
			//FIXED SIZE BG
			_decisions.y = _mc.bg_mc.height - 330;
			_mc.addChild(_decisions);
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_frame = new FrameView(_mc.frame_mc); 
			
			var frameSize:int = _decisions.y + 330;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
			
			if (DataModel.ipad1) {
				_smokes.cacheAsBitmap = true;
				_smokes.visible = true;
			}
			//EXCEPTION
//			_decisions.y = frameSize - 100;
			
//			TweenMax.from(_mc, 1, {alpha:0, delay:0, onComplete:pageOn});
		}
		
		private function pageOn(e:ViewEvent):void {
			if (DataModel.ipad1) return;
			
			_smokes.smoke3_mc.alpha = 0;
			_smokes.smoke3_mc.scaleX = _smokes.smoke3_mc.scaleY = 0;
			TweenMax.to(_smokes.smoke3_mc, 2.2, {alpha:.7, scaleX:2, scaleY:2, delay:0});
			TweenMax.to(_smokes.smoke3_mc, .5, {autoAlpha:0, delay:1.5});
			TweenMax.from(_smokes.smoke2_mc, 2, {alpha:0, scaleX:0, scaleY:0, delay:0});
			TweenMax.from(_smokes.smoke1_mc, 2.2, {alpha:0, scaleX:.2, scaleY:.2, delay:0});
			_smokes.visible = true;
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