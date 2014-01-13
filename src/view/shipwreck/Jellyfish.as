package view.shipwreck
{
	import flash.display.MovieClip;
	
	import model.DataModel;

	public class Jellyfish extends flash.display.MovieClip 
	{
		private var _mc:MovieClip;
//		private var _vx:Number = 0;
//		private var _vy:Number = 0;
//		private var _friction:Number = .95;
		
		private var angleX:Number = 0;
		private var angleY:Number = 0;
		private var centerX:Number;
		private var centerY:Number;
		private var range:Number = 50;
		private var xspeed:Number = .01;
		private var yspeed:Number = .02;
		
		
		public function Jellyfish(mc:MovieClip)
		{
			_mc = mc;
			centerX = _mc.x;
			centerY = _mc.y;
			
			xspeed = DataModel.getInstance().randomRange(.005, 0.01);
			yspeed = DataModel.getInstance().randomRange(.01, 0.02);
		}
		
		public function jellyAnim():void {
			_mc.play();
		}
		
		public function update():void {
//			_vx += Math.random() * 0.2 - 0.1;
//			_vy += Math.random() * 0.2 - 0.1;
//			_mc.x += Math.sin(_vx);
//			_mc.y += Math.sin(_vy);
//			_vx *= _friction;
//			_vy *= _friction;
			if (_mc.currentFrame == _mc.totalFrames) {
//				trace("last frame: "+_mc);
				_mc.gotoAndStop(1);
			}
			
			_mc.x = centerX + Math.sin(angleX) * range;
			_mc.y = centerY + Math.sin(angleY) * range;
			angleX += xspeed;
			angleY += yspeed;
		}
		
		public function destroy():void {
			_mc = null;
		}
	}
}