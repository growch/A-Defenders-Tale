package view.prologue.coins
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import assets.CoinMC;
	
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
	import view.prologue.DocksView;
	
	
	public class Coin4View extends MovieClip implements IPageView
	{
		private var _mc:CoinMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text; 
		private var _decisions:DecisionsView;		
		private var _cup:MovieClip;
		private var _coin:MovieClip;
		private var _frame:FrameView; 
		
		DocksView, Coin5View
		public function Coin4View()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
			
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
			
			_mc = new CoinMC();
			_cup = _mc.cup_mc;
			_coin = _cup["coin_mc"];
			_coin.visible = false;
			
			_nextY = 110;
			
			_bodyParts = DataModel.appData.coin4.body;
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[gender1]", DataModel.appData.coin4.gender1[DataModel.defenderInfo.gender]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_tf.cacheAsBitmap = true;
					_tf.cacheAsBitmapMatrix = new Matrix(); 
					
					if (part.id == "coinImage") {
//						_cup.y = Math.round(_tf.y + (_tf.height-_cup["cup_mc"].height)/2) + 25;
						_cup.y = Math.round(_tf.y + (_tf.height-_cup["cup_mc"].height)/2) + 50; //lil' hacky cuz item above is image vs text
					}
					
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
			_nextY += DataModel.appData.coin4.decisionsMarginTop;
			_decisions = new DecisionsView(DataModel.appData.coin4.decisions);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			addChild(_dragVCont);
			
			_frame = new FrameView(_mc.frame_mc);
			
			var frameSize:int = _decisions.y + 210;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
			_dragVCont.refreshView(true);
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:coinAnimation}); 
		}
		
		private function pageOn(event:ViewEvent):void {
			coinAnimation();
		}
		
		private function coinAnimation() : void {
			_mc.addChild(_cup);
			
			_coin.y = -_cup.y - 170;
			_coin.visible = true;
			TweenMax.to(_coin, 1.2, {y:170, ease:Quad.easeIn});
			TweenMax.to(_coin, 0, {autoAlpha:0, delay:1.2});
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.to(_mc, 1, {alpha:0});
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			// coin/alms count
//			if (event.data.decisionNumber == 1) {
//				DataModel.coinCount++;
//			}
//			
//			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			// coin/alms count
			if (thisPage.decisionNumber == 1) {
				DataModel.coinCount++;
			}
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}