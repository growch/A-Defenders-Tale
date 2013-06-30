package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
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
	
	public class CatRanchShoreView extends MovieClip implements IPageView
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
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		
		public function CatRanchShoreView()
		{
			_SAL = new SWFAssetLoader("theCattery.CatRanchShoreMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);

			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			!!!
			_picture.removeEventListener(MouseEvent.CLICK, swingPic);
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
		
		private function init(e:Event) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;	
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			_picture = _mc.picture_mc;
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
			
			_pageInfo = DataModel.appData.getPageInfo("catRanchShore");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					if (compAlongIndex == 0) {
						copy = StringUtil.replace(copy, "[companionComing1]", _pageInfo.companionComing1[compAlongIndex]);
					} else {
					// this is an array within an array
						copy = StringUtil.replace(copy, "[companionComing1]", _pageInfo.companionComing1[compAlongIndex][DataModel.defenderInfo.companion]);
					}
					
					copy = StringUtil.replace(copy, "[companionComing2]", _pageInfo.companionComing2[compAlongIndex]);
					copy = StringUtil.replace(copy, "[supplies]", _pageInfo.supplies[supplyIndex]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x000000), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = Math.round(_nextY + part.top);
					_mc.addChild(_tf);
					
					if (part.id == "picture") {
						_picture.y = Math.round(_tf.y + _tf.height) + 30;
					}
					
					_nextY += Math.round(_tf.height + part.top);
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += Math.round(part.height + part.top);
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
			
		}
		
		private function pageOn(e:ViewEvent):void {
//			return;
			_force = 20;
			_n = 0;
			_picture.addEventListener(MouseEvent.CLICK, swingPic);
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
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
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.killAll();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}