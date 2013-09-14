package view.capitol
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
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
	
	public class FightSmashleyView extends MovieClip implements IPageView
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
		
		public function FightSmashleyView()
		{
			_SAL = new SWFAssetLoader("capitol.FightReasonSmashleyMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
			_pageInfo = null;
			_bodyParts = null;
			
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
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 140;
			
			_mc.mallet_mc.visible = false;
			_mc.end_mc.visible = false;
			_mc.winPuddle_mc.visible = false;
			
			//used later in Escalator1View
			DataModel.climbDone = true;
			
			_pageInfo = DataModel.appData.getPageInfo("fightSmashley");
			_bodyParts = _pageInfo.body;
			
//			TESTING!!!!!
//			DataModel.STONE_SERPENT = true;
//			TESTING!!!!!!!
			
			var hasSerpentine:int = DataModel.STONE_SERPENT? 0 : 1;

			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[DataModel.defenderInfo.weapon][hasSerpentine]);
					
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
					
					if (hasSerpentine == 1) {
						_mc.mallet_mc.visible = true;
						
						_nextY += 60;
						
//						EXCEPTION CUZ DIFFERENT LENGTH TEXT
						if(DataModel.defenderInfo.weapon == 1) _nextY += 40;
						
						_mc.end_mc.visible = true;
						_mc.end_mc.y = _nextY + 20;
						
						if(DataModel.defenderInfo.weapon == 2) {
							_mc.mallet_mc.y = _mc.end_mc.y - _mc.mallet_mc.height;
						} else {
							_mc.mallet_mc.y = _mc.end_mc.y - _mc.mallet_mc.height + 60;
						}
						
						_nextY += _mc.end_mc.height + 40;
						
						break;
					} else {
						_mc.winPuddle_mc.visible = true;
						if (part.id == "topText") {
							_mc.winPuddle_mc.y = _nextY + 40;
							_nextY += _mc.winPuddle_mc.height;
						}
					}
					

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
//			_decisions = new DecisionsView(_pageInfo.decisions,0X040404,true); //tint it white, showBG
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			if (DataModel.STONE_SERPENT) {
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
			
		}
		
		private function pageOn(e:ViewEvent):void {
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
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
			//for delayed calls
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}