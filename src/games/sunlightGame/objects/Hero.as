package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	import flash.events.AccelerometerEvent;
	import flash.sensors.Accelerometer;
	
	import games.sunlightGame.core.Game;
	
	import model.DataModel;
	
	public class Hero extends MovieClip
	{
		private var _game:Game;
		public var player:MovieClip;
//		public var malletDown:Boolean;
		public var hit1MC:MovieClip;
		public var hit2MC:MovieClip;
		private var _smoke:MovieClip;
		private var _accel:Accelerometer;
		private var _accelX:Number;
		private var _accelY:Number;
		private var _leftEdge:Number;
		private var _rightEdge:Number;
//		private var _thisMC:Hero;

		
		public function Hero(game:Game, mc:MovieClip)
		{
			_game = game; 
			player = mc;
			hit1MC = player.getChildByName("hit1_mc") as MovieClip;
//			hit1MC.alpha = .5;
			hit2MC = player.getChildByName("hit2_mc") as MovieClip;
//			hit2MC.alpha = .5;

			_smoke = player.smoke_mc;
			_smoke.visible = false;
			
			_leftEdge = player.width;
			_rightEdge = DataModel.APP_WIDTH - player.width;
			
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
		
		public function update():void
		{
//			trace("update hero");
			//move cannon
			if(!Accelerometer.isSupported)
			{
				player.x += (player.stage.mouseX - player.x) * 0.8;
			} else {
				player.x -= _accelX * .2;
			}
			
			
			
			// Constrain the _glow to the X width boundries of the stage 
			if(player.x <= _leftEdge) player.x = _leftEdge;
			if(player.x >= _rightEdge)	player.x = _rightEdge;
			
			if (_game.fire ) {
//				if (!malletDown) {
////					player.gotoAndPlay("hit");
//					malletDown = true;
//				}
				_smoke.visible = true;
			} else {
//				player.gotoAndStop("idle");
//				malletDown = false;
				_smoke.visible = false;
			}
		}
	}
}