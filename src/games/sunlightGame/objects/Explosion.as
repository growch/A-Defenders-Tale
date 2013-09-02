package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import assets.sunlightGame.ExplosionMC; 
	import flash.display.MovieClip;
	
	public class Explosion extends MovieClip
	{
		private var _mc:MovieClip;
		
		public function Explosion()
		{
			_mc = new ExplosionMC();
			_mc.stop();
			addChild(_mc);
			
		}
		
		public function explode():void
		{
			_mc.gotoAndStop(1);
			_mc.play();
		}
		
		public function get mc():MovieClip {
			return _mc;
		}
		
		public function destroy():void {
			removeChild(_mc);
			_mc = null;
		}
	}
}