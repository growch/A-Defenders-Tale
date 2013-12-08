package view.prologue.coins
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
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	
	public class Coin5View extends MovieClip implements IPageView
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
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _coinSound:Track;
		private var _cupSound:Track;
		private var _bgSound:Track;
		
		public function Coin5View()
		{
			_SAL = new SWFAssetLoader("prologue.CoinMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
		}
		
		public function destroy():void
		{
//			
			_cup.removeEventListener(MouseEvent.CLICK, cupRattle);
			_coinSound = null;
			_cupSound = null;
			
			_cup = null;
			_coin = null;
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
			
			_cup = _mc.cup_mc;
			_coin = _cup["coin_mc"];
			_coin.visible = false;
			
			_nextY = 110;

			_pageInfo = DataModel.appData.getPageInfo("coin5");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
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
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop;
			_decisions = new DecisionsView(_pageInfo.decisions);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc);
			var frameSize:int = _decisions.y + 210;
			//			EXCEPTION FOR SCREENSHOT - PREVENTS WHITE FROM SHOWING UP
			// 			size black BG
			_mc.bg_mc.height = frameSize;
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
			
			// load sound
			_bgSound = new Track("assets/audio/prologue/prologue_outside.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		private function pageOn(event:ViewEvent):void {
			_coinSound = new Track("assets/audio/prologue/prologue_coin_drop.mp3");
			_cupSound = new Track("assets/audio/prologue/prologue_coin_shake.mp3");
			
			_cup.addEventListener(MouseEvent.CLICK, cupRattle);
			
			coinAnimation();
		}
		
		private function coinAnimation() : void {
			_mc.addChild(_cup);
			
			_coin.y = -_cup.y - 170;
			_coin.visible = true;
			TweenMax.to(_coin, 1, {y:170, ease:Quad.easeIn, onComplete:coinDropped});
		}
		
		protected function cupRattle(event:MouseEvent):void
		{
			_cupSound.start();
		}
		
		private function coinDropped():void {
			_coin.visible = false;
			_coinSound.start();
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			// coin/alms count
			if (event.data.decisionNumber == 1) {
				DataModel.coinCount++;
			}
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}