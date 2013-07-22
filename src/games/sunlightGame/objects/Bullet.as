package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	
	import assets.sunlightGame.CanonballMC;
	import flash.display.MovieClip;
	
	public class Bullet extends MovieClip
	{
		private var _mc:MovieClip;
		public function Bullet()
		{
			_mc = new CanonballMC();
			addChild(_mc);
		}
	}
}