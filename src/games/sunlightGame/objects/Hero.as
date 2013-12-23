package games.sunlightGame.objects
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import flash.display.MovieClip;
	import flash.events.AccelerometerEvent;
	import flash.sensors.Accelerometer;
	
	import games.sunlightGame.core.Game;
	
	import model.DataModel;
	
	public class Hero extends MovieClip
	{
		private var _game:Game;
		public var player:MovieClip;
		public var hit1MC:MovieClip;
		public var hit2MC:MovieClip;
		private var _smoke:MovieClip;
		private var _accel:Accelerometer;
		private var _accelX:Number;
		private var _accelY:Number;
		private var _accelZ:Number;
		private var _leftEdge:Number;
		private var _rightEdge:Number;
		private var orientationConst:Number = Math.sin(Math.PI/4);
		private var _mag:Number;
		private var _angle:Number;
		

		
		public function Hero(game:Game, mc:MovieClip)
		{
			_game = game; 
			player = mc;
			hit1MC = player.getChildByName("hit1_mc") as MovieClip;
			hit2MC = player.getChildByName("hit2_mc") as MovieClip;

			_smoke = player.smoke_mc;
			_smoke.visible = false;
			
			_leftEdge = player.width;
			_rightEdge = DataModel.APP_WIDTH - player.width;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(mc.cannon_mc);
			DataModel.getInstance().setGraphicResolution(mc.smoke_mc);
			
			// Check for Accelerometer availability and act accordingly. 
			if(Accelerometer.isSupported)
			{
				// Create a new Accelerometer instance.
				_accel = new Accelerometer();
				// Have the Accelerometer listen. This happens on every "tick".
//				_accel.addEventListener(AccelerometerEvent.UPDATE, accelUpdate);
			} else
			{
				// If there is no access to the Accelerometer
				trace("Accelerometer Not Supported");
			}
			
		}
		
		public function destroy():void
		{
			_game = null;
			player = null;
			hit1MC = null;
			hit2MC = null;
			_smoke = null;
			if (_accel) {
//				_accel.removeEventListener(AccelerometerEvent.UPDATE, accelUpdate);
				_accel = null;
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
//			_accelX = e.accelerationX * 100;
//			_accelY = e.accelerationY * 100;
			_accelX = e.accelerationX;
			_accelY = e.accelerationY;
			_accelZ = e.accelerationZ;
			
			/* These numbers can creep outside of the interval -1 to 1 if the phone is even moving very slightly, 
			so we use the following lines to keep the values between -1 and 1.*/
			if (_accelX < -1) _accelX = -1;
			if (_accelX > 1) _accelX = 1;
			if (_accelY < -1) _accelY = -1;
			if (_accelY > 1) _accelY = 1;
			if (_accelZ < -1) _accelZ = -1;
			if (_accelZ > 1) _accelZ = 1;
			
			/* 
			We calculate the angle by using the vectory identity u.v = |u| |v| cos(angle), 
			where u is the vector (aX,aY,aZ) and v is the vector (0,aY,0) which points vertically. 
			We have to subract 90 because arccos essentially returns values between 0 and 180, and we would like to interpret these between -90 and 90.
			*/
			_mag = Math.sqrt(_accelX*_accelX+_accelY*_accelY+_accelZ*_accelZ);
			_angle = Math.round((180/Math.PI)*Math.acos(_accelY/_mag)) - 90;
			
//			trace("_angle: "+_angle);
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
				player.x -= _accelX * 20;
				
//				player.rotation = _angle;
				
			}
			
			// Constrain to the X width boundries of the stage 
			if(player.x <= _leftEdge) player.x = _leftEdge;
			if(player.x >= _rightEdge)	player.x = _rightEdge;
			
			if (_game.fire ) {
				_smoke.visible = true;
			} else {
				_smoke.visible = false;
			}
		}
		
		public function flipUpsideDown():void
		{
			TweenMax.to(player, .7, {rotation:180, ease:Quad.easeOut});
		}
		
		public function flipRightSideUp():void
		{
			TweenMax.to(player, .7, {rotation:0, ease:Quad.easeOut});
		}
		
	}
}