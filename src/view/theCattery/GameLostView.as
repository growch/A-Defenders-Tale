package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import assets.GenericMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.StoryPart;
	
	import util.Formats;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.IPageView;
	
	public class GameLostView extends MovieClip implements IPageView
	{
		private var _mc:GenericMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		
		
		public function GameLostView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
		}
		
		public function destroy() : void {
			_decisions.destroy();
			_dragVCont.dispose();
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_mc = new GenericMC();
			
			// starting Y MAYBE PUT IN DM????
			_nextY = 65;
			
			_bodyParts = DataModel.appData.gameLost.body;
			
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
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top});
					//begin loading
					loader.load();
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += DataModel.appData.gameLost.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.gameLost.decisions);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			//HACK to get decisions from getting cut off
			_nextY += 220;
			// trim excess bottom off mc
			_mc.scrollRect = new Rectangle(0, 0, 768, _nextY); 
			TweenMax.delayedCall(1, clipMC); 
			
			_dragVCont = new DraggableVerticalContainer(0, 0x000000, 0, true);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			
			TweenMax.from(_mc, 2, {alpha:0, delay:0}); 
			addChild(_dragVCont);
		}
		
		protected function clipMC():void
		{
			_mc.scrollRect = new Rectangle(0, 0, 768, _nextY);
			_dragVCont.refreshView(true);
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}