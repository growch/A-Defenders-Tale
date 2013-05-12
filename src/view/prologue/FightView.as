package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Quad;
	import com.greensock.loading.ImageLoader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import assets.FightMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.StoryPart;
	
	import util.Formats;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.ApplicationView;
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	import view.MapView;
	
	public class FightView extends MovieClip implements IPageView
	{
		private var _mc:FightMC;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text; 
		private var _decisions:DecisionsView;		
		private var _companion:MovieClip;
		private var _frame:FrameView;
		private var _weaponInt:int;
		private var _instrumentInt:int;
		private var _supplyInt:int;
		private var _singleStart:Array;
		private var _doubleStart:Array;
		private var _noteTimer:Timer;
		private var _scrolling:Boolean;
		
		IntroAllIslandsView, MapView, ApplicationView
		public function FightView()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, init); 
//			*** USED LATER
			DataModel.captainBattled = true;
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
		}
		
		public function destroy():void
		{
			if (_noteTimer) {
				_noteTimer.stop();
				_noteTimer = null;
			}
			TweenMax.killAll();
			
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
			
			removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function init(e:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade); 
			
			_mc = new FightMC();
			
			_nextY = 110;
			
			_mc.armLeft_mc.visible = false;
			_mc.armRight_mc.visible = false;
			_mc.squidSmall_mc.visible = false;
			_mc.textSupplies_mc.visible = false;
			_mc.instruments_mc.visible = false;
			
			_weaponInt = int(DataModel.defenderInfo.weapon);
			_instrumentInt = int(DataModel.defenderInfo.instrument);
			
			if (DataModel.supplies) {
				_supplyInt = 0; // 0 = true
			} else {
				_supplyInt = 1;
			}
			
			if (_weaponInt != 2 && _supplyInt == 0) {
				_mc.textSupplies_mc.visible = true;
			}
			
			if (_weaponInt != 2 && _supplyInt == 1) {
				_mc.instruments_mc.instrument_mc.glows_mc.visible = false;
				_mc.instruments_mc.instrument_mc.shine_mc.visible = false;
				_mc.instruments_mc.visible = true;
				_mc.instruments_mc.instrument_mc.gotoAndStop(_instrumentInt+1);
				_mc.instruments_mc.instrument_mc.glows_mc.gotoAndStop(_instrumentInt+1);
				
				_mc.instruments_mc.instrument_mc.noteSingle_mc.alpha = 0;
				_singleStart = [_mc.instruments_mc.instrument_mc.noteSingle_mc.x, _mc.instruments_mc.instrument_mc.noteSingle_mc.y];
				_mc.instruments_mc.instrument_mc.noteDouble_mc.alpha = 0;
				_doubleStart = [_mc.instruments_mc.instrument_mc.noteDouble_mc.x, _mc.instruments_mc.instrument_mc.noteDouble_mc.y];
			}
			
			_bodyParts = DataModel.appData.fight.body;
			
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[weapon1]", DataModel.appData.fight.weapon1[DataModel.defenderInfo.weapon]);
					//this is tricky
					if (_weaponInt != 2) {
						copy = StringUtil.replace(copy, "[supplies]", DataModel.appData.fight.supplies[_supplyInt][_weaponInt]);
					} else {
						copy = StringUtil.replace(copy, "[supplies]", DataModel.appData.fight.supplies[_supplyInt]);
					}
					
					copy = StringUtil.replace(copy, "[instrument1]", DataModel.appData.fight.instrument1[DataModel.defenderInfo.instrument]);
					copy = StringUtil.replace(copy, "[island1]", DataModel.ISLAND_SELECTED[0]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					// position items. hack cuz 3 different layout options
					if (_weaponInt != 2 && _supplyInt == 0) {
						//big callout text in mc
						var index0:int = copy.indexOf("explained.", 0);
						var rect0:Rectangle = _tf.getCharBoundaries(index0);
						_mc.textSupplies_mc.y = rect0.y - 90;
						// TEXTFORMAT margins in XML were being buggy when doing   this
//						_tf.text = StringUtil.replace(_tf.text, "[spacer]", "");
//						_nextY -= _mc.textSupplies_mc.height + 110;
						var index1:int = copy.indexOf("Delicious", 0);
						var rect1:Rectangle = _tf.getCharBoundaries(index1);
						_mc.armLeft_mc.y = rect1.y + _mc.armLeft_mc.height - 50;
					}
					if (_weaponInt != 2 && _supplyInt == 1) {
						//big callout text in mc
						var index3:int = copy.indexOf("inspection.", 0);
						var rect3:Rectangle = _tf.getCharBoundaries(index3);
						_mc.instruments_mc.y = rect3.y - 320;
					}
					if (_weaponInt == 2) {
						var index:int = copy.indexOf("[spacer]", 0);
						var rect:Rectangle = _tf.getCharBoundaries(index);
						_mc.squidSmall_mc.y = rect.y + 110 + 10;
						
						_tf.text = StringUtil.replace(_tf.text, "[spacer]", "");
					}
					
					_mc.addChild(_tf);
					
					_nextY += Math.round(_tf.height + part.top);
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top});
					//begin loading
					loader.load();
					_nextY += Math.round(part.height + part.top);
				}
			}
			
			_nextY += DataModel.appData.fight.decisionsMarginTop
			_decisions = new DecisionsView(DataModel.appData.fight.decisions);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
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
			
