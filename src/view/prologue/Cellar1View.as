package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import assets.Cellar1MC;
	
	import control.EventController;
	import control.GoViralService;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DecisionInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.ApplicationView;
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class Cellar1View extends MovieClip implements IPageView
	{
		private var _mc:Cellar1MC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _goViral:GoViralService;
		private var _frame:FrameView;
		private var _magicSpacer:int = 210;
		
		PrologueView, ApplicationView, BoatIntroView
		public function Cellar1View()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
		}
		
		public function destroy() : void {
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
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			EventController.getInstance().addEventListener(ViewEvent.FACEBOOK_CONTACT_RESPONSE, facebookContactResponded);
			
			_mc = new Cellar1MC();
			_mc.companion_mc.gotoAndStop(DataModel.defenderInfo.companion+1);
			_mc.end_mc.visible = false;
			
			_nextY = 110;
			
			
			_bodyParts = DataModel.appData.cellar1.body;
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companion1]", DataModel.appData.cellar1.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", DataModel.appData.cellar1.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion3]", DataModel.appData.cellar1.companion3[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[weapon1]", DataModel.appData.cellar1.weapon1[DataModel.defenderInfo.weapon]);
					
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
						_mc.companion_mc.y = Math.round(((_tf.y + _tf.height) - part.height)/2);
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
			_nextY += DataModel.appData.cellar1.decisionsMarginTop
				
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			
			if (DataModel.defenderInfo.contactFBID != null) {
				dv.push(DataModel.appData.cellar1.decisions[0]);
				dv.push(DataModel.appData.cellar1.decisions[1]);
				dv.push(DataModel.appData.cellar1.decisions[2]);
				
			} else {
				dv.push(DataModel.appData.cellar1.decisions[1]);
				dv.push(DataModel.appData.cellar1.decisions[2]);
			}	
			_decisions = new DecisionsView(dv);
				
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			// HACK for 3 decisions
			if(dv.length > 2) {
				_magicSpacer += 60;
			}
			
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
			// HACK for 3 decisions
			if(dv.length > 2) {
				_frame.sizeFrame(_decisions.y + _magicSpacer - 60);
				_frame.extraDecisionAdjust(60);
				_decisions.y += 20;
			}
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0}); 
		}
		
		protected function facebookContactResponded(event:ViewEvent):void
		{
			var decY:int = _decisions.y;
			_decisions.destroy();
			_mc.removeChild(_decisions);
			
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			dv.push(DataModel.appData.cellar1.decisions[3]);
			_decisions = new DecisionsView(dv);
			_decisions.y = decY;
			_mc.addChild(_decisions);
			
			TweenMax.from(_decisions, 1, {alpha:0, delay:0});
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			if (event.data.id == "FacebookNotifyView") {
				_decisions.deactivateButton(0);
				_goViral = DataModel.goViralService;
				_goViral.postWallHelp();
				return;
			}
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			TweenMax.to(_mc, 1, {alpha:0});
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
			TweenMax.to(_mc, 1, {alpha:0});
		}
	}
}