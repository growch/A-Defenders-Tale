package view
{
	import assets.HelmetDiverMC;
	import assets.JellyfishMC;
	import assets.UnderwaterMC;
	
	import com.dougmccune.HitTester;
	import com.freeactionscript.CollisionTest;
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.events.AccelerometerEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.sensors.Accelerometer;
	
	import model.DataModel;
	
	public class JellyfishGameOGView extends MovieClip
	{
		private var _mc:UnderwaterMC;
		private var _accel:Accelerometer;
		private var _accelX:int = 0;
		private var _accelY:int = 0;
		private var _diver:MovieClip;
		private var _jellyfishCount:int = 7;
		private var _jellyfishArray:Array;
		private var _dm:DataModel;
		private var _shock:MovieClip;
		private var _jellyCount:int;
		private var _colTest:CollisionTest;
		
		public function JellyfishGameOGView()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init (event:Event) : void {
			_dm = DataModel.getInstance();
			
			_mc = new UnderwaterMC();
			addChild(_mc);
			
			_diver = _mc.diver_mc;
			_diver.cacheAsBitmap = true;
//			_diver.rotation = 90;
			_diver.alpha = 0;
			
			_shock = _mc.shock_mc;
			_shock.cacheAsBitmap = true;
			_shock.visible = false;
			
			_colTest = new CollisionTest();
			
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
			
			addJellyfish();
//			stage.addEventListener(Event.ENTER_FRAME, accelLoop);
		}
		
		private function addJellyfish() : void {
			_jellyfishArray = new Array();
			for (var i:int = 0; i < _jellyfishCount; i++) 
			{
				TweenMax.delayedCall((i*.2), delayedFish); 
			}
			
		}
		
		private function delayedFish() : void {
			var thisJ:JellyfishMC = new JellyfishMC();
//			thisJ.rotation = 90;
//			thisJ.stop();
			var jellySpace:Number = stage.stageHeight/_jellyfishCount;
			var startY:Number = _jellyCount * jellySpace;
			thisJ.x = _dm.randomRange(50, stage.stageWidth - 150);
			thisJ.y = _dm.randomRange(startY, startY + jellySpace + 10);
			_jellyfishArray.push(thisJ);
			TweenMax.from(thisJ, .6, {alpha:0});
			_mc.addChild(thisJ);
			
			_jellyCount++;
			
			// FIX THIS!!!!!
			if (_jellyfishArray.length > _jellyfishCount-1) {
				stage.addEventListener(Event.ENTER_FRAME, accelLoop);
				TweenMax.to(_diver, .6, {alpha:1});
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
		
		
		// Loop to run on ENTER FRAME
		private function accelLoop(e:Event):void
		{
			// Move the _diver based on the accelerometer data
			_diver.x -= _accelX * .1;
			_diver.y += _accelY * .1;
			
			if(!Accelerometer.isSupported)
			{
				_diver.x = stage.mouseX - _diver.width/2;
				_diver.y = stage.mouseY - _diver.height/2;
//				_diver.x = stage.mouseY - _diver.width/2;
//				_diver.y = stage.stageWidth - stage.mouseX - _diver.height/2;
			}
			
			// Constrain the _diver to the X width boundries of the stage 
			if(_diver.x <= 0)	
			{
				_diver.x = 0;
			}
			if(_diver.x >= stage.stageWidth - _diver.width)
			{
				_diver.x = stage.stageWidth - (_diver.width);
			}
			
			// Constrain the _diver to the Y height boundries of the stage 
			if(_diver.y <= 0)
			{
				_diver.y = 0;
			}
			if(_diver.y >= stage.stageHeight - _diver.height)
			{
				_diver.y = stage.stageHeight - _diver.height;
			}
			
			_shock.x = _diver.x;
			_shock.y = _diver.y; 
			
			// check for collision
			_shock.visible = false;
//			return;
			for (var i:int = 0; i < _jellyfishCount; i++) 
			{
				var thisJ:MovieClip = _jellyfishArray[i] as MovieClip;
				
				if (_colTest.complex(_diver, thisJ)) {
					_shock.visible = true;
				} 
			}
			
		}
		
	}
}