//			TweenMax.from(_mc, 2, {alpha:0, delay:0, onComplete:pageOn}); 
		}
		
		private function pageOn(e:ViewEvent):void {
			//!TESTING
//			_supplyInt = 0;
			if (_weaponInt == 2) {
				_mc.squidSmall_mc.visible = true;
				TweenMax.from(_mc.squidSmall_mc, 1.6, {scaleX:4, scaleY:4, ease:Elastic.easeOut});
			}
			
			if (_weaponInt != 2 && _supplyInt == 0) {
//				TweenMax.from(_mc.armLeft_mc, .8, {x:"-100",scaleX:.6,rotation:-15,rotationZ:45, ease:Quad.easeOut});
//				TweenMax.from(_mc.armRight_mc, .7, {y:"-200",scaleY:.6,rotation:-10,rotationZ:-45, ease:Quad.easeOut});
				TweenMax.from(_mc.armLeft_mc, .8, {x:"-100",scaleX:.6,rotation:-15,ease:Quad.easeOut});
				TweenMax.from(_mc.armRight_mc, .7, {y:"-200",scaleY:.6,rotation:-10,ease:Quad.easeOut});
				_mc.armLeft_mc.visible = true;
				_mc.armRight_mc.visible = true;
			}
			
			if (_weaponInt != 2 && _supplyInt == 1) {
				
				TweenMax.from(_mc.armRight_mc, .7, {y:"-200",scaleY:.6,rotation:10,ease:Quad.easeOut});
//				TweenMax.from(_mc.armRight_mc, .7, {y:"-200",scaleY:.6,rotation:10,rotationZ:45, ease:Quad.easeOut});
				_mc.armRight_mc.visible = true;
				_mc.armRight_mc.scaleX = -1;
				_mc.armRight_mc.x = 250;
				
				_noteTimer = new Timer(3000);
				_noteTimer.addEventListener(TimerEvent.TIMER, showNotes); 
				_noteTimer.start();
				
				_mc.instruments_mc.instrument_mc.glows_mc.cacheAsBitmap = true;
				_mc.instruments_mc.instrument_mc.shine_mc.cacheAsBitmap = true;
				_mc.instruments_mc.instrument_mc.glows_mc.mask = _mc.instruments_mc.instrument_mc.shine_mc;
				_mc.instruments_mc.instrument_mc.glows_mc.visible = true;
				_mc.instruments_mc.instrument_mc.shine_mc.visible = true;
			}
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		protected function showNotes(event:TimerEvent):void
		{
			TweenMax.to(_mc.instruments_mc.instrument_mc.shine_mc, 1.4, {y:520, ease:Quad.easeIn, onComplete:function():void {_mc.instruments_mc.instrument_mc.shine_mc.y = -400}}); 
			TweenMax.to(_mc.instruments_mc.instrument_mc.noteSingle_mc, .4, {alpha:1});
			TweenMax.to(_mc.instruments_mc.instrument_mc.noteSingle_mc, 2, {bezierThrough:[{x:-12, y:70}, {x:20, y:-10}, {x:-2, y:-40}],
				onComplete:function():void {
					_mc.instruments_mc.instrument_mc.noteSingle_mc.x = _singleStart[0];
					_mc.instruments_mc.instrument_mc.noteSingle_mc.y = _singleStart[1];
				}}); 
			TweenMax.to(_mc.instruments_mc.instrument_mc.noteSingle_mc, .4, {alpha:0, delay:1});
			
			TweenMax.to(_mc.instruments_mc.instrument_mc.noteDouble_mc, .4, {alpha:1, delay:.4});
			TweenMax.to(_mc.instruments_mc.instrument_mc.noteDouble_mc, 2, {bezierThrough:[{x:50, y:72}, {x:100, y:32}, {x:40, y:-30}], delay:.4,
				onComplete:function():void {
					_mc.instruments_mc.instrument_mc.noteDouble_mc.x = _doubleStart[0];
					_mc.instruments_mc.instrument_mc.noteDouble_mc.y = _doubleStart[1];
				}}); 
			TweenMax.to(_mc.instruments_mc.instrument_mc.noteDouble_mc, .4, {alpha:0, delay:1.8});
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				if (_noteTimer) {
					_noteTimer.stop();
				}
				
				_scrolling = true;
				
			} else {
				
				if (!_scrolling) return;
				if (_noteTimer) {
					_noteTimer.start();
				}
				
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
//			TweenMax.to(_mc, 1, {alpha:0});
//			TweenMax.to(_dragVCont, 1, {alpha:0, delay:0, onComplete:nextPage, onCompleteParams:[event.data]});
			if (_noteTimer) {
				_noteTimer.stop();
			}
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
		private function nextPage(thisPage:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, thisPage));
		}
	}
}