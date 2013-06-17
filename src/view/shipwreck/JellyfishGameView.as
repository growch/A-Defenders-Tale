package view.shipwreck
{
	import com.coreyoneil.collision.CollisionList;
	import com.greensock.TweenMax;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.sensors.Accelerometer;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import assets.JellyfishGameMC;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	import view.FrameView;
	import view.IPageView;
	
	public class JellyfishGameView extends MovieClip implements IPageView
	{
		private var _mc:JellyfishGameMC; 
		private var _frame:FrameView;
		private var _accel:Accelerometer;
		private var _accelX:int = 0;
		private var _accelY:int = 0;
		private var _glow:MovieClip;
		private var _jellyfishCount:int;
		private var _jellyfishArray:Array = [];
		private var _dm:DataModel;
		private var _jellyCount:int;
		private var _bg:MovieClip;
		private var _bottomBGY:int;
		private var _bottomGlowY:int;
		private var _leftEdge:int;
		private var _rightEdge:int;
		private var _timerSpeed:Number = 800;
		private var _jellyTimer:Timer;
		private var _counter:int = 0;
		private var i:int;
		private var thisJ:MovieClip;
		private var _glowHit:MovieClip;
		private var _collisionList:CollisionList;
		private var _collisions:Array;
		private var _hitTimeout:uint;
		private var _startMC:MovieClip;
		private var _winMC:MovieClip;
		private var _loseMC:MovieClip;
		private var _hitCount:int = 0;
		private var _starfish:MovieClip;
		
		public function JellyfishGameView()
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function destroy() : void {
			
			_jellyTimer.removeEventListener(TimerEvent.TIMER, animateJelly); 
			_jellyTimer = null;
			
			_winMC.cta_btn.removeEventListener(MouseEvent.CLICK, continueClick);
			
			_loseMC.map_btn.removeEventListener(MouseEvent.CLICK, gameLostDecision);
			_loseMC.restart_btn.removeEventListener(MouseEvent.CLICK, gameLostDecision);
			
			_frame.destroy();
			_frame = null;
			
			_collisionList.dispose();
			_collisionList = null;
			
			if (_accel) {
				_accel.removeEventListener(AccelerometerEvent.UPDATE, accelUpdate);
				_accel = null;
			}
			
			_jellyfishArray = null;
			
			DataModel.getInstance().removeAllChildren(_mc);
		}
		
		private function init (event:Event) : void {
			_dm = DataModel.getInstance();
			
//			var newPageClass:Class = getDefinitionByName("assets.JellyfishGameMC") as Class
//			_mc = new newPageClass();	
			_mc = new JellyfishGameMC();
			
			_bg = _mc.bg_mc;
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _bg.height;
			_frame.sizeFrame(frameSize);
			
			_bottomBGY = frameSize - DataModel.APP_HEIGHT;
			_bottomGlowY = frameSize - 180;
			
			_glow = _mc.glow_mc;
			_glowHit = _glow.hit_mc;
			_glowHit.alpha = .1;
			_glow.hitArea = _glowHit;
			
			_starfish = _mc.starfishHit_mc;
			_starfish.alpha = 0;
			
			_collisionList = new CollisionList(_glowHit);
//			_collisionList.alphaThreshold = 0;
			
			var buffer:int = 30;
			
			_leftEdge = buffer;
			_rightEdge = DataModel.APP_WIDTH - buffer;
			
			var jellyfish:MovieClip = _mc.jellyfish_mc;
			for (var i:int = 0; i < jellyfish.numChildren; i++) 
			{
				var thisJelly:MovieClip = jellyfish.getChildAt(i) as MovieClip;
				
				var jellyF:Jellyfish = new Jellyfish(thisJelly);
				
				thisJelly.stop();
				thisJelly.hit_mc.alpha = .1;
				
				_jellyfishArray.push(jellyF);
				
				_collisionList.addItem(thisJelly.hit_mc);
			}
			_jellyfishCount = _jellyfishArray.length;
			
			// Check for Accelerometer availability and act accordingly. 
			if(Accelerometer.isSupported)
			{
				// Create a new Accelerometer instance.
				_accel = new Accelerometer();
				// Have the Accelerometer listen. This happens on every "tick".
				_accel.addEventListener(AccelerometerEvent.UPDATE, accelUpdate);
			} else
			{
				// If there is no access to the Accelerometer
				trace("Accelerometer Not Supported");
			}
			
			_startMC = _mc.startGame_mc;
			_startMC.cta_btn.addEventListener(MouseEvent.CLICK, startClick);
			
			_winMC = _mc.win_mc;
			_winMC.visible = false;
			_winMC.cta_btn.addEventListener(MouseEvent.CLICK, continueClick);
			
			_loseMC = _mc.lose_mc;
			_loseMC.visible = false; 
			_loseMC.map_btn.addEventListener(MouseEvent.CLICK, gameLostDecision);
			_loseMC.restart_btn.addEventListener(MouseEvent.CLICK, gameLostDecision);
			
			
			addChild(_mc);
		}
		
		private function startClick(e:MouseEvent):void {
			_startMC.cta_btn.removeEventListener(MouseEvent.CLICK, startClick);
			startGame();
		}
		
		private function continueClick(e:MouseEvent):void {
			gameCompleted();
		}
		
		private function startGame():void {
			_startMC.visible = false;
			
			stage.addEventListener(Event.ENTER_FRAME, accelLoop);
			
			_jellyTimer = new Timer(_timerSpeed);
			_jellyTimer.addEventListener(TimerEvent.TIMER, animateJelly); 
			if (DataModel.ipad1) return;
			_jellyTimer.start();
			
		}
		
		private function stopGame():void {
			stage.removeEventListener(Event.ENTER_FRAME, accelLoop);
			_jellyTimer.stop();
		}
		
		private function gameLose():void
		{
			stopGame();
			_loseMC.y = -_mc.y;
			_loseMC.visible = true;
		}
		
		private function gameWon():void
		{
			stopGame();
			_winMC.y = -_mc.y;
			_winMC.visible = true;
		}
		
		private function gameCompleted():void
		{
			var tempObj:Object = new Object();
			tempObj.id = "shipwreck.Starfish3View";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
		}
		
		private function gameLostDecision(e:MouseEvent):void
		{
			var tempObj:Object = new Object();
			if (e.target.name == "map_btn") {
				tempObj.id = "MapView";
			} else {
				tempObj.id = "ApplicationView";
			}
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, tempObj));
		}
		
		private function animateJelly(e:TimerEvent):void {
			var thisJelly:Jellyfish = _jellyfishArray[_counter] as Jellyfish;
			thisJelly.jellyAnim(); 
			_counter++;
			if (_counter > _jellyfishArray.length-1) {
				_counter = 0;
			}
		}
		
		protected function accelUpdate(e:AccelerometerEvent):void
		{
			// Trace out the accelerometer data so we can see it when debugging
//			trace("Accelerometer X = " + e.accelerationX 
//				+ "\n" 
//				+ "Accelerometer Y = " + e.accelerationY
//				+ "\n");
			
			// Set our Accelerometer movement numbers
			_accelX = e.accelerationX * 100;
			_accelY = e.accelerationY * 100;
		}
		
		private function resetHero():void {
			clearTimeout(_hitTimeout);
			_hitTimeout = null;
			_glow.gotoAndStop(1);
		}
		
		// Loop to run on ENTER FRAME
		private function accelLoop(e:Event):void
		{
//			 Move items based on the accelerometer data
			_mc.y += _accelY * .04;
			if (_mc.y <= -_bottomBGY) _mc.y = -_bottomBGY;
			if (_mc.y >= 0) _mc.y = 0;
			
			
			if(!Accelerometer.isSupported)
			{
				_glow.x = stage.mouseX;
				_glow.y = stage.mouseY;
			}
			
			_glow.x -= _accelX * .04;
			_glow.y -= _accelY * .05;
			
			// Constrain the _glow to the X width boundries of the stage 
			if(_glow.x <= _leftEdge) _glow.x = _leftEdge;
			if(_glow.x >= _rightEdge)	_glow.x = _rightEdge;
//			
			// Constrain the _glow to the Y height boundries of the stage 
			if(_glow.y <= 60) _glow.y = 60;
			if(_glow.y >= _bottomGlowY) _glow.y = _bottomGlowY;
			
			for (i = 0; i < _jellyfishArray.length; i++) 
			{
				var thisJelly:Jellyfish = _jellyfishArray[i];
				thisJelly.update();
			}
			
			if (_glowHit.hitTestObject(_starfish)) {
				gameWon();
			}
			
			_collisions = _collisionList.checkCollisions();
			if (_collisions.length >= 1) {
//				trace("hittttt!");
				if (!_hitTimeout) {
					_hitCount++;
					if (_hitCount == 3) {
						gameLose();
					}
					
					_hitTimeout = setTimeout(resetHero, 2000);
					_glow.gotoAndPlay("hit");
				}
			} else {
				if (_hitTimeout) {
					resetHero();
				}
			}
			
		}
		
		
		
	}
}