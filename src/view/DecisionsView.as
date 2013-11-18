package view
{
	import assets.DecisionButtonMC;
	import assets.DecisionsMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextFieldAutoSize;
	
	import model.DataModel;
	import model.DecisionInfo;
	
	public class DecisionsView extends MovieClip
	{
		private var _mc:DecisionsMC;
		private var _decisions:Vector.<DecisionInfo>;
		private var _buttonArray:Array = [];
		private var _divider:MovieClip;
		private var _showBG:Boolean;
		private var _tintColor:uint;
		
		public function DecisionsView(decisions:Vector.<DecisionInfo>, tintColor:uint=666, showBG:Boolean=false)
		{
			_decisions = decisions;
			_showBG = showBG;
			_tintColor = tintColor;
			
//			super();
			
//			addEventListener(Event.ADDED_TO_STAGE, init);
			init();
		}
		
//		private function init(e:Event) : void {
		private function init() : void {
//			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_mc = new DecisionsMC();
//			text would dissappear when taking screenshots
			_mc.cacheAsBitmap = true;
			_mc.stop();
			
			_divider = _mc.divider_mc;
			
			if (_tintColor != 666) {
				var c:ColorTransform = new ColorTransform(); 
				c.color = _tintColor;
				_divider.transform.colorTransform = c;
			}
			
			for (var i:int = 0; i<_decisions.length; i++) {
				var decButt:DecisionButtonMC = new DecisionButtonMC();
				decButt.decision_txt.autoSize = TextFieldAutoSize.CENTER;
				decButt.decision_txt.htmlText = DataModel.getInstance().replaceVariableText(_decisions[i].description);
				
				//show BG?
				decButt.bg_mc.visible = false;
				if (_showBG) decButt.bg_mc.visible = true;
				
				//tint it?
				if (_tintColor != 666) {
					decButt.decision_txt.transform.colorTransform = c;
					decButt.frame_mc.transform.colorTransform = c;
				}
				
				// placement
				decButt.y = 40;
				
				if (i == 0) {
					if (_decisions.length == 1) {
						decButt.x = Math.round(_divider.x + (_divider.width - decButt.width)/2);
						_mc.divider_mc.gotoAndStop("single");
//						trace("single decision");
					} else {
						decButt.x = _divider.x;
						_mc.divider_mc.gotoAndStop("double");
//						trace("double decision");
					}
					
				} else if (i == 1) {
					decButt.x = _divider.x + _divider.width - decButt.width;
				} else if (i==2) {
					decButt.x = Math.round(_divider.x + (_divider.width - decButt.width)/2);
					decButt.y = 110;
				}
				
				decButt.buttonMode = true;
				decButt.mouseChildren = false;
				decButt.ID = i;
				decButt.addEventListener(MouseEvent.CLICK, decisionClick);
				
				_mc.addChild(decButt);
				
				_buttonArray.push(decButt);
			}

			addChild(_mc);
		}
		
		//hacky?
		public function ballException():void {
			_mc.x += 30;
			_divider.width -= 60;
			_buttonArray[1].x -= 60;
		}
		
		protected function decisionClick(event:MouseEvent):void
		{
			DataModel.getInstance().buttonTap();
			
			var thisID:Number = MovieClip(event.target).ID;
			var tempObj:Object = new Object();
			tempObj.decisionNumber = thisID;
			tempObj.id = _decisions[thisID].id;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, tempObj));
		}
		
		public function deactivateButton(thisButtonNumb:int) : void {
			var butt:MovieClip = _buttonArray[thisButtonNumb] as MovieClip;
			if (butt.hasEventListener(MouseEvent.CLICK)) {
				butt.removeEventListener(MouseEvent.CLICK, decisionClick);
			}
			butt.alpha = .5;
		}
		
		public function destroy():void
		{
			for (var i:int = 0; i<_buttonArray.length; i++) {
				var butt:MovieClip = _buttonArray[i] as MovieClip;
				if (butt.hasEventListener(MouseEvent.CLICK)) {
					butt.removeEventListener(MouseEvent.CLICK, decisionClick);
				}
				_mc.removeChild(butt);
			}
			removeChild(_mc);
		}
	}
}