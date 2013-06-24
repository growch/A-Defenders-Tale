package view.prologue
{
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	
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
	
	public class TruthView extends MovieClip implements IPageView
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
		
		public function TruthView()
		{
			_SAL = new SWFAssetLoader("prologue.TruthMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
		}
		
		public function destroy() : void {
			_pageInfo = null;
			
			_frame.destroy();
			_frame = null;
			
			_decisions.destroy();
			_mc.removeChild(_decisions);
			_decisions = null;
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
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
			_mc = _SAL.assetMC
				
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			var compInt:int = DataModel.defenderInfo.companion;
			_mc.companion_mc.gotoAndStop(compInt+1);
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("truth");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[wardrobe1]", _pageInfo.wardrobe1[DataModel.defenderInfo.wardrobe]);
					copy = StringUtil.replace(copy, "[gender1]", _pageInfo.gender1[DataModel.defenderInfo.gender]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					if (part.id == "companionImage") {
						if (compInt == 0) {
							_mc.companion_mc.y = Math.round(_tf.y) + 60;
							_nextY += 20;
						} else if (compInt == 1) {
							_mc.companion_mc.y = Math.round(_tf.y) + 60;
							// HACK CUZ THIS ITEM HAS TEXT AFTER IT WHERE OTHERS DON'T
							_nextY -= Math.round(_tf.height - 60 - part.top - 20);
						} else {
							_mc.companion_mc.y = Math.round(_tf.y) + 30;
						}
						
					}
					
					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:.5, scaleY:.5});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
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
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}