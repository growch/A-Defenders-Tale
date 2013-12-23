package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import assets.sunlightGame.ExplosionMC;
	
	import model.DataModel;
	
	public class Explosion extends MovieClip
	{
		private var _mc:MovieClip;
		private var _explosion:MovieClip;
		
		public function Explosion()
		{
			_mc = new ExplosionMC();
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc);
			_explosion = _mc.explosion_mc;
			addChild(_mc);
			
		}
		
		public function explode():void
		{
			_explosion.gotoAndStop(1);
			_explosion.play();
		}
		
		public function get mc():MovieClip {
			return _explosion;
		}
		
		public function destroy():void {
			_explosion = null;
			removeChild(_mc);
			_mc = null;
		}
	}
}