package view.prologue.coins
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import assets.CoinMC;
	import assets.FirefliesTextMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class Coin2View extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text; 
		private var _decisions:DecisionsView;		
		private var _cup:MovieClip;
		private var _coin:MovieClip;
		private var _frame:FrameView;
		private var _firefliesText:FirefliesTextMC;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		
		public function Coin2View()
		{
			_SAL = new SWFAssetLoader("prologue.CoinMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
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
			
//			_mc.removeChild(_firefliesText);
			removeEventListener(Event.ENTER_FRAME, scrollCheck);
		}
		
		public function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade); 
			
			_cup = _mc.cup_mc;
			_coin = _cup["coin_mc"];
			_coin.visible = false;
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("coin2");
			_bodyParts = _pageInfo.body;
			
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					if (part.id == "coinImage") {
						_cup.y = Math.round(_tf.y + (_tf.height-_cup["cup_mc"].height)/2);
					}
					
					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
				} else if (part.type == "image") {
					if (part.id == "fireflyText") {
						_firefliesText = new FirefliesTextMC();
						_firefliesText.x = 175;
						_firefliesText.y = Math.round(_nextY+part.top);
						_mc.addChild(_firefliesText);
					}
					
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += Math.round(part.height + part.top);
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop;
			_decisions = new DecisionsView(_pageInfo.decisions);
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
			addChild(_dragVCont);
			_dragVCont.refreshView(true);
		}
		
		private function pageOn(event:ViewEvent) : void {
			addEventListener(Event.ENTER_FRAME, scrollCheck);
			
			coinAnimation();
		}
		
		private function coinAnimation() : void {
			_mc.addChild(_cup);
			
			_coin.y = -_cup.y + 50;
			
			TweenMax.to(_coin, 1.6, {y:170, ease:Quad.easeIn, onComplete:function():void{_coin.visible = false;}});
			_coin.visible = true;
		}
		
		protected function scrollCheck(event:Event):void
		{
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_firefliesText.stopFlies();
				_scrolling = true;
			} else {
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_firefliesText.playFlies();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			// coin/alms count
			if (event.data.decisionNumber == 1) {
				DataModel.coinCount++;
			}
			
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
	}
}