package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.Cellar2MC;
	
	import control.EventController;
	import control.GoViralService;
	
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
	
	public class Cellar2View extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _goViral:GoViralService;
		private var _frame:FrameView;
		private var _magicSpacer:int = 210;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		
		public function Cellar2View()
		{
			_SAL = new SWFAssetLoader("prologue.Cellar2MC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
		}
		
		public function destroy() : void {
			_pageInfo = null;
			
			EventController.getInstance().removeEventListener(ViewEvent.FACEBOOK_CONTACT_RESPONSE, facebookContactResponded);
			
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
			_mc = _SAL.assetMC;
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_CONTACT_RESPONSE, facebookContactResponded);
			
			var compInt:int = DataModel.defenderInfo.companion;
			_mc.companion_mc.gotoAndStop(compInt+1);
			_mc.end_mc.visible = false;
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("cellar2");
			_bodyParts = _pageInfo.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[compInt]);
					copy = StringUtil.replace(copy, "[weapon1]", _pageInfo.weapon1[DataModel.defenderInfo.weapon]);
					
					// only add copy for no FB contact
					if (part.id == "noFacebook") {
						// don't add
						if (DataModel.defenderInfo.contactFBID != null) {
							break;
						}
					}
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					if (part.id == "companionImage") {
						
						if (compInt == 0) {
							_mc.companion_mc.y = Math.round(_tf.y);
						} else if (compInt ==1) {
							_mc.companion_mc.y = Math.round(_tf.y) + 170;
						} else {
							_mc.companion_mc.y = Math.round(_tf.y) + 50;
						}
						
					}

					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
					if (part.id == "noFacebook" && DataModel.defenderInfo.contactFBID == null) {
						_mc.end_mc.y = _nextY + 30;
						_mc.end_mc.visible = true;
						_nextY += _mc.end_mc.height + 30;
					}
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			
			if (DataModel.defenderInfo.contactFBID != null) {
				dv.push(_pageInfo.decisions[0]);
				dv.push(_pageInfo.decisions[1]);
				dv.push(_pageInfo.decisions[2]);
				
			} else {
				dv.push(_pageInfo.decisions[1]);
				dv.push(_pageInfo.decisions[2]);
			}	
			_decisions = new DecisionsView(dv);
			
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			// HACK for 3 decisions
			if(dv.length > 2) {
				_magicSpacer += 60;
			}
			
			_frame = new FrameView(_mc.frame_mc);
			var frameSize:int = _decisions.y + 210;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			// HACK for 3 decisions
			if(dv.length > 2) {
				_frame.sizeFrame(_decisions.y + _magicSpacer - 60);
				_frame.extraDecisionAdjust(60);
				_decisions.y += 20;
			}
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			
			
		}
		
		protected function facebookContactResponded(event:ViewEvent):void
		{
			var decY:int = _decisions.y;
			_decisions.destroy();
			_mc.removeChild(_decisions);
			
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			dv.push(_pageInfo.decisions[3]);
			_decisions = new DecisionsView(dv);
			_decisions.y = decY;
			_mc.addChild(_decisions);
			
			TweenMax.from(_decisions, 1, {alpha:0, delay:0});
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			if (event.data.id == "FacebookNotifyView") {
				_decisions.deactivateButton(0);
				_goViral = DataModel.getGoViral();
				_goViral.postWallHelp();
				return;
			}
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}